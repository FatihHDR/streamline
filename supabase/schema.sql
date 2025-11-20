-- Streamline Supabase schema
-- Jalankan file ini melalui `supabase db push` atau Supabase SQL editor.
set check_function_bodies = off;

-- Pastikan fungsi `gen_random_uuid()` tersedia untuk primary key.
create extension if not exists "pgcrypto";

-- Enum untuk jenis transaksi (masuk/keluar).
do $$
begin
  if not exists (
    select 1 from pg_type where typname = 'inventory_transaction_type'
  ) then
    create type public.inventory_transaction_type as enum ('incoming', 'outgoing');
  end if;
end $$;

-- Fungsi utilitas untuk menjaga kolom `updated_at`.
create or replace function public.set_current_timestamp_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- Fungsi untuk mengisi kolom `owner_id` dengan `auth.uid()` saat insert dari client-side.
create or replace function public.apply_request_owner_id()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if new.owner_id is null then
    new.owner_id := auth.uid();
  end if;
  return new;
end;
$$;

-- Tabel master barang.
create table if not exists public.inventory_items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  category text not null,
  quantity integer not null check (quantity >= 0),
  unit text not null default 'pcs',
  location text not null,
  min_stock integer not null default 10 check (min_stock >= 0),
  description text,
  last_updated timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- Tabel riwayat transaksi barang.
create table if not exists public.stock_transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  item_id uuid not null references public.inventory_items (id) on delete cascade,
  item_name_snapshot text not null,
  transaction_type public.inventory_transaction_type not null,
  quantity integer not null check (quantity > 0),
  note text,
  performed_by text,
  occurred_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- Index membantu query statistik dan lookup.
create index if not exists idx_inventory_items_owner_category
  on public.inventory_items (owner_id, category);
create index if not exists idx_inventory_items_low_stock
  on public.inventory_items (owner_id)
  where quantity <= min_stock;
create index if not exists idx_stock_transactions_item
  on public.stock_transactions (item_id);
create index if not exists idx_stock_transactions_owner_occurred
  on public.stock_transactions (owner_id, occurred_at desc);

-- Trigger untuk menjaga metadata otomatis.
drop trigger if exists trg_inventory_items_updated_at on public.inventory_items;
create trigger trg_inventory_items_updated_at
  before update on public.inventory_items
  for each row execute function public.set_current_timestamp_updated_at();

drop trigger if exists trg_stock_transactions_updated_at on public.stock_transactions;
create trigger trg_stock_transactions_updated_at
  before update on public.stock_transactions
  for each row execute function public.set_current_timestamp_updated_at();

-- Trigger untuk mengisi owner_id ketika request berasal dari klien yang sudah login.
drop trigger if exists trg_inventory_items_owner on public.inventory_items;
create trigger trg_inventory_items_owner
  before insert on public.inventory_items
  for each row execute function public.apply_request_owner_id();

drop trigger if exists trg_stock_transactions_owner on public.stock_transactions;
create trigger trg_stock_transactions_owner
  before insert on public.stock_transactions
  for each row execute function public.apply_request_owner_id();

-- Aktifkan Row Level Security agar data setiap user terisolasi.
alter table public.inventory_items enable row level security;
alter table public.stock_transactions enable row level security;

-- Kebijakan RLS untuk tabel master barang.
do $$
begin
  if not exists (
    select 1 from pg_policies where policyname = 'inventory_items_owner_policy'
  ) then
    create policy inventory_items_owner_policy
      on public.inventory_items
      for all
      to authenticated
      using (owner_id = auth.uid())
      with check (owner_id = auth.uid());
  end if;
end $$;

-- Kebijakan RLS untuk tabel transaksi.
do $$
begin
  if not exists (
    select 1 from pg_policies where policyname = 'stock_transactions_owner_policy'
  ) then
    create policy stock_transactions_owner_policy
      on public.stock_transactions
      for all
      to authenticated
      using (owner_id = auth.uid())
      with check (owner_id = auth.uid());
  end if;
end $$;

-- View sederhana untuk kebutuhan dashboard (total item, stok menipis, stok habis, total kuantitas).
create or replace view public.inventory_dashboard_metrics as
select
  owner_id,
  count(*) as total_items,
  sum(quantity) as total_quantity,
  count(*) filter (where quantity <= min_stock and quantity > 0) as low_stock_items,
  count(*) filter (where quantity = 0) as out_of_stock_items
from public.inventory_items
group by owner_id;

comment on table public.inventory_items is 'Daftar master barang gudang (sinkron dengan model StockItem).';
comment on table public.stock_transactions is 'Riwayat mutasi stok (sinkron dengan model StockTransaction).';
comment on view public.inventory_dashboard_metrics is 'Aggregasi ringan untuk statistik dashboard Streamline.';

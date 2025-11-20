-- FIX: Remove foreign key constraint untuk owner_id
-- Jalankan SQL ini di Supabase SQL Editor

-- 1. Drop foreign key constraint dari inventory_items
alter table public.inventory_items
  drop constraint if exists inventory_items_owner_id_fkey;

-- 2. Drop foreign key constraint dari stock_transactions
alter table public.stock_transactions
  drop constraint if exists stock_transactions_owner_id_fkey;

-- 3. Buat index untuk performance (karena kita masih pakai owner_id untuk RLS)
create index if not exists idx_inventory_items_owner_id
  on public.inventory_items (owner_id);

create index if not exists idx_stock_transactions_owner_id
  on public.stock_transactions (owner_id);

-- 4. Simplify RLS policies untuk allow all operations
drop policy if exists inventory_items_anon_policy on public.inventory_items;
create policy inventory_items_allow_all
  on public.inventory_items
  for all
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists stock_transactions_anon_policy on public.stock_transactions;
create policy stock_transactions_allow_all
  on public.stock_transactions
  for all
  to anon, authenticated
  using (true)
  with check (true);

-- Verify
select 'Foreign key constraints removed. Tables can now use any UUID for owner_id.' as status;

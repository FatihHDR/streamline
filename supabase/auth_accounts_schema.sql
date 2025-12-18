-- ============================================
-- STREAMLINE - AUTH & ACCOUNTS SCHEMA
-- ============================================
-- Tabel accounts di public schema yang sync dengan auth.users
-- Jalankan file ini di Supabase SQL Editor setelah schema.sql
-- ============================================

set check_function_bodies = off;

-- ============================================
-- 1. ENUM untuk ROLE
-- ============================================
do $$
begin
  if not exists (
    select 1 from pg_type where typname = 'user_role'
  ) then
    create type public.user_role as enum ('admin', 'staff', 'viewer');
  end if;
end $$;

-- ============================================
-- 2. TABEL ACCOUNTS (Public Profile)
-- ============================================
-- Tabel ini sync dengan auth.users dan menyimpan informasi tambahan user
create table if not exists public.accounts (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text,
  role public.user_role not null default 'staff',
  avatar_url text,
  phone text,
  is_active boolean not null default true,
  last_login_at timestamptz,
  metadata jsonb default '{}'::jsonb, -- untuk menyimpan data custom
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- Index untuk pencarian dan lookup
create index if not exists idx_accounts_email on public.accounts(email);
create index if not exists idx_accounts_role on public.accounts(role);
create index if not exists idx_accounts_is_active on public.accounts(is_active);

-- Trigger untuk update timestamp
drop trigger if exists trg_accounts_updated_at on public.accounts;
create trigger trg_accounts_updated_at
  before update on public.accounts
  for each row execute function public.set_current_timestamp_updated_at();

-- ============================================
-- 3. FUNCTION: Auto-create account saat user register
-- ============================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  insert into public.accounts (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', new.email),
    coalesce((new.raw_user_meta_data->>'role')::public.user_role, 'staff'::public.user_role)
  );
  return new;
end;
$$;

-- Trigger: Ketika user baru dibuat di auth.users, otomatis buat record di accounts
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================
-- 4. FUNCTION: Update last_login_at
-- ============================================
create or replace function public.update_last_login()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  update public.accounts
  set last_login_at = timezone('utc', now())
  where id = new.id;
  return new;
end;
$$;

-- Trigger: Update last_login ketika user login (auth.sessions created)
-- Note: Supabase tidak punya trigger langsung di sessions, jadi kita bisa panggil function ini dari client
-- Atau bisa pakai trigger di auth.audit_log_entries jika tersedia

-- ============================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================================
alter table public.accounts enable row level security;

-- Policy: User bisa melihat semua accounts (untuk collaboration)
drop policy if exists "accounts_select_policy" on public.accounts;
create policy "accounts_select_policy"
  on public.accounts
  for select
  to authenticated
  using (true); -- Semua authenticated user bisa lihat profile user lain

-- Policy: User hanya bisa update profile sendiri
drop policy if exists "accounts_update_own_policy" on public.accounts;
create policy "accounts_update_own_policy"
  on public.accounts
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Policy: Hanya admin yang bisa delete account
drop policy if exists "accounts_delete_admin_policy" on public.accounts;
create policy "accounts_delete_admin_policy"
  on public.accounts
  for delete
  to authenticated
  using (
    exists (
      select 1 from public.accounts
      where id = auth.uid() and role = 'admin'
    )
  );

-- Policy: Admin bisa update role user lain
drop policy if exists "accounts_admin_update_role_policy" on public.accounts;
create policy "accounts_admin_update_role_policy"
  on public.accounts
  for update
  to authenticated
  using (
    exists (
      select 1 from public.accounts
      where id = auth.uid() and role = 'admin'
    )
  );

-- ============================================
-- 6. HELPER FUNCTIONS
-- ============================================

-- Function: Get current user role
create or replace function public.get_user_role(user_id uuid)
returns text
language sql
security definer
set search_path = public
as $$
  select role::text from public.accounts where id = user_id;
$$;

-- Function: Check if user is admin
create or replace function public.is_admin(user_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select role = 'admin' from public.accounts where id = user_id;
$$;

-- Function: Get user display name
create or replace function public.get_user_display_name(user_id uuid)
returns text
language sql
security definer
set search_path = public
as $$
  select coalesce(full_name, email) from public.accounts where id = user_id;
$$;

-- ============================================
-- 7. UPDATE EXISTING TABLES - Add created_by & updated_by
-- ============================================

-- Add audit columns to inventory_items
alter table public.inventory_items 
  add column if not exists created_by uuid references public.accounts(id),
  add column if not exists updated_by uuid references public.accounts(id);

-- Add audit columns to stock_transactions
alter table public.stock_transactions
  add column if not exists created_by uuid references public.accounts(id);

-- Trigger untuk auto-fill created_by dan updated_by
create or replace function public.set_audit_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if TG_OP = 'INSERT' then
    new.created_by := auth.uid();
    new.updated_by := auth.uid();
  elsif TG_OP = 'UPDATE' then
    new.updated_by := auth.uid();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_inventory_items_audit on public.inventory_items;
create trigger trg_inventory_items_audit
  before insert or update on public.inventory_items
  for each row execute function public.set_audit_user();

drop trigger if exists trg_stock_transactions_audit on public.stock_transactions;
create trigger trg_stock_transactions_audit
  before insert on public.stock_transactions
  for each row execute function public.set_audit_user();

-- ============================================
-- 8. ACTIVITY LOG TABLE (User Activity Tracking)
-- ============================================
create table if not exists public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.accounts(id) on delete cascade,
  action text not null, -- 'login', 'logout', 'create_item', 'update_item', 'delete_item', etc
  entity_type text, -- 'inventory_item', 'stock_transaction', etc
  entity_id uuid,
  details jsonb default '{}'::jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default timezone('utc', now())
);

-- Index untuk query log
create index if not exists idx_activity_logs_user on public.activity_logs(user_id, created_at desc);
create index if not exists idx_activity_logs_action on public.activity_logs(action);
create index if not exists idx_activity_logs_entity on public.activity_logs(entity_type, entity_id);

-- RLS untuk activity logs
alter table public.activity_logs enable row level security;

-- Policy: User bisa lihat activity log sendiri
drop policy if exists "activity_logs_select_own_policy" on public.activity_logs;
create policy "activity_logs_select_own_policy"
  on public.activity_logs
  for select
  to authenticated
  using (user_id = auth.uid());

-- Policy: Admin bisa lihat semua activity logs
drop policy if exists "activity_logs_select_admin_policy" on public.activity_logs;
create policy "activity_logs_select_admin_policy"
  on public.activity_logs
  for select
  to authenticated
  using (
    exists (
      select 1 from public.accounts
      where id = auth.uid() and role = 'admin'
    )
  );

-- Policy: Semua authenticated user bisa insert activity log
drop policy if exists "activity_logs_insert_policy" on public.activity_logs;
create policy "activity_logs_insert_policy"
  on public.activity_logs
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- ============================================
-- 9. HELPER FUNCTION: Log Activity
-- ============================================
create or replace function public.log_activity(
  p_action text,
  p_entity_type text default null,
  p_entity_id uuid default null,
  p_details jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_log_id uuid;
begin
  insert into public.activity_logs (
    user_id,
    action,
    entity_type,
    entity_id,
    details
  ) values (
    auth.uid(),
    p_action,
    p_entity_type,
    p_entity_id,
    p_details
  ) returning id into v_log_id;
  
  return v_log_id;
end;
$$;

-- ============================================
-- 10. VIEW: Dashboard Metrics with User Info
-- ============================================
create or replace view public.user_dashboard_metrics as
select
  a.id as user_id,
  a.email,
  a.full_name,
  a.role,
  count(distinct ii.id) as total_items,
  sum(ii.quantity) as total_quantity,
  count(distinct ii.id) filter (where ii.quantity <= ii.min_stock and ii.quantity > 0) as low_stock_items,
  count(distinct ii.id) filter (where ii.quantity = 0) as out_of_stock_items,
  count(distinct st.id) as total_transactions,
  max(a.last_login_at) as last_login
from public.accounts a
left join public.inventory_items ii on ii.owner_id = a.id
left join public.stock_transactions st on st.owner_id = a.id
where a.is_active = true
group by a.id, a.email, a.full_name, a.role;

-- ============================================
-- 11. SEED DATA (Optional - First Admin User)
-- ============================================
-- Uncomment jika ingin create admin user pertama
-- Note: Ganti email dan password sesuai kebutuhan

/*
-- Insert admin ke auth.users (harus via Supabase Auth API atau Dashboard)
-- Atau bisa pakai function ini setelah register manual:

create or replace function public.promote_to_admin(user_email text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.accounts
  set role = 'admin'
  where email = user_email;
end;
$$;

-- Setelah register user pertama, jalankan:
-- select public.promote_to_admin('admin@streamline.com');
*/

-- ============================================
-- COMMENTS untuk dokumentasi
-- ============================================
comment on table public.accounts is 'User profiles yang sync dengan auth.users, dengan role dan metadata tambahan';
comment on table public.activity_logs is 'Log semua aktivitas user untuk audit trail';
comment on column public.accounts.role is 'User role: admin (full access), staff (create/edit), viewer (read only)';
comment on column public.accounts.metadata is 'JSON field untuk menyimpan custom user data';
comment on view public.user_dashboard_metrics is 'Dashboard metrics per user dengan info profile';

-- ============================================
-- END OF SCHEMA
-- ============================================

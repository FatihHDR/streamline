-- FIX: Make owner_id nullable dan update trigger untuk anonymous users
-- Jalankan SQL ini di Supabase SQL Editor

-- 1. Buat dummy user ID untuk anonymous operations
do $$
begin
  -- Buat constant UUID untuk anonymous user (bisa digunakan untuk semua operasi tanpa auth)
  if not exists (
    select 1 from pg_proc where proname = 'get_anonymous_user_id'
  ) then
    create or replace function public.get_anonymous_user_id()
    returns uuid
    language sql
    immutable
    as $func$
      select '00000000-0000-0000-0000-000000000000'::uuid;
    $func$;
  end if;
end $$;

-- 2. Update trigger untuk menggunakan anonymous ID jika auth.uid() null
create or replace function public.apply_request_owner_id()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if new.owner_id is null then
    -- Gunakan auth.uid() jika tersedia, kalau tidak pakai anonymous ID
    new.owner_id := coalesce(auth.uid(), public.get_anonymous_user_id());
  end if;
  return new;
end;
$$;

-- 3. Update RLS policies untuk allow anonymous user
drop policy if exists inventory_items_anon_policy on public.inventory_items;
create policy inventory_items_anon_policy
  on public.inventory_items
  for all
  to anon, authenticated
  using (
    owner_id = coalesce(auth.uid(), public.get_anonymous_user_id())
    or owner_id = public.get_anonymous_user_id()
  )
  with check (
    owner_id = coalesce(auth.uid(), public.get_anonymous_user_id())
    or owner_id = public.get_anonymous_user_id()
  );

drop policy if exists stock_transactions_anon_policy on public.stock_transactions;
create policy stock_transactions_anon_policy
  on public.stock_transactions
  for all
  to anon, authenticated
  using (
    owner_id = coalesce(auth.uid(), public.get_anonymous_user_id())
    or owner_id = public.get_anonymous_user_id()
  )
  with check (
    owner_id = coalesce(auth.uid(), public.get_anonymous_user_id())
    or owner_id = public.get_anonymous_user_id()
  );

-- Verify
select 'Setup complete. Anonymous user ID: ' || public.get_anonymous_user_id()::text as status;

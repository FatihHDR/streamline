-- TEMPORARY FIX: Bypass RLS untuk testing
-- JANGAN GUNAKAN DI PRODUCTION!
-- Jalankan SQL ini di Supabase SQL Editor untuk sementara waktu

-- Drop existing policies
drop policy if exists inventory_items_owner_policy on public.inventory_items;
drop policy if exists stock_transactions_owner_policy on public.stock_transactions;

-- Create permissive policies for anon users (for testing only)
create policy inventory_items_anon_policy
  on public.inventory_items
  for all
  to anon, authenticated
  using (true)
  with check (true);

create policy stock_transactions_anon_policy
  on public.stock_transactions
  for all
  to anon, authenticated
  using (true)
  with check (true);

-- NOTE: Setelah selesai testing, hapus policy ini dan kembalikan ke policy yang proper dengan auth

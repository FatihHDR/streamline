-- ================================================================
-- DISABLE RLS COMPLETELY FOR TESTING
-- ================================================================
-- IMPORTANT: This is for TESTING ONLY! 
-- DO NOT use in production!
-- Jalankan SQL ini di Supabase SQL Editor
-- ================================================================

-- Step 1: Drop all existing RLS policies
DROP POLICY IF EXISTS inventory_items_owner_policy ON public.inventory_items;
DROP POLICY IF EXISTS inventory_items_anon_policy ON public.inventory_items;
DROP POLICY IF EXISTS inventory_items_allow_all ON public.inventory_items;
DROP POLICY IF EXISTS stock_transactions_owner_policy ON public.stock_transactions;
DROP POLICY IF EXISTS stock_transactions_anon_policy ON public.stock_transactions;
DROP POLICY IF EXISTS stock_transactions_allow_all ON public.stock_transactions;

-- Step 2: DISABLE Row Level Security completely
ALTER TABLE public.inventory_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_transactions DISABLE ROW LEVEL SECURITY;

-- Step 3: Verify RLS is disabled
SELECT 
  schemaname, 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE tablename IN ('inventory_items', 'stock_transactions');

-- Expected output: rowsecurity should be 'false' for both tables

-- Step 4: Test query (should work now)
SELECT COUNT(*) FROM public.inventory_items;
SELECT * FROM public.inventory_items LIMIT 5;

-- ================================================================
-- To re-enable RLS later, run:
-- ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.stock_transactions ENABLE ROW LEVEL SECURITY;
-- Then recreate policies from schema.sql
-- ================================================================

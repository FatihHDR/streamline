-- ================================================================
-- DIAGNOSTIC QUERIES FOR INVENTORY SYNC ISSUES
-- ================================================================
-- Run these queries in Supabase SQL Editor to diagnose sync problems
-- ================================================================

-- 1. Check if RLS is enabled
SELECT 
  tablename, 
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('inventory_items', 'stock_transactions');

-- 2. List all active RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename IN ('inventory_items', 'stock_transactions')
ORDER BY tablename, policyname;

-- 3. Count total inventory items
SELECT COUNT(*) as total_items FROM public.inventory_items;

-- 4. Show all inventory items with details
SELECT 
  id,
  name,
  category,
  quantity,
  unit,
  location,
  owner_id,
  created_at,
  updated_at
FROM public.inventory_items
ORDER BY created_at DESC;

-- 5. Check owner_id distribution
SELECT 
  COALESCE(owner_id::text, 'NULL') as owner_id,
  COUNT(*) as item_count
FROM public.inventory_items
GROUP BY owner_id;

-- 6. Check if there are items with NULL owner_id
SELECT COUNT(*) as items_with_null_owner
FROM public.inventory_items
WHERE owner_id IS NULL;

-- 7. Check triggers on inventory_items
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'inventory_items';

-- 8. Test insert (will fail if RLS blocks anonymous users)
-- Uncomment to test:
-- INSERT INTO public.inventory_items (
--   name, category, quantity, unit, location, min_stock, 
--   description, last_updated
-- ) VALUES (
--   'Test Sync Item',
--   'Test Category',
--   50,
--   'pcs',
--   'Test Location',
--   10,
--   'Testing sync',
--   NOW()
-- ) RETURNING *;

-- 9. Check foreign key constraints
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name IN ('inventory_items', 'stock_transactions')
  AND tc.constraint_type = 'FOREIGN KEY';

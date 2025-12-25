-- Verify data exists in Supabase tables
-- Check inventory items
SELECT 'Total Items' as info, COUNT(*) as count FROM inventory_items;

-- Check RLS status
SELECT 
  tablename, 
  rowsecurity as rls_enabled 
FROM pg_tables 
WHERE tablename IN ('inventory_items', 'stock_transactions');

-- Show sample items (limit 5)
SELECT 
  id,
  name,
  category,
  quantity,
  owner_id,
  created_at
FROM inventory_items
ORDER BY created_at DESC
LIMIT 5;

-- Check transactions
SELECT 'Total Transactions' as info, COUNT(*) as count FROM stock_transactions;

-- Sample transactions
SELECT 
  id,
  item_name_snapshot,
  transaction_type,
  quantity,
  occurred_at
FROM stock_transactions
ORDER BY occurred_at DESC
LIMIT 5;

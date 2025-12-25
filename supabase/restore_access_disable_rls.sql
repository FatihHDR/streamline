-- Completely disable RLS for inventory tables to ensure data is visible
ALTER TABLE public.inventory_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_transactions DISABLE ROW LEVEL SECURITY;

-- Ensure explicit grants are in place
GRANT ALL ON public.inventory_items TO anon, authenticated, service_role;
GRANT ALL ON public.stock_transactions TO anon, authenticated, service_role;

-- Check data count to verify data still exists
SELECT 'inventory_items' as table_name, count(*) as count FROM inventory_items
UNION ALL
SELECT 'stock_transactions' as table_name, count(*) as count FROM stock_transactions;

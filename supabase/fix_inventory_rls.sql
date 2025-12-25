-- Enable RLS (just to be safe, so we can attach policies)
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_transactions ENABLE ROW LEVEL SECURITY;

-- Grant access to anon (since Auth is currently acting as anonymous/guest without strict login)
GRANT ALL ON public.inventory_items TO anon, authenticated, service_role;
GRANT ALL ON public.stock_transactions TO anon, authenticated, service_role;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Enable all access for all users" ON public.inventory_items;
DROP POLICY IF EXISTS "Enable all access for all users" ON public.stock_transactions;
DROP POLICY IF EXISTS "inventory_items_policy" ON public.inventory_items;
DROP POLICY IF EXISTS "stock_transactions_policy" ON public.stock_transactions;

-- Create permissive policies for inventory_items
CREATE POLICY "Enable all access for all users"
ON public.inventory_items
FOR ALL
USING (true)
WITH CHECK (true);

-- Create permissive policies for stock_transactions
CREATE POLICY "Enable all access for all users"
ON public.stock_transactions
FOR ALL
USING (true)
WITH CHECK (true);

-- Force schema cache reload
NOTIFY pgrst, 'reload config';

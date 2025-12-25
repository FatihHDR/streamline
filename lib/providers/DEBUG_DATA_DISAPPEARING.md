# Fixing Data Disappearing Issue

## Problem
User synced 16 items successfully, data appeared in Stock List, but after refresh, data disappeared.

## Root Cause
When user refreshes:
1. `InventoryDataProvider.fetchStockItems()` calls Supabase
2. Supabase query returns **empty array** (not error) - likely due to auth/RLS issue
3. `cacheStockItems()` **overwrites cache with empty array**
4. Stock List shows empty

## Why Supabase Returns Empty?

Possible reasons:
1. **Auth session expired/changed** - anonymous user ID changed
2. **RLS filtering data** - even though RLS disabled, policy might filter by owner_id
3. **Query issue** - Supabase query has filter that excludes data

Remember: Data in Supabase has `owner_id: 00000000-0000-0000-0000-000000000000`
If current user's auth.uid() is different, RLS policy `owner_id = auth.uid()` will filter all data out.

## Solution Implemented

Updated `InventoryDataProvider.fetchStockItems()` to:
1. **Not overwrite cache with empty data**
2. **Return cached data if Supabase returns empty**
3. **Add detailed logging** to debug the issue

## Next Steps

1. Check console log when refresh happens:
   - Look for: "DEBUG: Supabase returned X items"
   - If X = 0, check WHY Supabase returns empty

2. If Supabase returns 0 items:
   - Check auth.uid() in console
   - Compare with owner_id in database
   - Verify RLS policy allows query

3. Potential fixes:
   - **Option A**: Update all data to have correct owner_id
   - **Option B**: Change RLS policy to not filter by owner
   - **Option C**: Use service role key instead of anon key

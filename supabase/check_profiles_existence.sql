-- Check if the profiles table exists in the public schema
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE  table_schema = 'public'
   AND    table_name   = 'profiles'
);

-- List all tables in public schema to see what's there
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

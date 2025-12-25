-- Grant access to the profiles table for all roles
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO anon, authenticated, service_role;

-- Ensure RLS is enabled (or disabled for testing if you prefer)
-- Let's keep it enabled but ensure policies exist
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Re-create policies just in case they were missed
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT
  USING ( true );

DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT
  WITH CHECK ( auth.uid() = id );

DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;
CREATE POLICY "Users can update own profile."
  ON public.profiles FOR UPDATE
  USING ( auth.uid() = id );

-- Refresh the schema cache (This notifies PostgREST to reload)
NOTIFY pgrst, 'reload config';

-- =============================================================
-- FILE: storage_cors_fix.sql
-- Run this in Supabase SQL Editor to fix file uploads on web
-- =============================================================

-- Drop and recreate storage policies with broader web access
drop policy if exists "Auth users upload docs" on storage.objects;
drop policy if exists "Public read docs" on storage.objects;
drop policy if exists "Users delete own docs" on storage.objects;

-- Allow any authenticated user to upload
create policy "Auth users upload docs"
  on storage.objects for insert
  to authenticated
  with check ( bucket_id = 'supporting-docs' );

-- Allow public to read all files in the bucket
create policy "Public read docs"
  on storage.objects for select
  using ( bucket_id = 'supporting-docs' );

-- Allow authenticated users to update their files
create policy "Auth users update docs"
  on storage.objects for update
  to authenticated
  using ( bucket_id = 'supporting-docs' );

-- Allow authenticated users to delete files
create policy "Auth users delete docs"
  on storage.objects for delete
  to authenticated
  using ( bucket_id = 'supporting-docs' );

select 'Storage policies updated successfully.' as result;

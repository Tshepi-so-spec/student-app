-- =============================================================
-- FILE: supabase_setup.sql
-- PROJECT: TPG316C - Student Assistant Application System
-- INSTRUCTIONS: Run this ENTIRE script in the Supabase SQL Editor
--   (Supabase Dashboard → SQL Editor → New Query → Paste → Run)
-- GROUP MEMBERS:
--   1. [Full Name]  [Student Number]
--   2. [Full Name]  [Student Number]
--   3. [Full Name]  [Student Number]
--   4. [Full Name]  [Student Number]
--   5. [Full Name]  [Student Number]
-- =============================================================

-- ──────────────────────────────────────────────────────────────
-- 1. APPLICATIONS TABLE
-- ──────────────────────────────────────────────────────────────
create table if not exists public.applications (
  id              uuid        primary key default gen_random_uuid(),
  student_id      uuid        not null references auth.users(id) on delete cascade,
  student_email   text        not null default '',
  year_of_study   int         not null check (year_of_study between 1 and 3),
  module_1_level  text        not null,
  module_1_name   text        not null,
  module_2_level  text,
  module_2_name   text,
  doc_url         text,
  status          text        not null default 'pending'
                              check (status in ('pending', 'approved', 'rejected')),
  created_at      timestamptz not null default now()
);

-- ──────────────────────────────────────────────────────────────
-- 2. ROW LEVEL SECURITY
-- ──────────────────────────────────────────────────────────────
alter table public.applications enable row level security;

-- Drop existing policies if re-running
drop policy if exists "Students manage own applications" on public.applications;
drop policy if exists "Admins full access" on public.applications;

-- Students: full CRUD on their own rows only
create policy "Students manage own applications"
  on public.applications
  for all
  using  ( auth.uid() = student_id )
  with check ( auth.uid() = student_id );

-- Admins: full access to all rows
-- Set admin role via: Dashboard → Authentication → Users → Edit → Raw meta: {"role":"admin"}
create policy "Admins full access"
  on public.applications
  for all
  using  ( (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin' )
  with check ( (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin' );

-- ──────────────────────────────────────────────────────────────
-- 3. STORAGE BUCKET
-- ──────────────────────────────────────────────────────────────
insert into storage.buckets (id, name, public)
values ('supporting-docs', 'supporting-docs', true)
on conflict (id) do nothing;

-- Allow authenticated users to upload to their own folder
drop policy if exists "Auth users upload docs" on storage.objects;
create policy "Auth users upload docs"
  on storage.objects for insert
  with check (
    bucket_id = 'supporting-docs'
    and auth.role() = 'authenticated'
  );

-- Allow public read (for URL access)
drop policy if exists "Public read docs" on storage.objects;
create policy "Public read docs"
  on storage.objects for select
  using ( bucket_id = 'supporting-docs' );

-- Allow users to delete their own files
drop policy if exists "Users delete own docs" on storage.objects;
create policy "Users delete own docs"
  on storage.objects for delete
  using (
    bucket_id = 'supporting-docs'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- ──────────────────────────────────────────────────────────────
-- 4. HELPFUL INDEXES
-- ──────────────────────────────────────────────────────────────
create index if not exists idx_applications_student_id
  on public.applications(student_id);

create index if not exists idx_applications_status
  on public.applications(status);

-- ──────────────────────────────────────────────────────────────
-- 5. VERIFY
-- ──────────────────────────────────────────────────────────────
select 'Setup complete. Tables and policies created.' as result;

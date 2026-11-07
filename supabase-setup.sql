-- Run this in Supabase Dashboard > SQL Editor.
-- Create your admin user first in Authentication > Users, then copy its UUID.

create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.portfolio_projects (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 90),
  description text not null default '',
  live_url text not null check (live_url ~* '^https?://'),
  image_url text,
  is_published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.admin_profiles enable row level security;
alter table public.portfolio_projects enable row level security;

-- Users can only read their own admin flag. Only service-side project setup should grant admin status.
drop policy if exists "Admins can read own profile" on public.admin_profiles;
create policy "Admins can read own profile" on public.admin_profiles
for select to authenticated using (user_id = auth.uid());

-- Public visitors can only see published work.
drop policy if exists "Anyone can view published projects" on public.portfolio_projects;
create policy "Anyone can view published projects" on public.portfolio_projects
for select to anon, authenticated using (is_published = true);

-- Only users explicitly listed as admins can manage projects.
drop policy if exists "Admins can manage projects" on public.portfolio_projects;
create policy "Admins can manage projects" on public.portfolio_projects
for all to authenticated
using (exists (select 1 from public.admin_profiles ap where ap.user_id = auth.uid() and ap.is_admin = true))
with check (exists (select 1 from public.admin_profiles ap where ap.user_id = auth.uid() and ap.is_admin = true));

-- Create a PUBLIC bucket for portfolio thumbnails. Keep uploaded files non-sensitive.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('project-images', 'project-images', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 5242880, allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Public can view project images" on storage.objects;
create policy "Public can view project images" on storage.objects for select to public using (bucket_id = 'project-images');

drop policy if exists "Admins upload project images" on storage.objects;
create policy "Admins upload project images" on storage.objects for insert to authenticated
with check (bucket_id = 'project-images' and (storage.foldername(name))[1] = auth.uid()::text and exists (select 1 from public.admin_profiles ap where ap.user_id = auth.uid() and ap.is_admin = true));

drop policy if exists "Admins update project images" on storage.objects;
create policy "Admins update project images" on storage.objects for update to authenticated
using (bucket_id = 'project-images' and (storage.foldername(name))[1] = auth.uid()::text and exists (select 1 from public.admin_profiles ap where ap.user_id = auth.uid() and ap.is_admin = true))
with check (bucket_id = 'project-images' and (storage.foldername(name))[1] = auth.uid()::text and exists (select 1 from public.admin_profiles ap where ap.user_id = auth.uid() and ap.is_admin = true));

drop policy if exists "Admins delete project images" on storage.objects;
create policy "Admins delete project images" on storage.objects for delete to authenticated
using (bucket_id = 'project-images' and (storage.foldername(name))[1] = auth.uid()::text and exists (select 1 from public.admin_profiles ap where ap.user_id = auth.uid() and ap.is_admin = true));

-- After creating your admin in Authentication > Users, replace the UUID below and run:
-- insert into public.admin_profiles (user_id, is_admin) values ('PASTE-AUTH-USER-UUID-HERE', true)
-- on conflict (user_id) do update set is_admin = true;

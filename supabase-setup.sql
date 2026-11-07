-- Wealth's Tech: run this ONCE in Supabase > SQL Editor > New query > Run

-- 1. The table that holds the live sites shown in "Our Work"
create table if not exists public.live_sites (
  id          uuid primary key default gen_random_uuid(),
  title       text not null check (char_length(title) between 1 and 80),
  url         text not null check (url ~* '^https?://'),
  description text check (char_length(description) <= 160),
  image_url   text,
  created_at  timestamptz not null default now()
);

-- 2. Row Level Security: the rules that decide who can do what
alter table public.live_sites enable row level security;

-- Everyone (website visitors) can only READ
drop policy if exists "public can read live sites" on public.live_sites;
create policy "public can read live sites"
  on public.live_sites for select using (true);

-- Only a logged-in user (you, the admin) can add, edit or delete
drop policy if exists "admin can insert live sites" on public.live_sites;
create policy "admin can insert live sites"
  on public.live_sites for insert to authenticated with check (true);

drop policy if exists "admin can update live sites" on public.live_sites;
create policy "admin can update live sites"
  on public.live_sites for update to authenticated using (true) with check (true);

drop policy if exists "admin can delete live sites" on public.live_sites;
create policy "admin can delete live sites"
  on public.live_sites for delete to authenticated using (true);

-- 3. A public storage bucket for the preview screenshots you upload
insert into storage.buckets (id, name, public)
values ('site-previews', 'site-previews', true)
on conflict (id) do nothing;

drop policy if exists "admin can upload previews" on storage.objects;
create policy "admin can upload previews"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'site-previews');

drop policy if exists "admin can delete previews" on storage.objects;
create policy "admin can delete previews"
  on storage.objects for delete to authenticated
  using (bucket_id = 'site-previews');

-- AFTER running this:
--   Authentication > Users > Add user  (create YOUR admin email + password)
--   Authentication > Sign In / Providers > turn OFF "Allow new users to sign up"
--   (the rules above trust any logged-in user, so nobody else must be able to register)

-- Field Notes database update for app version 0.7 (course, assessments and study plans).
-- Paste into Supabase → SQL Editor → New query, then press Run. Safe to run more than once.
-- (Supabase may warn about "destructive operations" because of the drop policy lines — they only replace the privacy rules on these new tables.)

create table if not exists public.assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  subject_code text not null,
  name text not null,
  due date not null,
  weight numeric(5,2),
  status text not null default 'todo' check (status in ('todo', 'doing', 'submitted', 'marked')),
  mark numeric(5,1),
  plan jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.assessments enable row level security;
drop policy if exists "own assessments" on public.assessments;
create policy "own assessments" on public.assessments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.subject_results (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  code text not null,
  mark numeric(5,1) not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, code)
);
alter table public.subject_results enable row level security;
drop policy if exists "own subject results" on public.subject_results;
create policy "own subject results" on public.subject_results for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

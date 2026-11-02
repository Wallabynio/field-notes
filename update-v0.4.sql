-- Field Notes database update for app version 0.4 (weigh-ins, waist and blood pressure).
-- Paste into Supabase → SQL Editor → New query, then press Run. Safe to run more than once.
-- (Supabase may warn about "destructive operations" because of the drop policy line — it only replaces the privacy rule on this new table.)

create table if not exists public.body (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  weight_kg numeric(5,1),
  waist_cm numeric(5,1),
  bp_sys int,
  bp_dia int,
  updated_at timestamptz not null default now(),
  primary key (user_id, date)
);
alter table public.body enable row level security;
drop policy if exists "own body" on public.body;
create policy "own body" on public.body for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

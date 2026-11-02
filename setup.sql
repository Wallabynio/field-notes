-- Field Notes database setup. Paste into Supabase → SQL Editor → New query, then press Run.

create table if not exists public.shifts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  normal_min int not null default 0,
  home_min int not null default 0,
  receipts numeric(10,2) not null default 0,
  km int default 0,
  note text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  category text not null,
  amount numeric(10,2) not null,
  note text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.days (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  exercise text,
  study_min int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, date)
);

create table if not exists public.tax_weeks (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  week_start date not null,
  amount numeric(10,2) not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, week_start)
);

-- Only you can see or change your own rows.
alter table public.shifts enable row level security;
alter table public.expenses enable row level security;
alter table public.days enable row level security;
alter table public.tax_weeks enable row level security;

create policy "own shifts" on public.shifts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own expenses" on public.expenses for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own days" on public.days for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own tax weeks" on public.tax_weeks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);


-- Shifts: gross fares and Uber fees, so the BAS can use real figures.
alter table public.shifts add column if not exists gross_fares numeric(10,2);
alter table public.shifts add column if not exists uber_fees numeric(10,2);

-- Expenses: business share, the GST inside the amount, and whether a tax invoice was kept.
alter table public.expenses add column if not exists business_pct int not null default 100;
alter table public.expenses add column if not exists gst numeric(10,2) not null default 0;
alter table public.expenses add column if not exists receipt_kept boolean not null default false;

-- Vehicle logbook: one row per trip or shift, business or private.
create table if not exists public.logbook (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  odo_start int not null,
  odo_end int not null,
  kind text not null default 'business' check (kind in ('business', 'private')),
  purpose text default '',
  created_at timestamptz not null default now()
);
alter table public.logbook enable row level security;
drop policy if exists "own logbook" on public.logbook;
create policy "own logbook" on public.logbook for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

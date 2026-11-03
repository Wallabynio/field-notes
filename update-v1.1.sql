-- Field Notes database update for app version 1.1 (driving stints, Uber balance, monthly statements, bills, gym, walks, evening check-in).
-- Paste into Supabase → SQL Editor → New query, then press Run. Safe to run more than once.
-- (Supabase may warn about "destructive operations" because of the drop policy lines — they only replace the privacy rules on these new tables.)

-- Driving stints: odometer and time at start and stop, what you were paid, tolls inside that. Private trips too.
create table if not exists public.stints (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  kind text not null default 'uber' check (kind in ('uber', 'homeward', 'private', 'business')),
  started_at timestamptz,
  ended_at timestamptz,
  odo_start int not null,
  odo_end int,
  earned numeric(10,2) not null default 0,
  tolls numeric(10,2) not null default 0,
  note text default '',
  created_at timestamptz not null default now()
);

-- Money leaving the Uber balance: instant cash-outs ($1.50 fee) and the weekly payout.
create table if not exists public.cashouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  kind text not null default 'instant' check (kind in ('instant', 'weekly', 'adjust')),
  amount numeric(10,2) not null,
  fee numeric(10,2) not null default 0,
  note text default '',
  created_at timestamptz not null default now()
);

-- Uber monthly statement: gross fares and Uber fees, entered when the statement arrives.
create table if not exists public.uber_months (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  month date not null,
  gross_fares numeric(10,2),
  uber_fees numeric(10,2),
  updated_at timestamptz not null default now(),
  primary key (user_id, month)
);

-- Bills: what's due when; each payment is saved as an expense linked to the bill.
create table if not exists public.bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null,
  category text not null default 'Personal',
  amount numeric(10,2) not null default 0,
  every text not null default 'month' check (every in ('week', 'fortnight', 'month', 'quarter', 'year')),
  next_due date not null,
  business_pct int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.expenses add column if not exists bill_id uuid;
alter table public.expenses add column if not exists kwh numeric(7,2);

-- Gym: your machine names (renamed, hidden or added), and every set you do.
create table if not exists public.machines (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  key text not null,
  name text not null,
  kind text not null default 'weights' check (kind in ('weights', 'cardio', 'body')),
  hidden boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);
create table if not exists public.gym_sets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  exercise text not null,
  set_no int not null default 1,
  kg numeric(6,2),
  reps int,
  minutes numeric(6,1),
  level int,
  km numeric(6,2),
  created_at timestamptz not null default now()
);

-- Walks: time and distance from the Apple Watch.
create table if not exists public.walks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  minutes int not null,
  km numeric(6,2),
  avg_hr int,
  note text default '',
  created_at timestamptz not null default now()
);

-- Evening check-in on the day record.
alter table public.days add column if not exists energy int;
alter table public.days add column if not exists sleep int;
alter table public.days add column if not exists stress int;

-- Only you can see or change your own rows.
alter table public.stints enable row level security;
alter table public.cashouts enable row level security;
alter table public.uber_months enable row level security;
alter table public.bills enable row level security;
alter table public.machines enable row level security;
alter table public.gym_sets enable row level security;
alter table public.walks enable row level security;
drop policy if exists "own stints" on public.stints;
drop policy if exists "own cashouts" on public.cashouts;
drop policy if exists "own uber months" on public.uber_months;
drop policy if exists "own bills" on public.bills;
drop policy if exists "own machines" on public.machines;
drop policy if exists "own gym sets" on public.gym_sets;
drop policy if exists "own walks" on public.walks;
create policy "own stints" on public.stints for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own cashouts" on public.cashouts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own uber months" on public.uber_months for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own bills" on public.bills for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own machines" on public.machines for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own gym sets" on public.gym_sets for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own walks" on public.walks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Food shopping: what you bought, how much, what it cost. Counts against the $165 food and coffee budget.
create table if not exists public.food_buys (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  store text not null default 'Aldi',
  item text not null,
  qty numeric(10,2),
  unit text default 'each',
  price numeric(10,2) not null,
  on_list boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.food_buys enable row level security;
drop policy if exists "own food buys" on public.food_buys;
create policy "own food buys" on public.food_buys for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

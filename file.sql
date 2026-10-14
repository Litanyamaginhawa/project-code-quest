-- Progress per user per topic
create table public.progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  language text not null,
  topic text not null,
  score int default 0,
  total int default 0,
  updated_at timestamptz default now(),
  unique (user_id, language, topic)
);

-- Saved custom tests
create table public.custom_tests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  language text not null,
  topic text not null,
  questions jsonb not null,
  created_at timestamptz default now()
);

alter table public.progress enable row level security;
alter table public.custom_tests enable row level security;

revoke all on table public.progress from anon;
revoke all on table public.custom_tests from anon;
grant select, insert, update, delete on public.progress to authenticated;
grant select, insert, update, delete on public.custom_tests to authenticated;

create policy "own progress" on public.progress
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "own tests" on public.custom_tests
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create index progress_user_idx on public.progress using btree (user_id);
create index custom_tests_user_idx on public.custom_tests using btree (user_id);

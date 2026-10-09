create table if not exists public.product_sales (
  product_id text primary key,
  sales_count integer not null default 0
    check (sales_count >= 0),
  updated_at timestamptz not null default now()
);

insert into public.product_sales (product_id, sales_count)
values
  ('chocolate', 0),
  ('strawberry', 0),
  ('matcha', 0),
  ('caramel', 0),
  ('plain', 0)
on conflict (product_id) do nothing;

alter table public.product_sales enable row level security;

grant select on public.product_sales to anon, authenticated;
grant select, insert, update on public.product_sales to authenticated;

drop policy if exists "Public can read product sales"
on public.product_sales;

create policy "Public can read product sales"
on public.product_sales
for select
to anon, authenticated
using (true);

drop policy if exists "Signed-in staff can insert product sales"
on public.product_sales;

create policy "Signed-in staff can insert product sales"
on public.product_sales
for insert
to authenticated
with check (true);

drop policy if exists "Signed-in staff can update product sales"
on public.product_sales;

create policy "Signed-in staff can update product sales"
on public.product_sales
for update
to authenticated
using (true)
with check (true);

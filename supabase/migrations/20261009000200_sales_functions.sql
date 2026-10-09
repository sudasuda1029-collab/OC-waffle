-- 売上を安全に加算・減算する関数
create or replace function public.change_product_sales(
  p_product_id text,
  p_amount integer
)
returns public.product_sales
language plpgsql
security invoker
set search_path = ''
as $$
declare
  result public.product_sales;
begin
  if auth.uid() is null then
    raise exception 'ログインが必要です';
  end if;

  if p_product_id not in (
    'chocolate', 'strawberry', 'matcha', 'caramel', 'plain'
  ) then
    raise exception '無効な商品IDです';
  end if;

  if p_amount not in (-1, 1, 5) then
    raise exception '無効な加算・減算値です';
  end if;

  update public.product_sales
  set sales_count = greatest(0, sales_count + p_amount),
      updated_at = now()
  where product_id = p_product_id
  returning * into result;

  if not found then
    raise exception '商品が見つかりません';
  end if;

  return result;
end;
$$;

-- 売上をすべてリセットする関数
create or replace function public.reset_product_sales()
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'ログインが必要です';
  end if;

  update public.product_sales
  set sales_count = 0,
      updated_at = now();
end;
$$;

-- ログイン済みユーザーだけ実行可能にする
revoke all on function public.change_product_sales(text, integer)
from public, anon;

revoke all on function public.reset_product_sales()
from public, anon;

grant execute on function public.change_product_sales(text, integer)
to authenticated;

grant execute on function public.reset_product_sales()
to authenticated;

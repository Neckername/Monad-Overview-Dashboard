with latest_snapshot as (
  select max(day) as snapshot_day
  from stablecoins_evm.balances
  where blockchain = 'monad'
),
market_cap as (
  select
    b.token_symbol,
    b.token_address,
    sum(coalesce(b.balance_usd, 0)) as market_cap_usd,
    count(distinct case when coalesce(b.balance, 0) > 0 then b.address end) as holders
  from stablecoins_evm.balances b
  join latest_snapshot ls
    on b.day = ls.snapshot_day
  where b.blockchain = 'monad'
  group by 1, 2
),
volume_30d as (
  select
    t.token_symbol,
    t.token_address,
    sum(coalesce(t.amount_usd, 0)) as volume_30d_usd
  from stablecoins_evm.transfers t
  where t.blockchain = 'monad'
    and t.block_date between date_add('day', -29, current_date) and current_date
    and t.block_month >= date_trunc('month', date_add('day', -29, current_date))
  group by 1, 2
),
combined as (
  select
    m.token_symbol,
    m.token_address,
    m.market_cap_usd,
    m.holders,
    coalesce(v.volume_30d_usd, 0) as volume_30d_usd
  from market_cap m
  left join volume_30d v
    on m.token_symbol = v.token_symbol
   and m.token_address = v.token_address
)
select
  token_symbol,
  token_address,
  market_cap_usd,
  100.0 * market_cap_usd / nullif(sum(market_cap_usd) over (), 0) as market_share_pct,
  holders,
  volume_30d_usd,
  100.0 * volume_30d_usd / nullif(sum(volume_30d_usd) over (), 0) as volume_share_pct_30d
from combined
order by market_cap_usd desc;

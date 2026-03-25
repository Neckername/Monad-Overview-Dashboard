with params as (
  select
    cast(substr('{{StartDate}}', 1, 10) as date) as start_date,
    cast(substr('{{StopDate}}', 1, 10) as date) as stop_date
),
days as (
  select day
  from params p
  cross join unnest(sequence(p.start_date, p.stop_date, interval '1' day)) as t(day)
),
daily_transactions as (
  select
    t.block_date as day,
    count(*) as daily_transactions
  from monad.transactions t
  cross join params p
  where t.block_date between p.start_date and p.stop_date
  group by 1
)
select
  d.day,
  cast(coalesce(tx.daily_transactions, 0) as double) / 86400.0 as daily_tps
from days d
left join daily_transactions tx
  on d.day = tx.day
order by 1;

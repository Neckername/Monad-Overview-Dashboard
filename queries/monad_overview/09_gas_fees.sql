with date_window as (
  select
    date_add('day', -30, current_date) as start_date,
    current_date as stop_date
),
days as (
  select day
  from date_window w
  cross join unnest(sequence(w.start_date, w.stop_date, interval '1' day)) as t(day)
),
daily_gas as (
  select
    g.block_date as day,
    avg(g.tx_fee_usd) as avg_gas_fee_usd,
    sum(g.tx_fee_usd) as total_gas_fee_usd,
    avg(g.tx_fee) as avg_gas_fee_mon,
    sum(g.tx_fee) as total_gas_fee_mon
  from gas.fees g
  cross join date_window w
  where g.blockchain = 'monad'
    and g.block_date between w.start_date and w.stop_date
  group by 1
),
daily_transactions as (
  select
    t.block_date as day,
    count(*) as daily_transactions
  from monad.transactions t
  cross join date_window w
  where t.block_date between w.start_date and w.stop_date
  group by 1
)
select
  d.day,
  coalesce(g.avg_gas_fee_usd, 0) as avg_gas_fee_usd,
  coalesce(g.total_gas_fee_usd, 0) as total_gas_fee_usd,
  coalesce(g.avg_gas_fee_mon, 0) as avg_gas_fee_mon,
  coalesce(g.total_gas_fee_mon, 0) as total_gas_fee_mon,
  coalesce(tx.daily_transactions, 0) as daily_transactions
from days d
left join daily_gas g
  on d.day = g.day
left join daily_transactions tx
  on d.day = tx.day
order by 1;

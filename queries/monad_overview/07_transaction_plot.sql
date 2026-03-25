with params as (
  select
    cast(substr('{{StartDate}}', 1, 10) as date) as start_date,
    cast(substr('{{StopDate}}', 1, 10) as date) as stop_date,
    '{{Interval}}' as interval_unit
),
contracts as (
  select distinct address
  from monad.contracts
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
),
eoa_sender_rows as (
  select
    t.block_date as day,
    t."from" as sender
  from monad.transactions t
  cross join params p
  left join contracts c
    on t."from" = c.address
  where t.block_date between p.start_date and p.stop_date
    and c.address is null
),
daily_unique_users as (
  select
    day,
    count(distinct sender) as daily_unique_users
  from eoa_sender_rows
  group by 1
),
daily_filled as (
  select
    d.day,
    coalesce(tx.daily_transactions, 0) as daily_transactions,
    coalesce(u.daily_unique_users, 0) as daily_unique_users
  from days d
  left join daily_transactions tx
    on d.day = tx.day
  left join daily_unique_users u
    on d.day = u.day
),
daily_with_ma as (
  select
    day,
    daily_transactions,
    daily_unique_users,
    avg(cast(daily_transactions as double)) over (
      order by day
      rows between 29 preceding and current row
    ) as tx_ma30
  from daily_filled
),
bucketed_transactions as (
  select
    case
      when p.interval_unit = 'week' then cast(date_trunc('week', m.day) as date)
      when p.interval_unit = 'month' then cast(date_trunc('month', m.day) as date)
      else m.day
    end as "time",
    sum(m.daily_transactions) as transactions
  from daily_with_ma m
  cross join params p
  group by 1
),
bucketed_users as (
  select
    case
      when p.interval_unit = 'week' then cast(date_trunc('week', e.day) as date)
      when p.interval_unit = 'month' then cast(date_trunc('month', e.day) as date)
      else e.day
    end as "time",
    count(distinct e.sender) as unique_users
  from eoa_sender_rows e
  cross join params p
  group by 1
),
bucketed_ma as (
  select
    case
      when p.interval_unit = 'week' then cast(date_trunc('week', m.day) as date)
      when p.interval_unit = 'month' then cast(date_trunc('month', m.day) as date)
      else m.day
    end as "time",
    max_by(m.tx_ma30, m.day) as tx_ma30
  from daily_with_ma m
  cross join params p
  group by 1
),
combined as (
  select
    t."time",
    t.transactions,
    coalesce(u.unique_users, 0) as unique_users,
    m.tx_ma30
  from bucketed_transactions t
  left join bucketed_users u
    on t."time" = u."time"
  left join bucketed_ma m
    on t."time" = m."time"
)
select
  "time",
  transactions,
  unique_users,
  cast(transactions as double) / nullif(unique_users, 0) as tx_per_user,
  sum(transactions) over (order by "time") as cumulative_transactions,
  tx_ma30
from combined
order by 1;

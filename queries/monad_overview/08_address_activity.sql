with params as (
  select
    cast(substr('{{StartDate}}', 1, 10) as date) as start_date,
    cast(substr('{{StopDate}}', 1, 10) as date) as stop_date
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
eoa_sender_history as (
  select
    t.block_date as day,
    t."from" as sender
  from monad.transactions t
  cross join params p
  left join contracts c
    on t."from" = c.address
  where c.address is null
    and t.block_date >= date '2025-01-01'
    and t.block_date <= p.stop_date
),
first_seen as (
  select
    sender,
    min(day) as first_seen_day
  from eoa_sender_history
  group by 1
),
active_window as (
  select
    h.day,
    h.sender
  from eoa_sender_history h
  cross join params p
  where h.day between p.start_date and p.stop_date
),
daily_active as (
  select
    day,
    count(distinct sender) as active_wallet_addresses
  from active_window
  group by 1
),
daily_new as (
  select
    f.first_seen_day as day,
    count(*) as new_wallet_addresses
  from first_seen f
  cross join params p
  where f.first_seen_day between p.start_date and p.stop_date
  group by 1
),
daily_recurring as (
  select
    a.day,
    count(distinct a.sender) as recurring_wallet_addresses
  from active_window a
  join first_seen f
    on a.sender = f.sender
  where f.first_seen_day < a.day
  group by 1
)
select
  d.day,
  coalesce(n.new_wallet_addresses, 0) as new_wallet_addresses,
  coalesce(r.recurring_wallet_addresses, 0) as recurring_wallet_addresses,
  coalesce(a.active_wallet_addresses, 0) as active_wallet_addresses
from days d
left join daily_new n
  on d.day = n.day
left join daily_recurring r
  on d.day = r.day
left join daily_active a
  on d.day = a.day
order by 1;

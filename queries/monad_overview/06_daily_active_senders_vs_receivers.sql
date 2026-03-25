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
base as (
  select
    t.block_date as day,
    t."from" as sender,
    t."to" as receiver,
    c_from.address as sender_contract,
    c_to.address as receiver_contract
  from monad.transactions t
  cross join params p
  left join contracts c_from
    on t."from" = c_from.address
  left join contracts c_to
    on t."to" = c_to.address
  where t.block_date between p.start_date and p.stop_date
),
daily_senders as (
  select
    day,
    count(distinct sender) as daily_senders
  from base
  where sender_contract is null
  group by 1
),
daily_receivers as (
  select
    day,
    count(distinct receiver) as daily_receivers
  from base
  where receiver is not null
    and receiver_contract is null
  group by 1
)
select
  d.day,
  coalesce(s.daily_senders, 0) as daily_senders,
  coalesce(r.daily_receivers, 0) as daily_receivers
from days d
left join daily_senders s
  on d.day = s.day
left join daily_receivers r
  on d.day = r.day
order by 1;

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
daily_deployments as (
  select
    cast(c.created_at as date) as day,
    count(*) as daily_contract_deployments
  from monad.contracts c
  cross join params p
  where c.base = false
    and cast(c.created_at as date) between p.start_date and p.stop_date
  group by 1
),
baseline as (
  select
    count(*) as deployments_before_start
  from monad.contracts c
  cross join params p
  where c.base = false
    and cast(c.created_at as date) < p.start_date
),
daily_filled as (
  select
    d.day,
    coalesce(dd.daily_contract_deployments, 0) as daily_contract_deployments
  from days d
  left join daily_deployments dd
    on d.day = dd.day
)
select
  f.day,
  f.daily_contract_deployments,
  b.deployments_before_start
    + sum(f.daily_contract_deployments) over (order by f.day) as cumulative_contract_deployments
from daily_filled f
cross join baseline b
order by 1;

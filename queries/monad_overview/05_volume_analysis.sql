with params as (
  select
    cast(substr('{{StartDate}}', 1, 10) as date) as start_date,
    cast(substr('{{StopDate}}', 1, 10) as date) as stop_date,
    '{{Interval}}' as interval_unit
),
days as (
  select day
  from params p
  cross join unnest(sequence(p.start_date, p.stop_date, interval '1' day)) as t(day)
),
daily_volume as (
  select
    t.block_date as day,
    sum(coalesce(t.amount, 0)) as daily_volume_mon
  from tokens.transfers t
  cross join params p
  where t.blockchain = 'monad'
    and t.token_standard = 'native'
    and t.block_date between p.start_date and p.stop_date
  group by 1
),
daily_filled as (
  select
    d.day,
    coalesce(v.daily_volume_mon, 0) as daily_volume_mon
  from days d
  left join daily_volume v
    on d.day = v.day
),
daily_with_ma as (
  select
    day,
    daily_volume_mon,
    avg(daily_volume_mon) over (
      order by day
      rows between 29 preceding and current row
    ) as ma30_daily_volume_mon
  from daily_filled
),
bucketed_volume as (
  select
    case
      when p.interval_unit = 'week' then cast(date_trunc('week', m.day) as date)
      when p.interval_unit = 'month' then cast(date_trunc('month', m.day) as date)
      else m.day
    end as "time",
    sum(m.daily_volume_mon) as total_volume_mon
  from daily_with_ma m
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
    max_by(m.ma30_daily_volume_mon, m.day) as ma30_daily_volume_mon
  from daily_with_ma m
  cross join params p
  group by 1
)
select
  v."time",
  v.total_volume_mon,
  m.ma30_daily_volume_mon
from bucketed_volume v
join bucketed_ma m
  on v."time" = m."time"
order by 1;

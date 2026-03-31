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
time_buckets as (
  select distinct
    case
      when p.interval_unit = 'week' then cast(date_trunc('week', d.day) as date)
      when p.interval_unit = 'month' then cast(date_trunc('month', d.day) as date)
      else d.day
    end as "time"
  from days d
  cross join params p
),
bucketed_project_volume as (
  select
    case
      when p.interval_unit = 'week' then cast(date_trunc('week', t.block_date) as date)
      when p.interval_unit = 'month' then cast(date_trunc('month', t.block_date) as date)
      else t.block_date
    end as "time",
    t.project,
    sum(t.amount_usd) as volume_usd
  from dex.trades t
  cross join params p
  where t.blockchain = 'monad'
    and t.block_month between date_trunc('month', p.start_date) and date_trunc('month', p.stop_date)
    and t.block_date between p.start_date and p.stop_date
    and t.amount_usd is not null
    and t.amount_usd > 0
  group by 1, 2
),
project_totals as (
  select
    project,
    sum(volume_usd) as total_volume_usd
  from bucketed_project_volume
  where project is not null
    and trim(project) <> ''
  group by 1
),
top_projects as (
  select project
  from project_totals
  order by total_volume_usd desc
  limit 9
),
labeled_volume as (
  select
    b."time",
    case
      when b.project in (select project from top_projects) then b.project
      else 'other'
    end as dex_project,
    sum(b.volume_usd) as volume_usd
  from bucketed_project_volume b
  group by 1, 2
),
dex_labels as (
  select project as dex_project
  from top_projects
  union all
  select 'other'
),
grid as (
  select
    tb."time",
    dl.dex_project
  from time_buckets tb
  cross join dex_labels dl
),
filled as (
  select
    g."time",
    g.dex_project,
    coalesce(lv.volume_usd, 0) as volume_usd
  from grid g
  left join labeled_volume lv
    on g."time" = lv."time"
   and g.dex_project = lv.dex_project
),
totals as (
  select
    "time",
    sum(volume_usd) as total_volume_usd
  from filled
  group by 1
)
select
  f."time",
  f.dex_project,
  f.volume_usd,
  100.0 * cast(f.volume_usd as double) / nullif(t.total_volume_usd, 0) as pct_of_total_dex_volume
from filled f
join totals t
  on f."time" = t."time"
order by
  f."time",
  case when f.dex_project = 'other' then 1 else 0 end,
  f.volume_usd desc;

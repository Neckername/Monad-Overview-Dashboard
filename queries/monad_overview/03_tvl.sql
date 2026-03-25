with raw as (
  select cast(
    json_parse(http_get('https://api.llama.fi/v2/historicalChainTvl/Monad')) as array(json)
  ) as records
),
rows as (
  select record
  from raw
  cross join unnest(records) as u(record)
)
select
  from_unixtime(cast(json_extract_scalar(record, '$.date') as bigint)) as "time",
  cast(json_extract_scalar(record, '$.tvl') as double) as tvl
from rows
order by 1;

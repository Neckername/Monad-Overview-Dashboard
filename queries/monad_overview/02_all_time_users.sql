with contracts as (
  select distinct address
  from monad.contracts
)
select
  current_date as as_of_date,
  count(distinct t."from") as all_time_users
from monad.transactions t
left join contracts c
  on t."from" = c.address
where t.block_date >= date '2025-01-01'
  and c.address is null;

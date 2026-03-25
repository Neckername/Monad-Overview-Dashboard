select
  current_date as as_of_date,
  count(*) as total_transactions
from monad.transactions
where block_date >= date '2025-01-01';

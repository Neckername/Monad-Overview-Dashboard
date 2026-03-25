SELECT
  current_date AS as_of_date,
  COUNT(DISTINCT address) AS total_contracts_deployed
FROM monad.traces
WHERE "type" = 'create'
  AND success = TRUE
  AND tx_success = TRUE
  AND block_date >= DATE '2025-01-01';

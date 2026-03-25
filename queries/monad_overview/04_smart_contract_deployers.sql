SELECT
  COUNT(DISTINCT tx_from) AS total_smart_contract_deployers
FROM monad.traces
WHERE "type" = 'create'
  AND success = TRUE
  AND tx_success = TRUE;

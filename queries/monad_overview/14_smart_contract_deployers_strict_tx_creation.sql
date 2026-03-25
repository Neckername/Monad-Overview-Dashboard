SELECT
  COUNT(DISTINCT "from") AS total_smart_contract_deployers
FROM monad.transactions
WHERE "to" IS NULL
  AND success = TRUE;

# Monad Overview Dashboard Plan

## Summary
Build `Monad Overview` as a Dune dashboard backed by 11 saved private, non-temp queries and their visualizations. Use Dune-native Monad datasets for chain activity, users, gas, deployments, and TPS; use DefiLlama’s chain TVL endpoint for TVL because you explicitly want the Ethereum TVL reference query’s methodology replicated for Monad.

## Query Set
1. `Monad Overview - Total Transactions`
Count all rows in `monad.transactions` and return the latest all-time total as a counter source.
Assumption: “transactions” means all indexed transactions, not only successful ones.

2. `Monad Overview - All-Time Users`
Count cumulative unique EOA sender wallets from `monad.transactions`.
EOA filter: anti-join sender addresses against `monad.contracts`.
Return a single latest-value row for a counter.

3. `Monad Overview - TVL`
Replicate the Ethereum reference query against `https://api.llama.fi/v2/historicalChainTvl/Monad`.
Base query returns historical `time, tvl`; dashboard counter uses the latest row.
If DefiLlama exposes Monad under a different chain slug, substitute that exact slug and keep the same query shape.

4. `Monad Overview - Smart Contract Deployers`
Use `monad.contracts`, filter `base = false`, count distinct `from` addresses, and return the latest all-time total as a counter.
Do not EOA-filter this metric; factory deployers remain valid deployers.

5. `Monad Overview - Native Volume Analysis`
Use `tokens.transfers` filtered to `blockchain = 'monad'` and native-token rows only.
Add `Interval` enum parameter with `day`, `week`, `month`.
Bars: bucketed native transfer volume from full available history.
Line: true 30-day moving average computed from underlying daily volume, then aligned to each selected bucket using the last daily MA value inside the bucket.
Output columns: `time`, `total_volume`, `ma30_avg`.

6. `Monad Overview - Daily Active Senders vs Receivers`
Use `monad.transactions` full history.
Compute daily distinct EOA senders and daily distinct EOA receivers.
EOA filter: anti-join both sides against `monad.contracts`; exclude null receivers.
Fill missing days with zeroes.
Output columns: `day`, `daily_senders`, `daily_receivers`.

7. `Monad Overview - Transaction Trends`
Use `monad.transactions` full history.
Series:
`daily_transactions`
`cumulative_transactions`
`daily_unique_eoa_senders`
`tx_ma30`
This locks “unique transactions” to daily unique EOA senders, since user/activity metrics are EOA-only and sender-based.

8. `Monad Overview - Address Activity`
Use EOA sender wallets only.
Derive `first_seen_day` per sender.
Series:
`new_wallet_addresses`
`recurring_wallet_addresses`
`active_wallet_addresses`
Definitions:
`new` = first seen on that day
`active` = distinct active EOA senders that day
`recurring` = active senders whose first seen day is before that day

9. `Monad Overview - Gas Fees vs Transactions`
Use last 30 days only.
From `gas.fees`: daily `sum(tx_fee_usd)` where `blockchain = 'monad'`.
From `monad.transactions`: daily tx count.
Output columns: `day`, `gas_fee_usd`, `daily_transactions`.

10. `Monad Overview - Contract Deployments`
Use `monad.contracts`, filter `base = false`.
Compute daily deployment count and cumulative deployment count from `created_at`.
Output columns: `day`, `daily_contract_deployments`, `cumulative_contract_deployments`.

11. `Monad Overview - Transactions Per Second`
Use `monad.transactions` full history.
Compute daily average TPS as `daily_transactions / 86400.0`.
Fill missing days with zeroes.
Output columns: `day`, `daily_tps`.

## Visualizations And Dashboard Assembly
Use counters for queries 1-4.
Use a mixed column + line chart for query 5: columns for `total_volume`, line for `ma30_avg`.
Use an area chart for query 6 with separate series for senders and receivers.
Use a dual-axis line chart for query 7: daily series on the left axis, cumulative transactions on the right axis.
Use a line chart for query 8 with the three wallet lifecycle series.
Use a mixed column + line chart for query 9: columns for `gas_fee_usd`, line for `daily_transactions`, dual axis enabled.
Use a mixed area + line chart for query 10: area for daily deployments, line for cumulative deployments, dual axis enabled.
Use an area chart for query 11.
Assemble the final `Monad Overview` dashboard in the Dune UI by adding each saved visualization as a widget and arranging counters first, then historical charts.

## Validation
Verify the TVL series matches the DefiLlama Monad chain endpoint and the counter equals the latest row.
Verify the volume query changes correctly across `day`, `week`, and `month`, while the overlay remains a true 30-day MA.
Spot-check EOA-only metrics by confirming sampled excluded addresses exist in `monad.contracts`.
Confirm the gas query returns exactly the last 30 calendar days.
Confirm full-history charts start at the earliest indexed Monad date available in the underlying dataset.
Confirm cumulative series are monotonic and zero-filled days do not break chart continuity.

## Assumptions
Saved queries are private and non-temp.
Dashboard creation itself is done in the Dune web app after query and visualization creation.
EOA filtering relies on `monad.contracts`, so it inherits Dune contract-detection completeness.
User lifecycle metrics are sender-based; the separate senders/receivers chart covers both sides of activity.
Native volume follows your Ethereum reference query’s intent, but the moving average is corrected to a true 30-day calculation.

# Monad Overview Dashboard, Revised Against Ethereum Overview

## Summary
Build `Monad Overview` as a Dune dashboard with `12 saved queries` and shared dashboard parameters where they improve parity with the Ethereum reference dashboard.

This revision adds the three gaps found in the Ethereum comparison:
- `tx_per_user` plus shared date controls on the main transaction plot
- a `stablecoin composition` panel
- `native MON gas fees` alongside the existing USD gas-fee view

The comparison baseline is the public Ethereum query footprint I could verify from the dashboard: transaction plot, contract creation, daily gas fees, daily active addresses, and stablecoin composition.

## Key Changes
### Shared dashboard controls
Use shared dashboard parameters on long-range charts:
- `Interval` enum: `day`, `week`, `month`
- `StartDate` date
- `StopDate` date

Bind these to:
- `Monad Overview - Volume Analysis`
- `Monad Overview - Transaction Plot`

Use only `StartDate` and `StopDate` on daily-only history charts where bucketing would change the metric definition:
- `Daily Active Senders vs Receivers`
- `Address Activity`
- `Contract Deployments`
- `Transactions Per Second`

Defaults:
- `Interval = day`
- `StartDate = earliest available Monad date in the source table`
- `StopDate = CURRENT_DATE`

### Saved queries
1. `Monad Overview - Total Transactions`
Source: `monad.transactions`
Return latest all-time `count(*)` as a counter source.

2. `Monad Overview - All-Time Users`
Source: `monad.transactions`
Metric: cumulative distinct EOA sender addresses.
EOA rule: exclude addresses present in `monad.contracts`.

3. `Monad Overview - TVL`
Source: DefiLlama `historicalChainTvl/Monad` via `http_get`, matching the Ethereum TVL reference pattern.
Return full historical `time, tvl`.
Use the same query for:
- latest TVL counter
- optional historical TVL line widget

4. `Monad Overview - Smart Contract Deployers`
Source: `monad.contracts`
Metric: distinct `from` addresses where `base = false`.
Do not EOA-filter this metric; factory deployers count.

5. `Monad Overview - Volume Analysis`
Source: `tokens.transfers`
Definition: native `MON` transfer volume only, matching the Ethereum native-transfer volume query pattern rather than DEX trade volume.
Parameters: `Interval`, `StartDate`, `StopDate`
Output:
- `time`
- `total_volume_mon`
- `ma30_daily_volume_mon`
Logic:
- compute daily native transfer volume first
- compute a true 30-day moving average on daily volume
- rebucket daily volume to selected interval for bars
- for each selected bucket, use the last daily MA value in that bucket for the overlay line

6. `Monad Overview - Daily Active Senders vs Receivers`
Source: `monad.transactions`
Parameters: `StartDate`, `StopDate`
Output:
- `day`
- `daily_senders`
- `daily_receivers`
Definitions:
- EOA senders only
- EOA receivers only
- exclude null `to`
- fill missing days with zeroes

7. `Monad Overview - Transaction Plot`
Source: `monad.transactions`
Parameters: `Interval`, `StartDate`, `StopDate`
This replaces the earlier transaction-trends spec with the Ethereum-style plot plus the extra moving average you requested.
Output:
- `time`
- `transactions`
- `unique_users`
- `tx_per_user`
- `cumulative_transactions`
- `tx_ma30`
Definitions:
- `transactions`: total tx count in bucket
- `unique_users`: distinct EOA sender addresses in bucket
- `tx_per_user`: `transactions / nullif(unique_users, 0)`
- `cumulative_transactions`: running sum of bucketed transactions
- `tx_ma30`: true 30-day moving average derived from daily tx counts, then aligned to the selected bucket
Note:
- the earlier “unique transactions” label is normalized to `unique_users`, because the Ethereum reference plot measures distinct senders, not distinct hashes

8. `Monad Overview - Address Activity`
Source: `monad.transactions`
Parameters: `StartDate`, `StopDate`
Sender-based EOA lifecycle metric.
Output:
- `day`
- `new_wallet_addresses`
- `recurring_wallet_addresses`
- `active_wallet_addresses`
Definitions:
- `new`: sender first seen on that day
- `active`: distinct EOA senders active that day
- `recurring`: active senders first seen before that day

9. `Monad Overview - Gas Fees`
Sources: `gas.fees`, `monad.transactions`
Window: last 30 calendar days only
Output:
- `day`
- `gas_fee_usd`
- `gas_fee_mon`
- `daily_transactions`
Definitions:
- `gas_fee_usd`: daily `sum(tx_fee_usd)` from `gas.fees`
- `gas_fee_mon`: daily `sum(tx_fee)` from `gas.fees`
- `daily_transactions`: daily tx count from `monad.transactions`
This single query should drive two widgets:
- combo chart: bars `gas_fee_usd`, line `daily_transactions`
- native-fee widget: line or bar chart for `gas_fee_mon` to match Ethereum’s native gas-fee coverage

10. `Monad Overview - Contract Deployments`
Source: `monad.contracts`
Parameters: `StartDate`, `StopDate`
Filter: `base = false`
Output:
- `day`
- `daily_contract_deployments`
- `cumulative_contract_deployments`

11. `Monad Overview - Transactions Per Second`
Source: `monad.transactions`
Parameters: `StartDate`, `StopDate`
Output:
- `day`
- `daily_tps`
Definition:
- `daily_tps = daily_transactions / 86400.0`
Fill missing days with zeroes.

12. `Monad Overview - Stablecoin Composition`
Sources: `stablecoins_evm.balances`, `stablecoins_evm.transfers`
Snapshot: latest available balance day on `blockchain = 'monad'`
Trailing activity: last 30 days of transfer data
Output table:
- `token_symbol`
- `token_address`
- `market_cap_usd`
- `market_share_pct`
- `holders`
- `volume_30d_usd`
- `volume_share_pct_30d`
Sort by `market_cap_usd desc`.
This is the Monad replacement for the Ethereum stablecoin composition panel, using Dune’s curated stablecoin datasets instead of Ethereum-only manual token logic.

### Visualizations and dashboard layout
Use these widgets:
- counters: total transactions, all-time users, latest TVL, smart contract deployers
- line widget: optional historical TVL trend
- combo chart: volume bars + 30-day MA line
- area chart: daily senders vs receivers
- dual-axis line chart: transaction plot, with `cumulative_transactions` on the right axis
- line chart: address activity
- combo chart: gas fee USD bars + daily transactions line
- native-fee chart: `gas_fee_mon`
- dual-axis area + line chart: daily vs cumulative contract deployments
- area chart: TPS
- table widget: stablecoin composition

Recommended dashboard order:
1. counters
2. transaction plot
3. volume analysis
4. daily senders vs receivers
5. address activity
6. gas fees
7. contract deployments
8. TPS
9. TVL trend
10. stablecoin composition table

## Test Plan
- Verify `monad.transactions`, `monad.contracts`, `tokens.transfers`, `gas.fees`, and `stablecoins_evm.*` all return data across the expected Monad history window.
- Verify `Interval`, `StartDate`, and `StopDate` drive both transaction plot and volume analysis correctly.
- Verify the 30-day moving-average series is daily-based before rebucketing, not row-based after aggregation.
- Verify EOA-only metrics exclude contract senders and contract receivers via `monad.contracts`.
- Verify contract deployment counts exclude `base = true`.
- Verify gas query returns exactly 30 calendar days and that USD and MON totals reconcile with `gas.fees`.
- Verify stablecoin composition uses the latest available snapshot day and that 30-day transfer volume uses proper partition filters.
- Verify cumulative series are monotonic and missing-day backfills do not create gaps.
- Spot-check the Ethereum parity items:
  - transaction plot includes `transactions`, `unique_users`, `tx_per_user`, `cumulative_transactions`
  - contract deployment panel exists
  - native gas-fee view exists
  - stablecoin composition panel exists

## Assumptions
- Comparison scope is the public Ethereum Overview query footprint I could verify, not a full dashboard DOM scrape, because direct dashboard enumeration was blocked by Cloudflare.
- “Users” means distinct EOA sender addresses.
- “Volume” means native MON transfer volume, because that is what the Ethereum reference volume query measures.
- TVL continues to use DefiLlama, matching the Ethereum reference methodology.
- Stablecoin composition is implemented with curated Dune stablecoin tables, not Ethereum-specific hand-curated token lists.

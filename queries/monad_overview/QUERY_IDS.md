# Monad Overview Saved Queries

Created on 2026-03-25 (America/New_York). Updated on 2026-03-30.

| # | Query Name | Query ID | Privacy | Last Validation Execution ID |
|---|---|---:|---|---|
| 1 | Monad Overview - Total Transactions | 6904848 | private | 01KMJ8B6FZ53TJDPHDTD0MEZPH |
| 2 | Monad Overview - All-Time Users | 6904849 | private | 01KMJ8B6M1Q03822ZGRACZ95SN |
| 3 | Monad Overview - TVL | 6904850 | private | 01KMJ8BBMVHV5R8KZD6EXP2Q1Z |
| 4 | Monad Overview - Smart Contract Deployers | 6904851 | private | 01KMJFE4B4B8DJMPW19J5AGMHC |
| 5 | Monad Overview - Volume Analysis (public datetime) | 6909733 | public | 01KMM8QRV7YRBDD864QZKH4GC3 |
| 6 | Monad Overview - Daily Active Senders vs Receivers (public datetime interval) | 6924982 | public | 01KMYXV2D7SD58J5XA8JC9YZTR |
| 7 | Monad Overview - Transaction Plot (public datetime) | 6909735 | public | 01KMM8QRVMXD8Q9XEBVD3W24DF |
| 8 | Monad Overview - Address Activity (public datetime interval) | 6924983 | public | 01KMYXV2HJT9VEY2BJQRGHD7AQ |
| 9 | Monad Overview - Gas Fees (public datetime interval) | 6925095 | public | 01KMYZ9QE5PT2YCB5S800K4JBH |
| 10 | Monad Overview - Contract Deployments (public datetime interval) | 6924984 | public | 01KMYXV2NTWSM53RWQBMJNFJ1A |
| 11 | Monad Overview - Transactions Per Second (public datetime interval) | 6924985 | public | 01KMYXV2T2R3ZMTGHX0E3X0G78 |
| 12 | Monad Overview - Stablecoin Composition | 6904878 | public | 01KMJ8MAY008T0MB7SSACPNCNH |
| 13 | Monad Overview - Total Contracts Deployed | 6905338 | public | 01KMJEZHQJQ3P8EE839XH303DN |
| 14 | Monad Overview - Smart Contract Deployers (Strict Tx Creation) | 6905474 | public | 01KMJG7Y158ED2D4HPAYGMBH4Q |
| 15 | Monad Overview - DEX Volume Top 9 + Other (USD, % of Total) | 6925181 | public | 01KMZ0D16BAC4EPAEXZD52VA1S |

## Notes

- Queries 11 and 12 were created as public because Dune returned `max_number_of_private_queries_reached` when attempting to create additional private queries.
- On 2026-03-26, queries 5, 6, 7, 8, and 10 were moved to public datetime clones (`6909733`, `6909734`, `6909735`, `6909736`, `6909737`) so dashboard date controls stay on datetime.
- On 2026-03-30, queries 6, 8, 10, and 11 were moved to public datetime+interval clones (`6924982`, `6924983`, `6924984`, `6924985`) so both interval and datetime selectors work together.
- On 2026-03-30, query 9 was moved to a public datetime+interval clone (`6925095`) to align with the same dashboard selectors.
- On 2026-03-30, query 15 was added as a new public datetime+interval DEX volume share query (`6925181`) for Monad top-9 DEX + `other` composition.
- Parameterized queries use:
  - `Interval` enum: `day`, `week`, `month`
  - `StartDate` datetime default: `2025-05-14 00:00:00`
  - `StopDate` datetime default: `2026-03-25 00:00:00`

# Monad Overview Saved Queries

Created on 2026-03-25 (America/New_York).

| # | Query Name | Query ID | Privacy | Last Validation Execution ID |
|---|---|---:|---|---|
| 1 | Monad Overview - Total Transactions | 6904848 | private | 01KMJ8B6FZ53TJDPHDTD0MEZPH |
| 2 | Monad Overview - All-Time Users | 6904849 | private | 01KMJ8B6M1Q03822ZGRACZ95SN |
| 3 | Monad Overview - TVL | 6904850 | private | 01KMJ8BBMVHV5R8KZD6EXP2Q1Z |
| 4 | Monad Overview - Smart Contract Deployers | 6904851 | private | 01KMJFE4B4B8DJMPW19J5AGMHC |
| 5 | Monad Overview - Volume Analysis | 6904853 | private | 01KMJ8DBJQVXQVNSKNB3E89J3Z |
| 6 | Monad Overview - Daily Active Senders vs Receivers | 6904854 | private | 01KMJ8DBQ141P6GFM9GYR3Q7K3 |
| 7 | Monad Overview - Transaction Plot | 6904858 | private | 01KMJ8DBVDKVMAGK7TK8FAZT9D |
| 8 | Monad Overview - Address Activity | 6904859 | private | 01KMJ8DBZJ8D1RWP3KEG5ZPJXC |
| 9 | Monad Overview - Gas Fees | 6904862 | private | 01KMJBYF34JJH0NPTBWHQ8AXCT |
| 10 | Monad Overview - Contract Deployments | 6904863 | private | 01KMJ8MANKN9P6TAV26M0CGDZ6 |
| 11 | Monad Overview - Transactions Per Second | 6904877 | public | 01KMJ8MASNXZVXHM4R04D6YGWC |
| 12 | Monad Overview - Stablecoin Composition | 6904878 | public | 01KMJ8MAY008T0MB7SSACPNCNH |
| 13 | Monad Overview - Total Contracts Deployed | 6905338 | public | 01KMJEZHQJQ3P8EE839XH303DN |
| 14 | Monad Overview - Smart Contract Deployers (Strict Tx Creation) | 6905474 | public | 01KMJG7Y158ED2D4HPAYGMBH4Q |

## Notes

- Queries 11 and 12 were created as public because Dune returned `max_number_of_private_queries_reached` when attempting to create additional private queries.
- Parameterized queries use:
  - `Interval` enum: `day`, `week`, `month`
  - `StartDate` datetime default: `2025-05-14 00:00:00`
  - `StopDate` datetime default: `2026-03-25 00:00:00`

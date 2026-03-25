# Monad Overview Query Bundle

This folder contains the SQL for the revised 12-query Monad Overview dashboard plan.

## Parameter conventions

- `StartDate`: query parameter of type `datetime` in format `YYYY-MM-DD HH:mm:ss`
- `StopDate`: query parameter of type `datetime` in format `YYYY-MM-DD HH:mm:ss`
- `Interval`: query parameter of type `enum` with values `day`, `week`, `month`

Date parameters are cast in SQL as:

```sql
cast(substr('{{StartDate}}', 1, 10) as date)
```

Use default parameter values:

- `StartDate = 2025-05-14 00:00:00`
- `StopDate = CURRENT_DATE at 00:00:00 in dashboard control`
- `Interval = day`

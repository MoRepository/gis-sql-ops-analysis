# Late delivery outliers (Olist)

**Goal:** Identify delivery areas (state/city/zip_prefix) with unusually high late-delivery delay.

## What the query does
- Uses `olist.orders_delays` (late deliveries where `delay_days > 0`)
- Aggregates per area:
  - delivered_count
  - avg_delay_days
  - p90_area_delay (90th percentile delay in days)
- Flags outliers where an area’s `p90_area_delay` is >= global 95th percentile of area p90s
- Ranks areas by worst p90 delay

## How to run
Run `sql/advanced/olist_late_delivery_outliers.sql` in pgAdmin connected to the `olist` database.

## Output columns (what to look at)
- `p90_area_delay`: “worst-case typical delay” for the area (90th percentile)
- `global_p95_p90_area_delay`: cutoff for outlier areas
- `p90_rank`: ordering of worst outliers

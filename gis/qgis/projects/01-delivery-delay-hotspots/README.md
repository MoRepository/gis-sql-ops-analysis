# QGIS Project 01 — Delivery Delay Hotspots (Olist)

Goal: turn the SQL outputs from the Olist delivery analysis into a simple map workflow in QGIS, so delays can be reviewed by location and compared over time.

## Inputs
- PostgreSQL (schema: `olist`)
- Tables/views used:
  - `olist.orders_enriched` (customer city/state/zip prefix + delivery timestamps)
  - `olist.deliveries_fact` (derived delivery metrics used for analysis)

## What I mapped
1) **Late delivery hotspot candidates**
   - Areas grouped by `customer_state`, `customer_city`, `customer_zip_code_prefix`
   - A “late_count” threshold to avoid noisy tiny samples
   - Ranked by p90 delay to surface extreme pockets

2) **Trend check (optional)**
   - Simple week-over-week change flag for late delivery rate

## QGIS workflow (high level)
1) Connect QGIS to PostgreSQL
2) Load the area rollup result as a layer (query layer or a saved view)
3) Join to a boundary layer (if available) OR symbolize by city/state and label the top problem areas
4) Style by p90 delay (graduated) and late_count (labels)

## Output
- Screenshot(s) will be added here after styling (map + legend + notes).

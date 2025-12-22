# GIS / QGIS Work

This folder contains QGIS outputs built from the PostgreSQL tables/views created in this repo (Olist dataset).

## What I’m mapping
- Late delivery intensity by area (state / city / zip prefix)
- “Outlier” areas with unusually high delay (p90 delay-based)
- Week-over-week on-time trend by state

## Data source
PostgreSQL schema: `olist`
Key tables/views used:
- `olist.orders_delays` (delivery delay in days vs estimated date)
- `olist.deliveries_fact` (aggregated metrics)
- SQL scripts in `/sql/advanced` generate the map-ready outputs

## Outputs (to be added)
- `/gis/exports/` → CSV exports for QGIS joins
- `/gis/maps/` → QGIS project + rendered map images

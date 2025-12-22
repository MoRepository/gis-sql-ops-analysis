# QGIS

This folder covers the QGIS side of the project — turning my SQL outputs into map-ready layers and simple deliverables (PNG/PDF).

## What I do in QGIS (the point of this folder)
- Bring in rollups exported from PostgreSQL (CSV)
- Join them to a boundary layer using a shared key (usually a location code / prefix)
- Style and label problem areas so patterns are obvious fast
- Export maps for “ops-style” reporting (quick to read, not over-designed)

## Typical workflow I follow
1. Export SQL result to CSV (from pgAdmin)
2. Add CSV to QGIS
3. Add boundary layer (zip/area polygons)
4. Join: boundary layer → CSV
5. QA check: join rate + nulls + “does this look reasonable?”
6. Style: graduated colors by KPI (delay, on-time %, etc.)
7. Export map(s) as PNG/PDF

## Repo note
I’m not committing large/raw datasets here.
This repo focuses on the queries + the repeatable steps for mapping the outputs.

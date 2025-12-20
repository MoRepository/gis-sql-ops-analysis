
-- Late delivery outliers (Olist / PostgreSQL)
-- Uses: olist.orders_delays (must include delay_days + customer_state/city/zip_prefix)
-- Note: thresholds are tuned for Olist at ZIP-prefix granularity.
-- If this returns 0 rows, lower late_deliveries >= 10 to >= 5, or change cutoff from 0.90 to 0.85.

WITH area_rollup AS (
  SELECT
    customer_state,
    customer_city,
    customer_zip_code_prefix,
    COUNT(*) AS delivered_count,

    -- late-only metrics (delay_days > 0)
    COUNT(*) FILTER (WHERE delay_days > 0) AS late_deliveries,
    AVG(delay_days) FILTER (WHERE delay_days > 0)::numeric(10,2) AS avg_late_delay_days,
    percentile_cont(0.90) WITHIN GROUP (ORDER BY delay_days)
      FILTER (WHERE delay_days > 0) AS p90_late_delay_days

  FROM olist.orders_delays
  GROUP BY 1,2,3

  -- Stability + enough late rows to compute a meaningful p90
  HAVING COUNT(*) >= 50
     AND COUNT(*) FILTER (WHERE delay_days > 0) >= 10
),
cutoff AS (
  SELECT
    percentile_cont(0.90) WITHIN GROUP (ORDER BY p90_late_delay_days) AS outlier_cutoff
  FROM area_rollup
),
ranked AS (
  SELECT
    a.*,
    DENSE_RANK() OVER (ORDER BY p90_late_delay_days DESC) AS p90_rank
  FROM area_rollup a
)
SELECT
  r.customer_state,
  r.customer_city,
  r.customer_zip_code_prefix,
  r.delivered_count,
  r.late_deliveries,
  r.avg_late_delay_days,
  r.p90_late_delay_days,
  r.p90_rank,
  c.outlier_cutoff
FROM ranked r
CROSS JOIN cutoff c
WHERE r.p90_late_delay_days >= c.outlier_cutoff
ORDER BY r.p90_late_delay_days DESC, r.delivered_count DESC
LIMIT 50;



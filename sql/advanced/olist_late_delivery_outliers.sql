-- Requires: Postgres
-- Uses: olist.orders_delays (a view/table that includes delay_days + customer location fields)
-- Output: areas (state/city/zip_prefix) whose p90 delay is extreme vs global distribution

WITH area_rollup AS (
  SELECT
    customer_state,
    customer_city,
    customer_zip_code_prefix,
    COUNT(*) AS delivered_count,
    AVG(delay_days)::numeric(10,2) AS avg_delay_days,
    percentile_cont(0.90) WITHIN GROUP (ORDER BY delay_days) AS p90_area_delay
  FROM olist.orders_delays
  -- focus on LATE deliveries only (delay > 0). remove this line if you want early+late together.
  WHERE delay_days > 0
  GROUP BY 1,2,3
  HAVING COUNT(*) >= 50
),
stats AS (
  SELECT
    percentile_cont(0.95) WITHIN GROUP (ORDER BY p90_area_delay) AS global_p95_p90_area_delay,
    percentile_cont(0.99) WITHIN GROUP (ORDER BY p90_area_delay) AS global_p99_p90_area_delay
  FROM area_rollup
),
ranked_areas AS (
  SELECT
    a.*,
    DENSE_RANK() OVER (ORDER BY p90_area_delay DESC) AS p90_rank
  FROM area_rollup a
)
SELECT
  r.customer_state,
  r.customer_city,
  r.customer_zip_code_prefix,
  r.delivered_count,
  r.avg_delay_days,
  r.p90_area_delay,
  r.p90_rank,
  s.global_p95_p90_area_delay,
  s.global_p99_p90_area_delay
FROM ranked_areas r
CROSS JOIN stats s
WHERE r.p90_area_delay >= s.global_p95_p90_area_delay
ORDER BY r.p90_area_delay DESC, r.delivered_count DESC
LIMIT 50;

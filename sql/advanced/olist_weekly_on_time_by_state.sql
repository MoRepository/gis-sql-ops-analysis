-- Olist (PostgreSQL): Weekly on-time delivery % by customer_state + 4-week moving average
-- Requires: olist.deliveries_fact view (orders joined to customers)
-- Verified on local import: 99,441 orders; on_time non-null: 96,476

WITH weekly AS (
  SELECT
    customer_state,
    date_trunc('week', order_purchase_timestamp)::date AS week_start,
    COUNT(*) FILTER (WHERE on_time IS NOT NULL) AS delivered_count,
    COUNT(*) FILTER (WHERE on_time = 1) AS on_time_delivered_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE on_time = 1)
      / NULLIF(COUNT(*) FILTER (WHERE on_time IS NOT NULL), 0),
      1
    ) AS on_time_pct
  FROM olist.deliveries_fact
  GROUP BY customer_state, week_start
)
SELECT
  customer_state,
  week_start,
  delivered_count,
  on_time_delivered_count,
  on_time_pct,
  ROUND(
    AVG(on_time_pct) OVER (
      PARTITION BY customer_state
      ORDER BY week_start
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ),
    1
  ) AS on_time_pct_4wk_ma
FROM weekly
ORDER BY customer_state, week_start;

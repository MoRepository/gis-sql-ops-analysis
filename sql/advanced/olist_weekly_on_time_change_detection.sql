-- Weekly on-time % trend + change detection (Olist / PostgreSQL)
-- Uses: olist.orders_enriched (must include purchase timestamp + delivered + estimated + customer_state)

WITH delivered AS (
  SELECT
    customer_state,
    date_trunc('week', order_purchase_timestamp)::date AS week_start,
    CASE
      WHEN order_delivered_customer_date IS NULL THEN NULL
      WHEN order_estimated_delivery_date IS NULL THEN NULL
      WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
      ELSE 0
    END AS on_time_flag
  FROM olist.orders_enriched
),
weekly AS (
  SELECT
    customer_state,
    week_start,
    COUNT(*) FILTER (WHERE on_time_flag IS NOT NULL) AS delivered_count,
    COUNT(*) FILTER (WHERE on_time_flag = 1) AS on_time_delivered_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE on_time_flag = 1)
      / NULLIF(COUNT(*) FILTER (WHERE on_time_flag IS NOT NULL), 0),
      1
    ) AS on_time_pct
  FROM delivered
  GROUP BY 1,2
  HAVING COUNT(*) FILTER (WHERE on_time_flag IS NOT NULL) >= 50
),
trend AS (
  SELECT
    customer_state,
    week_start,
    delivered_count,
    on_time_pct,
    ROUND(
      AVG(on_time_pct) OVER (
        PARTITION BY customer_state
        ORDER BY week_start
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
      ),
      1
    ) AS on_time_pct_4wk_ma,
    LAG(on_time_pct) OVER (
      PARTITION BY customer_state
      ORDER BY week_start
    ) AS prev_week_on_time_pct
  FROM weekly
)
SELECT
  customer_state,
  week_start,
  delivered_count,
  on_time_pct,
  on_time_pct_4wk_ma,
  prev_week_on_time_pct,
  ROUND(on_time_pct - prev_week_on_time_pct, 1) AS wow_change_pct,
  CASE
    WHEN prev_week_on_time_pct IS NULL THEN NULL
    WHEN (on_time_pct - prev_week_on_time_pct) <= -10 THEN 'DROP >= 10 pts'
    WHEN (on_time_pct - prev_week_on_time_pct) >= 10 THEN 'RISE >= 10 pts'
    ELSE NULL
  END AS change_flag
FROM trend
ORDER BY customer_state, week_start;

-- Weekly cancellation rate by customer_state (Olist / PostgreSQL)
-- Uses: olist.orders_enriched (order_status + order_purchase_timestamp + customer_state)

WITH weekly AS (
  SELECT
    customer_state,
    date_trunc('week', order_purchase_timestamp)::date AS week_start,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_status = 'canceled') AS canceled_orders,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE order_status = 'canceled') / NULLIF(COUNT(*), 0),
      2
    ) AS cancel_rate_pct
  FROM olist.orders_enriched
  GROUP BY 1,2
  HAVING COUNT(*) >= 50
),
trend AS (
  SELECT
    customer_state,
    week_start,
    total_orders,
    canceled_orders,
    cancel_rate_pct,
    ROUND(
      AVG(cancel_rate_pct) OVER (
        PARTITION BY customer_state
        ORDER BY week_start
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
      ),
      2
    ) AS cancel_rate_pct_4wk_ma,
    LAG(cancel_rate_pct) OVER (
      PARTITION BY customer_state
      ORDER BY week_start
    ) AS prev_week_cancel_rate_pct
  FROM weekly
)
SELECT
  customer_state,
  week_start,
  total_orders,
  canceled_orders,
  cancel_rate_pct,
  cancel_rate_pct_4wk_ma,
  prev_week_cancel_rate_pct,
  ROUND(cancel_rate_pct - prev_week_cancel_rate_pct, 2) AS wow_change_pct
FROM trend
ORDER BY customer_state, week_start;

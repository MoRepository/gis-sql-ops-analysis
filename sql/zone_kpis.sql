-- Zone KPI summary (generic SQL)
SELECT
  location AS zone,
  COUNT(*) AS total_deliveries,
  SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered_count,
  SUM(CASE WHEN status = 'delivered' AND on_time = 1 THEN 1 ELSE 0 END) AS on_time_delivered_count,
  ROUND(
    100.0 * SUM(CASE WHEN status = 'delivered' AND on_time = 1 THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END), 0),
    1
  ) AS on_time_percentage
FROM deliveries
GROUP BY location
ORDER BY on_time_percentage ASC, total_deliveries DESC;

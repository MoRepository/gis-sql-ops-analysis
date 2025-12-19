-- Flag zones below an on-time threshold using a CTE (generic SQL)
WITH zone_summary AS (
  SELECT
    location AS zone,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) AS delivered_count,
    SUM(CASE WHEN status = 'delivered' AND on_time = 1 THEN 1 ELSE 0 END) AS on_time_delivered_count,
    100.0 * SUM(CASE WHEN status = 'delivered' AND on_time = 1 THEN 1 ELSE 0 END)
      / NULLIF(SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END), 0) AS on_time_percentage
  FROM deliveries
  GROUP BY location
)
SELECT *
FROM zone_summary
WHERE on_time_percentage < 50
ORDER BY on_time_percentage ASC;

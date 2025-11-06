DROP VIEW IF EXISTS median_price_per_district;
CREATE VIEW IF NOT EXISTS median_price_per_district AS 
SELECT district, ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid
GROUP BY district;

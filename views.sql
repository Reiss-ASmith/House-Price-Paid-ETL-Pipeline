DROP VIEW IF EXISTS median_price_per_district;
CREATE VIEW median_price_per_district AS 
SELECT district, ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid
GROUP BY district;

DROP VIEW IF EXISTS median_price_per_county;
CREATE VIEW median_price_per_county AS
SELECT county, ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid
GROUP BY county;

DROP VIEW IF EXISTS median_price_per_month;
CREATE VIEW median_price_per_month AS
SELECT EXTRACT('MONTH' FROM "date") AS "Month", ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid
GROUP BY EXTRACT('MONTH' FROM "date");
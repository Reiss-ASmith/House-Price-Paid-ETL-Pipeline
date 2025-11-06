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

DROP VIEW IF EXISTS total_sales_per_district;
CREATE VIEW total_sales_per_district AS
SELECT district, COUNT(*) AS total_house_sales
FROM house_data.house_price_paid
GROUP BY district;

DROP VIEW IF EXISTS total_sales_per_county;
CREATE VIEW total_sales_per_county AS
SELECT county, COUNT(*) AS total_house_sales
FROM house_data.house_price_paid
GROUP BY county;

DROP VIEW IF EXISTS total_sales_per_month;
CREATE VIEW total_sales_per_month AS
SELECT EXTRACT('MONTH' FROM "date") AS "Month", COUNT(*) AS total_house_sales
FROM house_data.house_price_paid
GROUP BY EXTRACT('MONTH' FROM "date");
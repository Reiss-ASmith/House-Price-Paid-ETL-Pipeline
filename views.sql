DROP VIEW IF EXISTS median_price_per_district_2025;
CREATE VIEW median_price_per_district_2025 AS 
SELECT lad23cd, district, ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid_2025 AS p
JOIN house_data.districts AS d ON d.district_id = p.district_id
GROUP BY district, lad23cd;

DROP VIEW IF EXISTS median_price_per_county_2025;
CREATE VIEW median_price_per_county_2025 AS
SELECT county, ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid_2025 AS p
JOIN house_data.districts AS d ON d.district_id = p.district_id
JOIN house_data.counties AS c ON c.county_id = d.county_id
GROUP BY county;

DROP VIEW IF EXISTS median_price_per_month_2025;
CREATE VIEW median_price_per_month_2025 AS
SELECT EXTRACT('MONTH' FROM "date") AS "Month", ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid_2025
GROUP BY EXTRACT('MONTH' FROM "date");

DROP VIEW IF EXISTS total_sales_per_district_2025;
CREATE VIEW total_sales_per_district_2025 AS
SELECT lad23cd, district, COUNT(*) AS total_house_sales
FROM house_data.house_price_paid_2025 AS p
JOIN house_data.districts AS d ON d.district_id = p.district_id
GROUP BY district, lad23cd;

DROP VIEW IF EXISTS total_sales_per_county_2025;
CREATE VIEW total_sales_per_county_2025 AS
SELECT county, COUNT(*) AS total_house_sales
FROM house_data.house_price_paid_2025 AS p
JOIN house_data.districts AS d ON d.district_id = p.district_id
JOIN house_data.counties AS c ON c.county_id = d.county_id
GROUP BY county;

DROP VIEW IF EXISTS total_sales_per_month_2025;
CREATE VIEW total_sales_per_month_2025 AS
SELECT EXTRACT('MONTH' FROM "date") AS "Month", COUNT(*) AS total_house_sales
FROM house_data.house_price_paid_2025
GROUP BY EXTRACT('MONTH' FROM "date");

DROP VIEW IF EXISTS median_price_per_year;
CREATE VIEW median_price_per_year AS
SELECT EXTRACT('YEAR' FROM "date") AS "Year", ROUND(percentile_cont(0.5) WITHIN GROUP(ORDER BY price)::numeric, 2) AS median_price
FROM house_data.house_price_paid
GROUP BY EXTRACT('YEAR' FROM "date");

DROP VIEW IF EXISTS median_price_per_district_per_year;
CREATE VIEW median_price_per_district_per_year AS
SELECT d.lad23cd, d.district, EXTRACT(YEAR FROM p."date")::int AS year, percentile_cont(0.5) WITHIN GROUP (ORDER BY p.price)::numeric AS median_price
FROM house_data.house_price_paid p
JOIN house_data.districts d ON d.district_id = p.district_id
GROUP BY d.lad23cd, d.district, EXTRACT(YEAR FROM p."date");
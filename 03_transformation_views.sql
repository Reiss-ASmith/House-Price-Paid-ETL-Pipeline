--Creates view for the median price of a house sold in each district every year
CREATE OR REPLACE VIEW house_data.v_median_price_per_district_year AS
SELECT
    d.lad23cd,
    d.district,
    EXTRACT(YEAR FROM p."date")::int AS year,
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY p.price)::numeric, 2) AS median_price
FROM house_data.house_price_paid p
JOIN house_data.districts d ON d.district_id = p.district_id
GROUP BY d.lad23cd, d.district, EXTRACT(YEAR FROM p."date");

--Creates view for the median price of a house sold in each county every year
CREATE OR REPLACE VIEW house_data.v_median_price_per_county_year AS
SELECT
    c.county,
    EXTRACT(YEAR FROM p."date")::int AS year,
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY p.price)::numeric, 2) AS median_price
FROM house_data.house_price_paid p
JOIN house_data.districts d ON d.district_id = p.district_id
JOIN house_data.counties c ON c.county_id = d.county_id
GROUP BY c.county, EXTRACT(YEAR FROM p."date");

--Creates view that shows the median price per month of each year
CREATE OR REPLACE VIEW house_data.v_median_price_per_month_year AS
SELECT
    EXTRACT(YEAR FROM p."date")::int  AS year,
    EXTRACT(MONTH FROM p."date")::int AS month,
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY p.price)::numeric, 2) AS median_price
FROM house_data.house_price_paid p
GROUP BY EXTRACT(YEAR FROM p."date"), EXTRACT(MONTH FROM p."date");

--Creates a view that shows the total number of sales per district each year
CREATE OR REPLACE VIEW house_data.v_total_sales_per_district_year AS
SELECT
    d.lad23cd,
    d.district,
    EXTRACT(YEAR FROM p."date")::int AS year,
    COUNT(*) AS total_house_sales
FROM house_data.house_price_paid p
JOIN house_data.districts d ON d.district_id = p.district_id
GROUP BY d.lad23cd, d.district, EXTRACT(YEAR FROM p."date");

--Creates a view that shows the total number of house sales per county each year
CREATE OR REPLACE VIEW house_data.v_total_sales_per_county_year AS
SELECT
    c.county,
    EXTRACT(YEAR FROM p."date")::int AS year,
    COUNT(*) AS total_house_sales
FROM house_data.house_price_paid p
JOIN house_data.districts d ON d.district_id = p.district_id
JOIN house_data.counties c ON c.county_id = d.county_id
GROUP BY c.county, EXTRACT(YEAR FROM p."date");

--Creates a view that shows the median house sale price per year across England & Wales
CREATE OR REPLACE VIEW house_data.v_median_price_per_year AS
SELECT
    EXTRACT(YEAR FROM p."date")::int AS year,
    ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY p.price)::numeric, 2) AS median_price
FROM house_data.house_price_paid p
GROUP BY EXTRACT(YEAR FROM p."date");


-- ranks the median house sale of each district per month

CREATE OR REPLACE VIEW house_data.v_median_price_per_district_ranked AS
with median_prices AS (
    SELECT
        DATE_TRUNC('month', p."date")::date AS month_start,
        d.district as district_name,
        ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY p.price)::numeric, 2) AS median_price
    FROM house_data.house_price_paid p
    JOIN house_data.districts d ON d.district_id = p.district_id
    GROUP BY DATE_TRUNC('month', p."date")::date, d.district
    )
SELECT
    district_name,
    median_price,
    EXTRACT(YEAR FROM month_start)::int AS year,
    EXTRACT(MONTH FROM month_start)::int AS month,
    DENSE_RANK() OVER(PARTITION BY month_start ORDER BY median_price DESC) AS median_price_rank
FROM median_prices;

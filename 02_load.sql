-- CREATING A VIEW THAT COMBINES THE HOUSE DATA TABLES IN THE RAW SCHEMA
CREATE OR REPLACE VIEW raw_house_data.house_price_paid_full AS 
SELECT * FROM raw_house_data.house_price_paid
UNION ALL
SELECT * FROM raw_house_data.house_price_paid_monthly_update;

-- INSERTING DATA INTO TABLES
--inserts data into the county table
INSERT INTO house_data.counties(county)
SELECT DISTINCT county
FROM raw_house_data.house_price_paid_full
ON CONFLICT (county) DO NOTHING;

--inserts data into the districts table by joining three tables together for the required columns
INSERT INTO house_data.districts(lad23cd, district, county_id)
SELECT DISTINCT lad.LAD23CD, r.district, co.county_id
FROM raw_house_data.house_price_paid_full AS r
JOIN house_data.counties AS co ON co.county = r.county
JOIN raw_house_data.local_authority_districts_map AS lad ON UPPER(TRIM(lad.LAD23NM)) = UPPER(TRIM(r.district))
ON CONFLICT (lad23cd) DO NOTHING;

--inserts data into the property_types table
INSERT INTO house_data.property_types(property_type, property_type_code)
VALUES
    ('Detached', 'D'),
    ('Semi-Detached', 'S'),
    ('Terraced', 'T'),
    ('Flat/Maisonette', 'F'),
    ('Other', 'O')
ON CONFLICT (property_type_code) DO NOTHING;

--inserts data into the tenures table
INSERT INTO house_data.tenures(tenure_code, tenure_name)
VALUES
    ('F', 'Freehold'),
    ('L', 'Leasehold'),
    ('U', 'Unknown')
ON CONFLICT (tenure_code) DO NOTHING;

--inserts data into the house_price_paid table by using columns from two tables
INSERT INTO house_data.house_price_paid(sale_id, price, "date", property_type_code, new_build, district_id, tenure_code)
SELECT r.sale_id,
r.price,
CAST(r."datetime" AS DATE),
r.property_type,
(r.new_build = 'Y'),
d.district_id,
r.tenure
FROM raw_house_data.house_price_paid_full AS r 
JOIN house_data.districts as d ON UPPER(TRIM(d.district)) = UPPER(TRIM(r.district))
ON CONFLICT (sale_id, "date") DO NOTHING;
--clears the database
DROP SCHEMA IF EXISTS house_data CASCADE;
DROP SCHEMA IF EXISTS raw_house_data CASCADE;

--creates schemas for data imports
CREATE SCHEMA IF NOT EXISTS house_data;
CREATE SCHEMA IF NOT EXISTS raw_house_data;

--changes date format from YYYY/MM/DD to DD/MM/YYYY
SET DateStyle TO 'European';

-- TABLE CREATION FOR THE TABLES IN RAW_HOUSE_DATA SCHEMA
--creates a temporary table used to store the raw data from the local_authority_district_map file later
CREATE TABLE IF NOT EXISTS raw_house_data.local_authority_districts_map (
    Fid int NOT NULL UNIQUE,
    LAD23CD varchar(9) NOT NULL UNIQUE,
    LAD23NM TEXT NOT NULL UNIQUE,
    LAD23NMW TEXT,
    BNG_E int NOT NULL,
    BNG_N int NOT NULL,
    LONG DOUBLE PRECISION NOT NULL,
    LAT DOUBLE PRECISION NULL,
    Shape_Area DOUBLE PRECISION NOT NULL,
    Shape_Length DOUBLE PRECISION NOT NULL,
    GlobalID TEXT not null,
    PRIMARY KEY(LAD23NM)
);

--creates a temporary table used to store the raw data from the house price paid files files later
CREATE TABLE IF NOT EXISTS raw_house_data.house_price_paid (
    sale_id TEXT NOT NULL UNIQUE,
    price INT NOT NULL,
    "datetime" TEXT NOT NULL,
    postcode VARCHAR(10),
    property_type CHAR(1) NOT NULL,
    new_build CHAR(1) NOT NULL,
    tenure CHAR(1) NOT NULL,
    PAON TEXT NOT NULL,
    SAON TEXT,
    street TEXT,
    locality TEXT,
    town_city TEXT NOT NULL,
    district TEXT NOT NULL,
    county TEXT NOT NULL,
    PPD_category CHAR(1) NOT NULL,
    record_status CHAR(1) NOT NULL
);

--imports files into tables above
COPY raw_house_data.local_authority_districts_map FROM '/imports/local_authority_districts_map.csv' WITH DELIMITER ',' csv HEADER;
COPY raw_house_data.house_price_paid FROM '/imports/pp-2025.csv' DELIMITER ',' csv HEADER;

-- TABLE CREATION FOR THE TABLES IN THE HOUSE_DATA SCHEMA
--creates a counties table
CREATE TABLE IF NOT EXISTS house_data.counties (
    county_id SMALLSERIAL PRIMARY KEY,
    county TEXT NOT NULL
);

--creates a table to act as a key explaining the property type codes
CREATE TABLE IF NOT EXISTS house_data.property_types (
    property_type VARCHAR(32) NOT NULL,
    property_type_code CHAR(1) PRIMARY KEY
);

--creates a table to act as a key explaining the property tenure
CREATE TABLE IF NOT EXISTS house_data.tenures (
    tenure_code CHAR(1) PRIMARY KEY,
    tenure_name VARCHAR(10) NOT NULL
);

--creates a table to store district information that references the county table
CREATE TABLE IF NOT EXISTS house_data.districts (
    district_id SMALLSERIAL PRIMARY KEY,
    lad23cd VARCHAR(9) UNIQUE NOT NULL,
    district TEXT NOT NULL,
    county_id INT REFERENCES house_data.counties(county_id)
);

--creates a table for the house price paid data that references other tables
CREATE TABLE IF NOT EXISTS house_data.house_price_paid (
    sale_id TEXT PRIMARY KEY,
    price INT NOT NULL,
    "date" DATE NOT NULL,
    property_type_code CHAR(1) REFERENCES house_data.property_types(property_type_code),
    new_build BOOLEAN NOT NULL,
    district_id INT REFERENCES house_data.districts(district_id),
    tenure_code CHAR(1) REFERENCES house_data.tenures(tenure_code)
);

-- INSERTING DATA INTO TABLES
--inserts data into the county table
INSERT INTO house_data.counties(county)
SELECT DISTINCT county
FROM raw_house_data.house_price_paid;

--inserts data into the districts table by joining three tables together for the required columns
INSERT INTO house_data.districts(lad23cd, district, county_id)
SELECT DISTINCT lad.LAD23CD, r.district, co.county_id
FROM raw_house_data.house_price_paid AS r
JOIN house_data.counties AS co ON co.county = r.county
JOIN raw_house_data.local_authority_districts_map AS lad ON UPPER(TRIM(lad.LAD23NM)) = UPPER(TRIM(r.district));

--inserts data into the property_types table
INSERT INTO house_data.property_types(property_type, property_type_code)
VALUES
('Detached', 'D'),
('Semi-Detached', 'S'),
('Terraced', 'T'),
('Flat/Maisonette', 'F'),
('Other', 'O');

--inserts data into the tenures table
INSERT INTO house_data.tenures(tenure_code, tenure_name)
VALUES
('F', 'Freehold'),
('L', 'Leasehold');

INSERT INTO house_data.house_price_paid(sale_id, price, "date", property_type_code, new_build, district_id, tenure_code)
SELECT r.sale_id,
r.price,
CAST(r."datetime" AS DATE),
r.property_type,
(r.new_build = 'Y'),
d.district_id,
r.tenure
FROM raw_house_data.house_price_paid AS r 
JOIN house_data.districts as d ON UPPER(TRIM(d.district)) = UPPER(TRIM(r.district));

--deletes the raw_house_data schema
DROP SCHEMA IF EXISTS raw_house_data CASCADE;
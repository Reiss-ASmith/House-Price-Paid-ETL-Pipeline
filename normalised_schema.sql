--clears the database
DROP SCHEMA IF EXISTS house_data CASCADE;
DROP SCHEMA IF EXISTS raw_house_data CASCADE;

--creates schemas for data imports
CREATE SCHEMA IF NOT EXISTS house_data;
CREATE SCHEMA IF NOT EXISTS raw_house_data;

SET DateStyle TO 'European';

-- raw_house_data schema creation
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

CREATE TABLE IF NOT EXISTS house_data.counties (
    county_id SMALLSERIAL PRIMARY KEY,
    county TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS house_data.property_types (
    property_type VARCHAR(32) NOT NULL,
    property_type_code CHAR(1) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS house_data.tenures (
    tenure_code CHAR(1) PRIMARY KEY,
    tenure_name VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS house_data.districts (
    district_id SMALLSERIAL PRIMARY KEY,
    lad23cd VARCHAR(9) UNIQUE NOT NULL,
    district TEXT NOT NULL,
    county_id INT REFERENCES house_data.counties(county_id)
);

CREATE TABLE IF NOT EXISTS house_data.house_price_paid (
    sale_id TEXT PRIMARY KEY,
    price INT NOT NULL,
    "date" DATE NOT NULL,
    property_type_code CHAR(1) REFERENCES house_data.property_types(property_type_code),
    new_build BOOLEAN NOT NULL,
    district_id INT REFERENCES house_data.districts(district_id),
    tenure_code CHAR(1) REFERENCES house_data.tenures(tenure_code)
);

INSERT INTO house_data.counties(county)
SELECT DISTINCT county
FROM raw_house_data.house_price_paid;

WITH district_table_data AS(
    SELECT DISTINCT r.district AS district, r.county, co.county_id, lad.LAD23CD
    FROM raw_house_data.house_price_paid AS r
    JOIN house_data.counties AS co ON co.county = r.county
    JOIN raw_house_data.local_authority_districts_map AS lad ON UPPER(TRIM(lad.LAD23NM)) = r.district
)
 INSERT INTO house_data.districts(lad23cd, district, county_id)
 SELECT LAD23CD, district, county_id
 FROM district_table_data;

INSERT INTO house_data.property_types(property_type, property_type_code)
VALUES
('Detached', 'D'),
('Semi-Detached', 'S'),
('Terraced', 'T'),
('Flat/Maisonette', 'F'),
('Other', 'O');

INSERT INTO house_data.tenures(tenure_code, tenure_name)
VALUES
('F', 'Freehold'),
('L', 'Leasehold');
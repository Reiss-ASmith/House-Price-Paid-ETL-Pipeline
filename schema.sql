DROP SCHEMA IF EXISTS house_data CASCADE;
DROP SCHEMA IF EXISTS raw_house_data CASCADE;
CREATE SCHEMA IF NOT EXISTS house_data;
CREATE SCHEMA IF NOT EXISTS raw_house_data;

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

COPY raw_house_data.local_authority_districts_map FROM '/imports/local_authority_districts_map.csv' WITH DELIMITER ',' csv HEADER;

CREATE TABLE house_data.local_authority_districts_map AS
SELECT Fid,
LAD23CD,
UPPER(TRIM(LAD23NM)) AS LAD23NM,
LAD23NMW,
BNG_E,
BNG_N,
LONG,
LAT,
Shape_Area,
Shape_Length,
GlobalID
FROM raw_house_data.local_authority_districts_map;

ALTER TABLE house_data.local_authority_districts_map ADD PRIMARY KEY (LAD23NM);

SET DateStyle TO 'European';

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

CREATE TABLE IF NOT EXISTS house_data.house_price_paid (
    sale_id TEXT NOT NULL UNIQUE,
    price INT NOT NULL,
    "date" DATE NOT NULL,
    property_type CHAR(1) NOT NULL,
    new_build BOOLEAN NOT NULL,
    district TEXT NOT NULL,
    county TEXT NOT NULL,
    FOREIGN KEY(district) REFERENCES house_data.local_authority_districts_map (LAD23NM)
);

COPY raw_house_data.house_price_paid FROM '/imports/pp-2025.csv' DELIMITER ',' csv HEADER;

INSERT INTO house_data.house_price_paid(sale_id, price, "date", property_type, new_build, district, county)
SELECT sale_id,
price,
CAST("datetime" AS DATE) as "date",
property_type,
(new_build = 'Y') AS new_build,
UPPER(TRIM(district)) AS district,
county
FROM raw_house_data.house_price_paid;

DROP INDEX IF EXISTS district_index;
DROP INDEX IF EXISTS date_index;
CREATE INDEX IF NOT EXISTS district_index ON house_data.house_price_paid ("district");
CREATE INDEX IF NOT EXISTS date_index ON house_data.house_price_paid ("date");

DROP TABLE raw_house_data.house_price_paid;
DROP TABLE raw_house_data.local_authority_districts_map;

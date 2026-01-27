
--creates schemas for data imports
CREATE SCHEMA IF NOT EXISTS house_data;
CREATE SCHEMA IF NOT EXISTS raw_house_data;

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
    "datetime" TIMESTAMP NOT NULL,
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

CREATE TABLE IF NOT EXISTS raw_house_data.house_price_paid_monthly_update (
    LIKE raw_house_data.house_price_paid INCLUDING ALL
);

-- TABLE CREATION FOR THE TABLES IN THE HOUSE_DATA SCHEMA
--creates a counties table
CREATE TABLE IF NOT EXISTS house_data.counties (
    county_id SMALLSERIAL UNIQUE PRIMARY KEY,
    county TEXT UNIQUE NOT NULL
);

--creates a table to act as a key explaining the property type codes
CREATE TABLE IF NOT EXISTS house_data.property_types (
    property_type VARCHAR(32) UNIQUE NOT NULL,
    property_type_code CHAR(1) UNIQUE PRIMARY KEY
);

--creates a table to act as a key explaining the property tenure
CREATE TABLE IF NOT EXISTS house_data.tenures (
    tenure_code CHAR(1) UNIQUE PRIMARY KEY,
    tenure_name VARCHAR(10) UNIQUE NOT NULL
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
    sale_id TEXT NOT NULL,
    price INT NOT NULL,
    "date" DATE NOT NULL,
    property_type_code CHAR(1) REFERENCES house_data.property_types(property_type_code),
    new_build BOOLEAN NOT NULL,
    district_id INT REFERENCES house_data.districts(district_id),
    tenure_code CHAR(1) REFERENCES house_data.tenures(tenure_code),
    PRIMARY KEY (sale_id, "date")
) PARTITION BY RANGE("date");

--partitions the house_price_paid table by year
DO $$
DECLARE
    y int;
    end_year int := extract(year from current_date)::int + 1;
BEGIN
    FOR y IN 1995..end_year LOOP
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS house_data.house_price_paid_%s
            PARTITION OF house_data.house_price_paid
            FOR VALUES FROM (%L) TO (%L);',
            y,
            make_date(y, 1, 1),
            make_date(y+1, 1, 1)
        );
    END LOOP;
END $$;

--creates index on the date column in the house_price_paid table
CREATE INDEX IF NOT EXISTS date_index ON house_data.house_price_paid ("date");

--creates index on the district id column in the house_price_paid table
CREATE INDEX IF NOT EXISTS district_id_index ON house_data.house_price_paid (district_id);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
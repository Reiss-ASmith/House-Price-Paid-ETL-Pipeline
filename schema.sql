CREATE TABLE IF NOT EXISTS local_authority_districts_map (
    Fid int NOT NULL UNIQUE,
    LAD23CD varchar(9) NOT NULL UNIQUE,
    LAD23NM VARCHAR(32) NOT NULL UNIQUE,
    LAD23NMW VARCHAR(32),
    BNG_E int NOT NULL,
    BNG_N int NOT NULL,
    LONG REAL NOT NULL,
    LAT REAL NOT NULL,
    Shape_Area REAL NOT NULL,
    Shape_Length REAL NOT NULL,
    GlobalID TEXT not null,
    PRIMARY KEY("LAD23NM")
);

\copy local_authority_districts_map FROM 'local_authority_districts_map.csv' DELIMITER ',' csv HEADER;


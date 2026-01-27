import logging
from db import get_connection

log = logging.getLogger(__name__)

#A function thats used to run each SQL file
def run_sql_file(cursor, filename):
    log.info("Executing SQL file: %s", filename)
    with open(filename, "r", encoding="utf-8") as f:
        sql = f.read().strip()
        if sql:
            cursor.execute(sql)

#A function that creates the database schema when called
def create_db_schema():
    log.info("Attempting to create schema")
    with get_connection() as conn:
        with conn.cursor() as cur:
            run_sql_file(cur, "00_schema.sql")
        conn.commit()
    log.info("Schema creation complete")

#A function that moves the complete-pp.csv data from disk to the Postgres database
def copy_complete_data():
    log.info("Truncating raw_house_data.house_price_paid")
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE raw_house_data.house_price_paid;")
            log.info("Copying pp-complete.csv to raw_house_data.house_price_paid")
            with open("./data/pp-complete.csv", "r", encoding="utf-8", newline="") as complete_data:
                cur.copy_expert(
                    """
                    COPY raw_house_data.house_price_paid
                    FROM STDIN
                    WITH (FORMAT csv, HEADER false)
                    """, complete_data
                )
        conn.commit()
    log.info("Raw full load complete")

#A function that moves the pp-monthly_update_new_version.csv data from disk to the Postgres database
def copy_monthly_update_data():
    log.info("Truncating raw_house_data.house_price_paid_monthly_update")
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE raw_house_data.house_price_paid_monthly_update")
            log.info("Copying pp-monthly_update_new_version.csv to raw_house_data.house_price_paid_monthly_update")
            with open("./data/pp-monthly-update-new-version.csv", "r", encoding="utf-8", newline="") as monthly_update:
                cur.copy_expert(
                    """
                    COPY raw_house_data.house_price_paid_monthly_update
                    FROM STDIN
                    WITH (FORMAT csv, HEADER false)
                    """, monthly_update
                )
        conn.commit()
    log.info("Raw monthly load complete")

#A function that moves the local_authority_districts_map.csv data from disk to the Postgres database
def copy_map_data():
    log.info("Truncating raw_house_data.local_authority_districts_map")
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE raw_house_data.local_authority_districts_map;")
            log.info("Copying local_authority_districts_map.csv to raw_house_data.local_authority_districts_map")
            with open("./data/local_authority_districts_map.csv", "r", encoding="utf-8", newline="") as local_map:
                cur.copy_expert(
                    """
                    COPY raw_house_data.local_authority_districts_map
                    FROM STDIN
                    WITH (FORMAT csv, HEADER true)
                    """, local_map
                )
        conn.commit()
    log.info("Raw district map load complete")

#A function that runs the 02_load.sql file which moves data from the raw schema to the core schema
def load_from_raw():
    log.info("Loading core tables from raw (02_load.sql)")
    with get_connection() as conn:
        with conn.cursor() as cur:
            run_sql_file(cur, "02_load.sql")
        conn.commit()
    log.info("Core load complete")
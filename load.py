from db import get_connection

def run_sql_file(cursor, filename):
    with open(filename, "r", encoding="utf-8") as f:
        sql = f.read().strip()
        if sql:
            cursor.execute(sql)

def create_db_schema():
    with get_connection() as conn:
        with conn.cursor() as cur:
            run_sql_file(cur, "00_schema.sql")
        conn.commit()

def copy_complete_data():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE raw_house_data.house_price_paid;")
            with open("./data/pp-complete.csv", "r", encoding="utf-8", newline="") as complete_data:
                cur.copy_expert(
                    """
                    COPY raw_house_data.house_price_paid
                    FROM STDIN
                    WITH (FORMAT csv, HEADER false)
                    """, complete_data
                )
        conn.commit()

def copy_monthly_update_data():
    with get_connection() as conn:
        with conn.cursor() as cur:
            with open("./data/pp-monthly-update-new-version.csv") as monthly_update:
                cur.copy_expert(
                    """
                    COPY raw_house_data.house_price_paid_monthly_update
                    FROM STDIN
                    WITH (FORMAT csv, HEADER false)
                    """, monthly_update
                )

def copy_map_data():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE raw_house_data.local_authority_districts_map;")
            with open("./data/local_authority_districts_map.csv", "r", encoding="utf-8", newline="") as local_map:
                cur.copy_expert(
                    """
                    COPY raw_house_data.local_authority_districts_map
                    FROM STDIN
                    WITH (FORMAT csv, HEADER true)
                    """, local_map
                )
        conn.commit()

def load_from_raw():
    with get_connection() as conn:
        with conn.cursor() as cur:
            run_sql_file(cur, "02_load.sql")
        conn.commit()
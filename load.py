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
            cur.execute("TRUNCATE TABLE raw_house_data.house_price_paid")
            with open("./data/pp-complete.csv", "r", encoding="utf-8", newline="") as complete_data:
                cur.copy_expert(
                    """
                    COPY raw_house_data.house_price_paid
                    FROM STDIN
                    WITH (FORMAT csv, HEADER false)
                    """, complete_data
                )
        conn.commit()

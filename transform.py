from db import get_connection
from load import run_sql_file  # reuse helper
import logging

log = logging.getLogger(__name__)

def create_views():
    log.info("Attempting to create table views")
    with get_connection() as conn:
        with conn.cursor() as cur:
            run_sql_file(cur, "03_transformation_views.sql")
        conn.commit()
    log.info("Table view creation complete")
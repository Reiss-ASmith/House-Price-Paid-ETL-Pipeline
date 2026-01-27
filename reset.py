from load import run_sql_file
from db import get_connection
import logging

log = logging.getLogger(__name__)

def reset_database():
    log.info("Attempting to reset database")
    with get_connection() as conn:
        with conn.cursor as cur:
            run_sql_file(cur, "99_reset.sql")
    log.info("Reset complete")
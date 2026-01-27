from db import get_connection
from load import run_sql_file 
import logging

log = logging.getLogger(__name__)

#A function that runs the 03_transformation_views.sql file which creates the views used for analytics
def create_views():
    log.info("Attempting to create table views")
    with get_connection() as conn:
        with conn.cursor() as cur:
            run_sql_file(cur, "03_transformation_views.sql")
        conn.commit()
    log.info("Table view creation complete")
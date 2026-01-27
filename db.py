import psycopg2
import os
from dotenv import load_dotenv

#lets python use variables stored in a .env file
load_dotenv()

#A function that creates a connection to the Postgres database using the psycopg2 module
def get_connection():
    conn = psycopg2.connect(dbname=os.environ["DB_NAME"],
                            host=os.environ["DB_HOST"],
                            user=os.environ["DB_USER"],
                            password=os.environ["DB_PASSWORD"],
                            port=os.environ["DB_PORT"])
    return conn
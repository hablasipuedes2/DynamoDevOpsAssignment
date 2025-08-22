import psycopg2
import os
import time
import sys

# --- Read DB config from environment ---
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

def get_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ["DB_PORT"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        sslmode="require"
    )

def wait_for_db(max_retries=10, delay=3):
    """Retry DB connection until it's ready."""
    for attempt in range(max_retries):
        try:
            conn = get_connection()
            conn.close()
            sys.stdout.write("Database is ready.")
            return
        except psycopg2.OperationalError:
            sys.stderr.write(f"Database not ready (attempt {attempt+1}/{max_retries})...")
            time.sleep(delay)
    raise Exception("Database is not ready after retries.")

def create_table():
    """Create 'users' table if it doesn't exist."""
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            email VARCHAR(100) UNIQUE
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

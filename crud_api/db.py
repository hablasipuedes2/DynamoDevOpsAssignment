import psycopg2
import os
import time
from psycopg2 import OperationalError

# --- Read DB config from environment ---
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")       # Provided via env or Kubernetes Secret
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

def get_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ["DB_PORT"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"]
    )

def wait_for_db(max_retries=10, delay=3):
    """Retry DB connection until it's ready."""
    for attempt in range(max_retries):
        try:
            conn = get_connection()
            conn.close()
            print("✅ Database is ready.")
            return
        except OperationalError:
            print(f"⏳ Database not ready (attempt {attempt+1}/{max_retries})...")
            time.sleep(delay)
    raise Exception("❌ Database is not ready after retries.")

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

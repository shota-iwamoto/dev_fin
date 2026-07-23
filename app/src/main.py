import os

from fastapi import FastAPI
from sklearn import __version__ as sklearn_version
from sqlalchemy import create_engine, text
import redis

app = FastAPI(title="dev_finace API")

MARIADB_USER = os.getenv("MARIADB_USER", "app_user")
MARIADB_PASSWORD = os.getenv("MARIADB_PASSWORD", "app_password")
MARIADB_DATABASE = os.getenv("MARIADB_DATABASE", "app_db")
MARIADB_HOST = os.getenv("MARIADB_HOST", "mariadb")
MARIADB_PORT = os.getenv("MARIADB_PORT", "3306")

VALKEY_HOST = os.getenv("VALKEY_HOST", "valkey")
VALKEY_PORT = int(os.getenv("VALKEY_PORT", "6379"))

DATABASE_URL = (
    f"mysql+pymysql://{MARIADB_USER}:{MARIADB_PASSWORD}"
    f"@{MARIADB_HOST}:{MARIADB_PORT}/{MARIADB_DATABASE}"
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
redis_client = redis.Redis(host=VALKEY_HOST, port=VALKEY_PORT, decode_responses=True)


@app.get("/")
def root():
    return {"message": "dev_finace API", "sklearn_version": sklearn_version}


@app.get("/health")
def health():
    status = {"api": "ok", "mariadb": "unknown", "valkey": "unknown"}

    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        status["mariadb"] = "ok"
    except Exception as exc:
        status["mariadb"] = f"error: {exc}"

    try:
        redis_client.ping()
        status["valkey"] = "ok"
    except Exception as exc:
        status["valkey"] = f"error: {exc}"

    return status

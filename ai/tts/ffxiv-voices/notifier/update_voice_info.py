import os

import psycopg
from fastapi import FastAPI, HTTPException

app = FastAPI()

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "dbname": os.getenv("PGDATABASE", "postgres"),
    "user": os.getenv("PGUSER", "postgres"),
    "password": os.getenv("PGPASSWORD", ""),
    "port": int(os.getenv("PGPORT", "5432")),
}


@app.put("/update/{voice_id}")
def update_generation_date(voice_id: str):
    nb_row_updated = 0
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    UPDATE ffxivv_data
                    SET last_generation_date = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (voice_id,),
                )
                nb_row_updated = cur.rowcount
                print(f"Updated {nb_row_updated} for {voice_id}")
        return {
            "status": "ok",
            "id": voice_id,
            "count": nb_row_updated

        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

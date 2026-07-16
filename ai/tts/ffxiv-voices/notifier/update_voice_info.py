import os

import psycopg
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import PlainTextResponse
from datetime import datetime
from io import StringIO
import csv


app = FastAPI()

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "dbname": os.getenv("PGDATABASE", "postgres"),
    "user": os.getenv("PGUSER", "postgres"),
    "password": os.getenv("PGPASSWORD", ""),
    "port": int(os.getenv("PGPORT", "5432")),
}


@app.get(
    "/voicelines/lastest-generation",
    response_class=PlainTextResponse,
)
def get_last_generation_date():
    return os.getenv("BATCH_GENERATION_DATE","2070-12-31")


@app.get(
    "/voicelines/{voice_id}",
    response_class=PlainTextResponse,
)
def get_voice_csv(
    voice_id: str,
    last_update_date: datetime = Query(
        default=datetime(1970, 1, 1)
    ),
    last_generation_date: datetime = Query(
        default=datetime(1970, 1, 1)
    ),
):
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT id, sentence_fr
                    FROM ffxivv_data
                    WHERE voice_id = %s
                      AND sentence_fr is not null
                      AND last_update_date > %s 
                      AND (last_generation_date < %s or last_generation_date is null)
                    """,
                    (
                        str(voice_id),
                        last_update_date,
                        last_generation_date,
                    ),
                )

                rows = cur.fetchall()

        output = StringIO()
        writer = csv.writer(
            output,
            delimiter="|",
            lineterminator="\n",
        )

        writer.writerows(rows)

        return PlainTextResponse(
            content=output.getvalue(),
            media_type="text/csv",
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.put("/voicelines/line/{line_id}/last-generation-date")
def update_generation_date(line_id: str):
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
                    (line_id,),
                )
                nb_row_updated = cur.rowcount
                print(f"Updated {nb_row_updated} for {line_id}")
        return {
            "status": "ok",
            "id": line_id,
            "count": nb_row_updated

        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

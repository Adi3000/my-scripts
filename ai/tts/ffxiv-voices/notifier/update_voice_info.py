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


@app.put("/voicelines/{voice_id}/last-generation-date")
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

from datetime import datetime
from io import StringIO
from uuid import UUID
import csv

from fastapi import HTTPException, Query
from fastapi.responses import PlainTextResponse


@app.get(
    "/voicelines/{voice_id}",
    response_class=PlainTextResponse,
)
def get_voice_csv(
    voice_id: UUID,
    last_update_date: datetime = Query(
        default=datetime(1970, 1, 1)
    ),
    last_generation_date: datetime = Query(
        default_factory=datetime(1970, 1, 1)
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
                      AND (last_generation_date > %s or last_generation_date is null)
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


from fastapi import HTTPException
from fastapi.responses import PlainTextResponse


@app.get(
    "/voicelines/lastest-generation",
    response_class=PlainTextResponse,
)
def get_last_generation_date():
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT MAX(last_generation_date)
                    FROM ffxivv_data
                    """
                )

                last_generation_date = cur.fetchone()[0]

        if last_generation_date is None:
            return PlainTextResponse("", media_type="text/plain")

        return PlainTextResponse(
            content=last_generation_date.isoformat(),
            media_type="text/plain",
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
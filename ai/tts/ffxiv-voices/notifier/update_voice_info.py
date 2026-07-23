import os

import psycopg
import requests
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import PlainTextResponse, StreamingResponse
from datetime import datetime
from io import StringIO, BytesIO
import csv
import base64
import soundfile as sf

app = FastAPI()

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "dbname": os.getenv("PGDATABASE", "postgres"),
    "user": os.getenv("PGUSER", "postgres"),
    "password": os.getenv("PGPASSWORD", ""),
    "port": int(os.getenv("PGPORT", "5432")),
}

RUNPOD_ENDPOINT_ID = os.getenv("RUNPOD_ENDPOINT_ID", "abcdef12345678")
RUNPOD_APIKEY = os.getenv("RUNPOD_APIKEY", "apikey_not_defined")


@app.get(
    "/voicelines/latest-generation",
    response_class=PlainTextResponse,
)
def get_last_generation_date():
    
    return PlainTextResponse(
            content=os.getenv("BATCH_GENERATION_DATE","2070-12-31")
        )



@app.get(
    "/voicelines/tts",
    response_class=PlainTextResponse,
)
def tts_call(
    text: str,
    voice_id: str,
    npc_id: str = 'null',
    speaker: str = 'null',
    local_voice_id: str = 'null',
):
    print(f"Speaker : {speaker}, voice_id : {voice_id}, npc_id : {npc_id}, local_voice : {local_voice_id} :\n=======> [{text}]")
    if voice_id == 'null':
        raise HTTPException(
            status_code=403,
            detail=f"Voice_id is mandatory for now, received   Speaker : {speaker}, voice_id : {voice_id}, npc_id : {npc_id}, local_voice : {local_voice_id}, :\n=======> [{text}]"
        )
    runpod_response = requests.post(
        f"https://api.runpod.ai/v2/{RUNPOD_ENDPOINT_ID}/runsync",
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {RUNPOD_APIKEY}",
        },
        json={
            "input": {
                "text": text,
                "voice_id": voice_id
            }
        }
    )
    runpod_response.raise_for_status()

    runpod_output = runpod_response.json()
    output = runpod_response.json()["output"]
    wav_bytes = base64.b64decode(output["wav"])

    return StreamingResponse(
        BytesIO(wav_bytes),
        media_type="audio/wav",
        headers={
            "Content-Disposition": "inline; filename=output.wav"
        }
    )
    


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

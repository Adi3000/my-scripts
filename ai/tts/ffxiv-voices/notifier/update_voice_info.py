import os

import psycopg
from psycopg.rows import dict_row
import requests
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import PlainTextResponse, Response, StreamingResponse
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
XIVVOICES_URL = os.getenv("XIVVOICES_URL", "https://xivv.example.com")
XIVVOICES_AUTH_ACCESS = os.getenv("XIVVOICES_AUTH_ACCESS", "x")
XIVVOICES_AUTH_REFRESH = os.getenv("XIVVOICES_AUTH_REFRESH", "y")


def update_manifest(original_manifest):
    modified_npcs = original_manifest["npcs"]
    npc_to_merge = {npc["id"]: npc for npc in original_manifest["npcs"]}
    with psycopg.connect(**DB_CONFIG, row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                select
                    distinct npc_id_en as id,
                    speaker_fr
                from
                    ffxivv_data
                where
                    npc_id_en <> speaker_fr
                    and npc_id_en <> 'Bubble'
                    and speaker_fr not in ('Voix familière', '???');
                """
            )
            npcs = cur.fetchall()

    for npc in npcs:
        npc_id = npc["id"]
        if npc_id in npc_to_merge:
            existing_npc = npc_to_merge[npc_id]
            if not npc["speaker_fr"] in existing_npc["speakers"]:
                existing_npc["speakers"] += [npc["speaker_fr"]]

    with psycopg.connect(**DB_CONFIG, row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                select
                    npc_id_en as npc_id,
                    sentence_fr,
                    speaker_fr
                from
                    ffxivv_data
                where
                    npc_id_en <> speaker_fr
                    and npc_id_en <> 'Bubble'
                    and speaker_fr in ('Voix familière', '???');
                """
            )
            sentences = cur.fetchall()

    for sentence in sentences:
        original_manifest["speaker_mappings"] += [{
            "speaker": sentence["speaker_fr"],
            "sentence": sentence["sentence_fr"],
            "type": "nameless",
            "npc_id": sentence["npc_id"]
        }]
    return original_manifest


@app.get("/files/manifest.json")
def get_manifest():
    response = requests.get(
        f"{XIVVOICES_URL}/files/manifest.json",
        cookies={
            "auth_access": XIVVOICES_AUTH_ACCESS,
            "auth_refresh": XIVVOICES_AUTH_REFRESH,
        }
    )
    response.raise_for_status()

    return update_manifest(response.json())


@app.get("/files/{filename}")
def get_file(filename: str):
    try:
        response = requests.get(
            f"{XIVVOICES_URL}/files/{filename}",
            cookies={
                "auth_access": XIVVOICES_AUTH_ACCESS,
                "auth_refresh": XIVVOICES_AUTH_REFRESH,
            }
        )
        response.raise_for_status()

    except requests.exceptions.HTTPError as e:
        if response.status_code == 404:
            print(f"File {filename} not found (404)")
            return Response(status_code=404, content=f"File {filename} not found")
        else:
            return Response(status_code=response.status_code, content=response.content)

    return Response(content=response.content, media_type="application/octet-stream")

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

@app.put("_status")
def status():
    return PlainTextResponse(
            content="xivv",
            media_type="text/html",
        )

@app.get("/auth/oauth2/discord")
def login(state: str):
    return PlainTextResponse(
            content="You can close this window",
            media_type="text/html",
        )


@app.get("/auth/oauth2/discord/authorized")
def login(state: str):
    return PlainTextResponse(
            content=f"Fake authentication done with {state}",
            media_type="text/html",
        )

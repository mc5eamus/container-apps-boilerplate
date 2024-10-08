import os
import random
from fastapi import FastAPI, Request
import uvicorn
import argparse
import logging
import time
import requests
import asyncio

#take the backend url from the environment variable backend
backend_url = os.getenv("backend", "http://aca-boilerplate-backend")

app = FastAPI()

logging.getLogger().setLevel(logging.INFO)

@app.post("/entity")
async def post_summary(request: Request):
    requests.post(backend_url + "/repo")
    await asyncio.sleep(3)
    return {"status": "success", "message": "Entity created successfully"}

@app.get("/entity")
async def get_summary(request: Request):
    from_backend = requests.get(backend_url + "/repo")
    await asyncio.sleep(3)
    logging.info(from_backend.json())
    return from_backend.json()

@app.get("/entity/nowait")
async def get_summary_nowait(request: Request):
    from_backend = requests.get(backend_url + "/repo/nowait")
    logging.info(from_backend.json())
    return from_backend.json()

@app.get("/entity/cosmos")
async def get_summary(request: Request):
    logging.info("Getting entity for cosmos")
    from_backend = requests.get(backend_url + "/repo/cosmos")
    response = from_backend.json()
    logging.info(response)
    id = response["id"]
    state = response["state"]
    logging.info(f"Deleting entity: {id}")
    requests.delete(backend_url + f"/repo/cosmos/{id}")
    return {"status": "success", "id": id, "state": state}

if __name__ == "__main__":

    logging.info("starting")

    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=3000, help="Port number to listen on")

    args = parser.parse_args()

    uvicorn.run(app, host="0.0.0.0", port=args.port)
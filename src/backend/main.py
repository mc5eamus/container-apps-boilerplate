import os
import dotenv
import asyncio
import random
from fastapi import FastAPI, Request
import uvicorn
import argparse
import logging
from repo_cosmos import Repo

dotenv.load_dotenv()

app = FastAPI()

logging.getLogger().setLevel(logging.INFO)
cosmos_endpoint = os.getenv("CosmosEndpoint", "")
cosmos_database = os.getenv("CosmosDatabase", "")
cosmos_collection = os.getenv("CosmosCollection", "")

repo = Repo(endpoint=cosmos_endpoint, database_name=cosmos_database, container_name=cosmos_collection)

@app.post("/repo")
async def post_summary(request: Request):
    await asyncio.sleep(2)
    return {"status": "success", "message": "Entity created successfully"}

@app.get("/repo")
async def get_summary(request: Request):
    logging.info("Getting entity")
    await asyncio.sleep(2)
    random_number = random.randint(0, 1000000)
    logging.info(f"Returning entity: {random_number}")
    return {"status": "success", "entity": random_number}

@app.get("/repo/nowait")
async def get_summary_nowait(request: Request):
    logging.info("Getting entity without waiting")
    random_number = random.randint(0, 1000000)
    logging.info(f"Returning entity: {random_number}")
    return {"status": "success", "entity": random_number, "waited": False}

@app.get("/repo/cosmos")
async def get_summary_cosmos(request: Request):
    logging.info("Getting entity for cosmos")
    random_number = random.randint(0, 1000000)
    random_string = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=100))
    await repo.store_state(str(random_number), random_string)

    state = await repo.get_state(str(random_number))

    logging.info(f"Returning entity: {random_number}")
    return {"status": "success", "id": random_number, 'state': state}

@app.delete("/repo/cosmos/{id}")
async def get_summary_cosmos(request: Request, id: str):
    logging.info("Deleting cosmos entry for id: " + id)

    await repo.delete_state(id)
    
    logging.info("Deleted cosmos entry for id: " + id)
    
    return {"status": "deleted", "id": id}

if __name__ == "__main__":

    logging.info("starting")

    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=3000, help="Port number to listen on")

    args = parser.parse_args()

    uvicorn.run(app, host="0.0.0.0", port=args.port)
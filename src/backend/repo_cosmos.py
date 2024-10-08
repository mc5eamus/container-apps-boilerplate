from azure.cosmos.aio import CosmosClient as cosmos_client
from azure.cosmos import exceptions
import json
from azure.identity.aio import DefaultAzureCredential

class Repo:
    def __init__(self, endpoint: str, database_name: str, container_name: str):
        self.endpoint = endpoint
        #self.key = key
        self.database_name = database_name
        self.container_name = container_name
        self.credentials = DefaultAzureCredential()
        self.client = cosmos_client(self.endpoint, credential = self.credentials)
        self.database = self.client.get_database_client(self.database_name)
        self.container = self.database.get_container_client(self.container_name)

    async def store_state(self, id: str, state: str):
        await self.container.upsert_item(body={'id': id, 'state': state})
    
    async def get_state(self, id: str):
        try:
            item = await self.container.read_item(item = id, partition_key = id)
            return item['state']
        except exceptions.CosmosResourceNotFoundError:
            return None
        
    async def delete_state(self, id: str):
        try:
            await self.container.delete_item(item = id, partition_key = id)
        except exceptions.CosmosResourceNotFoundError:
            pass



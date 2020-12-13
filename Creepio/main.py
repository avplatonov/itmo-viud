from pymongo import MongoClient
from scrapper import dl_stream
from robot import getAllCameras
import bson

DB_NAME = "creepio"
MONGO_PATH = "mongodb://localhost:27017/"

try: 
    client = MongoClient(MONGO_PATH)
    print("Connected successfully!") 
except:   
    print("Could not connect to MongoDB")

db = client.creepio
collection = db.videos
url = "https://www.geocam.ru/in/st-petersburg/"
camera_data = getAllCameras(url)
for camera in camera_data:
    try:
        files = dl_stream(camera["video_link"], "/live", 5)
        camera["files"] = files
        collection.insert_one(camera)
    except:
        pass


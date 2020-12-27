from pymongo import MongoClient
from scrapper import dl_stream
from robot import getAllCameras
import bson

DB_NAME = "creepio"
MONGO_PATH = "mongodb://localhost:27017/"

try: 
    client = MongoClient('mongodb://creepio:Chinese@localhost')
    if client is None:
        # no connection, exit early
        print("faield to connect")
    db = client.creepio
    print("Connected successfully!") 
except:   
    print("Could not connect to MongoDB")

collection = db.videos
url = "https://www.geocam.ru/in/st-petersburg/"
camera_data = [{"video_link":"http://www.cactus.tv:8080/cam42/tracks-v1/mono.m3u8", "geolaction":[60.050467, 30.4417]},
{"video_link":"http://www.cactus.tv:8080/cam44/tracks-v1/mono.m3u8", "geolaction":[60.051032, 30.442052]},
{"video_link":"http://www.cactus.tv:8080/cam45/tracks-v1/mono.m3u8", "geolaction":[60.051061, 30.442057]},
{"video_link":"http://www.cactus.tv:8080/cam46/tracks-v1/mono.m3u8", "geolaction":[60.051266, 30.438145]},
{"video_link":"http://www.cactus.tv:8080/cam73/tracks-v1/mono.m3u8", "geolaction":[60.04254685, 30.46658614]},
{"video_link":"http://www.cactus.tv:8080/cam48/tracks-v1/mono.m3u8", "geolaction":[60.051495, 30.4375]},
{"video_link":"http://www.cactus.tv:8080/cam90/tracks-v1/mono.m3u8", "geolaction":[60.05813299, 30.48058398]},
{"video_link":"http://www.cactus.tv:8080/cam106/tracks-v1/mono.m3u8", "geolaction":[60.04999242, 30.44485385]},
{"video_link":"http://www.cactus.tv:8080/cam107/tracks-v1/mono.m3u8", "geolaction":[60.05004339, 30.44489676]},
{"video_link":"http://www.cactus.tv:8080/cam108/tracks-v1/mono.m3u8", "geolaction":[60.05008095, 30.44491822]},
{"video_link":"http://www.cactus.tv:8080/cam117/tracks-v1/mono.m3u8", "geolaction":[60.05236971, 30.45179014]},
{"video_link":"http://www.cactus.tv:8080/cam121/tracks-v1/mono.m3u8", "geolaction":[60.051175, 30.449604]},
{"video_link":"http://www.cactus.tv:8080/cam125/tracks-v1/mono.m3u8", "geolaction":[60.049469, 30.444769]},
{"video_link":"http://www.cactus.tv:8080/cam136/tracks-v1/mono.m3u8", "geolaction":[60.051508, 30.436952]},
{"video_link":"http://www.cactus.tv:8080/cam160/tracks-v1/mono.m3u8", "geolaction":[60.051237, 30.438089]},
{"video_link":"http://www.cactus.tv:8080/cam168/tracks-v1/mono.m3u8", "geolaction":[60.054883, 30.476614]},
{"video_link":"http://www.cactus.tv:8080/cam169/tracks-v1/mono.m3u8", "geolaction":[60.054779, 30.476471]},
{"video_link":"http://www.cactus.tv:8080/cam174/tracks-v1/mono.m3u8", "geolaction":[60.040197, 30.453542]},
{"video_link":"http://www.cactus.tv:8080/cam175/tracks-v1/mono.m3u8", "geolaction":[60.04809, 30.45754]},
{"video_link":"http://www.cactus.tv:8080/cam180/tracks-v1/mono.m3u8", "geolaction":[60.042851, 30.454132]},
{"video_link":"http://www.cactus.tv:8080/cam181/tracks-v1/mono.m3u8", "geolaction":[60.042774, 30.452895]},
{"video_link":"http://www.cactus.tv:8080/cam182/tracks-v1/mono.m3u8", "geolaction":[60.043193, 30.460043]},
{"video_link":"http://www.cactus.tv:8080/cam183/tracks-v1/mono.m3u8", "geolaction":[60.043205, 30.460178]},
{"video_link":"http://www.cactus.tv:8080/cam184/tracks-v1/mono.m3u8", "geolaction":[60.042817, 30.456503]},
{"video_link":"http://www.cactus.tv:8080/cam188/tracks-v1/mono.m3u8", "geolaction":[60.043055, 30.45725]},
{"video_link":"http://www.cactus.tv:8080/cam189/tracks-v1/mono.m3u8", "geolaction":[60.043055, 30.457299]},
{"video_link":"http://www.cactus.tv:8080/cam190/tracks-v1/mono.m3u8", "geolaction":[60.043113, 30.461815]},
{"video_link":"http://www.cactus.tv:8080/cam192/tracks-v1/mono.m3u8", "geolaction":[60.042599, 30.452467]},
{"video_link":"http://www.cactus.tv:8080/cam193/tracks-v1/mono.m3u8", "geolaction":[60.042624, 30.452557]},
{"video_link":"http://www.cactus.tv:8080/cam211/tracks-v1/mono.m3u8", "geolaction":[60.056805, 30.479804]},
{"video_link":"http://www.cactus.tv:8080/cam212/tracks-v1/mono.m3u8", "geolaction":[60.056918, 30.480903]}]

for camera in camera_data:
    try:
        files = dl_stream(camera["video_link"], "/live", 10)
        camera["files"] = files
        collection.insert_one(camera)
    except:
        pass;


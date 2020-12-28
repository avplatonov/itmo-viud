import boto3
from pymongo import MongoClient
import subprocess as s
import os
import json

client = MongoClient('mongodb://creep:FuckTheChinese@46.101.158.25')
videos = client.creepio.videos

s3 = boto3.client('s3')
aws_client = None

def do_session():
    global aws_client
    if aws_client != None:
        return aws_client
    
    session = boto3.session.Session()
    aws_client = session.client('s3',
                        region_name='fra1',
                        endpoint_url='https://creepio.fra1.digitaloceanspaces.com',
                        aws_access_key_id='TQI6J75API4J6CBXD67L',
                        aws_secret_access_key='+TG+ONn5UfNg70WfEg/YDUTq0wxqrN0aC4I/lX+SRas')
    return aws_client

s3 = do_session()

for video in videos.find({"parsed":{"$exists": False}}, batch_size=10):
    print(video)
    curpath = os.path.realpath(os.path.curdir)
    to_parse = []
    for i,file in enumerate(video['files']):
        print(file)
        s3.download_file('creepio', file, file.split('/')[1])
        to_parse.append((curpath + "/" + file.split('/')[1]).encode('utf-8'))

    
    darknet_dir = "/home/user/programs/my/vuid/darknet_2/"
    p = s.Popen([darknet_dir + "./darknet", "detector", "test", darknet_dir+ "./cfg/coco.data",\
                darknet_dir+ "./cfg/yolov4.cfg", darknet_dir+ "./yolov4.weights", "-ext_output", "-dont_show", "-out", curpath + "/out.json", "-i", "0", "-thresh", "0.25"], stdin=s.PIPE, stdout=s.PIPE, stderr=s.PIPE, bufsize=1, cwd=darknet_dir)
    outs, errs = p.communicate(b"\n".join(to_parse))

    with open('out.json') as f:
        file_data = json.load(f)

    for f in file_data:
        f['filename'] = f['filename'].split('/')[-1]

    videos.find_one_and_update(video, {'$set': {'parsed': file_data}})
    
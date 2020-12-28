import os
import boto3


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

                                          
def upload_file_to_bucket(day, file_path):
    client = do_session()
    file_dir, file_name = os.path.split(file_path)
    client.upload_file(file_path, 'creepio', day + '/' + file_name, ExtraArgs={'ACL':'public-read'})

    s3_url = f"https://creepio.fra1.digitaloceanspaces.com/{file_name}"
    return s3_url

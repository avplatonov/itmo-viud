import os
import boto3

def do_session():
    session = boto3.session.Session()
    files_client = session.client('s3',
                        region_name='fra1',
                        endpoint_url='https://creepio.fra1.digitaloceanspaces.com',
                        aws_access_key_id='35DQEW2OVKTKCFH6CJCG',
                        aws_secret_access_key='OcppR3M/8k9fhxSv8/5PwQN5AQKWgfZNmRd3iSFrYCU')
    return files_client

                    
def upload_file_to_bucket(file_path):
    client = do_session()
    file_dir, file_name = os.path.split(file_path)
    client.upload_file(file_path, 'creepio', file_name, ExtraArgs={'ACL':'public-read'})

    s3_url = f"https://creepio.fra1.digitaloceanspaces.com/{file_name}"
    return s3_url
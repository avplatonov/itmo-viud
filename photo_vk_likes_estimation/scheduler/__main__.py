import os
import time

import mongoengine
import schedule

from config import Config
from scheduler.training import train_and_update_model

mongoengine.connect(Config.MONGO_DATABASE, host=Config.MONGO_URI)


def job():
    print("Starting crawling...")
    os.system("scrapy crawl vk_dating_photos")
    print("Finished crawling.")

    print("Starting training...")
    train_and_update_model()
    print("Finished training.")


schedule.every(6).hours.do(job)

while True:
    schedule.run_pending()
    time.sleep(1)

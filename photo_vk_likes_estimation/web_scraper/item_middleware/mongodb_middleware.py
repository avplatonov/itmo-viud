from dataclasses import asdict
from datetime import datetime
from io import BytesIO

import mongoengine
from itemadapter import ItemAdapter
from mongoengine import DoesNotExist
from scrapy import Request
from scrapy.crawler import Crawler
from scrapy.exceptions import DropItem
from scrapy.http import Response

from common.models.photo import Photo
from config import Config
from web_scraper.items.photo_item import PhotoItem


class MongodbMiddleware:
    mongo_uri: str
    mongo_db: str
    crawler: Crawler

    def __init__(self, mongo_uri: str, mongo_db: str, crawler: Crawler):
        self.mongo_uri = mongo_uri
        self.mongo_db = mongo_db
        self.crawler = crawler

    @classmethod
    def from_crawler(cls, crawler: Crawler):
        return cls(
            Config.MONGO_URI,
            Config.MONGO_DATABASE,
            crawler
        )

    def open_spider(self, spider):
        mongoengine.connect(self.mongo_db, host=self.mongo_uri)

    def close_spider(self, spider):
        mongoengine.connection.disconnect()

    def process_item(self, item, spider):
        item = PhotoItem(**ItemAdapter(item).asdict())
        if item.image:
            self._save_photo_item(item)
            return item

        self.crawler.engine.crawl(
            Request(
                url=item.photo_url,
                callback=self._process_image_response,
                cb_kwargs=dict(item=item)
            ),
            spider
        )
        raise DropItem("Image is required to save PhotoItem, scheduled HTTP GET photo_url to the crawler.")

    def _process_image_response(self, response: Response, item: PhotoItem):
        item.image = response.body
        yield item

    def _save_photo_item(self, item: PhotoItem):
        item_dict = asdict(item)
        del item_dict["photo_url"]
        image = item_dict.pop("image")
        doc = self._get_or_create_photo_document(item, item_dict)
        doc.image.replace(BytesIO(image), filename=f"{item.community_id}_{item.post_id}.jpg", content_type="image/jpeg")
        doc.dt_updated = datetime.utcnow()
        doc.save()

    def _get_or_create_photo_document(self, item: PhotoItem, item_dict: dict) -> Photo:
        try:
            return Photo.objects(community_id=item.community_id, post_id=item.post_id, photo_id=item.photo_id).get()
        except DoesNotExist:
            return Photo(**item_dict)

import json
from typing import List
from urllib.parse import urlencode

import scrapy
from scrapy import Request
from scrapy.http import TextResponse

from config import Config
from web_scraper.items.photo_item import PhotoItem


class CrawlingError(Exception):
    """ Error during crawling. """

    def __init__(self, *args, **kwargs):  # real signature unknown
        pass


class VkDatingPhotosSpider(scrapy.Spider):
    name = "vk_dating_photos"
    response_page_size = 100  # 100 is max page_size available due to VK API limitations

    def start_requests(self):
        for screen_name in Config.START_SCREEN_NAMES:
            query = dict(count=self.response_page_size)
            if screen_name.startswith("public"):
                query["owner_id"] = -int(screen_name[6:])
            else:
                query["domain"] = screen_name

            req_url = _get_vk_wall_get_url(**query)
            yield Request(req_url, callback=self.parse, cb_kwargs=query)

    def parse(self, response: TextResponse, **query):
        json_obj = json.loads(response.text)
        if "error" in json_obj:
            raise CrawlingError(json_obj)

        data = json_obj["response"]
        posts = _filter_posts_batch(data["items"])
        like_counts = [p["likes"]["count"] for p in posts]
        views_counts = [p["views"]["count"] for p in posts]
        for post in posts:
            yield from _assemble_photo_items(post, _get_list_mean(like_counts), _get_list_mean(views_counts))

        offset = query.get("offset", 0)
        if offset < data["count"]:
            # more posts available on the next pages
            query = query.copy()
            query["offset"] = offset + self.response_page_size
            yield Request(url=_get_vk_wall_get_url(**query), cb_kwargs=query)


def _get_list_mean(arr: List[int]) -> float:
    return sum(arr) / len(arr)


def _get_vk_wall_get_url(**kwargs) -> str:
    kwargs["v"] = "5.95"
    kwargs["access_token"] = Config.VK_API_TOKEN
    kwargs_url = urlencode(kwargs)
    return f"https://api.vk.com/method/wall.get?{kwargs_url}"


def _filter_posts_batch(posts) -> List[dict]:
    passed = []
    for post in posts:
        if post["marked_as_ads"] != 0:
            continue

        if "attachments" not in post or sum(1 for att in post["attachments"] if att["type"] == 'photo') == 0:
            continue

        passed.append(post)

    return passed


def _assemble_photo_items(post: dict, avg_batch_likes_count: float, avg_batch_views_count: float) -> PhotoItem:
    for att in post["attachments"]:
        if att["type"] != 'photo':
            continue

        first_photo_sizes = att["photo"]["sizes"]
        size_types = set(sz["type"] for sz in first_photo_sizes)
        selected_type = "y" if "y" in size_types else "x"
        photo_url = next(sz["url"] for sz in first_photo_sizes if sz["type"] == selected_type)

        yield PhotoItem(
            community_id=post["owner_id"],
            post_id=post["id"],
            photo_id=att["photo"]["id"],
            likes_count=post["likes"]["count"],
            views_count=post["views"]["count"],
            avg_batch_likes_count=avg_batch_likes_count,
            avg_batch_views_count=avg_batch_views_count,
            photo_url=photo_url
        )

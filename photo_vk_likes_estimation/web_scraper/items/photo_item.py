# Models for scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html
from dataclasses import dataclass
from typing import Optional


@dataclass
class PhotoItem:
    community_id: int
    post_id: int

    likes_count: int
    views_count: int

    avg_batch_likes_count: float
    avg_batch_views_count: float

    photo_url: str
    image: Optional[bytes] = None

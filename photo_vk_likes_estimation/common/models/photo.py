from datetime import datetime

from mongoengine import Document, IntField, FloatField, ImageField, DateTimeField


class Photo(Document):
    community_id: int = IntField(required=True)
    post_id: int = IntField(required=True, unique_with='community_id')

    likes_count: int = IntField(required=True)
    views_count: int = IntField(required=True)

    avg_batch_likes_count: float = FloatField(required=True)
    avg_batch_views_count: float = FloatField(required=True)

    image = ImageField()

    dt_created: datetime = DateTimeField(required=True, default=datetime.utcnow)
    dt_updated: datetime = DateTimeField(required=True, default=datetime.utcnow)

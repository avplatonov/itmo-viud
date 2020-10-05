from typing import List

from config.enums.environment import Environment


class BaseConfig:
    VK_API_TOKEN: str
    START_SCREEN_NAMES: List[str]
    MONGO_DATABASE: str
    MONGO_URI: str
    COLLECTION_NAME: str


class ProductionConfig(BaseConfig):
    ENVIRONMENT = Environment.PRODUCTION


class DevelopmentConfig(BaseConfig):
    ENVIRONMENT = Environment.DEVELOPMENT

    MONGO_DATABASE = "photo_vk_likes_estimation_dev"
    MONGO_URI = "mongodb://localhost:27017"

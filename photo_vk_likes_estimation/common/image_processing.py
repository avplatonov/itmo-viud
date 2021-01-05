import base64
from io import BytesIO

import PIL
import numpy as np
from PIL.Image import Image
from bson import ObjectId
from mongoengine import GridFSProxy
from resizeimage import resizeimage

from common.models.photo import Photo

IMAGE_SIZE = 224


def preprocess_image(image):
    image = image.convert("RGB")
    image = resizeimage.resize_cover(image, [IMAGE_SIZE, IMAGE_SIZE], validate=False)
    return np.array(image)


def read_image_to_arr(object_id):
    bimage = GridFSProxy(ObjectId(object_id), collection_name=Photo.image.collection_name).get().read()
    image = PIL.Image.open(BytesIO(bimage))
    return preprocess_image(image)


def estimate_image(model, image: Image):
    image_arr = preprocess_image(image)
    pred = model.predict(np.array([image_arr]))[0]
    labels = ["lo", "mid", "hi"]
    return dict(zip(labels, pred))


def dataurl_from_image(img):
    """Base64 encodes image bytes for inclusion in an HTML img element"""
    data = BytesIO()
    img.convert("RGB").save(data, "JPEG")
    data64 = base64.b64encode(data.getvalue()).decode("utf8")
    return f"data:image/jpeg;base64,{data64}"

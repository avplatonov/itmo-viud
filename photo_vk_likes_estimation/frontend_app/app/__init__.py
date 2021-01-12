from dataclasses import dataclass
from io import BytesIO

import PIL
import mongoengine
import numpy as np
from flask import Flask, render_template, request, abort

from common.image_processing import dataurl_from_image, preprocess_image
from config import Config
from frontend_app.app.utils.models import tensorflow_warmup, cached_model


def create_app():
    app = Flask(__name__)
    mongoengine.connect(Config.MONGO_DATABASE, host=Config.MONGO_URI)

    try:
        tensorflow_warmup()
        app.logger.info('tensorflow_warmup succesful')
    except Exception:
        app.logger.info('tensorflow_warmup failed')
        pass

    @dataclass
    class ExecutionResult:
        image: PIL.Image
        lo: float
        mid: float
        hi: float

        @property
        def image_dataurl(self):
            return dataurl_from_image(self.image)

    @app.route('/', methods=["GET"])
    def index():
        return render_template("index.html")

    @app.route('/', methods=["POST"])
    def index_with_image():
        if 'file' not in request.files:
            abort(400)
            return

        image = PIL.Image.open(BytesIO(request.files['file'].stream.read()))
        image_arr = preprocess_image(image)
        estimation = cached_model.instance.predict(np.array([image_arr]))[0]
        labels = ["lo", "mid", "hi"]
        result = ExecutionResult(image=PIL.Image.fromarray(image_arr), **dict(zip(labels, estimation)))
        return render_template("index.html", result=result)

    return app

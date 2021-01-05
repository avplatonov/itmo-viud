import os
import sys

import tensorflow as tf
from tensorflow.keras.models import Model

from config import Config
from frontend_app.app.utils.cached_object import CachedObject


class CachedModel(CachedObject[Model]):
    _model_path = Config.MODEL_DIR
    __last_modified_time: float = None

    def load(self) -> Model:
        model = tf.keras.models.load_model(self._model_path)
        self.__last_modified_time = os.path.getmtime(self._model_path)
        return model

    def is_reload_needed(self) -> bool:
        return abs(self.__last_modified_time - os.path.getmtime(self._model_path)) > sys.float_info.epsilon


cached_model = CachedModel()


def tensorflow_warmup():
    gpu_devices = tf.config.experimental.list_physical_devices('GPU')
    for device in gpu_devices:
        tf.config.experimental.set_memory_growth(device, True)

    # Load model instance
    # noinspection PyStatementEffect
    cached_model.instance

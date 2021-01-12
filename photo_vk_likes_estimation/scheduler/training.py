import shutil

import numpy as np
import pandas as pd
import tensorflow as tf
from classification_models.tfkeras import Classifiers
from pandas import DataFrame
from sklearn.model_selection import train_test_split

from common.image_processing import read_image_to_arr, IMAGE_SIZE
from common.models.photo import Photo
from config import Config

ResNet34, _ = Classifiers.get("resnet34")


def _produce_df_from_db() -> DataFrame:
    logarg_shift = 0.07  # target mean was 0.93 on test data sample

    def lv_to_target(lv, avglv):
        return np.log(lv / avglv + logarg_shift)

    def target_to_lv(target, avglv):
        return avglv * (np.exp(target) - logarg_shift)

    def to_target_dict(p):
        res = dict(p.to_mongo())

        lv = p.likes_count / p.views_count
        avglv = p.avg_batch_likes_count / p.avg_batch_views_count
        res["lv"] = lv
        res["target"] = lv_to_target(lv, avglv)

        res["image"] = str(res["image"])
        return res

    def test_for_valid_photo_counts(p) -> bool:
        if p.views_count == 0:
            return False

        if p.avg_batch_views_count == 0:
            return False

        avglv = p.avg_batch_likes_count / p.avg_batch_views_count
        if avglv == 0:
            return False

        return True

    df = pd.DataFrame(to_target_dict(p) for p in Photo.objects.all() if test_for_valid_photo_counts(p))

    tmid_lo, tmid_hi = map(df.target.quantile, (1 / 3, 2 / 3))
    df["target_class"] = df.target.apply(lambda t: "lo" if t < tmid_lo else ("mid" if t < tmid_hi else "hi"))
    df = df.assign(**pd.get_dummies(df.target_class))

    return df


def train_and_update_model():
    df = _produce_df_from_db()

    def get_dataset_generator(df):
        def generator():
            for idx, row in df.iterrows():
                yield read_image_to_arr(row.image), row[["lo", "mid", "hi"]].values

        return generator

    def df_to_dataset(df, shuffle=True, batch_size=None, repeat=False):
        ds = tf.data.Dataset.from_generator(get_dataset_generator(df), output_types=(tf.float32, tf.float32),
                                            output_shapes=((IMAGE_SIZE, IMAGE_SIZE, 3), (3,)))
        ds = ds.shuffle(buffer_size=1024) if shuffle else ds
        ds = ds.batch(batch_size) if batch_size else ds
        ds = ds.repeat() if repeat else ds
        return ds

    N = len(df)
    shuffled_df = df.sample(frac=1)
    trainval_df, test_df = train_test_split(shuffled_df, test_size=1 / 10)
    train_df, val_df = train_test_split(trainval_df, test_size=1 / 9)

    print(f"N:\t{N}")
    print(f"Train:\t{len(train_df)}, {len(train_df) / N * 100:.0f}%")
    print(f"Val:\t{len(val_df)}, {len(val_df) / N * 100:.0f}%")
    print(f"Test:\t{len(test_df)}, {len(test_df) / N * 100:.0f}%")

    train_ds = df_to_dataset(train_df, batch_size=32, repeat=True)
    val_ds = df_to_dataset(val_df, batch_size=8)
    test_ds = df_to_dataset(test_df, batch_size=8)

    n_classes = 3

    base_model = ResNet34(input_shape=(224, 224, 3), weights='imagenet', include_top=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(base_model.output)
    output = tf.keras.layers.Dense(n_classes, activation='softmax')(x)
    model = tf.keras.models.Model(inputs=[base_model.input], outputs=[output])

    model.compile(optimizer=tf.keras.optimizers.Adam(lr=0.00003),
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])

    model.fit(train_ds,
              epochs=10,
              steps_per_epoch=200,
              validation_data=val_ds,
              validation_steps=25)

    test_loss, test_acc = model.evaluate(test_ds, steps=150)

    print(f"TEST LOSS: {test_loss}, TEST ACCURACY: {test_acc * 100:.2f}%")

    model.save("model_new")
    shutil.move("model_new", Config.MODEL_DIR)

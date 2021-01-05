from abc import ABC, abstractmethod
from typing import Optional, TypeVar, Generic

from flask import current_app

TObject = TypeVar("TObject")


class CachedObject(Generic[TObject], ABC):
    __cache: Optional[TObject] = None

    @abstractmethod
    def load(self) -> TObject:
        """ Loads the object and returns it """
        ...

    # noinspection PyMethodMayBeStatic
    def is_reload_needed(self) -> bool:
        return False

    @property
    def instance(self):
        if self.__cache is None or self.is_reload_needed():
            if current_app:
                current_app.logger.info(f"{self.__class__.__name__} is reloading. Old: {self.__cache}.")

            self.__cache = self.load()

        return self.__cache

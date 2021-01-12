from typing import Type

from config.base_config import BaseConfig
from config.enums.environment import Environment

try:
    # noinspection PyUnresolvedReferences
    from config.current_config import CurrentConfig
except ModuleNotFoundError as e:
    raise ModuleNotFoundError(
        f"No config/current_config.py file was yet created.\n"
        f"Each developer has to do it manually to be aware of project's configuration mechanics.\n"
        f"See config/current_config.py.template for more info."
    ) from e

Config = CurrentConfig  # type: Type[BaseConfig]

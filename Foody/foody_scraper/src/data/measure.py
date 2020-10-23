from dataclasses import dataclass

from foody_scraper.src.data.utils.fractions_unicode_dict import fractions
from foody_scraper.src.data.utils.functions import is_float


@dataclass
class Measure:
    title: str
    normal_title_form: str
    amount: float

from dataclasses import dataclass

from foody_scraper.src.data.measure import Measure


@dataclass
class Nutrition:
    name: str
    measure: Measure

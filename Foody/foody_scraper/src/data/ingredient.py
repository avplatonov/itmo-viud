from dataclasses import dataclass
from typing import Dict, Any

from foody_scraper.src.data.measure import Measure
from foody_scraper.src.data.utils.functions import is_float
from foody_scraper.src.data_analysis.language_analyser import LanguageAnalyser
from foody_scraper.src.data.utils.fractions_unicode_dict import fractions


@dataclass
class Ingredient:
    id: int
    name: str
    measure: Measure


class IngredientConverter:
    def __init__(self):
        self.language_analyser = LanguageAnalyser()

    def get_from_dict(self, ingredient_dict: Dict[str, Any]):
        id = ingredient_dict['id']
        name = ingredient_dict['name']
        measure = self.parse_measure_from_string(ingredient_dict['amount'])
        return Ingredient(
            id=id,
            name=name,
            measure=measure
        )

    def parse_measure_from_string(self, measure: str) -> Measure:
        splitted_measure = measure.split()
        measure_amount = splitted_measure[0]
        is_measure_parsable = is_float(measure_amount) or measure_amount in fractions

        if is_measure_parsable:
            title = self.apply_measure_pattern(' '.join(splitted_measure[1:]))
            normal_title_form = self.language_analyser.get_normal_form(title)
            amount = self.parse_measure_amount(measure_amount)
        else:
            title = measure.lower()
            normal_title_form = self.language_analyser.get_normal_form(title)
            amount = '-1'

        return Measure(
            title,
            normal_title_form,
            amount
        )

    @staticmethod
    def apply_measure_pattern(measure_title):
        if measure_title == 'г':
            return 'гр'
        return measure_title

    @staticmethod
    def parse_measure_amount(measure_amount: str) -> float:
        if measure_amount in fractions:
            return fractions[measure_amount]
        else:
            return float(measure_amount)

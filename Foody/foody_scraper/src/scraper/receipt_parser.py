import json
from typing import Any, Optional, List

from bs4 import BeautifulSoup

from foody_scraper.src.data.ingredient import IngredientConverter
from foody_scraper.src.data.measure import Measure
from foody_scraper.src.data.nutrition import Nutrition
from foody_scraper.src.data_analysis.language_analyser import LanguageAnalyser


class ReceiptPageParser:
    def __init__(self):
        self.ingredient_converter = IngredientConverter()
        self.language_analyser = LanguageAnalyser()

    def get_receipt_title_from_soup(self, page_soup: BeautifulSoup) -> Optional[str]:
        raw_title = page_soup.findAll('h1', 'recipe__name g-h1')

        return raw_title[0].text.strip() if raw_title else ''

    def get_receipt_time_from_soup(self, page_soup: BeautifulSoup) -> Optional[str]:
        data = self.__get_important_from_info_pad(page_soup, 1)
        return data

    def get_receipt_n_persons_from_soup(self, page_soup: BeautifulSoup) -> Optional[int]:
        data = self.__get_important_from_info_pad(page_soup, 0)

        return int(data) if data else data

    def get_ingredients_from_soup(self, page_soup: BeautifulSoup):
        raw_ingredients_list = page_soup.findAll('div', 'ingredients-list__content')
        if not raw_ingredients_list:
            return None
        raw_ingredients = raw_ingredients_list[0].find_all('p', 'ingredients-list__content-item content-item js-cart-ingredients')
        ingredients = []

        for raw_ingredient in raw_ingredients:
            ingredient = json.loads(raw_ingredient['data-ingredient-object'])
            ingredients.append(self.ingredient_converter.get_from_dict(ingredient))

        return ingredients

    def get_tags_from_soup(self, page_soup: BeautifulSoup) -> List[str]:
        raw_tag_list = page_soup.findAll('ul', 'breadcrumbs')
        if not raw_tag_list:
            return []

        raw_tags = raw_tag_list[0].find_all('a', '')
        tags = []
        for raw_tag in raw_tags:
            tags.append(raw_tag.text)

        return tags

    def get_nutrition_list_from_soup(self, page_soup: BeautifulSoup) -> List[Nutrition]:
        raw_nutrition_list = page_soup.findAll('ul', 'nutrition__list')
        if not raw_nutrition_list:
            return []

        raw_nutritions = raw_nutrition_list[0].findAll('li', '')
        if not raw_nutritions:
            return []

        nutritions = []
        for raw_nutrition in raw_nutritions:
            splitted_nutrition = raw_nutrition.text.strip().split('\n')
            if len(splitted_nutrition) > 0:
                nutritions.append(
                    Nutrition(
                        name=splitted_nutrition[0],
                        measure=Measure(
                            title=splitted_nutrition[2],
                            normal_title_form=self.language_analyser.get_normal_form(splitted_nutrition[2]),
                            amount=float(splitted_nutrition[1].replace(',', '.')))
                    )
                )

        return nutritions

    def get_recipe_steps(self, page_soup: BeautifulSoup) -> List[str]:
        raw_recipe_steps = page_soup.findAll('ul', 'recipe__steps')

        if not raw_recipe_steps:
            return []

        raw_instruction_descriptions = page_soup.findAll('span', 'instruction__description')
        if not raw_instruction_descriptions:
            return []

        recipe_steps = [recipe_step.text.strip() for recipe_step in raw_instruction_descriptions if recipe_step is not None]

        return recipe_steps


    @staticmethod
    def __get_important_from_info_pad(page_soup:  BeautifulSoup, element_position: int) -> Optional[Any]:
        raw_info_pad = page_soup.findAll('div', 'recipe__info-pad info-pad print-invisible')
        if not raw_info_pad:
            return None

        raw_data = raw_info_pad[0].find_all('span', 'info-text')
        return raw_data[element_position].text.strip() if raw_data else None

import asyncio
from typing import Dict

import aiohttp
from bs4 import BeautifulSoup

from foody_scraper.src.data.recipe import Recipe
from foody_scraper.src.scraper.api_constants import *
from .receipt_link_parser import ReceiptLinkParser
from .receipt_parser import ReceiptPageParser


class Scraper:
    def __init__(self):
        self.receipt_page_parser = ReceiptPageParser()
        self.links_page_parser = ReceiptLinkParser()

    async def get_receipts(self) -> Dict[str, Recipe]:
        receipts = {}

        await asyncio.wait([
            self.load_receipts_from_page(receipts, page_number)
            for page_number in range(1, 3)])

        return receipts

    async def load_receipts_from_page(self, receipts, page_number):
        print(f'Started loading for page: {page_number}')
        receipt_links = await self.get_receipt_links(page_number)
        await asyncio.wait([self.update_receipts(receipts, receipt_link)
                            for receipt_link in receipt_links])
        print(f'Finished page: {page_number}')

    async def update_receipts(self, receipts: Dict[str, Recipe], receipt_link: str):
        receipts[receipt_link] = await self.get_receipt(receipt_link)

    async def get_receipt_links(self, page_number: int):
        links_page_url = EDA_URL + "/recepty?page=" + str(page_number)
        async with aiohttp.ClientSession() as session:
            response = await session.get(links_page_url)
            soup = BeautifulSoup(await response.text(), 'html.parser')
            await session.close()
        return self.links_page_parser.get_links(soup)

    async def get_receipt(self, receipt_link: str) -> Recipe:
        async with aiohttp.ClientSession() as session:
            response = await session.get(receipt_link)
            soup = BeautifulSoup(await response.text(), 'html.parser')
            await session.close()
        receipt_title = self.receipt_page_parser.get_receipt_title_from_soup(soup)
        receipt_time = self.receipt_page_parser.get_receipt_time_from_soup(soup)
        receipt_n_persons = self.receipt_page_parser.get_receipt_n_persons_from_soup(soup)
        ingredients = self.receipt_page_parser.get_ingredients_from_soup(soup)
        tags = self.receipt_page_parser.get_tags_from_soup(soup)
        nutritions = self.receipt_page_parser.get_nutrition_list_from_soup(soup)
        recipe_steps = self.receipt_page_parser.get_recipe_steps(soup)

        return Recipe(
            title=receipt_title,
            time=receipt_time,
            n_persons=receipt_n_persons,
            ingredients=ingredients,
            tags=tags,
            nutritions=nutritions,
            recipe_steps=recipe_steps
        )

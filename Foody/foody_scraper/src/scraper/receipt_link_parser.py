from typing import List

from bs4 import BeautifulSoup, ResultSet

from foody_scraper.src.scraper.api_constants import EDA_URL


class ReceiptLinkParser:

    def __init__(self):
        self.receipt_block_class = 'tile-list__horizontal-tile horizontal-tile js-portions-count-parent js-bookmark__obj'
        self.link_block_class = 'horizontal-tile__item-title item-title'

    def get_links(self, page_soup: BeautifulSoup) -> List[str]:
        links = []
        receipt_blocks: ResultSet = page_soup.findAll('div', self.receipt_block_class)
        for i in range(len(receipt_blocks)):
            receipt_block = receipt_blocks[i]
            link_block = receipt_block.findAll('h3', self.link_block_class)[0]
            link = link_block.findAll('a')[0].attrs['href']
            links.append(EDA_URL + link)
        return links

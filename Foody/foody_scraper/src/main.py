from foody_scraper.src.scraper.scraper import Scraper
import asyncio

async def main():
    scraper_task = Scraper()
    receipts = await scraper_task.get_receipts()
    for recipe in receipts:
        print(receipts[recipe])


if __name__ == '__main__':
    asyncio.get_event_loop().run_until_complete(main())

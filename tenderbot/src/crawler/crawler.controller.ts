import { Controller, Get } from '@nestjs/common';

import { CrawlerService } from './crawler.service';

@Controller('crawl')
export class CrawlerController {
	constructor(private readonly crawlerService: CrawlerService) {}

	@Get('all')
	async crawlAll(): Promise<string> {
		this.crawlerService.crawlAll();
		return 'Crawling all...';
	}

	@Get('new')
	async crawlNew(): Promise<string> {
		this.crawlerService.crawlNew();
		return 'Crawling new...';
	}
}

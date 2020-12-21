import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';

import { LoggerModule } from 'src/logger/logger.module';
import { TenderModule } from 'src/data/tender/tender.module';
import { CrawlerController } from './crawler.controller';
import { CrawlerService } from './crawler.service';

@Module({
	imports: [LoggerModule, TenderModule, ScheduleModule.forRoot()],
	controllers: [CrawlerController],
	providers: [CrawlerService],
})
export class CrawlerModule {}

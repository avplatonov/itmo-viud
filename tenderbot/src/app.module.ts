import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { config } from './config';
import { CrawlerModule } from './crawler/crawler.module';
import { AnalyzerModule } from './analyzer/analyzer.module';
import { LoggerModule } from 'src/logger/logger.module';
import { TenderModule } from 'src/data/tender/tender.module';
import { AnalysisResultModule } from './data/analaysis-result/analysis-result.module';
import { FrontModule } from 'src/front/front.module';

@Module({
	imports: [
		MongooseModule.forRoot(config.dbPath),
		CrawlerModule,
		AnalyzerModule,
		LoggerModule,
		TenderModule,
		AnalysisResultModule,
		FrontModule,
	],
})
export class AppModule {}

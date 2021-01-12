import { Module } from '@nestjs/common';

import { LoggerModule } from 'src/logger/logger.module';
import { TenderModule } from 'src/data/tender/tender.module';
import { AnalysisResultModule } from 'src/data/analaysis-result/analysis-result.module';
import { ScheduleModule } from '@nestjs/schedule';
import { AnalyzerController } from './analyzer.controller';
import { AnalyzerServcie } from './analyzer.service';

@Module({
	imports: [LoggerModule, TenderModule, AnalysisResultModule, ScheduleModule.forRoot()],
	controllers: [AnalyzerController],
	providers: [AnalyzerServcie],
})
export class AnalyzerModule {}

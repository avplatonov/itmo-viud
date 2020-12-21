import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { AnalysisResult, AnalysisResultSchema } from './schemas/analysis-result.schema';
import { AnalysisResultService } from './analysis-result.service';

@Module({
	imports: [MongooseModule.forFeature([{ name: AnalysisResult.name, schema: AnalysisResultSchema }])],
	providers: [AnalysisResultService],
	exports: [AnalysisResultService],
})
export class AnalysisResultModule {}

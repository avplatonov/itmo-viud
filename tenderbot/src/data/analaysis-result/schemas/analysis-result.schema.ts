import { Document } from 'mongoose';
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';

import { TotalResultSchema, TotalResult } from './total-result.schema';
import { RegionalResultSchema, RegionalResult } from './regional-result.schema';
import { RegionalToTotalRatiosSchema, RegionalToTotalRatios } from './regional-to-total-ratios.schema';

export type AnalysisResultDocument = AnalysisResult & Document;

@Schema()
export class AnalysisResult {
	@Prop({ type: TotalResultSchema, required: true })
	total: TotalResult;

	@Prop({ type: [RegionalResultSchema], required: true, default: [] })
	regional: RegionalResult[];

	@Prop({ type: [RegionalToTotalRatiosSchema], default: [] })
	regionalToTotalRatios: RegionalToTotalRatios[];

	@Prop({ required: true })
	createdAt: string;
}

export const AnalysisResultSchema = SchemaFactory.createForClass(AnalysisResult);

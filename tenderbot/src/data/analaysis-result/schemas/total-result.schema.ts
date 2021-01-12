import { Document } from 'mongoose';
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';

import { NumericalMetricsSchema, NumericalMetrics } from './numerical-metrics.schema';
import { WordFrequency, WordFrequencySchema } from './word-frequency.schema';

export type TotalResultDocument = TotalResult & Document;

@Schema()
export class TotalResult {
	@Prop({ required: true })
	tendersAmount: number;

	@Prop({ type: NumericalMetricsSchema })
	price: NumericalMetrics;

	@Prop({ type: NumericalMetricsSchema })
	hours: NumericalMetrics;

	@Prop({ type: NumericalMetricsSchema })
	pricePerHour: NumericalMetrics;

	@Prop({ type: [WordFrequencySchema] })
	wordFrequencies: WordFrequency[];
}

export const TotalResultSchema = SchemaFactory.createForClass(TotalResult);

import { Document } from 'mongoose';
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';

import { NumericalMetricsSchema, NumericalMetrics } from './numerical-metrics.schema';
import { WordFrequency, WordFrequencySchema } from './word-frequency.schema';

export type RegionalResultDocument = RegionalResult & Document;

@Schema()
export class RegionalResult {
	@Prop({ required: true })
	region: string;

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

export const RegionalResultSchema = SchemaFactory.createForClass(RegionalResult);

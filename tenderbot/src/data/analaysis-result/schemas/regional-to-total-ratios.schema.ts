import { Document } from 'mongoose';
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';

import { NumericalMetricsSchema, NumericalMetrics } from './numerical-metrics.schema';

export type RegionalToTotalRatiosDocument = RegionalToTotalRatios & Document;

@Schema()
export class RegionalToTotalRatios {
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
}

export const RegionalToTotalRatiosSchema = SchemaFactory.createForClass(RegionalToTotalRatios);

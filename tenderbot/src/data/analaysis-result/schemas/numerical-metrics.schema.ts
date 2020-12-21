import { Document } from 'mongoose';
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';

export type NumericalMetricsDocument = NumericalMetrics & Document;

@Schema()
export class NumericalMetrics {
	@Prop()
	average: number;

	@Prop()
	median: number;

	@Prop()
	min: number;

	@Prop()
	max: number;

	@Prop()
	sum: number;
}

export const NumericalMetricsSchema = SchemaFactory.createForClass(NumericalMetrics);

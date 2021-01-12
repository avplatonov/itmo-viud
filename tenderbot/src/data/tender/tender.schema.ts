import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type TenderDocument = Tender & Document;

@Schema()
export class Tender {
	@Prop({ required: true })
	title: string;

	@Prop({ required: true })
	customer: string;

	@Prop({ required: true })
	allocatedBudget: number;

	@Prop({ required: true })
	contestOpenDate: Date;

	@Prop({ required: true })
	contestClosedDate: Date;

	@Prop({ required: true })
	info: string;

	@Prop({ required: true })
	anouncementId: string;

	@Prop({ required: true })
	lotId: string;

	@Prop({ required: true })
	unitOfMeasure: string;

	@Prop({ required: true })
	amount: number;

	@Prop({ required: true })
	pricePerPiece: number;

	@Prop({ required: true })
	placeOfDelivery: string;

	@Prop({ required: true })
	regionofDelivery: string;
}

export const TenderSchema = SchemaFactory.createForClass(Tender);

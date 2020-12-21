import { Document } from 'mongoose';
import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';

export type WordFrequencyDocument = WordFrequency & Document;

@Schema()
export class WordFrequency {
	@Prop({ required: true })
	word: string;

	@Prop({ required: true })
	frequency: number;
}

export const WordFrequencySchema = SchemaFactory.createForClass(WordFrequency);

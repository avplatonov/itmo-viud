import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';

import { Tender, TenderSchema } from './tender.schema';
import { TenderService } from './tender.service';

@Module({
	imports: [MongooseModule.forFeature([{ name: Tender.name, schema: TenderSchema }])],
	providers: [TenderService],
	exports: [TenderService],
})
export class TenderModule {}

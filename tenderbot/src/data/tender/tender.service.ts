import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { Tender, TenderDocument } from './tender.schema';
import { TenderDto } from './tender.dto';
import { FilterInput } from 'src/globals/filter-input';

@Injectable()
export class TenderService {
	constructor(@InjectModel(Tender.name) private readonly tenderModel: Model<TenderDocument>) {}

	/**
	 * Gets Tender with specified id
	 * @param id
	 * @returns Tender
	 */
	async findOne(id: string): Promise<Tender> {
		return await this.tenderModel.findById(id);
	}

	/**
	 * Gets all Tenders
	 * @returns Tenders
	 */
	async findAll(): Promise<Tender[]> {
		return await this.tenderModel.find();
	}

	/**
	 * Gets all Tenders, filtered
	 * @param filters
	 * @returns Tenders
	 */
	async findAllFiltered(filters: FilterInput[]): Promise<Tender[]> {
		const query = this.tenderModel.find();
		for (let filter of filters) {
			query.where(filter.property).equals(filter.value);
		}
		return await query.exec();
	}

	/**
	 * Creates new Tender
	 * @param tenderDto
	 * @returns Tender
	 */
	async create(tenderDto: TenderDto): Promise<Tender> {
		return await new this.tenderModel(tenderDto).save();
	}

	/**
	 * Gets one tender with specified lotId
	 * @param lotId
	 * @returns Tender
	 */
	async findOneByLotId(lotId: string): Promise<Tender> {
		return await this.tenderModel.findOne({ lotId: lotId });
	}
}

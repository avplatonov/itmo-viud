import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

import { AnalysisResult, AnalysisResultDocument } from './schemas/analysis-result.schema';
import { AnalysisResultDto } from './interfaces/analysis-result.dto';

@Injectable()
export class AnalysisResultService {
	constructor(
		@InjectModel(AnalysisResult.name)
		private readonly analysisResultModel: Model<AnalysisResultDocument>,
	) {}

	/**
	 * Gets Analysis Result with specified id
	 * @param id
	 * @returns Analysis Result
	 */
	async findOne(id: string): Promise<AnalysisResult> {
		return await this.analysisResultModel.findById(id);
	}

	/**
	 * Gets all Analysis Results
	 * @returns Analysis Result
	 */
	async findAll(): Promise<AnalysisResult[]> {
		return await this.analysisResultModel.find();
	}

	/**
	 * Creates new Analysis Result
	 * @param analysisResultDto
	 * @returns Analysis Result
	 */
	async create(analysisResultDto: AnalysisResultDto): Promise<AnalysisResult> {
		return await new this.analysisResultModel(analysisResultDto).save();
	}
}

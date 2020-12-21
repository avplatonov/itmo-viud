import { Injectable, OnApplicationBootstrap } from '@nestjs/common';

import { LoggerService } from 'src/logger/logger.service';
import { TenderService } from 'src/data/tender/tender.service';
import { AnalysisResultService } from 'src/data/analaysis-result/analysis-result.service';
import { TenderDto } from 'src/data/tender/tender.dto';
import { AnalysisResultDto } from 'src/data/analaysis-result/interfaces/analysis-result.dto';
import { TotalResultDto } from 'src/data/analaysis-result/interfaces/total-result.dto';
import { RegionalResultDto } from 'src/data/analaysis-result/interfaces/regional-result.dto';
import { NumericalMetricsDto } from 'src/data/analaysis-result/interfaces/numerical-metrics.dto';
import { WordFrequencyDto } from 'src/data/analaysis-result/interfaces/word-frequency.dto';
import { FilterInput } from 'src/globals/filter-input';
import { RegionalToTotalRatiosDto } from 'src/data/analaysis-result/interfaces/regional-to-total-ratios.dto';
import { Interval } from '@nestjs/schedule';
import { info } from 'console';

@Injectable()
export class AnalyzerServcie implements OnApplicationBootstrap {
	constructor(
		private readonly loggerService: LoggerService,
		private readonly tenderService: TenderService,
		private readonly analysisResultService: AnalysisResultService,
	) {}

	private readonly regions: string[] = [
		'Акмолинская область',
		'Актюбинская область',
		'Алматинская область',
		'Атырауская область',
		'Восточно-Казахстанская область',
		'Жамбылская область',
		'Западно-Казахстанская область',
		'Карагандинская область',
		'Костанайская область',
		'Кызылординская область',
		'Мангистауская область',
		'Павлодарская область',
		'Северо-Казахстанская область',
		'Туркестанская область',
		'Южно-Казахстанская область',
		'г.Алматы',
		'г.Нур-Султан',
		'г.Шымкент',
	];
	private readonly ignoredWords: string[] = [
		'по',
		'и',
		'к',
		'с',
		'в',
		'от',
		'из',
		'для',
		'не',
		'на',
		'п',
		'б',
		'ко',
		'за',
		'рн',
		'бор',
		'лен',
		'их',
	];

	async onApplicationBootstrap(): Promise<void> {
		this.analyze();
	}

	@Interval(8.64e7)
	async analyze(): Promise<void> {
		const startTime = new Date();
		if (this.loggerService.settings.info) {
			this.loggerService.logInfo('Started analysis at ' + startTime.toISOString());
		}
		const tenders: TenderDto[] = await this.tenderService.findAll();

		const total = await this.analyzeTotal(tenders);
		const regional = await this.analyzeRegions(tenders);
		const regionalToTotalRatios = await this.analyzeRegionalToTotalRatios(regional, total);
		const result: AnalysisResultDto = {
			total: total,
			regional: regional,
			regionalToTotalRatios: regionalToTotalRatios,
			createdAt: new Date().toISOString(),
		};
		await this.analysisResultService.create(result);
		if (this.loggerService.settings.info) {
			this.loggerService.logInfo(
				'Finished analysis in ' +
					(new Date().getMilliseconds() - startTime.getMilliseconds()) / 1000 +
					' seconds',
			);
		}
	}

	async analyzeTotal(tenders: TenderDto[]): Promise<TotalResultDto> {
		const totalResult: TotalResultDto = await this.analyzeRawData(tenders, null);
		return totalResult;
	}

	async analyzeRegions(tenders: TenderDto[]): Promise<RegionalResultDto[]> {
		const tendersInRegions: { [id: string]: TenderDto[] } = {};
		for (let region of this.regions) {
			tendersInRegions[region] = [];
		}
		for (let tender of tenders) {
			tendersInRegions[tender.regionofDelivery].push(tender);
		}
		const regionalResults = [];
		for (let region of this.regions) {
			const regionalResult = await this.analyzeRawData(tendersInRegions[region], region);
			regionalResults.push(regionalResult);
		}
		return regionalResults;
	}

	async analyzeRegionalToTotalRatios(
		regional: RegionalResultDto[],
		total: TotalResultDto,
	): Promise<RegionalToTotalRatiosDto[]> {
		const regionalToTotalRatios: RegionalToTotalRatiosDto[] = [];
		for (let region of regional) {
			const thisRegionalToTotalRatios: RegionalToTotalRatiosDto = {
				region: region.region,
				tendersAmount: region.tendersAmount / total.tendersAmount,
				price: {
					average: region.price.average / total.price.average,
					median: region.price.median / total.price.median,
					min: region.price.min / total.price.min,
					max: region.price.max / total.price.max,
					sum: region.price.sum / total.price.sum,
				},
				hours: {
					average: region.hours.average / total.hours.average,
					median: region.hours.median / total.hours.median,
					min: region.hours.min / total.hours.min,
					max: region.hours.max / total.hours.max,
					sum: region.hours.sum / total.hours.sum,
				},
				pricePerHour: {
					average: region.pricePerHour.average / total.pricePerHour.average,
					median: region.pricePerHour.median / total.pricePerHour.median,
					min: region.pricePerHour.min / total.pricePerHour.min,
					max: region.pricePerHour.max / total.pricePerHour.max,
				},
			};
			regionalToTotalRatios.push(thisRegionalToTotalRatios);
		}
		return regionalToTotalRatios;
	}

	async analyzeRawData(tenders: TenderDto[], region?: string) {
		const tendersAmount = tenders.length;
		const price = await this.getPriceNumericalMetrics(tenders);
		const hours = await this.getHoursNumericalMetrics(tenders);
		const pricePerHour: NumericalMetricsDto = {
			min: price.min / hours.min,
			max: price.max / hours.max,
			average: price.average / hours.average,
			median: price.median / hours.median,
		};
		const wordFrequencies: WordFrequencyDto[] = await this.getWordFrequencies(tenders);
		if (region) {
			const regionalResult: RegionalResultDto = {
				region: region,
				tendersAmount: tendersAmount,
				price: price,
				hours: hours,
				pricePerHour: pricePerHour,
				wordFrequencies: wordFrequencies,
			};
			return regionalResult;
		} else {
			const totalResult: TotalResultDto = {
				tendersAmount: tendersAmount,
				price: price,
				hours: hours,
				pricePerHour: pricePerHour,
				wordFrequencies: wordFrequencies,
			};
			return totalResult;
		}
	}

	async getPriceNumericalMetrics(tenders: TenderDto[]): Promise<NumericalMetricsDto> {
		return await this.getNumericalMetrics(tenders.map((tender) => tender.allocatedBudget));
	}

	async getHoursNumericalMetrics(tenders: TenderDto[]): Promise<NumericalMetricsDto> {
		return await this.getNumericalMetrics(
			tenders.map(
				(tender) => (tender.contestClosedDate.getTime() - tender.contestOpenDate.getTime()) / 1000 / 60 / 60,
			),
		);
	}

	async getNumericalMetrics(numbers: number[]): Promise<NumericalMetricsDto> {
		numbers.sort((a, b) => a - b);
		const min = numbers[0];
		const max = numbers[numbers.length - 1];
		const sum = numbers.reduce((sum, current) => sum + current, 0);
		const avg = sum / numbers.length;
		const half = Math.floor(numbers.length / 2);
		const median = numbers.length % 2 ? numbers[half] : (numbers[half - 1] + numbers[half]) / 2;
		return {
			average: avg,
			median: median,
			min: min,
			max: max,
			sum: sum,
		};
	}

	async getWordFrequencies(tenders: TenderDto[]): Promise<WordFrequencyDto[]> {
		const words: string[] = tenders
			.map((tender) => tender.title.toLowerCase().replace(/[\(\)\/-]/g, ' '))
			.reduce((result, current) => result + current + ' ', '')
			.split(' ')
			.filter((item) => item != '' && item != ',' && this.ignoredWords.indexOf(item) == -1);
		const wordFrequencies: { [word: string]: number } = {};
		for (let word of words) {
			wordFrequencies[word] = wordFrequencies[word] ? wordFrequencies[word] + 1 : 1;
		}
		return await this.sortWordFrequenciesDictionary(wordFrequencies);
	}

	async sortWordFrequenciesDictionary(dictionary: { [word: string]: number }): Promise<WordFrequencyDto[]> {
		const sortable: WordFrequencyDto[] = [];
		for (let key in dictionary) {
			sortable.push({
				word: key,
				frequency: dictionary[key],
			});
		}
		return sortable.sort((a, b) => b.frequency - a.frequency);
	}

	async filterByKeywords(req) {
		let tenders: TenderDto[] = await this.tenderService.findAll();
		let titlePart = req['title'].toLowerCase();
		let measurePart = req['unitOfMeasure'].toLowerCase();
		let infoPart = req['info'].toLowerCase();

		let preFilteredTenders = tenders
			.filter(tender => tender.unitOfMeasure.toLowerCase().includes(measurePart));

		let titleKeywords = titlePart.split(' ');
		for (let keyword of titleKeywords) {
			preFilteredTenders = preFilteredTenders
				.filter(tender => tender.title.toLowerCase().includes(keyword));
		}

		let infoKeywords = infoPart.split(' ');
		for (let keyword of infoKeywords) {
			preFilteredTenders = preFilteredTenders
				.filter(tender => tender.info.toLowerCase().includes(keyword));
		}

		return await this.deepAnalyse(preFilteredTenders);
	}

	extractKeywordsAndLowercase(str: string): string[] {
		return str.split(' ').map((keyword) => keyword.toLowerCase());
	}

	async deepAnalyse(tenders: TenderDto[]) {
		// Max demand
		let tendersDemand = tenders
			.map((o) => o.regionofDelivery)
			.reduce((acc, o) => ((acc[o] = (acc[o] || 0) + 1), acc), {});
		let sortedTendersDemand = await this.sortWordFrequenciesDictionary(tendersDemand);
		// Max profit
		let maxProfitRegions = tenders
			.sort((a, b) => b.pricePerPiece - a.pricePerPiece)
			.slice(0, 5)
			.map((o) => [o.regionofDelivery, o.pricePerPiece]);
		// Max budget per tender
		let maxBudgetRegions = tenders
			.sort((a, b) => b.allocatedBudget - a.allocatedBudget)
			.slice(0, 5)
			.map((o) => [o.regionofDelivery, o.allocatedBudget]);
		// Max region budget
		let regionsBudgets: { [id: string]: number } = {};
		for (let i = 0; i < this.regions.length; i++) {
			regionsBudgets[this.regions[i]] = 0;
		}
		for (let i = 0; i < tenders.length; i++) {
			regionsBudgets[tenders[i].regionofDelivery] += tenders[i].allocatedBudget;
		}
		let sortedRegionsBudgets = await this.sortWordFrequenciesDictionary(regionsBudgets);
		return {
			maxDemand: sortedTendersDemand,
			maxProfitRegions: maxProfitRegions,
			maxBudgetRegions: maxBudgetRegions,
			regionsBudgets: sortedRegionsBudgets,
		};
	}
}

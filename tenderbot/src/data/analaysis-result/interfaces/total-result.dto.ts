import { NumericalMetricsDto } from './numerical-metrics.dto';
import { WordFrequencyDto } from './word-frequency.dto';

export interface TotalResultDto {
	tendersAmount: number;
	price?: NumericalMetricsDto;
	hours?: NumericalMetricsDto;
	pricePerHour?: NumericalMetricsDto;
	wordFrequencies?: WordFrequencyDto[];
}

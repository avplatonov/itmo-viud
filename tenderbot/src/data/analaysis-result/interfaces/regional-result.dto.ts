import { NumericalMetricsDto } from './numerical-metrics.dto';
import { WordFrequencyDto } from './word-frequency.dto';

export interface RegionalResultDto {
	region: string;
	tendersAmount: number;
	price?: NumericalMetricsDto;
	hours?: NumericalMetricsDto;
	pricePerHour?: NumericalMetricsDto;
	wordFrequencies?: WordFrequencyDto[];
}

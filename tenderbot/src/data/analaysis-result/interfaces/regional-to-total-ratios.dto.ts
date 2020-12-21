import { NumericalMetricsDto } from './numerical-metrics.dto';

export interface RegionalToTotalRatiosDto {
	region: string;
	tendersAmount: number;
	price?: NumericalMetricsDto;
	hours?: NumericalMetricsDto;
	pricePerHour?: NumericalMetricsDto;
}

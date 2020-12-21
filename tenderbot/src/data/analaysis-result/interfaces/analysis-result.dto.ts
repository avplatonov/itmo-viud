import { TotalResultDto } from './total-result.dto';
import { RegionalResultDto } from './regional-result.dto';
import { RegionalToTotalRatiosDto } from './regional-to-total-ratios.dto';

export interface AnalysisResultDto {
	total: TotalResultDto;
	regional: RegionalResultDto[];
	regionalToTotalRatios: RegionalToTotalRatiosDto[];
	createdAt: string;
}

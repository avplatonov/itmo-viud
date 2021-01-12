import { Controller, Get, Res, Post, Req } from '@nestjs/common';
import { Response, Request } from 'express';

import { AnalyzerServcie } from './analyzer.service';
import { config } from 'src/config';

@Controller('analyze')
export class AnalyzerController {
	constructor(private readonly analyzerService: AnalyzerServcie) {}

	@Get('filter')
	async filterPage(@Res() res: Response) {
		return res.render('analyze_filter', { domain: config.domain });
	}

	@Post('filter')
	async filter(@Req() req: Request) {
		return await this.analyzerService.filterByKeywords(req.body);
	}
}

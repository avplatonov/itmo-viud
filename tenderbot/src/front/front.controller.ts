import { Controller, Get, Render } from '@nestjs/common';

@Controller('')
export class FrontController {
	@Get('')
	@Render('landing')
	async landingPage() {}
}

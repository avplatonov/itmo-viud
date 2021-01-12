import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

import { AppModule } from './app.module';

async function bootstrap() {
	const crawler = await NestFactory.create<NestExpressApplication>(AppModule);

	crawler.setBaseViewsDir(join(__dirname, '..', 'views'));
	crawler.setViewEngine('hbs');

	await crawler.listen(3000);
}
bootstrap();

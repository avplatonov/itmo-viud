import { Injectable, OnApplicationBootstrap } from '@nestjs/common';
import { Interval } from '@nestjs/schedule';

import { LoggerService } from 'src/logger/logger.service';
import { TenderService } from 'src/data/tender/tender.service';
import { TenderDto } from 'src/data/tender/tender.dto';

import * as crawler from 'crawler';

@Injectable()
export class CrawlerService {
	constructor(private readonly loggerService: LoggerService, private readonly tenderService: TenderService) {}

	private crawlerOptions = {
		maxConnections: 15,
		callback: this.handle.bind(this),
	};

	private crawlerInstance = new crawler(this.crawlerOptions);

	private siteProperties = {
		baseUri: 'https://tenderbot.kz',
		pageAppend: '/goszakup/page/',
		tenderAppend: '/tender/',
	};

	private isPageExists: boolean = true;

	async crawlAll() {
		let pageNumber = 1;
		while (this.isPageExists) {
			const uri = `${this.siteProperties.baseUri + this.siteProperties.pageAppend}${pageNumber}`;
			this.loggerService.logDebug(`In queue: ${uri}`);
			await this.addToQueue(uri, 0);
			const delay = (ms) => new Promise((res) => setTimeout(res, ms));
			await delay(200);
			pageNumber++;
		}
	}

	@Interval(300000)
	async crawlNew() {
		const pagesToCrawl: number = 3;
		for (let page = 1; page <= pagesToCrawl; page++) {
			const uri = `${this.siteProperties.baseUri + this.siteProperties.pageAppend}${page}`;
			if (this.loggerService.settings.info) {
				this.loggerService.logDebug(`In queue: ${uri}`);
			}
			await this.addToQueue(uri, 0);
		}
	}

	async addToQueue(uri: string, priority: number): Promise<void> {
		await this.crawlerInstance.queue({
			uri: uri,
			priority: priority,
		});
		//await this.crawlerInstance.queue(uri);
	}

	async handle(error, result, done): Promise<void> {
		if (error) {
			if (this.loggerService.settings.error) {
				this.loggerService.logError(error);
			}
		} else {
			if (this.loggerService.settings.info) {
				this.loggerService.logInfo(`Status: ${result.statusCode} (${result.request.uri.href})`);
			}

			if (result.statusCode === 404) {
				this.isPageExists = false;
				done();
				return;
			}

			if (result.options.uri.includes(this.siteProperties.baseUri + this.siteProperties.pageAppend)) {
				this.handleList(result.$);
			} else {
				this.handleTender(result.$);
			}
		}
		done(result);
	}

	handleList(page) {
		page('.lot-list-item-main-info__title a').each((_, tenderAnchor) => {
			const link = tenderAnchor.attribs.href;
			this.addToQueue(`${this.siteProperties.baseUri}${link}`, 1);
		});
	}

	async handleTender(page) {
		const tender = this.getTenderFromTenderPage(page);
		const existingTender = await this.tenderService.findOneByLotId(tender.lotId);
		if (!existingTender) {
			await this.tenderService.create(tender);
			this.loggerService.logInfo(`CREATE ${tender.title}:${tender.lotId}`);
		}
	}

	getTenderFromTenderPage(page): TenderDto {
		const title = page('.ui_page_title').text().trim();
		const customer = page('.lot-content-customer__value').text().trim();
		const contestOpenDate = page('.lot-content-main-dates-item__value_open').text().trim();
		const contestClosedDate = page('.lot-content-main-dates-item__value_closed').text().trim();
		let info = '';
		page('.lot-content-main-info__description').each((_, descr) => {
			info += descr.children[0].data + '\n';
		});
		const anouncementId =
			page('.lot-content-main-values-item__value span').get(0).children[0].data +
			' ' +
			page('.lot-content-main-values-item__value span').get(1).children[0].data;
		const lotId = page('.lot-content-main-values-item__value').get(1).children[0].data.trim();
		const unitOfMeasure = page('.lot-content-main-values-item__value span').get(2).children[0].data;
		const amount = page('.lot-content-main-values-item__value span').get(3).children[0].data;
		const pricePerPiece = page('.lot-content-main-values-item__value span')
			.get(4)
			.children[0].data.replace(/\s/g, '');
		const placeOfDelivery = page('.lot-content-main-values-item__value span').get(5).children[0].data.trim();
		const regionOfDelivery = placeOfDelivery.substr(0, placeOfDelivery.indexOf(','));
		const allocatedBudget = page('.lot-info-price__value').text().replace(/\s/g, '');
		return {
			title: title,
			customer: customer,
			allocatedBudget: parseFloat(allocatedBudget),
			contestOpenDate: this.getDate(contestOpenDate),
			contestClosedDate: this.getDate(contestClosedDate),
			info: info,
			anouncementId: anouncementId,
			lotId: lotId,
			unitOfMeasure: unitOfMeasure,
			amount: parseInt(amount),
			pricePerPiece: parseFloat(pricePerPiece),
			placeOfDelivery: placeOfDelivery,
			regionofDelivery: regionOfDelivery,
		};
	}

	getDate(dateString: string): Date {
		const date = dateString.split(' ')[0];
		const time = dateString.split(' ')[1];
		return new Date(
			date.split('.')[2] +
				'-' +
				date.split('.')[1] +
				'-' +
				date.split('.')[0] +
				'T' +
				time.split(':')[0] +
				':' +
				time.split(':')[1] +
				':00',
		);
	}
}

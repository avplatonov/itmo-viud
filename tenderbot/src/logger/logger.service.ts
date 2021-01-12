import { Injectable } from '@nestjs/common';

@Injectable()
export class LoggerService {
	settings = {
		debug: true,
		info: true,
		error: true,
	};

	async logDebug(message) {
		if (this.settings.debug) {
			console.log('\x1b[2m%s\x1b[0m', `(DEBUG) ${message}`);
		}
	}

	async logInfo(message) {
		if (this.settings.info) {
			console.log('\x1b[94m%s\x1b[0m', `(INFO)  ${message}`);
		}
	}

	async logError(message) {
		if (this.settings.error) {
			console.log('\x1b[41m%s\x1b[0m', `(ERROR) ${message}`);
		}
	}
}

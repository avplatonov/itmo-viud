export interface TenderDto {
	title: string;
	customer: string;
	allocatedBudget: number;
	contestOpenDate: Date;
	contestClosedDate: Date;
	info: string;
	anouncementId: string;
	lotId: string;
	unitOfMeasure: string;
	amount: number;
	pricePerPiece: number;
	placeOfDelivery: string;
	regionofDelivery: string;
}

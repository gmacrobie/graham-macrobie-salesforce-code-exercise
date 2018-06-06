/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Unit test for PaymentDto.
*/

@isTest
private class PaymentDtoTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}
	
	@isTest static void testConstructor() {
		DeveloperToolsService.insertRandomPayments(100);

		PaymentsDto payments = new PaymentsDto();

		List<Payment__c> paymentList = [select 
			id, 
			name, 
			Project__c, 
			Project__r.name, 
			Project__r.TotalPayments__c, 
			Project__r.MostRecentPaymentDate__c, 
			Payer__c, 
			Payer__r.name, 
			Payer__r.FirstName,
			Payer__r.LastName,
			Payer__r.TotalPayments__c, 
			Payer__r.MostRecentPaymentDate__c, 
			Payer__r.Photo__c,
			PaymentDate__c, 
			PaymentAmount__c 

			from Payment__c limit 100];

		for (Payment__c payment : paymentList) {
			payments.data.add(new PaymentDto(payment));
		}

		String jsonData = JSON.serialize(payments);

		PaymentsDto newPayments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(100, newPayments.data.size());
	}
}
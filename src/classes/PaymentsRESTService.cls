/**
* @author Graham MacRobie
* @date November 19, 2017
*
* @description REST Service which returns all rows of Payment__c data (for now) in JSON format.
*/

@RestResource(urlMapping='/retrieve/*')

global with sharing class PaymentsRESTService {
	public static final Integer ROW_LIMIT = 10000;

	@HttpGet
	global static void doGet() {
		PaymentsDto payments = PaymentService.getAllPayments(ROW_LIMIT);

		String jsonData = payments.toJson();

		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.responseBody = Blob.valueOf(jsonData);
	}
}
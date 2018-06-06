/**
* @author Graham MacRobie
* @date November 19, 2017
*
* @description Unit test for PaymentsRESTService.
*/

@isTest
private class PaymentsRESTServiceTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}
	
	@isTest static void testDoGet() {
		DeveloperToolsService.insertRandomPayments(10);

		RestRequest req = new RestRequest();
		RestContext.request = req;
		
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/retrieve';  // Request URL
		req.httpMethod = 'GET';  // HTTP Request Type

		RestContext.response= res;

		PaymentsRESTService.doGet();

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(RestContext.response.responseBody.toString(), PaymentsDto.class);

		System.assertEquals(10, payments.data.size());
	}
}
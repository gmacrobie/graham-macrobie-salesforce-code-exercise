/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Unit test for PaymentsJSONController.
*/

@isTest
private class PaymentsJSONControllerTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}
	
	@isTest static void testConstructor() {
		DeveloperToolsService.insertRandomPayments(10);

		PaymentsJSONController controller = new PaymentsJSONController();

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(controller.jsonData, PaymentsDto.class);

		System.assertEquals(10, payments.data.size());
	}
}
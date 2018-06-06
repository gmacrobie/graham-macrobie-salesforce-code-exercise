/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Unit test for PaymentsDto.
*/

@isTest
private class PaymentsDtoTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}
	
	@isTest static void testContructor() {
		PaymentsDto payments = new PaymentsDto();

		payments.addFieldError('name', 'status');

		System.assertEquals('status', payments.fieldErrors.get(0).status);
	}
}
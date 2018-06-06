/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Unit tests for DeveloperToolsController
*/

@isTest
private class DeveloperToolsControllerTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	/**************************************************************************************************************
	* @description Tests insertion of 100 random payment records, confirms that 100 were added.
	*/

	@isTest static void testInsert() {
		DeveloperToolsController controller = new DeveloperToolsController();
		controller.numberOfPayments = 100;
		controller.insertRandom();

		List<Payment__c> payments = [select id from Payment__c];
		Integer sizeAfter = payments.size();

		System.assertEquals(100, sizeAfter);
	}

	/**************************************************************************************************************
	* @description Tests insertion of -3 payment records, confirms that 0 were added.
	*/

	@isTest static void testInsertBadNumber() {
		DeveloperToolsController controller = new DeveloperToolsController();
		controller.numberOfPayments = -3;  // negative not ok
		controller.insertRandom();

		List<Payment__c> payments = [select id from Payment__c];
		Integer sizeAfter = payments.size();

		System.assertEquals(0, sizeAfter);  // shouldn't have changed
	}

	/**************************************************************************************************************
	* @description Tests insertion of 100 payment records followed by deletion of 50 records, confirms that 50 remain.
	*/

	@isTest static void testDelete() {
		DeveloperToolsController controller = new DeveloperToolsController();
		controller.numberOfPayments = 100;
		controller.insertRandom();

		List<Payment__c> payments = [select id from Payment__c];
		Integer size = payments.size();

		DeveloperToolsController controller2 = new DeveloperToolsController();
		controller2.numberOfPayments = 50;
		controller2.deleteRandom();

		payments = [select id from Payment__c];
		Integer sizeAfter = payments.size();

		System.assertEquals(size - 50, sizeAfter);
	}
}
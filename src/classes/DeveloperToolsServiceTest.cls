/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Unit tests for DeveloperToolsService
*/

@isTest
private class DeveloperToolsServiceTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	/**************************************************************************************************************
	* @description Tests insertion of 100 random payment records, confirms that 100 were added.
	*/

	@isTest static void testInsert() {
		DeveloperToolsService.insertRandomPayments(100);

		List<Payment__c> payments = [select id from Payment__c];
		Integer sizeAfter = payments.size();

		System.assertEquals(100, sizeAfter);
	}

	/**************************************************************************************************************
	* @description Tests insertion of 100 payment records followed by deletion of 50 records, confirms that 50 remain.
	*/

	@isTest static void testDelete() {
		DeveloperToolsService.insertRandomPayments(100);

		List<Payment__c> payments = [select id from Payment__c];
		Integer size = payments.size();

		DeveloperToolsService.deleteRandomPayments(50);

		payments = [select id from Payment__c];
		Integer sizeAfter = payments.size();

		System.assertEquals(size - 50, sizeAfter);
	}

	/**************************************************************************************************************
	* @description Tests insertion of 100 payment records followed by deletion of 50 records, confirms that the 50
	* that remain are totalled correctly (max date too).
	*/

	@isTest static void testAudit() {
		DeveloperToolsService.insertRandomPayments(100);

		DeveloperToolsService.deleteRandomPayments(50);

		DeveloperToolsService.auditTotals();  // asserts are in this method
	}
}
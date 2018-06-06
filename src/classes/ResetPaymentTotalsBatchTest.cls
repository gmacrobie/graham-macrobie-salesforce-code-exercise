/**
* @author Graham MacRobie
* @date November 17, 2017
*
* @description Unit test for ResetPaymentTotalsBatch
*/

@isTest
private class ResetPaymentTotalsBatchTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	@isTest static void testBatch() {
		DeveloperToolsService.insertRandomPayments(100);

		List<Project__c> projects = [select id from Project__c limit 10];

		for (Project__c project : projects) {
			project.TotalPayments__c = 0;
			project.MostRecentPaymentDate__c = null;
		}

		update projects;

		List<Contact> contacts = [select id from Contact limit 10];

		for (Contact theContact : contacts) {
			theContact.TotalPayments__c = 0;
			theContact.MostRecentPaymentDate__c = null;
		}

		update contacts;

		ResetPaymentTotalsBatch theBatch = new ResetPaymentTotalsBatch(null, null);

		Database.QueryLocator locator = theBatch.start(null);
		List<Payment__c> scope = (List<Payment__c>) Database.query(locator.getQuery());

		theBatch.execute(null, scope);

		DeveloperToolsService.auditTotals();  // asserts are in this method
	}
}
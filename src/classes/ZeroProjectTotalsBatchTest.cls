/**
* @author Graham MacRobie
* @date November 17, 2017
*
* @description Unit test for ZeroProjectTotalsBatch
*/

@isTest
private class ZeroProjectTotalsBatchTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	@isTest static void testBatch() {
		DeveloperToolsService.insertRandomPayments(100);

		ZeroProjectTotalsBatch theBatch = new ZeroProjectTotalsBatch(null, null);

		Database.QueryLocator locator = theBatch.start(null);
		List<Project__c> scope = (List<Project__c>) Database.query(locator.getQuery());

		theBatch.execute(null, scope);

		List<Project__c> projects = [select id, TotalPayments__c, MostRecentPaymentDate__c from Project__c limit 10];

		for (Project__c project : projects) {
			System.assertEquals(0.00d, project.TotalPayments__c);
			System.assertEquals(null, project.MostRecentPaymentDate__c);
		}
	}
}
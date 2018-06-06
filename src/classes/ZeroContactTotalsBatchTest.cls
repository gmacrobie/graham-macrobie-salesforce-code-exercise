/**
* @author Graham MacRobie
* @date November 17, 2017
*
* @description Unit test for ZeroContactTotalsBatch
*/

@isTest
private class ZeroContactTotalsBatchTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	@isTest static void testBatch() {
		DeveloperToolsService.insertRandomPayments(100);

		ZeroContactTotalsBatch theBatch = new ZeroContactTotalsBatch(null, null);

		Database.QueryLocator locator = theBatch.start(null);
		List<Contact> scope = (List<Contact>) Database.query(locator.getQuery());

		theBatch.execute(null, scope);

		List<Contact> contacts = [select id, TotalPayments__c, MostRecentPaymentDate__c from Contact limit 10];

		for (Contact theContact : contacts) {
			System.assertEquals(0.00d, theContact.TotalPayments__c);
			System.assertEquals(null, theContact.MostRecentPaymentDate__c);
		}
	}
}
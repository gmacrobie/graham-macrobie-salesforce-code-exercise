/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Unit tests for RecomputeMostRecentPaymentDateBatch
*/

@isTest
private class RecomputeMostRecentPaymentDateBatchTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	@isTest static void testBatchContact() {
		DeveloperToolsService.insertRandomPayments(100);

		List<Contact> contacts = [select id from Contact limit 10];

		Set<Id> toRecompute = new Set<Id>();

		for (Contact theContact : contacts) {
			toRecompute.add(theContact.id);
		}

		RecomputeMostRecentPaymentDateBatch theBatch = new RecomputeMostRecentPaymentDateBatch(toRecompute, 'Payer__c', 'Contact');

		Database.QueryLocator locator = theBatch.start(null);
		List<Payment__c> scope = (List<Payment__c>) Database.query(locator.getQuery());

		theBatch.execute(null, scope);

		theBatch.finish(null);

		Map<Id, Contact> contactMap = new Map<Id, Contact>([select id, TotalPayments__c, MostRecentPaymentDate__c from Contact limit 10]);

		List<AggregateResult> results = [select Payer__c, Sum(PaymentAmount__c), Max(PaymentDate__c) from Payment__c group by Payer__c];

		for (AggregateResult result : results) {
			Id payerId = (Id) result.get('Payer__c');

			Contact theContact = contactMap.get(payerId);

			System.assertEquals(theContact.TotalPayments__c, result.get('expr0'));
			System.assertEquals(theContact.MostRecentPaymentDate__c, result.get('expr1'));
		}
	}

	@isTest static void testBatchProject() {
		DeveloperToolsService.insertRandomPayments(100);

		List<Project__c> projects = [select id from Project__c limit 10];

		Set<Id> toRecompute = new Set<Id>();

		for (Project__c project : projects) {
			toRecompute.add(project.id);
		}

		RecomputeMostRecentPaymentDateBatch theBatch = new RecomputeMostRecentPaymentDateBatch(toRecompute, 'Project__c', 'Project__c');

		Database.QueryLocator locator = theBatch.start(null);
		List<Payment__c> scope = (List<Payment__c>) Database.query(locator.getQuery());

		theBatch.execute(null, scope);

		theBatch.finish(null);

		Map<Id, Project__c> projectMap = new Map<Id, Project__c>([select id, TotalPayments__c, MostRecentPaymentDate__c from Project__c limit 10]);

		List<AggregateResult> results = [select Project__c, Sum(PaymentAmount__c), Max(PaymentDate__c) from Payment__c group by Project__c];

		for (AggregateResult result : results) {
			Id projectId = (Id) result.get('Project__c');

			Project__c project = projectMap.get(projectId);

			System.assertEquals(project.TotalPayments__c, result.get('expr0'));
			System.assertEquals(project.MostRecentPaymentDate__c, result.get('expr1'));
		}
	}
}
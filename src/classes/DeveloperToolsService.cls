/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Service class that handles insertion and deletion of random payment records for development purposes.
*/

public with sharing class DeveloperToolsService {
	/**************************************************************************************************************
	* @description Inserts random payment records for testing purposes.
	*
	* @param count the number of random payment records to create and insert
	*/

	public static void insertRandomPayments(Integer count) {
		List<Project__c> projects = [select id from Project__c limit 24999];
		List<Contact> payers = [select id from Contact limit 24999];

		List<Payment__c> toInsert = new List<Payment__c>();

		for (Integer i = 0; i < count; i++) {
			Integer projectIndex = (Integer) Math.floor(Math.random() * (Double) projects.size());
			Integer payerIndex = (Integer) Math.floor(Math.random() * (Double) payers.size());

			Decimal paymentAmount = (Math.floor(Math.random() * 98999.0d) + 1000.0d) / 100.0d;  // range 10.00 - 999.99
			paymentAmount.setScale(2);

			Integer daysBack = (Integer) Math.floor(Math.random() * 366.0d);  // range 0 - 365
			Date paymentDate = Date.today().addDays(-daysBack);

			Payment__c newPayment = new Payment__c();
			newPayment.Project__c = projects.get(projectIndex).id;
			newPayment.Payer__c = payers.get(payerIndex).id;
			newPayment.PaymentAmount__c = paymentAmount;
			newPayment.PaymentDate__c = paymentDate;

			toInsert.add(newPayment);
		}

		try {
			insert toInsert;

		} catch (DmlException ex) {
			throw ex;  // do nothing, handle exception in caller
		}
	}

	/**************************************************************************************************************
	* @description Deletes random payment records for testing purposes.
	*
	* @param count the number of random payment records to delete
	*/

	public static void deleteRandomPayments(Integer count) {
		List<Payment__c> payments = [select id from Payment__c limit 49999];

		if (count >= payments.size()) {
			delete payments;

			return;
		}

		// randomize list order

		for (Integer i = 0; i < (payments.size() * 5); i++) {  // roughly, swap the entire list 5 times
			Integer pos1 = (Integer) Math.floor(Math.random() * (Double) payments.size());
			Integer pos2 = (Integer) Math.floor(Math.random() * (Double) payments.size());

			// swap
			Payment__c temp = payments.get(pos1);
			payments.set(pos1, payments.get(pos2));
			payments.set(pos2, temp);
		}

		List<Payment__c> toDelete = new List<Payment__c>();

		for (Integer i = 0; i < count; i++) {
			toDelete.add(payments.get(i));
		}

		try {
			delete toDelete;

		} catch (DmlException ex) {
			throw ex;  // do nothing, handle exception in caller
		}
	}

	/**************************************************************************************************************
	* @description Simple tool to audit totals and max dates in Contact and Project__c.  This tool won't handle
	* large tables, but that's ok because the main purpose is to be able to quickly verify the integrity of the 
	* tables (after applying the Payment__c trigger algorithm) for testing only.  The method limits Contact and
	* Project__c records to 100 each, and is limited by SF governor limits for the group by clauses.  Intentionally
	* just throws an uncaught exception (through asserts) to make it easier for a developer to see what the descrepancy is.
	*/

	public static void auditTotals() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>([select id, TotalPayments__c, MostRecentPaymentDate__c from Contact limit 100]);

		List<AggregateResult> results = [select Payer__c, Sum(PaymentAmount__c), Max(PaymentDate__c) from Payment__c group by Payer__c];

		for (AggregateResult result : results) {
			Id payerId = (Id) result.get('Payer__c');

			Contact theContact = contactMap.get(payerId);

			System.assertEquals(theContact.TotalPayments__c, result.get('expr0'));
			System.assertEquals(theContact.MostRecentPaymentDate__c, result.get('expr1'));
		}

		Map<Id, Project__c> projectMap = new Map<Id, Project__c>([select id, TotalPayments__c, MostRecentPaymentDate__c from Project__c limit 100]);

		results = [select Project__c, Sum(PaymentAmount__c), Max(PaymentDate__c) from Payment__c group by Project__c];

		for (AggregateResult result : results) {
			Id projectId = (Id) result.get('Project__c');

			Project__c project = projectMap.get(projectId);

			System.assertEquals(project.TotalPayments__c, result.get('expr0'));
			System.assertEquals(project.MostRecentPaymentDate__c, result.get('expr1'));
		}
	}
}
/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Step 2 of a 3 step process to reset all the totals in Project__c and Contact (TotalPayments__c and
* MostRecentPaymentDate__c).  Step 3 is ResetPaymentTotalsBatch, which is chained from this batch's finish method.
* This was implemented as a batch so that it could handle huge numbers of Project__c, Contact, and Payment__c 
* records, if necessary.
*/

global class ZeroContactTotalsBatch implements Database.Batchable<sObject> {
	private String emailAddress;
	private Id userId;

	global static void go(String emailAddress, String userId) {
		Database.executeBatch(new ZeroContactTotalsBatch(emailAddress, userId), 9999);
	}

	global ZeroContactTotalsBatch(String emailAddress, Id userId) {
		this.emailAddress = emailAddress;
		this.userId = userId;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('select id, TotalPayments__c from Contact');
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
   		for (Contact theContact : scope) {
   			theContact.TotalPayments__c = 0;
   			theContact.MostRecentPaymentDate__c = null;
   			theContact.Recomputing__c = false;
   		}

   		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		ResetPaymentTotalsBatch.go(emailAddress, userId);
	}
}
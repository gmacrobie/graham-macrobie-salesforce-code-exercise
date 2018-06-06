/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Step 1 of a 3 step process to reset all the totals in Project__c and Contact (TotalPayments__c and
* MostRecentPaymentDate__c).  Step 2 is ZeroContactTotalsBatch, which is chained from this batch's finish method.
* This was implemented as a batch so that it could handle huge numbers of Project__c, Contact, and Payment__c 
* records, if necessary.
*/

global class ZeroProjectTotalsBatch implements Database.Batchable<sObject> {
	private String emailAddress;
	private Id userId;

	global static void go() {
		Database.executeBatch(new ZeroProjectTotalsBatch(UserInfo.getUserEmail(), UserInfo.getUserId()), 9999);
	}

	global ZeroProjectTotalsBatch(String emailAddress, Id userId) {
		this.emailAddress = emailAddress;
		this.userId = userId;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('select id, TotalPayments__c from Project__c');
	}

   	global void execute(Database.BatchableContext BC, List<Project__c> scope) {
   		for (Project__c project : scope) {
   			project.TotalPayments__c = 0;
   			project.MostRecentPaymentDate__c = null;
   			project.Recomputing__c = false;
   		}

   		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		ZeroContactTotalsBatch.go(emailAddress, userId);
	}
}
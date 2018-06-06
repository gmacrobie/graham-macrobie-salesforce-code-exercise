/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Step 3 of a 3 step process to reset all the totals in Project__c and Contact (TotalPayments__c and
* MostRecentPaymentDate__c).  This was implemented as a batch so that it could handle huge numbers of Project__c, 
* Contact, and Payment__c records, if necessary.  Fires off an email (from a template) when it finishes, to let
* the developer know that the process is complete.
*/

global class ResetPaymentTotalsBatch implements Database.Batchable<sObject> {
	private String emailAddress;
	private Id userId;

	global static void go(String emailAddress, Id userId) {
		Database.executeBatch(new ResetPaymentTotalsBatch(emailAddress, userId), 2400);
	}

	global ResetPaymentTotalsBatch(String emailAddress, Id userId) {
		this.emailAddress = emailAddress;
		this.userId = userId;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('select id, Project__c, Payer__c, PaymentDate__c, PaymentAmount__c from Payment__c');
	}

   	global void execute(Database.BatchableContext BC, List<Payment__c> scope) {
   		PaymentService.updateProjectsAndContacts(scope, null, false);
	}
	
	global void finish(Database.BatchableContext BC) {
		EmailTemplateUtility.sendSystemAlertEmail(emailAddress, 'Reset_Totals_Batch_Complete', null, userId);
	}
}
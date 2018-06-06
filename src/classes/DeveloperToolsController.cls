/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Controller for DeveloperTools VF page, a simple utility to allow testing of insert and delete trigger
* in bulk.  Can also launch a batch job to reset all totals if they get borked in testing.
*/

public with sharing class DeveloperToolsController {
	public Integer numberOfPayments {get; set;}  // input from user
	public Integer currentNumberOfPayments {get; set;}  // display current total for easy reference

	public DeveloperToolsController() {
		init();
	}

	public void init() {
		numberOfPayments = null;	

		List<Payment__c> payments = [select id from Payment__c limit 49999];  // table may have more rows, but the count will be off

		currentNumberOfPayments = payments.size();
	}

	/**************************************************************************************************************
	* @description Checks to ensure that numberOfPayments is > 0
	*
	* @return true if the validation succeeded
	*/

	private Boolean validateNumberOfPayments() {
		if (numberOfPayments <= 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, Label.PPG_MSG_Payment_Records_Positive));

			return false;
		}

		return true;
	}

	/**************************************************************************************************************
	* @description Handles commandButton to insert random payment records, based on numberOfPayments field.
	*
	* @return null PageReference (always)
	*/

	public PageReference insertRandom() {
		if (!validateNumberOfPayments()) {
			return null;
		}

		try {
			DeveloperToolsService.insertRandomPayments(numberOfPayments);
		
		} catch (DmlException ex) {
			System.debug(ex);

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, Label.PPG_MSG_Payments_Insert_Failed));

			return null;
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, numberOfPayments + ' ' + Label.PPG_MSG_Payments_Inserted));
		
		init();

		return null;
	}

	/**************************************************************************************************************
	* @description Handles commandButton to delete random payment records, based on numberOfPayments field.
	*
	* @return null PageReference (always)
	*/

	public PageReference deleteRandom() {
		if (!validateNumberOfPayments()) {
			return null;
		}

		if (numberOfPayments > currentNumberOfPayments) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, Label.PPG_MSG_Payment_Records_Too_Large));

			return null;
		}

		try {
			DeveloperToolsService.deleteRandomPayments(numberOfPayments);

		} catch (DmlException ex) {
			System.debug(ex);

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, Label.PPG_MSG_Payments_Delete_Failed));

			return null;
		}

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, numberOfPayments + ' ' + Label.PPG_MSG_Payments_Deleted));

		init();

		return null;
	}

	/**************************************************************************************************************
	* @description Handles commandButton to Kick off audit of the current totals for Contact and Project__c.
	*
	* @return null PageReference (always)
	*/

	public PageReference auditTotals() {
		DeveloperToolsService.auditTotals();

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, Label.PPG_MSG_Audit_Successful));

		return null;
	}

	/**************************************************************************************************************
	* @description Handles commandButton to Kick off the batch jobs to reset totals.
	*
	* @return null PageReference (always)
	*/

	public PageReference resetTotals() {
		PaymentService.resetTotals();

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, Label.PPG_MSG_Reset_Batch_Started));

		return null;
	}
}
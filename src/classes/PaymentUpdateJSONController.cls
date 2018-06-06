/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Controller for PaymentUpdateJSON VF page (returns JSON only).  Supports adding, editing, and deleting
* Payment__c records.
*/

public with sharing class PaymentUpdateJSONController {
	public String jsonData {get; set;}

	public PaymentUpdateJSONController() {
	}

	public PageReference go() {  // DML can't happen in the constructor, called from page action on load
		Map<String, String> params = ApexPages.currentPage().getParameters();

		return doWork(params);
	}

	public PageReference doWork(Map<String, String> params) {  // not in go() to make unit testing easier (params can be specified in test)
		String action = params.get('action');

		if (action == null) {
			throw new InvalidParameterValueException('action', null);
		}

		if (action.equalsIgnoreCase('create')) {
			jsonData = PaymentService.doCreate(params);

		} else if (action.equalsIgnoreCase('edit')) {
			jsonData = PaymentService.doEdit(params);

		} else if (action.equalsIgnoreCase('remove')) {
			jsonData = PaymentService.doDelete(params);

		} else {
			throw new InvalidParameterValueException('action', action);
		}

		return null;
	}
}
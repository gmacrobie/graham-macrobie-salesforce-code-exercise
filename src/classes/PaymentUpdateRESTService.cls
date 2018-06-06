/**
* @author Graham MacRobie
* @date November 19, 2017
*
* @description REST Service which supports updates to Payment__c objects (add, edit, delete).  Returns JSON.
*/

@RestResource(urlMapping='/update/*')

global with sharing class PaymentUpdateRESTService {
	@HttpGet
	global static void doGet() {
		Map<String, String> params = RestContext.request.params;

		String jsonData = doWork(params);

		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.responseBody = Blob.valueOf(jsonData);
	}

	public static String doWork(Map<String, String> params) {  // not in doGet() to make unit testing easier (params can be specified in test)
		String action = params.get('action');

		if (action == null) {
			throw new InvalidParameterValueException('action', null);
		}

		if (action.equalsIgnoreCase('create')) {
			return PaymentService.doCreate(params);

		} else if (action.equalsIgnoreCase('edit')) {
			return PaymentService.doEdit(params);

		} else if (action.equalsIgnoreCase('remove')) {
			return PaymentService.doDelete(params);

		} else {
			throw new InvalidParameterValueException('action', action);
		}

		return null;
	}
}
/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Controller for PaymentsJSON Visualforce page.  AJAX / JSON interface to retrieve initial Payment__c rows.
*/

public with sharing class PaymentsJSONController {
	public static final Integer ROW_LIMIT = 10000;

	public String jsonData {get; set;}

	public PaymentsJSONController() {
		PaymentsDto payments = PaymentService.getAllPayments(ROW_LIMIT);

		jsonData = payments.toJson();
	}
}
/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Data Transfer Object (like Java bean) for a payment record.
*/

public with sharing class PaymentDto {
	public Id paymentId {get; set;}
	public String paymentName {get; set;}
	
	public Id projectId {get; set;}
	public String projectName {get; set;}
	public String totalProjectPayments {get; set;}  // sent as string for formatting purposes
	public Date mostRecentProjectPaymentDate {get; set;}
	
	public Id payerId {get; set;}
	public String payerName {get; set;}
	public String totalPayerPayments {get; set;}  // sent as string for formatting purposes
	public Date mostRecentPayerPaymentDate {get; set;}
	public String payerPhoto {get; set;}
	
	public Decimal paymentAmount {get; set;}
	public Date paymentDate {get; set;}

	public PaymentDto() {
	}

	/**************************************************************************************************************
	* @description Convenience constructor that initializes all field values from a Payment__c SObject.
	*
	* @param payment the Payment__c SObject to clone
	*/

	public PaymentDto(Payment__c payment) {
		paymentId = payment.id;
		paymentName = payment.name;

		projectId = payment.Project__c;
		projectName = payment.Project__r.name;
		totalProjectPayments = (payment.Project__r.TotalPayments__c != null) ? '$' + payment.Project__r.TotalPayments__c.setScale(2).format() : '$0.00';
		mostRecentProjectPaymentDate = payment.Project__r.MostRecentPaymentDate__c;

		payerId = payment.Payer__c;
		payerName = payment.Payer__r.LastName + ', ' + payment.Payer__r.FirstName;
		totalPayerPayments = (payment.Payer__r.TotalPayments__c != null) ? '$' + payment.Payer__r.TotalPayments__c.setScale(2).format() : '$0.00';
		mostRecentPayerPaymentDate = payment.Payer__r.MostRecentPaymentDate__c;
		payerPhoto = payment.Payer__r.Photo__c;

		paymentAmount = payment.PaymentAmount__c;
		paymentDate = payment.PaymentDate__c;
	}
}
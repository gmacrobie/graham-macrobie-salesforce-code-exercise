/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Data Transfer Object (like Java bean) for a list of payment records.
*/

public with sharing class PaymentsDto {
	public List<PaymentDto> data;
	public String error;
	public List<FieldErrorDto> fieldErrors;
	
	public PaymentsDto() {
		data = new List<PaymentDto>();
	}

	public void addPayment(PaymentDto payment) {
		data.add(payment);
	}

	public void setError(String error) {
		this.error = error;
	}

	/**************************************************************************************************************
	* @description Adds a field error to the DTO response.
	*
	* @param name the field name
	* @param status the error message
	*/

	public void addFieldError(String name, String status) {
		if (fieldErrors == null) {
			fieldErrors = new List<FieldErrorDto>();
		}

		fieldErrors.add(new FieldErrorDto(name, status));
	}

	public String toJson() {
		return JSON.serialize(this);
	}
}
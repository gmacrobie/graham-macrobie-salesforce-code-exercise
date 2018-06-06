/**
* @author Graham MacRobie
* @date November 15, 2017
*
* @description Data Transfer Object (like Java bean) for field errors.  No unit test necessary.
*/

public with sharing class FieldErrorDto {
	public String name;  // field name
	public String status;  // field error message

	public FieldErrorDto() {
	}

	/**************************************************************************************************************
	* @description Convenience constructor that initializes all field values.
	*
	* @param name the name of the field that has an error
	* @param status the message associated with the field error
	*/

	public FieldErrorDto(String name, String status) {
		this.name = name;
		this.status = status;
	}
}
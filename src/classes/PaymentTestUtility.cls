/**
* @author Graham MacRobie
* @date November 16, 2017
*
* @description Common setup for Payment__c related tests.  Creates Project__c and Contact records.
*/

@isTest
public with sharing class PaymentTestUtility {
	public static final String PROJECT_NAME_1 = 'Test Project 1';
	public static final String PROJECT_NAME_2 = 'Test Project 2';
	public static final String PROJECT_NAME_3 = 'Test Project 3';

	public static final String CONTACT_FIRSTNAME_1 = 'John';
	public static final String CONTACT_FIRSTNAME_2 = 'Jane';
	public static final String CONTACT_FIRSTNAME_3 = 'Robert';

	public static final String CONTACT_LASTNAME_1 = 'Doe';
	public static final String CONTACT_LASTNAME_2 = 'Smith';
	public static final String CONTACT_LASTNAME_3 = 'Black';

	public static void setup() {
		List<Project__c> projects = new List<Project__c>();

		Project__c project1 = new Project__c(name = PROJECT_NAME_1);
		projects.add(project1);

		Project__c project2 = new Project__c(name = PROJECT_NAME_2);
		projects.add(project2);

		Project__c project3 = new Project__c(name = PROJECT_NAME_3);
		projects.add(project3);

		insert projects;

		List<Contact> contacts = new List<Contact>();

		Contact contact1 = new Contact(firstName = CONTACT_FIRSTNAME_1, lastName = CONTACT_LASTNAME_1);
		contacts.add(contact1);

		Contact contact2 = new Contact(firstName = CONTACT_FIRSTNAME_2, lastName = CONTACT_LASTNAME_2);
		contacts.add(contact2);

		Contact contact3 = new Contact(firstName = CONTACT_FIRSTNAME_3, lastName = CONTACT_LASTNAME_3);
		contacts.add(contact3);

		insert contacts;
	}
}
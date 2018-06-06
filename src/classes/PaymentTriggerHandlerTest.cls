/**
* @author Graham MacRobie
* @date November 13, 2017
*
* @description Unit tests for PaymentTriggerHandler.
*/

@isTest
private class PaymentTriggerHandlerTest {
	private static final Decimal PAYMENT_AMOUNT_1 = 5.00;
	private static final Decimal PAYMENT_AMOUNT_2 = 13.57;
	private static final Decimal PAYMENT_AMOUNT_3 = 52358.22;
	private static final Decimal PAYMENT_AMOUNT_4 = 31.80;
	private static final Decimal PAYMENT_AMOUNT_5 = 0.1;
	private static final Decimal PAYMENT_AMOUNT_6 = 8235.17;

	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	private static Payment__c insertOnePayment() {
		Project__c project = [select id from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		Contact theContact = [select id from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		Payment__c payment = new Payment__c(Project__c = project.id, Payer__c = theContact.id, PaymentDate__c = Date.today(), PaymentAmount__c = PAYMENT_AMOUNT_1);

		insert payment;

		return payment;
	}	

	@isTest static void testInsertOnePayment() {
		insertOnePayment();

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		Contact theContact = [select id, TotalPayments__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(PAYMENT_AMOUNT_1, project.TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_1, theContact.TotalPayments__c);
	}

	@isTest static void testUpdateOnePayment() {
		Payment__c payment = insertOnePayment();

		payment.PaymentAmount__c = PAYMENT_AMOUNT_4;

		update payment;

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		Contact theContact = [select id, TotalPayments__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(PAYMENT_AMOUNT_4, project.TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_4, theContact.TotalPayments__c);
	}

	@isTest static void testDeleteOnePayment() {
		Payment__c payment = insertOnePayment();

		delete payment;

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		Contact theContact = [select id, TotalPayments__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(0, project.TotalPayments__c);
		System.assertEquals(0, theContact.TotalPayments__c);
	}

	@isTest static void testUndeleteOnePayment() {
		Payment__c payment = insertOnePayment();

		delete payment;

		undelete payment;

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		Contact theContact = [select id, TotalPayments__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(PAYMENT_AMOUNT_1, project.TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_1, theContact.TotalPayments__c);
	}

	private static List<Payment__c> insertMultiplePayments() {
		List<Project__c> projects = [select id from Project__c order by id limit 3];
		List<Contact> contacts = [select id from Contact order by id limit 3];

		List<Payment__c> payments = new List<Payment__c>();

		Payment__c payment1 = new Payment__c(Project__c = projects.get(0).id, Payer__c = contacts.get(0).id, PaymentDate__c = Date.today(), PaymentAmount__c = PAYMENT_AMOUNT_1);
		payments.add(payment1);

		Payment__c payment2 = new Payment__c(Project__c = projects.get(1).id, Payer__c = contacts.get(1).id, PaymentDate__c = Date.today().addDays(-7), PaymentAmount__c = PAYMENT_AMOUNT_2);
		payments.add(payment2);

		Payment__c payment3 = new Payment__c(Project__c = projects.get(2).id, Payer__c = contacts.get(2).id, PaymentDate__c = Date.today().addDays(-14), PaymentAmount__c = PAYMENT_AMOUNT_3);
		payments.add(payment3);

		insert payments;

		return payments;
	}

	@isTest static void testInsertMultiplePayments() {
		insertMultiplePayments();

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_1, projects.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_1, contacts.get(0).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_2, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_2, contacts.get(1).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_3, projects.get(2).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, contacts.get(2).TotalPayments__c);
	}

	@isTest static void testUpdateMultiplePayments() {
		List<Payment__c> payments = insertMultiplePayments();

		payments.get(0).PaymentAmount__c = PAYMENT_AMOUNT_4;
		payments.get(1).PaymentAmount__c = PAYMENT_AMOUNT_5;
		payments.get(2).PaymentAmount__c = PAYMENT_AMOUNT_6;

		update payments;

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_4, projects.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_4, contacts.get(0).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_5, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_5, contacts.get(1).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_6, projects.get(2).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_6, contacts.get(2).TotalPayments__c);
	}

	@isTest static void testDeleteMultiplePayments() {
		List<Payment__c> payments = insertMultiplePayments();

		List<Payment__c> toDelete = new List<Payment__c>();

		toDelete.add(payments.get(0));
		toDelete.add(payments.get(1));

		delete toDelete;

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(0, projects.get(0).TotalPayments__c);
		System.assertEquals(0, contacts.get(0).TotalPayments__c);

		System.assertEquals(0, projects.get(1).TotalPayments__c);
		System.assertEquals(0, contacts.get(1).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_3, projects.get(2).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, contacts.get(2).TotalPayments__c);
	}

	@isTest static void testUndeleteMultiplePayments() {
		List<Payment__c> payments = insertMultiplePayments();

		List<Payment__c> toDelete = new List<Payment__c>();

		toDelete.add(payments.get(0));
		toDelete.add(payments.get(1));

		delete toDelete;

		undelete toDelete;

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_1, projects.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_1, contacts.get(0).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_2, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_2, contacts.get(1).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_3, projects.get(2).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, contacts.get(2).TotalPayments__c);
	}

	private static List<Payment__c> insertMultiplePaymentsOneProject() {
		Project__c project = [select id from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		List<Contact> contacts = [select id from Contact order by id limit 3];

		List<Payment__c> payments = new List<Payment__c>();

		Payment__c payment1 = new Payment__c(Project__c = project.id, Payer__c = contacts.get(0).id, PaymentDate__c = Date.today(), PaymentAmount__c = PAYMENT_AMOUNT_1);
		payments.add(payment1);

		Payment__c payment2 = new Payment__c(Project__c = project.id, Payer__c = contacts.get(1).id, PaymentDate__c = Date.today().addDays(-7), PaymentAmount__c = PAYMENT_AMOUNT_2);
		payments.add(payment2);

		Payment__c payment3 = new Payment__c(Project__c = project.id, Payer__c = contacts.get(2).id, PaymentDate__c = Date.today().addDays(-14), PaymentAmount__c = PAYMENT_AMOUNT_3);
		payments.add(payment3);

		insert payments;

		return payments;
	}

	@isTest static void testInsertMultiplePaymentsOneProject() {
		insertMultiplePaymentsOneProject();

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_1 + PAYMENT_AMOUNT_2 + PAYMENT_AMOUNT_3, project.TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_1, contacts.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_2, contacts.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, contacts.get(2).TotalPayments__c);
	}

	@isTest static void testUpdateMultiplePaymentsOneProject() {
		List<Payment__c> payments = insertMultiplePaymentsOneProject();

		payments.get(0).PaymentAmount__c = PAYMENT_AMOUNT_4;
		payments.get(1).PaymentAmount__c = PAYMENT_AMOUNT_5;
		payments.get(2).PaymentAmount__c = PAYMENT_AMOUNT_6;

		update payments;

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_4 + PAYMENT_AMOUNT_5 + PAYMENT_AMOUNT_6, project.TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_4, contacts.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_5, contacts.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_6, contacts.get(2).TotalPayments__c);
	}

	@isTest static void testDeleteMultiplePaymentsOneProject() {
		List<Payment__c> payments = insertMultiplePaymentsOneProject();

		List<Payment__c> toDelete = new List<Payment__c>();

		toDelete.add(payments.get(0));
		toDelete.add(payments.get(1));

		delete toDelete;

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_3, project.TotalPayments__c);

		System.assertEquals(0, contacts.get(0).TotalPayments__c);
		System.assertEquals(0, contacts.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, contacts.get(2).TotalPayments__c);
	}

	@isTest static void testUndeleteMultiplePaymentsOneProject() {
		List<Payment__c> payments = insertMultiplePaymentsOneProject();

		List<Payment__c> toDelete = new List<Payment__c>();

		toDelete.add(payments.get(0));
		toDelete.add(payments.get(1));

		delete toDelete;

		undelete toDelete;

		Project__c project = [select id, TotalPayments__c from Project__c where name = :PaymentTestUtility.PROJECT_NAME_1];
		List<Contact> contacts = [select id, TotalPayments__c from Contact order by id limit 3];

		System.assertEquals(PAYMENT_AMOUNT_1 + PAYMENT_AMOUNT_2 + PAYMENT_AMOUNT_3, project.TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_1, contacts.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_2, contacts.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, contacts.get(2).TotalPayments__c);
	}

	private static List<Payment__c> insertMultiplePaymentsOneContact() {
		List<Project__c> projects = [select id from Project__c order by id limit 3];
		Contact theContact = [select id from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		List<Payment__c> payments = new List<Payment__c>();

		Payment__c payment1 = new Payment__c(Project__c = projects.get(0).id, Payer__c = theContact.id, PaymentDate__c = Date.today(), PaymentAmount__c = PAYMENT_AMOUNT_1);
		payments.add(payment1);

		Payment__c payment2 = new Payment__c(Project__c = projects.get(1).id, Payer__c = theContact.id, PaymentDate__c = Date.today().addDays(-7), PaymentAmount__c = PAYMENT_AMOUNT_2);
		payments.add(payment2);

		Payment__c payment3 = new Payment__c(Project__c = projects.get(2).id, Payer__c = theContact.id, PaymentDate__c = Date.today().addDays(-14), PaymentAmount__c = PAYMENT_AMOUNT_3);
		payments.add(payment3);

		insert payments;

		return payments;
	}

	@isTest static void testInsertMultiplePaymentsOneContact() {
		insertMultiplePaymentsOneContact();

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		Contact theContact = [select id, TotalPayments__c, MostRecentPaymentDate__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(PAYMENT_AMOUNT_1, projects.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_2, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, projects.get(2).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_1 + PAYMENT_AMOUNT_2 + PAYMENT_AMOUNT_3, theContact.TotalPayments__c);

		System.assertEquals(Date.today(), theContact.MostRecentPaymentDate__c);
	}

	@isTest static void testUpdateMultiplePaymentsOneContact() {
		List<Payment__c> payments = insertMultiplePaymentsOneContact();

		payments.get(0).PaymentAmount__c = PAYMENT_AMOUNT_4;
		payments.get(0).PaymentDate__c = Date.today().addDays(-1);
		payments.get(1).PaymentAmount__c = PAYMENT_AMOUNT_5;
		payments.get(2).PaymentAmount__c = PAYMENT_AMOUNT_6;

		update payments;

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		Contact theContact = [select id, TotalPayments__c, MostRecentPaymentDate__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(PAYMENT_AMOUNT_4, projects.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_5, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_6, projects.get(2).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_4 + PAYMENT_AMOUNT_5 + PAYMENT_AMOUNT_6, theContact.TotalPayments__c);

		System.assertEquals(Date.today().addDays(-1), theContact.MostRecentPaymentDate__c);
	}

	@isTest static void testDeleteMultiplePaymentsOneContact() {
		List<Payment__c> payments = insertMultiplePaymentsOneContact();

		List<Payment__c> toDelete = new List<Payment__c>();

		toDelete.add(payments.get(0));
		toDelete.add(payments.get(1));

		delete toDelete;

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		Contact theContact = [select id, TotalPayments__c, MostRecentPaymentDate__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(0, projects.get(0).TotalPayments__c);
		System.assertEquals(0, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, projects.get(2).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_3, theContact.TotalPayments__c);

		System.assertEquals(Date.today().addDays(-14), theContact.MostRecentPaymentDate__c);
	}

	@isTest static void testUndeleteMultiplePaymentsOneContact() {
		List<Payment__c> payments = insertMultiplePaymentsOneContact();

		List<Payment__c> toDelete = new List<Payment__c>();

		toDelete.add(payments.get(0));
		toDelete.add(payments.get(1));

		delete toDelete;

		undelete toDelete;

		List<Project__c> projects = [select id, TotalPayments__c from Project__c order by id limit 3];
		Contact theContact = [select id, TotalPayments__c, MostRecentPaymentDate__c from Contact where firstName = :PaymentTestUtility.CONTACT_FIRSTNAME_1 and lastName = :PaymentTestUtility.CONTACT_LASTNAME_1];

		System.assertEquals(PAYMENT_AMOUNT_1, projects.get(0).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_2, projects.get(1).TotalPayments__c);
		System.assertEquals(PAYMENT_AMOUNT_3, projects.get(2).TotalPayments__c);

		System.assertEquals(PAYMENT_AMOUNT_1 + PAYMENT_AMOUNT_2 + PAYMENT_AMOUNT_3, theContact.TotalPayments__c);

		System.assertEquals(Date.today(), theContact.MostRecentPaymentDate__c);
	}
}
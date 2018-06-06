/**
* @author Graham MacRobie
* @date November 13, 2017
*
* @description Unit tests for PaymentService.
*/

@isTest
private class PaymentServiceTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	@isTest static void testDoCreate() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(1, payments.data.size());
	}

	@isTest static void testDoCreateMissingPayment() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Numerical, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateInvalidPayment() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', 'a');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Numerical, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateNegativePayment() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '-5');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Positive, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreatePaymentTooLarge() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '1000000001');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Max, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateMissingDate() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Date_Format, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateBadDate() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', 'a');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Date_Format, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateOldDate() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '2014-01-01');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Date_Last_Year, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateFutureDate() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '2020-01-01');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payment_Date_Future, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateMissingProject() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', '');
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Project_Name_Selected, payments.fieldErrors.get(0).status);
	}

	@isTest static void testDoCreateMissingPayer() {
		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		Map<String, String> params = new Map<String, String>();

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', '');
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doCreate(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(Label.PPG_MSG_Payer_Id_Invalid, payments.error);
	}

	@isTest static void testDoEdit() {
		DeveloperToolsService.insertRandomPayments(1);

		Payment__c payment = [select id from Payment__c limit 1];

		Id paymentId = payment.id;

		Map<String, String> params = new Map<String, String>();

		params.put('data[' + paymentId + '][paymentAmount]', '5.00');
		params.put('data[' + paymentId + '][paymentDate]', '2017-11-17');

		String jsonData = PaymentService.doEdit(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(5.00d, payments.data.get(0).paymentAmount);
		System.assertEquals(Date.valueOf('2017-11-17'), payments.data.get(0).paymentDate);
	}

	@isTest static void testDoDelete() {
		DeveloperToolsService.insertRandomPayments(1);

		Payment__c payment = [select id from Payment__c limit 1];

		Id paymentId = payment.id;

		Map<String, String> params = new Map<String, String>();

		params.put('data[' + paymentId + '][paymentId]', '');

		String jsonData = PaymentService.doDelete(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(0, payments.data.size());
	}
}
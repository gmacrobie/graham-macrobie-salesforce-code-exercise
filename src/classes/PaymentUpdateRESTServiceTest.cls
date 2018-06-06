/**
* @author Graham MacRobie
* @date November 19, 2017
*
* @description Unit tests for PaymentUpdateRESTService.
*/

@isTest
private class PaymentUpdateRESTServiceTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}

	@isTest static void testCreate() {
		Map<String, String> params = new Map<String, String>();
		params.put('action', 'create');

		Contact payer = [select id from Contact limit 1];
		Project__c project = [select id from Project__c limit 1];

		params.put('data[0][projectSelect]', project.id);
		params.put('data[0][payerId]', payer.id);
		params.put('data[0][paymentAmount]', '5.00');
		params.put('data[0][paymentDate]', '2017-11-17');

		String jsonData = PaymentUpdateRESTService.doWork(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(1, payments.data.size());
	}

	@isTest static void testEdit() {
		Map<String, String> params = new Map<String, String>();
		params.put('action', 'edit');

		DeveloperToolsService.insertRandomPayments(1);

		Payment__c payment = [select id from Payment__c limit 1];

		Id paymentId = payment.id;

		params.put('data[' + paymentId + '][paymentAmount]', '5.00');
		params.put('data[' + paymentId + '][paymentDate]', '2017-11-17');

		String jsonData = PaymentUpdateRESTService.doWork(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(5.00d, payments.data.get(0).paymentAmount);
		System.assertEquals(Date.valueOf('2017-11-17'), payments.data.get(0).paymentDate);
	}

	@isTest static void testDelete() {
		Map<String, String> params = new Map<String, String>();
		params.put('action', 'remove');

		DeveloperToolsService.insertRandomPayments(1);

		Payment__c payment = [select id from Payment__c limit 1];

		Id paymentId = payment.id;

		params.put('data[' + paymentId + '][paymentId]', '');

		String jsonData = PaymentUpdateRESTService.doWork(params);

		PaymentsDto payments = (PaymentsDto) JSON.deserialize(jsonData, PaymentsDto.class);

		System.assertEquals(0, payments.data.size());
	}
}
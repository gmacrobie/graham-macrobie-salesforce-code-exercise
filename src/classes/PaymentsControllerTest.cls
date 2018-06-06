/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Unit test for PaymentsController.
*/

@isTest
private class PaymentsControllerTest {
	@testSetup static void setup() {
		PaymentTestUtility.setup();
	}
	
	@isTest static void testController() {
		PaymentsController controller = new PaymentsController();

		System.debug(controller.projectsJson);

		List<PaymentsController.ProjectSelectDto> projects = (List<PaymentsController.ProjectSelectDto>) JSON.deserialize(controller.projectsJson, List<PaymentsController.ProjectSelectDto>.class);

		System.assertEquals(4, projects.size());  // 3 projects from setup plus 1 "not selected yet" option
	}
}
/**
* @author Graham MacRobie
* @date November 16, 2017
*
* @description Unit tests for EmailTemplateUtility
*/

@isTest
private class EmailTemplateUtilityTest {
	@isTest static void testSendEmail() {
		Contact c = new Contact(LastName = 'Smith');
		insert c;

		EmailTemplateUtility.sendSystemAlertEmail('graham@macrobie.com', 'Reset_Totals_Batch_Complete', null, c.id);

		// basically just ensuring that this doesn't throw an exception
	}
}
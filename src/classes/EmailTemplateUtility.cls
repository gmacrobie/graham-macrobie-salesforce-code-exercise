/**
* @author Graham MacRobie
* @date November 16, 2017
*
* @description Utility class to help easily send an email template from Apex.
*/

public with sharing class EmailTemplateUtility {
	/**************************************************************************************************************
	* @description Convenience constructor with all previous and new values.
	*
	* @param toAddress the email address to send to
	* @param templateApiName the API name of the email template to use
	* @param whatId Id of the object that the template relates to
	* @param userId Id of the user that is being notified
	*/

	public static void sendSystemAlertEmail(String toAddress, String templateApiName, Id whatId, Id userId) {
		List<String> toRecipients = new List<String>();
		toRecipients.add(toAddress);

		List<String> ccRecipients = new List<String>();
		ccRecipients.add('graham@macrobie.com');

		try {
			Id templateId = [select id, Name from EmailTemplate where DeveloperName = :templateApiName limit 1].id;

			Id orgWideEmailId = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Graham MacRobie' limit 1].id;

			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

			email.setToAddresses(toRecipients);
			email.setCcAddresses(ccRecipients);
			email.setTargetObjectId(userId);
			email.setWhatId(whatId);
			email.setorgWideEmailAddressId(orgWideEmailId);
			email.setTemplateId(templateId);
			email.setSaveAsActivity(false);

			Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

			if (!results[0].success) {
				System.debug('The email template ' + templateApiName + ' failed to send for object ' + whatId + ': ' + results[0].errors[0].message);
			}
		} catch (Exception ex) {
			System.debug('The email template ' + templateApiName + ' failed to send for object ' + whatId);
			System.debug(ex);

			// TODO - intentionally dropping exception, don't want to risk blowing up main process, rethink if this is best			
		}
	}
}
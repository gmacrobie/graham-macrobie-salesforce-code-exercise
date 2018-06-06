/**
* @author Graham MacRobie
* @date November 14, 2017
*
* @description Controller for main "Payments for Payer" Visualforce page.  Only the list of projects is loaded here.  The rest
* of the data is loaded with AJAX / JSON.
*/

public with sharing class PaymentsController {
	public String projectsJson {get; set;}

	public class ProjectSelectDto {  // Data Transfer Object for project ids and names
		public String value;  // project id
		public String label;  // project name

		public ProjectSelectDto(String value, String label) {
			this.value = value;
			this.label = label;
		}
	}

	public PaymentsController() {
		List<ProjectSelectDto> projects = new List<ProjectSelectDto>();

		projects.add(new ProjectSelectDto('0', Label.PPG_LBL_Select_Project));  // first entry to indicate that none is chosen yet

		// load the list of projects.  For an environment with more than a few thousand projects, this would need to be rethought.

		List<Project__c> projectList = [select id, name from Project__c order by name limit 49999];

		for (Project__c project : projectList) {
			projects.add(new ProjectSelectDto(project.id, project.name));
		}

		projectsJson = JSON.serialize(projects);
	}
}
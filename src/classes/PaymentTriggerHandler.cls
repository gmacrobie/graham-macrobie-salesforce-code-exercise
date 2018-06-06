/**
* @author Graham MacRobie
* @date November 13, 2017
*
* @description Trigger handler for all Payment__c trigger events.  The async methods will likely be removed.
* isActive can be set to false to disable trigger events temporarily.  Many empty methods because this is
* boilerplate intended to allow future expansion without a developer needing to worry about how the trigger
* handler is setup.
*/

public with sharing class PaymentTriggerHandler {
    public static Boolean isActive = true;

    private Boolean isExecuting = false;
    private Integer batchSize = 0;

    public PaymentTriggerHandler(Boolean isExecuting, Integer size) {
        this.isExecuting = isExecuting;
        batchSize = size;
    }

    public void onBeforeInsert(Payment__c[] newRecords) {
    }

    public void onAfterInsert(Payment__c[] newRecords) {
        if (!isActive) {
            return;
        }

        PaymentService.updateProjectsAndContacts(newRecords, null, false);
    }

    @future public static void onAfterInsertAsync(Set<Id> newRecordIDs) {
    }

    public void onBeforeUpdate(Payment__c[] oldRecords, Payment__c[] updatedRecords, Map<Id, Payment__c> recordMap) {
    }

    public void onAfterUpdate(Payment__c[] oldRecords, Payment__c[] updatedRecords, Map<Id, Payment__c> recordMap, Map<Id, Payment__c> oldMap) {
        if (!isActive) {
            return;
        }

        PaymentService.updateProjectsAndContacts(updatedRecords, oldMap, false);
    }

    @future public static void onAfterUpdateAsync(Set<Id> updatedRecordIDs) {
    }

    public void onBeforeDelete(Payment__c[] recordsToDelete, Map<Id, Payment__c> recordMap) {
    }

    public void onAfterDelete(Payment__c[] deletedRecords, Map<Id, Payment__c> recordMap) {
        if (!isActive) {
            return;
        }

        PaymentService.updateProjectsAndContacts(deletedRecords, null, true);
    }

    @future public static void onAfterDeleteAsync(Set<Id> deletedRecordIDs) {
    }

    public void onUndelete(Payment__c[] restoredRecords) {
        if (!isActive) {
            return;
        }

        PaymentService.updateProjectsAndContacts(restoredRecords, null, false);
    }

    public Boolean isTriggerContext {
        get {
            return isExecuting;
        }
    }

    public Boolean isVisualforcePageContext {
        get {
            return !isTriggerContext;
        }
    }

    public Boolean isWebServiceContext {
        get {
            return !isTriggerContext;
        }
    }

    public Boolean isExecuteAnonymousContext {
        get {
            return !isTriggerContext;
        }
    }
}
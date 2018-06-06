trigger PaymentTrigger on Payment__c (
    after delete,
    after insert,
    after undelete,
    after update,
    before delete,
    before insert,
    before update) {

    PaymentTriggerHandler handler = new PaymentTriggerHandler(Trigger.isExecuting, Trigger.size);

    if (Trigger.isInsert && Trigger.isBefore) {
        handler.onBeforeInsert(Trigger.new);

    } else if (Trigger.isInsert && Trigger.isAfter) {
        handler.onAfterInsert(Trigger.new);
        //PaymentTriggerHandler.onAfterInsertAsync(Trigger.newMap.keySet());

    } else if (Trigger.isUpdate && Trigger.isBefore) {
        handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);

    } else if (Trigger.isUpdate && Trigger.isAfter) {
        handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        //PaymentTriggerHandler.onAfterUpdateAsync(Trigger.newMap.keySet());

    } else if (Trigger.isDelete && Trigger.isBefore) {
        handler.onBeforeDelete(Trigger.old, Trigger.oldMap);

    } else if (Trigger.isDelete && Trigger.isAfter) {
        handler.onAfterDelete(Trigger.old, Trigger.oldMap);
        //PaymentTriggerHandler.onAfterDeleteAsync(Trigger.oldMap.keySet());

    } else if (Trigger.isUnDelete) {
        handler.onUndelete(Trigger.new);

    }
}
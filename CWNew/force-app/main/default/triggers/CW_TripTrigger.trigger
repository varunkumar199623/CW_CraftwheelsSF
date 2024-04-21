/*
CW_TripTrigger

This trigger is designed to execute before the insertion or update of CW_Trip__c records.
It delegates the handling of before insert and before update operations to the CW_TripTriggerHandler class.
*/

trigger CW_TripTrigger on CW_Trip__c (before insert, before update) {
    // Checks if the trigger context is before insert and executes specific logic
    if (Trigger.isBefore && Trigger.isInsert) {
        // Calls the onBeforeInsert method of the CW_TripTriggerHandler class and passes the trigger.new records
        CW_TripTriggerHandler.onBeforeInsert(Trigger.new);
    }
    // Checks if the trigger context is before update and executes specific logic
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Calls the onBeforeUpdate method of the CW_TripTriggerHandler class and passes the trigger.new records
        CW_TripTriggerHandler.onBeforeUpdate(Trigger.new);
    }
}
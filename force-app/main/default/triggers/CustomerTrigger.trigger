trigger CustomerTrigger on Customer__c (before insert) {
    if (Trigger.isBefore) {
        if ( Trigger.isInsert ) {
            CustomerHandler.getInstance().beforeInsert();
        }
    }
}
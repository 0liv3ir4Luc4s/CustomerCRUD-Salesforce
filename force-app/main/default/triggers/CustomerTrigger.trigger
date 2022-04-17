trigger CustomerTrigger on Customer__c (
    before insert, 
    before update, 
    after update, 
    before delete, 
    after delete) {
        
    if (Trigger.isBefore) {
        if ( Trigger.isInsert ) {
            CustomerHandler.getInstance().beforeInsert();
        } else if ( Trigger.isUpdate ) {
            CustomerHandler.getInstance().beforeUpdate();
        } else {
            CustomerHandler.getInstance().beforeDelete();
        }
    } else {
        if ( Trigger.isUpdate ) {
            CustomerHandler.getInstance().afterUpdate();
        } else {
            CustomerHandler.getInstance().afterDelete();
        }
    }
}
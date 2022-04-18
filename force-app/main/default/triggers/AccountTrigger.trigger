trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if ( Trigger.isAfter ) {
        if ( Trigger.isUpdate ) {
            AccountHandler.getInstance().afterUpdate();
        } else if ( Trigger.isInsert ) {
            AccountHandler.getInstance().afterInsert();
        } else if ( Trigger.isDelete ) {
            AccountHandler.getInstance().afterDelete();
        }
    } else if ( Trigger.isBefore ) {
        if ( Trigger.isUpdate ) {
            AccountHandler.getInstance().beforeUpdate();
        } else if ( Trigger.isDelete ) {
            AccountHandler.getInstance().beforeDelete();
        } else if ( Trigger.isInsert ) {
            AccountHandler.getInstance().beforeInsert();
        }
    }
}
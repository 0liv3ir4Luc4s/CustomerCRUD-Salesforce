trigger ContactTrigger on Contact (before insert, after delete) {
    if ( Trigger.isAfter ) {
        if ( Trigger.isDelete ) {
            ContactHandler.getInstance().afterDelete();
        }
    }
}
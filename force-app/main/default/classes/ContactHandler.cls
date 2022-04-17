public with sharing class ContactHandler implements TriggerHandlerInterface {
    public static final ContactHandler instance = new ContactHandler();
    
    private ContactHandler() {}

    public static ContactHandler getInstance() {
        return instance;
    }

    public void beforeInsert() {}

    public void beforeUpdate() {}

    public void beforeDelete() {}

    public void afterInsert() {}

    public void afterUpdate() {}

    public void afterDelete() {
        ContactUtil.deleteRelatedCustomer( (List<Contact>) Trigger.old );
    }

    public void afterUndelete() {}
}
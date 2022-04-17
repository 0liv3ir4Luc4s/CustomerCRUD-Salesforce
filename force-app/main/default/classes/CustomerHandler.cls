public with sharing class CustomerHandler implements TriggerHandlerInterface {
    private static final CustomerHandler instance = new CustomerHandler();

    private CustomerHandler() { }

    public static CustomerHandler getInstance() {
        return instance;
    }

    public void beforeInsert() {
        
        CustomerUtil.syncCustomerWithAccount( (List<Customer__c>) Trigger.new );        

        CustomerUtil.sendErrorMessages( (List<Customer__c>) Trigger.new );
        
        CustomerUtil.setStatusNew( (List<Customer__c>) Trigger.new );
    
    }   

    public void afterInsert() {}

    public void beforeUpdate() {
        
        CustomerUtil.sendErrorMessages( (List<Customer__c>) Trigger.new, (Map<Id, Customer__c>) Trigger.newMap, (List<Customer__c>) Trigger.old, (Map<Id, Customer__c>) Trigger.oldMap );

        CustomerUtil.syncCustomerWithAccount( (Map<Id, Customer__c>) Trigger.newMap, (Map<Id, Customer__c>) Trigger.oldMap );
    
        CustomerUtil.submitToApproval( (Map<Id, Customer__c>) Trigger.newMap, (Map<Id, Customer__c>) Trigger.oldMap );

        CustomerUtil.treatApprovedsAndRejecteds( (Map<Id, Customer__c>) Trigger.newMap );

        CustomerUtil.blockEdition( (List<Customer__c>) Trigger.old, (Map<Id, Customer__c>) Trigger.newMap );

    }

    public void afterUpdate() {}

    public void beforeDelete() {}

    public void afterDelete() {

        CustomerUtil.deleteRelatedAccountsAndContacts( (List<Customer__c>) Trigger.old );
    
    }
}

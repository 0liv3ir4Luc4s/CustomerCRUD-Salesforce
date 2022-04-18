public class AccountHandler implements TriggerHandlerInterface {
    private static final AccountHandler instance = new AccountHandler();
    
    private AccountHandler() {}
    
    public static AccountHandler getInstance() {
        return instance;
    }

    public void beforeInsert() {}
    
    public void afterInsert() {}
    
    public void beforeUpdate() {
        AccountUtil.updateRelatedCustomers((Map<Id, Account>) Trigger.newMap, (Map<Id, Account>) Trigger.oldMap );        
    }
    
    public void afterUpdate() {}
    
    public void beforeDelete() {
        AccountUtil.deleteRelatedCustomer( (Map<Id, Account>) Trigger.oldMap );
    }
    
    public void afterDelete() {}
}
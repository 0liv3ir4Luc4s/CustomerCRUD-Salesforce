public with sharing class CustomerHandler {
    private static final CustomerHandler instance = new CustomerHandler();

    private CustomerHandler() {}

    public static CustomerHandler getInstance() {
        return instance;
    }

    public void beforeInsert() {}

    public void afterInsert() {}

    public void beforeUpdate() {}

    public void afterUpdate() {}

    public void beforeDelete() {}

    public void afterDelete() {}
}

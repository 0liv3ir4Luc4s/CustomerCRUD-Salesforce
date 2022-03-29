global interface TriggerHandlerInterface {
    void beforeInsert();

    void afterInsert();

    void beforeUpdate();

    void afterUpdate();

    void beforeDelete();

    void afterDelete();
}

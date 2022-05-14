@isTest
public class TestUtil {
    public static Id getRecordTypeId(Schema.DescribeSObjectResult salesforceObject, String recordTypeName) {
        return salesforceObject.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    public static void sendCustomersToIntegration(Customer__c[] customers) {
        for(Integer i = 0; i < customers.size(); i++) {
            customers[i].E_mail__c = 'email'+i+'@email.com';
            customers[i].Status__c = 'Enviado para integração';
        }
        update customers;
    }

}

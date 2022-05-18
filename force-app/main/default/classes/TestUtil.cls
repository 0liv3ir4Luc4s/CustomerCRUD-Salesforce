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

    public static void approveCustomers(Customer__c[] customers) {
        Map<Id, Customer__c> customersMap = new Map<Id, Customer__c>(customers);
        Approval.ProcessWorkItemRequest request;
        Approval.ProcessWorkItemRequest[] requests = new List<Approval.ProcessWorkItemRequest>();
        for (ProcessInstanceWorkItem p : [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :customersMap.keySet()]) {
            request = new Approval.ProcessWorkItemRequest();
            request.setWorkItemId(p.Id);
            request.setAction('Approve');
            requests.add(request);
        }
        Approval.process(requests);
    }
}

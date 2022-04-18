@isTest
public with sharing class ContactUtilTest {
    @isTest
    static void testDeleteSuccess(){
        Customer__c customer = new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='84657126954', E_mail__c='emaile@gmail.com');
        insert customer;

        customer.Status__c  = 'Enviado para integração';

        update customer;

        Id workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :customer.Id LIMIT 1 ].Id;
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkItemRequest();
        req.setWorkItemId( workItemId );
        req.setAction( 'Approve' );
        Approval.process( req );

        customer.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :customer.Id LIMIT 1 ].Account__c;

        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :customer.Account__c AND createdByTriggerFlag__c = true ];
        
        delete contact;

        System.assert( [ SELECT Count() FROM Customer__c WHERE Id = :customer.Id ] == 0 );

    }
}

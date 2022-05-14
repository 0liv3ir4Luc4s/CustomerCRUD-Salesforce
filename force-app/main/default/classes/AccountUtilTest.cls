@isTest
public class AccountUtilTest {
   
    @isTest
    static void testUpdateFailure() {
        List<Customer__c> inserted = TestDataFactory.createValidCustomersPessoaFisica(1);

        inserteds[0].E_mail__c = 'email@email.com';
        inserteds[0].Status__c = 'Enviado para integração';

        update inserteds[0];

        Id workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[0].Id ][0].Id;
        Approval.ProcessWorkItemRequest approveCPF = new Approval.ProcessWorkItemRequest();
        approveCPF.setWorkItemId( workItemId );
        approveCPF.setAction( 'Approve' );
        Approval.process( approveCPF );

        inserteds[0].Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :inserteds[0].Id].Account__c;
        Account a = [SELECT CPF__c FROM Account WHERE Id = :inserteds[0].Account__c ];

        a.CPF__c = '123456789';

        Database.SaveResult result = Database.update( a, false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF inválido!  ', result.getErrors()[0].getMessage() );

        cPessoaJuridica.E_mail__c = 'email2@email.com';
        cPessoaJuridica.Status__c = 'Enviado para integração';

        update cPessoaJuridica;

        workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[1].Id ][0].Id;
        Approval.ProcessWorkItemRequest approveCNPJ = new Approval.ProcessWorkItemRequest();
        approveCNPJ.setWorkItemId( workItemId );
        approveCNPJ.setAction( 'Approve' );
        Approval.process( approveCNPJ );

        inserteds[1].Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :inserteds[1].Id ].Account__c;

        result = Database.update( new Account( Id=inserteds[1].Account__c, CNPJ__c='123456789' ), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CNPJ inválido!  ', result.getErrors()[0].getMessage() );
    }

    @isTest 
    static void testUpdateSuccess() {
        insert new Account(Name='Test1', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945');

        insert new Account(Name='Test2', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345');

        Customer__c cPessoaFisica = new Customer__c();

        cPessoaFisica.Name = 'Test1';
        cPessoaFisica.RecordTypeId = '0128c000002EoQVAA0';
        cPessoaFisica.CPF__c = '12345678946';

        Customer__c cPessoaJuridica = new Customer__c();

        cPessoaJuridica.Name = 'Test2';
        cPessoaJuridica.RecordTypeId = '0128c000002EoQaAAK';
        cPessoaJuridica.CNPJ__c = '12345678912346';
        
        List<Customer__c> inserteds = new List<Customer__c>{ cPessoaFisica, cPessoaJuridica };

        insert inserteds;

        cPessoaFisica.E_mail__c = 'email@email.com';
        cPessoaFisica.Status__c = 'Enviado para integração';

        update cPessoaFisica;

        Id workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[0].Id ][0].Id;
        Approval.ProcessWorkItemRequest approveCPF = new Approval.ProcessWorkItemRequest();
        approveCPF.setWorkItemId( workItemId );
        approveCPF.setAction( 'Approve' );
        Approval.process( approveCPF );

        cPessoaFisica.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :cPessoaFisica.Id ].Account__c;

        update new Account( Id=inserteds[0].Account__c, CPF__c='12345678912' );

        inserteds[0].CPF__c = [SELECT CPF__c FROM Customer__c WHERE Id = :inserteds[0].Id ].CPF__c;

        System.assertEquals( '12345678912', inserteds[0].CPF__c );

        cPessoaJuridica.E_mail__c = 'email2@email.com';
        cPessoaJuridica.Status__c = 'Enviado para integração';

        update cPessoaJuridica;

        workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[1].Id ][0].Id;
        Approval.ProcessWorkItemRequest approveCNPJ = new Approval.ProcessWorkItemRequest();
        approveCNPJ.setWorkItemId( workItemId );
        approveCNPJ.setAction( 'Approve' );
        Approval.process( approveCNPJ );

        cPessoaJuridica.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :cPessoaJuridica.Id ].Account__c;

        update new Account( Id=inserteds[1].Account__c, CNPJ__c='12345678912348' );

        inserteds[1].CNPJ__c = [SELECT CNPJ__c FROM Customer__c WHERE Id = :inserteds[1].Id ].CNPJ__c;

        System.assertEquals( '12345678912348', inserteds[1].CNPJ__c );
    
    }

    @isTest
    static void testDeleteSuccess() {
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

        delete new Account( Id=customer.Account__c );

        System.assert( [SELECT Count() FROM Account WHERE Id = :customer.Account__c ] == 0 );
        System.assert( [ SELECT Count() FROM Customer__c WHERE Id = :customer.Id ] == 0 );
        System.assert( [ SELECT Count() FROM Contact WHERE AccountId =:customer.Account__c ] == 0 );

    }

}
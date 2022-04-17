@isTest
public with sharing class CustomerTest {
    
    @isTest
    static void testInsertFailure() {
        
        insert new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='00000000000');
        
        Database.SaveResult result = Database.insert( new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='00000000001'), false );
        
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Já existe um customer de nome Test1 ', result.getErrors()[0].getMessage() );

        insert new Account( Name='Test2', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945');

        result = Database.insert( new Customer__c(Name='Test2', RecordTypeId='0128c000002EoQVAA0', CPF__c='12345678945'), false );

        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'CPF já cadastrado! ', result.getErrors()[0].getMessage() );

        insert new Account(Name='Test3', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345');

        result = Database.insert( new Customer__c(Name='Test3', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='12345678912345'), false );

        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'CNPJ já cadastrado! ', result.getErrors()[0].getMessage() );        

    }

    @isTest
    static void testInsertSuccess() {

        insert new Customer__c(Name='Test', RecordTypeId='0128c000002EoQVAA0', CPF__c='00000000000');

        insert new Account(Name='Test1', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945');
        
        Customer__c cPessoaFisica = new Customer__c();

        cPessoaFisica.Name = 'Test1';
        cPessoaFisica.RecordTypeId = '0128c000002EoQVAA0';
        cPessoaFisica.CPF__c = '12345678946';

        Database.SaveResult result = Database.insert( cPessoaFisica, false );

        System.assert( result.isSuccess() );

        insert new Account(Name='Test2', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345');

        Customer__c cPessoaJuridica = new Customer__c();

        cPessoaJuridica.Name = 'Test2';
        cPessoaJuridica.RecordTypeId = '0128c000002EoQaAAK';
        cPessoaJuridica.CNPJ__c = '12345678912346';

        result = Database.insert( cPessoaJuridica, false );

        System.assert( result.isSuccess() );
        
        // Verificar status novo

    }

    @isTest
    static void testUpdateFailure() {

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

        Database.SaveResult result = Database.update( new Customer__c( Id=inserteds[0].Id, Name='Test2'), false );
        
        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Já existe um customer de nome Test2 ', result.getErrors()[0].getMessage() );

        result = Database.update( new Customer__c( Id=inserteds[0].Id, CPF__c='12345678945'), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'CPF já cadastrado! ', result.getErrors()[0].getMessage() );

        result = Database.update( new Customer__c( Id=inserteds[1].Id, CNPJ__c='12345678912345'), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'CNPJ já cadastrado! ', result.getErrors()[0].getMessage() );

        result = Database.update( new Customer__c( Id=inserteds[0].Id, Status__c='Enviado para integração'), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Email ou Telefone deve ser preenchido! ', result.getErrors()[0].getMessage() );

        Database.update( new Customer__c( Id=inserteds[0].Id, Status__c='Enviado para integração', Telefone__c='123'), false );
        
        Id workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[0].Id ][0].Id;
        Approval.ProcessWorkItemRequest approve = new Approval.ProcessWorkItemRequest();
        approve.setWorkitemId( workItemId );
        approve.setAction( 'Approve' );
        Approval.process( approve );

        result = Database.update( new Customer__c( Id=inserteds[0].Id, Telefone__c='12345' ), false );
        
        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Não se pode alterar um customer integrado', result.getErrors()[0].getMessage() );

        inserteds[0].Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :inserteds[0].Id].Account__c;
        Account a = [SELECT CPF__c FROM Account WHERE Id = :inserteds[0].Account__c ];

        a.CPF__c = '123456789';

        result = Database.update( a, false );

        inserteds[0] = [SELECT CPF__c FROM Customer__c WHERE Id = :inserteds[0].Id ];

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF inválido!  ', result.getErrors()[0].getMessage() );

        cPessoaJuridica.E_mail__c = 'email@email.com';
        cPessoaJuridica.Status__c = 'Enviado para integração';

        update cPessoaJuridica;

        workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[1].Id ][0].Id;
        Approval.ProcessWorkItemRequest approveCNPJ = new Approval.ProcessWorkItemRequest();
        approveCNPJ.setWorkItemId( workItemId );
        approveCNPJ.setAction( 'Approve' );
        Approval.process( approveCNPJ );

        inserteds[1].Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :inserteds[1].Id ].Account__c;

        result = Database.update( new Account( Id=inserteds[1].Account__c, CNPJ__c='123456789' ), false );

        inserteds[1].CNPJ__c = [SELECT CNPJ__c FROM Customer__c WHERE Id = :inserteds[1].Id ].CNPJ__c;

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
        
        Database.SaveResult result = Database.update( new Customer__c( Id=inserteds[0].Id, Name='Test3'), false );

        System.assert( result.isSuccess() );

        result = Database.update( new Customer__c( Id=inserteds[0].Id, CPF__c='12345678947'), false );

        System.assert( result.isSuccess() );

        result = Database.update( new Customer__c( Id=inserteds[1].Id, CNPJ__c='12345678912346' ), false );

        System.assert( result.isSuccess() );

        result = Database.update( new Customer__c( Id=inserteds[0].Id, Status__c='Enviado para integração', Telefone__c='13245' ), false );

        System.assert( result.isSuccess() );
        
        result = Database.update( new Customer__c( Id=inserteds[1].Id, Status__c='Enviado para integração', E_mail__c='email@email.com' ), false );
        
        System.assert( result.isSuccess() );

        ProcessInstance approvalProcess = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :inserteds[0].Id ];

        System.assert( approvalProcess.Status == 'Pending' );

        Id workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[0].Id ][0].Id;
        Approval.ProcessWorkItemRequest approve = new Approval.ProcessWorkItemRequest();
        approve.setWorkItemId( workItemId );
        approve.setAction( 'Approve' );
        Approval.process( approve );
        
        inserteds[0] = [ SELECT Name, CPF__c, Telefone__c, Account__c, E_mail__c FROM Customer__c WHERE Id = :inserteds[0].Id];

        Account a = [SELECT Id, Name, CPF__c, Phone, RecordTypeId FROM Account WHERE Id = :inserteds[0].Account__c ];

        System.assertEquals( inserteds[0].Account__c, a.Id );
        System.assertEquals( '0128c000002EsqWAAS', a.RecordTypeId );
        System.assertEquals( inserteds[0].Name, a.Name);
        System.assertEquals( inserteds[0].CPF__c, a.CPF__c );
        System.assertEquals( inserteds[0].Telefone__c, a.Phone );

        List<Contact> con = [SELECT LastName, Phone, Email, createdByTriggerFlag__c, createdByCustomerOfId__c FROM Contact WHERE Account.Id = :inserteds[0].Account__c ];

        System.assert( con.size() == 1 );
        System.assertEquals( inserteds[0].Name, con[0].LastName );
        System.assertEquals( inserteds[0].Telefone__c, con[0].Phone );
        System.assertEquals( inserteds[0].E_mail__c, con[0].Email );
        System.assert( con[0].createdByTriggerFlag__c );
        System.assertEquals( inserteds[0].Id, con[0].createdByCustomerOfId__c );

        a.CPF__c = '12345678993';

        update a;

        inserteds[0] = [SELECT CPF__c FROM Customer__c WHERE Id = :inserteds[0].Id ];

        System.assertEquals( '12345678993', inserteds[0].CPF__c );

        workItemId = [ SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :inserteds[1].Id ][0].Id;
        Approval.ProcessWorkItemRequest approvePessoaJuridica = new Approval.ProcessWorkItemRequest();
        approvePessoaJuridica.setWorkItemId( workItemId );
        approvePessoaJuridica.setAction( 'Approve' );
        Approval.process( approvePessoaJuridica );

        inserteds[1] = [SELECT Id, Name, CNPJ__c, Telefone__c, Account__c, E_mail__c FROM Customer__c WHERE Id = :inserteds[1].Id ];

        a = [SELECT Name, CNPJ__c, RecordTypeId, Phone FROM Account WHERE Id = :inserteds[1].Account__c ];

        System.assertEquals(  inserteds[1].Account__c, a.Id );
        System.assertEquals( inserteds[1].Name, a.Name );
        System.assertEquals( inserteds[1].Telefone__c, a.Phone );
        System.assertEquals( inserteds[1].CNPJ__c, a.CNPJ__c );
        System.assertEquals( '0128c000002Esqg', a.RecordTypeId );

        con = [SELECT LastName, Phone, Email, createdByTriggerFlag__c, createdByCustomerOfId__c FROM Contact WHERE Account.Id = :inserteds[1].Account__c ];

        System.assert( con.size() == 1 );
        System.assertEquals( inserteds[1].Name, con[0].LastName );
        System.assertEquals( inserteds[1].Telefone__c, con[0].Phone );
        System.assertEquals( inserteds[1].E_mail__c, con[0].Email );
        System.assertEquals( inserteds[1].Id, con[0].createdByCustomerOfId__c );
        System.assert( con[0].createdByTriggerFlag__c );

        update new Account( Id=inserteds[1].Account__c, CNPJ__c='12345678912348' );

        inserteds[1].CNPJ__c = [SELECT CNPJ__c FROM Customer__c WHERE Id = :inserteds[1].Id ].CNPJ__c;

        System.assertEquals( '12345678912348', inserteds[1].CNPJ__c );

        Customer__c cToReject = new Customer__c();

        cToReject.Name = 'Test4';
        cToReject.RecordTypeId = '0128c000002EoQVAA0';
        cToReject.CPF__c = '12345678946';

        insert cToReject;
        
        cToReject.Status__c = 'Enviado para integração';
        cToReject.Telefone__c = '123456';

        update cToReject;

        workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :cToReject.Id][0].Id;
        Approval.ProcessWorkItemRequest reject = new Approval.ProcessWorkItemRequest();
        reject.setWorkItemId( workItemId );
        reject.setAction( 'Reject' );
        Approval.process( reject );

        cToReject = [SELECT Name, Status__c FROM Customer__c WHERE Id = :cToReject.Id];

        System.assertEquals( 'Em análise', cToReject.Status__c );

        cToReject.Telefone__c = '456';
        result = Database.update( cToReject, false );

        System.assert( result.isSuccess() );

    }
}
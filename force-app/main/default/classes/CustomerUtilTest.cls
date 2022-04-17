@isTest
public with sharing class CustomerUtilTest {
    
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

        List<Account> accounts = new List<Account>{ 
            new Account(Name='Test1', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945'),
            new Account(Name='Test2', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345')
        };

        insert accounts;

        insert new Customer__c(Name='Test', RecordTypeId='0128c000002EoQVAA0', CPF__c='00000000000');
        
        Customer__c cPessoaFisica = new Customer__c();

        cPessoaFisica.Name = 'Test1';
        cPessoaFisica.RecordTypeId = '0128c000002EoQVAA0';
        cPessoaFisica.CPF__c = '12345678946';

        Database.SaveResult result = Database.insert( cPessoaFisica, false );

        System.assert( result.isSuccess() );

        Customer__c cPessoaJuridica = new Customer__c();

        cPessoaJuridica.Name = 'Test2';
        cPessoaJuridica.RecordTypeId = '0128c000002EoQaAAK';
        cPessoaJuridica.CNPJ__c = '12345678912346';

        result = Database.insert( cPessoaJuridica, false );

        System.assert( result.isSuccess() );
        
        // Verificar status novo

        // inserir customer com conta, ver sync

        Customer__c syncronizedCustomerCpf = new Customer__c( Name='Test3', RecordTypeId='0128c000002EoQVAA0', CPF__c='98745612355', Account__c=accounts[0].Id );
        Customer__c syncronizedCustomerCnpj = new Customer__c( Name='Test4', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='12345678912347', Account__c=accounts[1].Id );

        insert new List<Customer__c>{ syncronizedCustomerCpf, syncronizedCustomerCnpj };

        syncronizedCustomerCpf = [SELECT CPF__c FROM Customer__c WHERE Id = :syncronizedCustomerCpf.Id ];
        syncronizedCustomerCnpj = [SELECT CNPJ__c FROM Customer__c WHERE Id = :syncronizedCustomerCnpj.Id ];

        System.assertEquals( accounts[0].CPF__c, syncronizedCustomerCpf.CPF__c );
        System.assertEquals( accounts[1].CNPJ__c, syncronizedCustomerCnpj.CNPJ__c );

    }

    @isTest
    static void testUpdateFailure() {

        List<Account> accounts = new List<Account>{ 
            new Account(Name='Test1', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945'),
            new Account(Name='Test2', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345')
        };

        insert accounts;

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

    }

    @isTest
    static void testUpdateSuccess() {

        List<Account> accounts = new List<Account>{ 
            new Account(Name='Test1', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945'),
            new Account(Name='Test2', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345')
        };

        insert accounts;

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

        Customer__c cPessoaFisica2 = new Customer__c( Name='Test5', RecordTypeId='0128c000002EoQVAA0', CPF__c='12345678954', Account__c = accounts[0].Id );
        Customer__c cPessoaJuridica2 = new Customer__c( Name='Test6', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='12345678912349', Account__c = accounts[1].Id );

        Account acct1 = new Account(Name='Test5', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678965');
        Account acct2 = new Account(Name='Test6', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678965655');

        insert new List<Account>{ acct1, acct2 };
        insert new List<Customer__c>{ cPessoaFisica2, cPessoaJuridica2 };

        cPessoaFisica2.Account__c = acct1.Id;
        cPessoaJuridica2.Account__c = acct2.Id;

        update new List<SObject>{ acct1, acct2, cPessoaFisica2, cPessoaJuridica2 };

        cPessoaFisica2 = [SELECT CPF__c FROM Customer__c WHERE Id = :cPessoaFisica2.Id ];
        cPessoaJuridica2 = [SELECT CNPJ__c FROM Customer__c WHERE Id = :cPessoaJuridica2.Id ];

        System.assertEquals( acct1.CPF__c, cPessoaFisica2.CPF__c );
        System.assertEquals( acct2.CNPJ__c, cPessoaJuridica2.CNPJ__c );

    }

    @isTest
    static void testDeleteSuccess() {
        Customer__c customer = new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='84657126954', E_mail__c='emaile@gmail.com');
        insert customer;

        customer.Status__c  = 'Enviado para integração';

        update customer;

        Id workItemId = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :customer.Id LIMIT 1 ].Id;
        Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
        req.setWorkItemId( workItemId );
        req.setAction( 'Approve' );
        Approval.process( req );

        customer.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :customer.Id LIMIT 1 ].Account__c;
        
        delete customer;

        System.assert( [ SELECT Count() FROM Account WHERE Id = :customer.Account__c ] == 0 );

        
    }
}
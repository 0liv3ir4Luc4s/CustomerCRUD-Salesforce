@isTest
private with sharing class CustomerFieldsValidationUtilTest {
    
    @isTest 
    static void testInsertFailure() {

        Database.SaveResult result = Database.insert( new Customer__c(Name='Test', RecordTypeId='0128c000002EoQVAA0'), false );

        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF é obrigatório! ', result.getErrors()[0].getMessage() );

        result = Database.insert( new Customer__c(Name='Test', RecordTypeId='0128c000002EoQVAA0', CPF__c='123456789'), false );
        
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF inválido! ', result.getErrors()[0].getMessage() );

        result = Database.insert( new Customer__c( Name='Test', RecordTypeId='0128c000002EoQaAAK' ), false );

        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CNPJ é obrigatório! ', result.getErrors()[0].getMessage() );

        result = Database.insert( new Customer__c( Name='Test', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='123456789'), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CNPJ inválido! ', result.getErrors()[0].getMessage() );

    }

    @isTest 
    static void testInsertSuccess() {

        Database.SaveResult result = Database.insert( new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='12345678955') );

        System.assert( result.isSuccess() );

        result = Database.insert( new Customer__c(Name='Test2', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='00000000000000'), false );

        System.assert( result.isSuccess() );

    }

    @isTest
    static void testUpdateFailure() {

        List<Account> accounts = new List<Account>{ 
            new Account(Name='Test1', RecordTypeId='0128c000002EsqWAAS', CPF__c='12345678945'),
            new Account(Name='Test2', RecordTypeId='0128c000002EsqgAAC', CNPJ__c='12345678912345')
        };

        insert accounts;

        List<Customer__c> inserteds = new List<Customer__c>{ new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='12345678955'),
                                                        new Customer__c(Name='Test2', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='00000000000000') };
        
        insert inserteds;

        Database.SaveResult result = Database.update( new Customer__c(Id=inserteds[0].Id, CPF__c=''), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF é obrigatório! ', result.getErrors()[0].getMessage() );

        result = Database.update( new Customer__c( Id=inserteds[0].Id, CPF__c='123456789' ), false );
        
        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF inválido! ', result.getErrors()[0].getMessage() );

        result = Database.update( new Customer__c( Id=inserteds[1].Id, CNPJ__c='' ), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CNPJ é obrigatório! ', result.getErrors()[0].getMessage() );

        result = Database.update( new Customer__c( Id=inserteds[1].Id, CNPJ__c='123456789'), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CNPJ inválido! ', result.getErrors()[0].getMessage() );

        Customer__c cPessoaFisica2 = new Customer__c( Name='Test3', RecordTypeId='0128c000002EoQVAA0', Account__c=accounts[0].Id );
        Customer__c cPessoaJuridica2 = new Customer__c( Name='Test4', RecordTypeId='0128c000002EoQaAAK', Account__c=accounts[1].Id );

        insert new List<Customer__c>{ cPessoaFisica2, cPessoaJuridica2 };

        cPessoaFisica2.CPF__c='12345678910';
        cPessoaJuridica2.CNPJ__c='12345678912378';

        Database.SaveResult[] result2 = Database.update( new List<Customer__c>{ cPessoaFisica2, cPessoaJuridica2 }, false );

        System.assert( !result2[0].isSuccess() );
        System.assert( !result2[1].isSuccess() );
        System.assert( result2[0].getErrors().size() == 1 && result2[1].getErrors().size() == 1 );
        System.assertEquals( 'Não se pode alterar o CPF de um Customer com conta ', result2[0].getErrors()[0].getMessage() );
        System.assertEquals( 'Não se pode alterar o CNPJ de um Customer com conta ', result2[1].getErrors()[0].getMessage() );

        cPessoaFisica2.Account__c = accounts[1].Id;
        cPessoaJuridica2.Account__c = accounts[0].Id;

        result2 = Database.update( new List<Customer__c>{ cPessoaFisica2, cPessoaJuridica2 }, false );

        System.assert( !result2[0].isSuccess() );
        System.assert( !result2[1].isSuccess() );
        System.assert( result2[0].getErrors().size() == 1 );
        System.assert( result2[1].getErrors().size() == 1 );
        System.assertEquals( 'A conta relacionada deve ser uma Pessoa Física ', result2[0].getErrors()[0].getMessage() );
        System.assertEquals( 'A conta relacionada dever uma Pessoa Jurídica ', result2[1].getErrors()[0].getMessage() );

    }

    @isTest
    static void testUpdateSuccess() {
        List<Customer__c> inserteds = new List<Customer__c>{ new Customer__c(Name='Test1', RecordTypeId='0128c000002EoQVAA0', CPF__c='12345678955'),
                                                            new Customer__c(Name='Test2', RecordTypeId='0128c000002EoQaAAK', CNPJ__c='00000000000000') };

        insert inserteds;

        Database.SaveResult result = Database.update( new Customer__c( Id=inserteds[0].Id, CPF__c='12345678956' ), false);

        System.assert( result.isSuccess() );

        result = Database.update( new Customer__c(Id=inserteds[1].Id, CNPJ__c='00000000000001'), false );

        System.assert( result.isSuccess() );

    }
}
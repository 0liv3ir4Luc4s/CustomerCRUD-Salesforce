@isTest
public class AccountUtilTest {
   
    @isTest
    static void testUpdateFailure() {
        Customer__c customerPessoaFisica = TestDataFactory.createValidCustomersPessoaFisica(1)[0];

        Customer__c customerPessoaJuridica = TestDataFactory.createValidCustomersPessoaJuridica(1)[0];

        Customer__c[] customers = new List<Customer__c> {customerPessoaFisica, customerPessoaJuridica};

        TestUtil.sendCustomersToIntegration(customers);

        TestUtil.approveCustomers(customers);

        customerPessoaFisica.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :customerPessoaFisica.Id].Account__c;
        Account a = [SELECT CPF__c FROM Account WHERE Id = :customerPessoaFisica.Account__c ];

        a.CPF__c = '123456789';

        Database.SaveResult result = Database.update( a, false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CPF inválido!  ', result.getErrors()[0].getMessage() );

        customerPessoaJuridica.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :customerPessoaJuridica.Id ].Account__c;

        result = Database.update( new Account( Id=customerPessoaJuridica.Account__c, CNPJ__c='123456789' ), false );

        System.assert( !result.isSuccess() );
        System.assert( result.getErrors().size() == 1 );
        System.assertEquals( 'Campo CNPJ inválido!  ', result.getErrors()[0].getMessage() );
    }
    
    @isTest
    static void testUpdateFailureBulk() {
        Customer__c[] customers = new List<Customer__c>();
        customers.addAll(TestDataFactory.createValidCustomersPessoaFisica(50));
        customers.addAll(TestDataFactory.createValidCustomersPessoaJuridica(50));

        TestUtil.sendCustomersToIntegration(customers);

        TestUtil.approveCustomers(customers);

        customers = [SELECT Account__c FROM Customer__c WHERE Id IN :(new Map<Id, Customer__c>(customers).keySet())];

        Set<Id> relatedAccountsIds = new Set<Id>();

        for(Customer__c c : customers) relatedAccountsIds.add(c.Account__c);

        Map<Id, Account> relatedAccounts = new Map<Id, Account>([SELECT CPF__c, CNPJ__c, RecordTypeId FROM Account WHERE Id IN :relatedAccountsIds]);         

        for(Account a : relatedAccounts.values()) {
            if (a.RecordTypeId == TestUtil.RECORD_TYPE_ID_ACCOUNT_PESSOA_FISICA) {
               a.CPF__c = TestDataFactory.getCpf(false); 
            } else if (a.RecordTypeId == TestUtil.RECORD_TYPE_ID_ACCOUNT_PESSOA_JURIDICA) {
               a.CNPJ__c = TestDataFactory.getCnpj(false);
            }
        }

        Database.SaveResult[] results = Database.update(relatedAccounts.values(), false);
        
        String errorMessage;

        for (Database.SaveResult result : results) {
            System.assert(!result.isSuccess());
            System.assert(result.getErrors().size() == 1);
            if (relatedAccounts.get(result.getId()).RecordTypeId == TestUtil.RECORD_TYPE_ID_ACCOUNT_PESSOA_FISICA) {
                errorMessage = 'Campo CPF inválido!  ';
            } else if (relatedAccounts.get(result.getId()).RecordTypeId == TestUtil.RECORD_TYPE_ID_ACCOUNT_PESSOA_JURIDICA) {
                errorMessage = 'Campo CNPJ inválido!  ';
            }
            System.assertEquals(errorMessage, result.getErrors()[0].getMessage());
        }

    }

    @isTest 
    static void testUpdateSuccess() {
        
        Customer__c cPessoaFisica = TestDataFactory.createValidCustomersPessoaFisica(1)[0];

        Customer__c cPessoaJuridica = TestDataFactory.createValidCustomersPessoaJuridica(1)[0];

        Customer__c[] customers = new List<Customer__c>{cPessoaFisica, cPessoaJuridica};

        TestUtil.sendCustomersToIntegration(customers);
        TestUtil.approveCustomers(customers);

        cPessoaFisica.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :cPessoaFisica.Id ].Account__c;

        update new Account( Id=cPessoaFisica.Account__c, CPF__c='12345678912' );

        cPessoaFisica.CPF__c = [SELECT CPF__c FROM Customer__c WHERE Id = :cPessoaFisica.Id ].CPF__c;

        System.assertEquals( '12345678912', cPessoaFisica.CPF__c );

        cPessoaJuridica.Account__c = [SELECT Account__c FROM Customer__c WHERE Id = :cPessoaJuridica.Id ].Account__c;

        update new Account( Id=cPessoaJuridica.Account__c, CNPJ__c='12345678912348' );

        cPessoaJuridica.CNPJ__c = [SELECT CNPJ__c FROM Customer__c WHERE Id = :cPessoaJuridica.Id ].CNPJ__c;

        System.assertEquals( '12345678912348', cPessoaJuridica.CNPJ__c );
    
    }
    
    @isTest
    static void testUpdateSuccessBulk() {
        Customer__c[] customers = new List<Customer__c>();
        customers.addAll(TestDataFactory.createValidCustomersPessoaFisica(50));
        customers.addAll(TestDataFactory.createValidCustomersPessoaJuridica(50));

        TestUtil.sendCustomersToIntegration(customers);
        TestUtil.approveCustomers(customers);

        customers = [SELECT Account__c FROM Customer__c WHERE Id IN :(new Map<Id, Customer__c>(customers).keySet())];

        Set<Id> relatedAccountsIds = new Set<Id>();

        for(Customer__c c : customers) relatedAccountsIds.add(c.Account__c);

        Map<Id, Account> relatedAccounts = new Map<Id, Account>([SELECT CPF__c, CNPJ__c, RecordTypeId FROM Account WHERE Id IN :relatedAccountsIds]);         

        for(Account a : relatedAccounts.values()) {
            if (a.RecordTypeId == TestUtil.RECORD_TYPE_ID_ACCOUNT_PESSOA_FISICA) {
               a.CPF__c = TestDataFactory.getCpf(true); 
            } else if (a.RecordTypeId == TestUtil.RECORD_TYPE_ID_ACCOUNT_PESSOA_JURIDICA) {
               a.CNPJ__c = TestDataFactory.getCnpj(true);
            }
        }

        update(relatedAccounts.values()); 

        customers = [SELECT Account__c, RecordTypeId, CPF__c, CNPJ__c FROM Customer__c WHERE Id IN :(new Map<Id, Customer__c>(customers).keySet())];

        for (Customer__c c : customers) {
            if (c.RecordTypeId == TestUtil.RECORD_TYPE_ID_CUSTOMER_PESSOA_FISICA) {
                System.assert(c.CPF__c == relatedAccounts.get(c.Account__c).CPF__c);
            } else if (c.RecordTypeId == TestUtil.RECORD_TYPE_ID_CUSTOMER_PESSOA_JURIDICA) {
                System.assert(c.CNPJ__c == relatedAccounts.get(c.Account__c).CNPJ__c);
            }
        }
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
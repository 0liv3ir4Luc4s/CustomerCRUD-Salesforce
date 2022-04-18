public class AccountUtil {
    public static void updateRelatedCustomers( Map<Id, Account> updatedAccountsMap, Map<Id, Account> oldAccountsMap ) {
        List<Customer__c> relatedCustomers = new List<Customer__c>([SELECT Id, CPF__c, CNPJ__c, RecordTypeId, Account__c FROM Customer__c WHERE Account__c IN :updatedAccountsMap.keySet()]);
        
        for ( Customer__c c : relatedCustomers ) {
            Account newAcct = updatedAccountsMap.get( c.Account__c );
            Account oldAcct = oldAccountsMap.get( c.Account__c );
            
            if ( newAcct.CPF__c != oldAcct.CPF__c || newAcct.CNPJ__c != oldAcct.CNPJ__c ) {
            	if ( c.RecordTypeId == '0128c000002EoQVAA0' ) {
                	c.CPF__c = updatedAccountsMap.get( c.Account__c ).CPF__c;
            	} else if ( c.RecordTypeId == '0128c000002EoQaAAK' ) {
                	c.CNPJ__c = updatedAccountsMap.get( c.Account__c ).CNPJ__c;
   				}
        	}
            
            c.updatedByAcct__c = true;
        }
        
        Database.SaveResult[] results = Database.update( relatedCustomers, false);

        Map<Id, Account> CustomersToAccounts = new Map<Id, Account>();

        for ( Customer__c c : relatedCustomers ) {
            CustomersToAccounts.put( c.Id, updatedAccountsMap.get( c.Account__c ) );
        }

        for ( Database.SaveResult r : results ) {
            if ( !r.isSuccess() ) {
                String errorMessages = '';
                for ( Database.Error e : r.getErrors() ) {
                    errorMessages += e.getMessage() + ' ';
                }
                CustomersToAccounts.get( r.getId() ).addError(errorMessages);
            }
        }
    }

    public static void deleteRelatedCustomer( Map<Id, Account> deletedAccountsMap ) {
        List<Customer__c> toDelete = [ SELECT Id FROM Customer__c WHERE Account__c IN :deletedAccountsMap.keySet() ];

        if ( !toDelete.isEmpty() ) {
            delete toDelete;
        }
    }

}
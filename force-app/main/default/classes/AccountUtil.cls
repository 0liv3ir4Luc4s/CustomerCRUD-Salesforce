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
            
            if ( newAcct.Phone != oldAcct.Phone ) {
                c.Telefone__c = newAcct.Phone;
            }
            
            if ( newAcct.Name != oldAcct.Name ) {
                c.Name = newAcct.Name;
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

    public static void preventDeletionOfContacts( Set<Id> deletedAccountsIds ) {

        List<Contact> toNotDelete = new List<Contact>([SELECT Id FROM Contact WHERE AccountId IN :deletedAccountsIds AND createdByTriggerFlag__c = false]);

        for ( Contact con : toNotDelete ) {
            con.AccountId = null;
        }

        update toNotDelete;
    }
}
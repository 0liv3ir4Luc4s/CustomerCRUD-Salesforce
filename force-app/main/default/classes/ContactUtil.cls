public with sharing class ContactUtil {
    public static void deleteRelatedCustomer( List<Contact> deletedContacts ) {
        
        List<Customer__c> toDelete = new List<Customer__c>();
        
        for ( Contact con : deletedContacts ) {
            toDelete.add( new Customer__c( Id=con.createdByCustomerOfId__c ));
        }

        if ( !toDelete.isEmpty() ) {
            delete toDelete;
        }

    } 
}
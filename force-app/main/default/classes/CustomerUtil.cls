public with sharing class CustomerUtil {
    
    public static List<Customer__c> getCpf_CnpjDuplicates( List<Customer__c> newCustomers ) {
        List<Account> cpfs = [SELECT Id, CPF__c FROM Account WHERE CPF__c != null];
        List<Account> cnpjs = [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c != null];
        
        List<String> existingCustomersCPFs = new List<String>();
        List<String> existingCustomersCNPJs = new List<String>();
    
        List<Customer__c> duplicates = new List<Customer__c>();

        for ( Account acct : cpfs ) {
            existingCustomersCPFs.add(acct.CPF__c);
        }
        for ( Account acct : cnpjs ) {
            existingCustomersCNPJs.add(acct.CNPJ__c);
        }

        for ( Customer__c c : newCustomers ) {
            if ( c.RecordTypeId == '0128c000002EoQVAA0' && existingCustomersCPFs.contains(c.CPF__c) ||
                c.RecordTypeId == '0128c000002EoQaAAK' && existingCustomersCNPJs.contains(c.CNPJ__c) 
            ) {
                duplicates.add( c );
            }
        }

        return duplicates;
    }

	// Chamada do método que verifica duplicidade do CPF/CNPJ adaptado para update
    public static List<Customer__c> getCpf_CnpjDuplicates( Map<Id, Customer__c> updatedCustomers, Map<Id, Customer__c> oldCustomers ) {
        List<Customer__c> potentialCustomersWithDuplicatedCPForCNPJ = new List<Customer__c>();
        
        for ( String id : updatedCustomers.keySet() ) {
            if ( updatedCustomers.get(id).CPF__c != oldCustomers.get(id).CPF__c ||
                updatedCustomers.get(id).CNPJ__c != oldCustomers.get(id).CNPJ__c ) {

                potentialCustomersWithDuplicatedCPForCNPJ.add( updatedCustomers.get(id) );

            }
        }
        
        if ( !potentialCustomersWithDuplicatedCPForCNPJ.isEmpty() ) {
            return getCpf_CnpjDuplicates( potentialCustomersWithDuplicatedCPForCNPJ );
        }

        return new List<Customer__c>();
    }

    public static void sendErrorMessages( List<Customer__c> customers ) {

        List<Customer__c> toValidateCpfOrCnpj = new List<Customer__c>();

        for ( Customer__c  c : customers ) {
            if ( c.Account__c == null ) {
                toValidateCpfOrCnpj.add( c );
            }
        }

        Map<Id, Customer__c> toValidateRelationship = new Map<Id, Customer__c>();

        for ( Customer__c c : customers ) {
            toValidateRelationship.put( c.Id, c );
        }  
        
        Map<Customer__c, List<String>> validationErrors = CustomerFieldsValidationUtil.getErrorMessages( CustomerFieldsValidationUtil.validateRequired( customers ), CustomerFieldsValidationUtil.validateFormat( customers ), CustomerFieldsValidationUtil.validateRelationship( toValidateRelationship ) );
        Map<Customer__c, List<String>> duplicateErrors = CustomerUtil.getErrorMessages( CustomerUtil.getCpf_CnpjDuplicates( toValidateCpfOrCnpj ), CustomerUtil.getNameDuplicates( customers ) );

        List<Map<Customer__c, List<String>>> errorMessages = new List<Map<Customer__c, List<String>>>();
        errorMessages.add(validationErrors);
        errorMessages.add(duplicateErrors);

        CustomerUtil.sendErrorMessages( errorMessages );

    }

    public static void sendErrorMessages( List<Customer__c> newCustomers, Map<Id, Customer__c> newCustomersMap, List<Customer__c> oldCustomers, Map<Id, Customer__c> oldCustomersMap ) {
                Map<Id, Customer__c> updatedToValidateCpfOrCnpjMap = new Map<Id, Customer__c>();
                Map<Id, Customer__c> oldToValidateCpfOrCnpjMap = new Map<Id, Customer__c>();
                
                for ( Customer__c c : newCustomers ) {
                    if ( oldCustomersMap.get( c.Id ).Account__c == newCustomersMap.get( c.Id ).Account__c && !c.updatedByAcct__c) {
                        updatedToValidateCpfOrCnpjMap.put( c.Id, c );
                        oldToValidateCpfOrCnpjMap.put( c.Id, oldCustomersMap.get( c.Id ) );
                    }
                }
            
                Map<Customer__c, List<String>> validationErrors = CustomerFieldsValidationUtil.getErrorMessages( CustomerFieldsValidationUtil.validateRequired( newCustomers ), CustomerFieldsValidationUtil.validateFormat( newCustomers ), CustomerFieldsValidationUtil.requireTelefoneOrEmail( newCustomers ), CustomerFieldsValidationUtil.validateRelationship( newCustomersMap, oldCustomersMap ) );
                Map<Customer__c, List<String>> duplicateErrors = CustomerUtil.getErrorMessages( CustomerUtil.getCpf_CnpjDuplicates( updatedToValidateCpfOrCnpjMap, oldToValidateCpfOrCnpjMap ), CustomerUtil.getNameDuplicates( newCustomersMap, oldCustomersMap ) ); 

                List<Map<Customer__c, List<String>>> errorMessages = new List<Map<Customer__c, List<String>>>();
                errorMessages.add(validationErrors);
                errorMessages.add(duplicateErrors);

                CustomerUtil.sendErrorMessages( errorMessages );

    }

    // Reúne todas as mensagens de erro de um Customer e às envia de uma só vez
    public static void sendErrorMessages( List<Map<Customer__c, List<String>>> errorMessages ) {
        
        Map<Customer__c, List<String>> messagesToSend = new Map<Customer__c, List<String>>();
        
        for ( Map<Customer__c, List<String>> messages : errorMessages ) {
            for ( Customer__c c : messages.keySet() ) {
                if ( messagesToSend.get( c ) == null ) {
                    messagesToSend.put( c, new List<String>() );
                }
                messagesToSend.get( c ).addAll( messages.get( c ) );
            }
        }

        for ( Customer__c c : messagesToSend.keySet() ) {
            String message = '';
            for ( String m : messagesToSend.get ( c ) ) {
                message += m + ' ';
            }
            c.addError(message, false);
        }

    }

    // Monta, compila e associa com os Customers atualizados todas as mensagens de erro de duplicidade
    public static Map<Customer__c, List<String>> getErrorMessages( List<Customer__c> cpf_cnpjDuplicates, List<Customer__c> nameDuplicates ) {
        Map<Customer__c, List<String>> errorMessages = new Map<Customer__c, List<String>>();
        
        for ( Customer__c c : cpf_cnpjDuplicates ) {
            String message = c.CPF__c != null ? 'CPF' : 'CNPJ';
            errorMessages.put(c, new List<String>());
            errorMessages.get(c).add(message + ' já cadastrado!');
        }

        for ( Customer__c c : nameDuplicates ) {
            String message = 'Já existe um customer de nome ' + c.Name;
            if ( errorMessages.get( c ) == null ) {
                errorMessages.put( c, new List<String>() );
            }
            errorMessages.get( c ).add(message);
        }

        return errorMessages;
    }

    // Obtém todos os Customers atualizados com nome duplicado
    public static List<Customer__c> getNameDuplicates( List<Customer__c> customers ) {
        List<Customer__c> duplicates = new List<Customer__c>();

        List<Customer__c> existingCustomersNames = [SELECT Id, Name FROM Customer__c];
        
        List<String> existingNames = new List<String>();

        for ( Customer__c c : existingCustomersNames ) {
            existingNames.add( c.Name );
        }

        for ( Customer__c c : customers ) {
            if ( existingNames.contains( c.Name ) ) duplicates.add( c );
        } 

        return duplicates;
    }

    // Adaptação do método que obtém os Customers atualizados com nome duplicado para update
    public static List<Customer__c> getNameDuplicates( Map<Id, Customer__c> updatedCustomers, Map<Id, Customer__c> oldCustomers ) { 
        List<Customer__c> potentialCustomersWithDuplicatedName = new List<Customer__c>();

        for ( String id : updatedCustomers.keySet() ) {
            if ( updatedCustomers.get(id).Name != oldCustomers.get(id).Name ) {
                potentialCustomersWithDuplicatedName.add( updatedCustomers.get(id) );
            }
        }

        if ( !potentialCustomersWithDuplicatedName.isEmpty() ) { 
           return getNameDuplicates( potentialCustomersWithDuplicatedName );
        }
        
        return new List<Customer__c>();
    }

    public static void setStatusNew( List<Customer__c> newCustomers ) {
        for ( Customer__c c : newCustomers ) {
            c.Status__c = 'Novo';
        }
    }

    public static void submitToApproval( Map<Id, Customer__c> updatedCustomersMap, Map<Id, Customer__c> oldCustomersMap ) {
        
        List<Customer__c> toSubmitToApproval = new List<Customer__c>();

        for ( String id : updatedCustomersMap.keySet() ) {

            if ( updatedCustomersMap.get(id).Status__c != oldCustomersMap.get(id).Status__c && updatedCustomersMap.get(id).Status__c == 'Enviado para integração' ) {

                toSubmitToApproval.add( updatedCustomersMap.get(id) );        
            
            }

        }

        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        Approval.ProcessSubmitRequest[] requests = new List<Approval.ProcessSubmitRequest>();
        for ( Customer__c c : toSubmitToApproval ) {
            approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId( c.Id );
            approvalRequest.setSubmitterId( UserInfo.getUserId() );
            requests.add(approvalRequest);
        }
        Approval.process( requests );

    }

    // Obtém os Customers que estão sendo atualizados e estão aprovados ou rejeitados
    public static List<List<Customer__c>> getApprovalsStatus( List<Customer__c> toCheckApprovalStatus ) {
        List<ProcessInstance> processesInformations = new List<ProcessInstance>([SELECT TargetObjectId, Status FROM ProcessInstance]);
        Map<Id, String> processesInformationsMap = new Map<Id, String>();

        for ( ProcessInstance p : processesInformations ) {
            processesInformationsMap.put( p.TargetObjectId, p.Status );
        }
        
        List<Customer__c> approveds = new List<Customer__c>();
        List<Customer__c> rejecteds = new List<Customer__c>();

        for ( Customer__c c : toCheckApprovalStatus ) {
            if ( processesInformationsMap.get( c.Id ) == 'Approved' ) {
                approveds.add( c );
            } else if ( processesInformationsMap.get( c.Id ) == 'Rejected' ) {
                rejecteds.add( c );
            }
        }

        List<List<Customer__c>> result = new List<List<Customer__c>>();
        result.add(approveds);
        result.add(rejecteds);

        return result;
    }

    // Trata os Customers aprovados e rejeitados de acordo com as regras de negócio
    public static void treatApprovedsAndRejecteds( Map<Id, Customer__c> updatedCustomersMap ) {
        
        List<Customer__c> toCheckApprovalStatus = new List<Customer__c>();

        for ( String id : updatedCustomersMap.keySet() ) {
            if ( updatedCustomersMap.get(id).Status__c == 'Enviado para integração' ) {
                toCheckApprovalStatus.add( updatedCustomersMap.get(id) );
            }
        }

        if ( !toCheckApprovalStatus.isEmpty() ) {
            List<List<Customer__c>> approvedsAndRejecteds = CustomerUtil.getApprovalsStatus( toCheckApprovalStatus );

            Map<Id, Account> accountsToInsert = new Map<Id, Account>();
            Map<Id, Contact> contactsToInsert = new Map<Id, Contact>();
            List<Customer__c> toUpdate = new List<Customer__c>();

            for ( Customer__c c : approvedsAndRejecteds[0] ) {
                Boolean hasAccount = c.Account__c == null ? false : true;
                if ( !hasAccount ) {
            	    if ( c.RecordTypeId == '0128c000002EoQVAA0' ) {
                	    accountsToInsert.put( c.Id, new Account( Name=c.Name, Phone=c.Telefone__c, RecordTypeId='0128c000002EsqWAAS', CPF__c=c.CPF__c) );    
            	    } else if ( c.RecordTypeId == '0128c000002EoQaAAK' ) {
                	    accountsToInsert.put( c.Id, new Account( Name=c.Name, Phone=c.Telefone__c, RecordTypeId='0128c000002Esqg', CNPJ__c=c.CNPJ__c ) );
            	    }
                }
                contactsToInsert.put( c.Id, new Contact( LastName=c.Name, Phone=c.Telefone__c, Email=c.E_mail__c, createdByTriggerFlag__c=true, createdByCustomerOfId__c=c.Id ) );        
                c.Status__c = 'Integrado';
            }

            for ( Customer__c c : approvedsAndRejecteds[0] ) {
                if ( c.Account__c != null) {
                    contactsToInsert.get( c.Id ).AccountId = c.Account__c;
                }   
            }

            if ( !accountsToInsert.isEmpty() ) {
                insert accountsToInsert.values();
            
                for ( String id : contactsToInsert.keySet() ) {
                    contactsToInsert.get(id).AccountId = accountsToInsert.get(id).Id;
                }


                for ( Customer__c c : approvedsAndRejecteds[0] ) {
                    if ( c.Account__c == null ) {
                	    c.Account__c=accountsToInsert.get( c.Id ).Id;
                    }
                } 
            
            }

            insert contactsToInsert.values();

        
            for ( Customer__c c : approvedsAndRejecteds[1] ) {
                c.Status__c = 'Em análise';
            }

        }

    }

    public static void syncCustomerWithAccount( List<Customer__c> customers ) {

        List<Customer__c> toSync = new List<Customer__c>();

        for ( Customer__c c : customers ) {
            if ( c.Account__c != null && !c.updatedByAcct__c ) {
                toSync.add( c );
            }
        }

        List<Id> relatedAccountsIds = new List<Id>();
        
        for ( Customer__c c : toSync ) {
            relatedAccountsIds.add( c.Account__c );
        }
        
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, CPF__c, CNPJ__c FROM Account WHERE Id IN :relatedAccountsIds ]);
        for ( Customer__c c : toSync ) {
            if ( c.RecordTypeId == '0128c000002EoQVAA0') {
                c.CPF__c = accountsMap.get( c.Account__c ).CPF__c;
            } else if ( c.RecordTypeId == '0128c000002EoQaAAK' ) {
                c.CNPJ__c = accountsMap.get( c.Account__c ).CNPJ__c;
            }
        }
    }

    public static void syncCustomerWithAccount( Map<Id, Customer__c> newCustomersMap, Map<Id, Customer__c> oldCustomersMap ) {
        
        List<Customer__c> toSync = new List<Customer__c>();

        for ( Id id : newCustomersMap.keySet() ) {
            if ( oldCustomersMap.get( id ).Account__c != newCustomersMap.get( id ).Account__c || newCustomersMap.get( id ).Status__c != 'Integrado' ) {
                toSync.add( newCustomersMap.get( id ) );
            }
        }

        CustomerUtil.syncCustomerWithAccount( toSync );

    }
   
    public static void deleteRelatedAccountsAndContacts( List<Customer__c> deletedCustomersOld ) {
        
        Set<Id> relatedAccountsIds = new Set<Id>();
        
        for ( Customer__c c : (List<Customer__c>) Trigger.old ) {
            relatedAccountsIds.add( c.Account__c );
        }
        
        List<Account> relatedAccounts = [SELECT Id, ( SELECT Id, createdByTriggerFlag__c FROM Contacts ) FROM Account WHERE Id = :RelatedAccountsIds];
        
        List<SObject> toDelete = new List<SObject>();
        
        for ( Account a : relatedAccounts ) {
            if ( a.Contacts.size() > 1 ) {
                for ( Contact c : a.Contacts ) {
                    if ( c.createdByTriggerFlag__c ) {
                        toDelete.add( c );
                    }
                }
            } else if ( a.Contacts.size() != 0 && a.Contacts[0].createdByTriggerFlag__c ){
                toDelete.add( a );
            }
        }

        if ( !toDelete.isEmpty() )
            Database.delete( toDelete, false );
    }

    public static void blockEdition( List<Customer__c> oldCustomers, Map<Id, Customer__c> newCustomersMap ) {
        for ( Customer__c c : oldCustomers ) {
            if ( c.Status__c == 'Integrado' && !newCustomersMap.get( c.Id ).updatedByAcct__c ) {
                newCustomersMap.get( c.Id ).addError('Não se pode alterar um customer integrado');
            } else {
               	newCustomersMap.get( c.Id ).updatedByAcct__c = false;
            }
        }        
    }

}
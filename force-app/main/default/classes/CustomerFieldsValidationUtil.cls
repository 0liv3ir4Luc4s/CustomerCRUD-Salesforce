public with sharing class CustomerFieldsValidationUtil {
    
    // Valida o formato dos CPFs e dos CNPJs 
    public static Map<String, List<Customer__c>> validateFormat( List<Customer__c> customers ) {
        Map<String, List<Customer__c>> misformattedRecords = new Map<String, List<Customer__c>>();
        
        misformattedRecords.put( getFieldsLabel('CPF__c'), validateCpf( customers) );
        misformattedRecords.put( getFieldsLabel('CNPJ__c'), validateCnpj( customers) );

        return misformattedRecords;
    }

    // Valida se os campos obrigatórios foram preenchidos
    public static Map<String, List<Customer__c>> validateRequired( List<Customer__c> customers ) {
        Map<String, List<Customer__c>> invalidRecords = new Map<String, List<Customer__c>>();
        
        invalidRecords.put( getFieldsLabel('CPF__c'), requireCpf( customers ) );
        invalidRecords.put( getFieldsLabel('CNPJ__c'), requireCnpj( customers ) );

        return invalidRecords;
    }

    // Valida a relação conta - customer e os campos relacionados
    public static Map<String, List<Customer__c>> validateRelationship( Map<Id, Customer__c> updatedCustomersMap, Map<Id, Customer__c> oldCustomersMap ) {
        Map<String, List<Customer__c>> invalidRelationships = new Map<String, List<Customer__c>>();

        invalidRelationships.put( getFieldsLabel('Account__c'), validateRelatedAccountRecordType( updatedCustomersMap ) );
        invalidRelationships.put( getFieldsLabel('CPF__c'), validateCpf( updatedCustomersMap, oldCustomersMap ) );
        invalidRelationships.put( getFieldsLabel('CNPJ__c'), validateCnpj( updatedCustomersMap, oldCustomersMap ) );

        return invalidRelationships;
    }
	
    
    // Compila as mensagens de erro
    public static Map<Customer__c, List<String>> getErrorMessages( Map<String, List<Customer__c>> invalidRecords, Map<String, List<Customer__c>> misformattedRecords ) {
        Map<Customer__c, List<String>> errorMessages = new Map<Customer__c, List<String>>();

        // Prepara o mapa com o compilado de mensagens para cada Customer,
        // relacionando o Customer com suas mensagens de erro, evitando repetição
        for ( List<Customer__c> cList : misformattedRecords.values() ) {
            for ( Customer__c c : cList ) {
                if ( errorMessages.get( c ) == null) {
                    errorMessages.put( c, new List<String>() );
                }
            }
        }

        for ( List<Customer__c> cList : invalidRecords.values() ) {
            for ( Customer__c c : cList ) {
                if ( errorMessages.get( c ) == null ) {
                    errorMessages.put( c, new List<String>() );
                }
            }
        }

        // Monta as mensagens de erro de acordo com a situação e associa com o Customer
        for ( String requiredField : invalidRecords.keySet() ) {
            for ( Customer__c c : invalidRecords.get(requiredField) ) {
                if ( c.Account__c == null ) {
                    errorMessages.get( c ).add('Campo ' + requiredField + ' é obrigatório!');
                }
            } 
        }

        for ( String misformattedField : misformattedRecords.keySet() ) {
            for ( Customer__c  c : misformattedRecords.get(misformattedField) ) {
                errorMessages.get( c ).add('Campo ' + misformattedField + ' inválido!');
            }
        }

        return errorMessages;
    }

    // Compila as mensagens de erro incluindo a demanda especial de que telefone OU email seja preenchido para a fase 'Enviado para integração'
    public static Map<Customer__c, List<String>> getErrorMessages( Map<String, List<Customer__c>> invalidRecords, Map<String, List<Customer__c>> misformattedRecords, List<Customer__c> telefoneOrEmailRequired, Map<String, List<Customer__c>> invalidRelationships ) {
        System.debug(invalidRelationships);
        // Armazena resultado da chamada normal do método
        Map<Customer__c, List<String>> errorMessages = getErrorMessages( invalidRecords, misformattedRecords );
    
        // Processa demanda especial
        
        // Prepara o mapa com o compilado de mensagens para cada Customer,
        // relacionando o Customer com suas mensagens de erro, evitando repetição
        for ( Customer__c c : telefoneOrEmailRequired ) {
            if ( errorMessages.get( c ) == null ) {
                errorMessages.put( c, new List<String>() );
            }
        }

        // Monta as mensagens de erro de acordo com a situação e associa com o Customer
        for ( Customer__c c : telefoneOrEmailRequired ) {
            errorMessages.get( c ).add('Email ou Telefone deve ser preenchido!');
        }
        System.debug( invalidRelationships );
        for ( List<Customer__c> cList : invalidRelationships.values() ) {
            for ( Customer__c c : cList ) {
                if ( errorMessages.get( c ) == null ) {
                    errorMessages.put( c, new List<String>() );
                }
            }
        }

        for ( String invalidRelationshipField : invalidRelationships.keySet() ) {
            for ( Customer__c c : invalidRelationships.get( invalidRelationshipField ) ) {
                System.debug( invalidRelationshipField );
                if ( invalidRelationshipField == 'Account' ) {
                    if ( c.RecordTypeId == '0128c000002EoQVAA0' ) {
                        errorMessages.get( c ).add('A conta relacionada deve ser uma Pessoa Física');
                    } else if ( c.RecordTypeId == '0128c000002EoQaAAK' ) {
                        errorMessages.get( c ).add('A conta relacionada dever uma Pessoa Jurídica');
                    }
                } else {
                    errorMessages.get( c ).add('Não se pode alterar o ' + invalidRelationshipField + ' de um Customer com conta');
                }
            }
        }
        
        return errorMessages;
    }

    private static List<Customer__c> validateCpf( List<Customer__c> customers ) {
        List<Customer__c> misformattedRecords = new List<Customer__c>();
        for ( Customer__c c : customers ) {
            if ( c.RecordTypeId == '0128c000002EoQVAA0' && c.CPF__c != null && !( c.CPF__c.length() == 11 ) ) {
                misformattedRecords.add( c );
            }
        }
         
        return misformattedRecords;
    }

    private static List<Customer__c> validateCpf( Map<Id, Customer__c> updatedCustomersMap, Map<Id, Customer__c> oldCustomersMap ) {
        List<Customer__c> invalidRelationships = new List<Customer__c>();

        for ( String id : updatedCustomersMap.keySet() ) {
            if ( oldCustomersMap.get( id ).Account__c == updatedCustomersMap.get( id ).Account__c &&
            updatedCustomersMap.get( id ).CPF__c != oldCustomersMap.get( id ).CPF__c && !updatedCustomersMap.get( id ).updatedByAcct__c &&
            updatedCustomersMap.get( id ).Account__c != null ) {
                invalidRelationships.add( updatedCustomersMap.get( id ) );
            }
        }

        return invalidRelationships;
    }

    private static List<Customer__c> validateCnpj( List<Customer__c> customers ) {
        List<Customer__c> misformattedRecords = new List<Customer__c>();
        for ( Customer__c c : customers ) {
            if ( c.RecordTypeId == '0128c000002EoQaAAK' && c.CNPJ__c != null && !( c.CNPJ__c.length() == 14 ) ) {
                misformattedRecords.add( c );
            }
        }

        return misformattedRecords;
    }

    private static List<Customer__c> validateCnpj( Map<Id, Customer__c> updatedCustomersMap, Map<Id, Customer__c> oldCustomersMap ) {
        List<Customer__c> invalidRecords = new List<Customer__c>();

        for ( String id : updatedCustomersMap.keySet() ) {
            if ( oldCustomersMap.get( id ).Account__c == updatedCustomersMap.get( id ).Account__c &&
            updatedCustomersMap.get( id ).CNPJ__c != oldCustomersMap.get( id ).CNPJ__c && !updatedCustomersMap.get( id ).updatedByAcct__c &&
            updatedCustomersMap.get( id ).Account__c != null ) {
                invalidRecords.add( updatedCustomersMap.get( id ) );
            }
        }

        return invalidRecords;
    }
   
    private static List<Customer__c> requireCpf( List<Customer__c> customers ) {
        List<Customer__c> invalidRecords = new List<Customer__c>();
        for ( Customer__c c : customers ) {
            if ( c.RecordTypeId == '0128c000002EoQVAA0' && c.CPF__c == null ) {
                invalidRecords.add( c );
            }
        }

        return invalidRecords;
    }

    private static List<Customer__c> requireCnpj( List<Customer__c> customers ) {
        List<Customer__c> invalidRecords = new List<Customer__c>();
        for ( Customer__c c : customers ) {
            if ( c.RecordTypeId == '0128c000002EoQaAAK' && c.CNPJ__c == null ) {
                invalidRecords.add( c );
            }
        }

        return invalidRecords;
    }

    public static List<Customer__c> requireTelefoneOrEmail( List<Customer__c> customers ) {
        List<Customer__c> invalidRecords = new List<Customer__c>();
        for ( Customer__c c : customers ) {
            if ( c.Status__c == 'Enviado para integração' && c.Telefone__c == null && c.E_mail__c == null ) {
                invalidRecords.add( c );
            }
        }

        return invalidRecords;
    }

    public static List<Customer__c> validateRelatedAccountRecordType( Map<Id, Customer__c> customers ) {
        List<Id> accountsToGet = new List<Id>();
        
        for ( Customer__c c : customers.values() ) {
            accountsToGet.add( c.Account__c );
        }

        Map<Id, Account> relatedAccounts = new Map<Id, Account>([ SELECT Id, RecordTypeId FROM Account WHERE Id IN :accountsToGet ]);
        List<Customer__c> invalidRelationships = new List<Customer__c>();

        for ( Customer__c c : customers.values() ) {
            if ( c.Account__c != null ) {
                if ( ( relatedAccounts.get( c.Account__c ).RecordTypeId == '0128c000002EsqWAAS' && c.RecordTypeId == '0128c000002EoQaAAK' ) ||
                    ( relatedAccounts.get( c.Account__c ).RecordTypeId == '0128c000002EsqgAAC' && c.RecordTypeId == '0128c000002EoQVAA0' ) ) {
                    invalidRelationships.add( c );
                }
            }
        }

        return invalidRelationships;
    }

    // Obtém a label de um campo de acordo com sua API
    private static String getFieldsLabel ( String fieldsApiName ) {
        Map<String, Schema.SObjectType> schemas = Schema.getGlobalDescribe();
        Schema.SObjectType objectCustomer = schemas.get('Customer__c');
        Map<String, Schema.SObjectField> fields = objectCustomer.getDescribe().fields.getMap();

        return fields.get( fieldsApiName ).getDescribe().getLabel();    
    }
}
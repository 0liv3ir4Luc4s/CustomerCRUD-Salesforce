@isTest
public class TestDataFactory {
    
    public static Customer__c[] createValidCustomersPessoaFisica(Integer numCustomers) {
        List<Customer__c> toInsert = new List<Customer__c>();
        for (Integer i = 0; i < numCustomers; i++) {
            toInsert.add(new Customer__c(Name='ValidCustomerPF'+i, RecordTypeId=TestUtil.RECORD_TYPE_ID_CUSTOMER_PESSOA_FISICA, CPF__c=getCpf(true)));
        }        
        insert toInsert;
        return toInsert;
    }
    
    public static Customer__c[] createValidCustomersPessoaJuridica(Integer numCustomers) {
        List<Customer__c> toInsert = new List<Customer__c>();
        for (Integer i = 0; i < numCustomers; i++) {
            toInsert.add(new Customer__c(Name='ValidCustomerPJ'+i, RecordTypeId=TestUtil.RECORD_TYPE_ID_CUSTOMER_PESSOA_JURIDICA, CNPJ__c=getCnpj(true)));
        }
        insert toInsert;
        return toInsert;
    }

    public static String getCpf(Boolean isValid) {
        Integer span = 9;
        Integer n1 = getRandomInteger(span);
        Integer n2 = getRandomInteger(span);
        Integer n3 = getRandomInteger(span);
        Integer n4 = getRandomInteger(span);
        Integer n5 = getRandomInteger(span);
        Integer n6 = getRandomInteger(span);
        Integer n7 = getRandomInteger(span);
        Integer n8 = getRandomInteger(span);
        Integer n9 = getRandomInteger(span);
        Integer d1 = n9*2+n8*3+n7*4+n6*5+n5*6+n4*7+n3*8+n2*9+n1*10;
        d1 = 11 - (mod(d1,11));
        if (d1>=10) d1 = 0;
        Integer d2 = d1*2+n9*3+n8*4+n7*5+n6*6+n5*7+n4*8+n3*9+n2*10+n1*11;
        d2 = 11 - (mod(d2,11));
        if (d2>=10) d2 = 0;

        return isValid ? ''+n1+n2+n3+n4+n5+n6+n7+n8+n9+d1+d2 : ''+n1+n2+n3+n4+n5;
    }

    public static String getCnpj(Boolean isValid) {
        Integer n = 9;
        Integer n1  = getRandomInteger(n);
        Integer n2  = getRandomInteger(n);
        Integer n3  = getRandomInteger(n);
        Integer n4  = getRandomInteger(n);
        Integer n5  = getRandomInteger(n);
        Integer n6  = getRandomInteger(n);
        Integer n7  = getRandomInteger(n);
        Integer n8  = getRandomInteger(n);
        Integer n9  = 0;
        Integer n10 = 0;
        Integer n11 = 0;	
        Integer n12 = 1;		
        Integer d1 = n12*2+n11*3+n10*4+n9*5+n8*6+n7*7+n6*8+n5*9+n4*2+n3*3+n2*4+n1*5;
        d1 = 11 - ( mod(d1,11) );
        if (d1>=10) d1 = 0;
        Integer d2 = d1*2+n12*3+n11*4+n10*5+n9*6+n8*7+n7*8+n6*9+n5*2+n4*3+n3*4+n2*5+n1*6;
        d2 = 11 - ( mod(d2,11) );
        if (d2>=10) d2 = 0;

        return isValid ? ''+n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+d1+d2 : ''+n1+n2+n3+n4+n5;
    }

    private static Integer getRandomInteger(Integer n) {
        Integer ranNum = Math.round(Math.random()*n);
        return ranNum;
    }

    private static Integer mod(Integer dividendo, Integer divisor) {
        return Math.round(dividendo - (Math.floor(dividendo/divisor)*divisor));
    }
}

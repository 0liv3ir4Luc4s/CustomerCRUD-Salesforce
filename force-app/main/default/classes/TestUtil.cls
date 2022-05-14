@isTest
public class TestUtil {
    public static Id getRecordTypeId(Schema.DescribeSObjectResult salesforceObject, String recordTypeName) {
        return salesforceObject.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

}

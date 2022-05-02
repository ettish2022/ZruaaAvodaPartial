public with sharing class DynamicPickListFectcher {
    /**
    * Description : This generic method is used for for fetching dynamic picklist values by passing object API name and required field API name.
    */
    @AuraEnabled
    public static List<SelectOptionObj> getPicklistOptions(String objectApiName, String fieldApiName) {
        List<SelectOptionObj> picklistOptions = new List<SelectOptionObj>();
        try {
            Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
            Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
            Map<String,Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            SelectOptionObj option = null;
            for (Schema.PicklistEntry pickListVal : ple) {
                option = new SelectOptionObj(pickListVal.getLabel(), pickListVal.getValue(), pickListVal.isDefaultValue());
                picklistOptions.add(option);
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return picklistOptions;
    }

    
    public class SelectOptionObj {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public Boolean isDefault {get; set;}
        
        public SelectOptionObj(String label, String val, Boolean isDefault) {
            this.label = label;
            this.value = val;
            this.isDefault = isDefault;
        }
    }

}
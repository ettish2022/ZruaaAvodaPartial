/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-02-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class DynamicPickListFectcher_Test {
    @isTest
    static void requestTest(){    
        Test.startTest();
        DynamicPickListFectcher.getPicklistOptions('Request__c', 'Closing_Reason__c');
        Test.stopTest();
    }
}
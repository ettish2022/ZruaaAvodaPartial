/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-20-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-12-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@IsTest
public class Branch_Handler_Test {
    @isTest
    static void branchTest(){
        Account acc = [SELECT Id FROM Account limit 1];
        Contact con = [SELECT Id FROM Contact limit 1];
        Branch__c br = new Branch__c(Name = 'Test', Account__c = acc.Id, contact_from_request__c = false, Primary_Contact__c = con.Id);
        Test.startTest();
        insert br;
        Test.stopTest();
    }

    @TestSetup
    static void makeData(){
        Account acc = TEST_Utils.createTestAccount(new List<Account>{new Account()})[0];
        insert acc;
        
        Contact con = TEST_Utils.createTestContact(new List<Contact>{new Contact(AccountId = acc.Id)})[0];
        insert con;
    }
}
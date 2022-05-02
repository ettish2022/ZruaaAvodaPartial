/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-17-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
    @IsTest
    public class RequestHandlerTest {
        @isTest
        static void requestTest(){    
            Id parentRequestRTId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Parent_Request').getRecordTypeId();
            Id childRequestRTId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();
            Id idOfCurrentUser = UserInfo.getUserId();

            Account acc = [SELECT Id FROM Account limit 1];
            Contact con = [SELECT Id FROM Contact limit 1];
            Branch__c br = [SELECT Id FROM Branch__c limit 1];

            List<Request__c> reqList = new List<Request__c>{new Request__c(RecordTypeId = childRequestRTId, Area__c = 'North', Submition_Id__c = '1234', Account__c = acc.Id, Primary_Contact__c = con.Id),
                                                            new Request__c(RecordTypeId = childRequestRTId, Area__c = 'North', Submition_Id__c = '1234', Account__c = acc.Id, Primary_Contact__c = con.Id)};    
            Test.startTest();
            insert reqList;

            reqList[0].Branch__c = br.Id;
            update reqList[0];
            
            Request__c parent = [SELECT Id, RecordTypeId, OwnerId FROM Request__c WHERE RecordTypeId =: parentRequestRTId];
            System.debug('///parent: ' + parent);
            if(parent != null){
                parent.OwnerId = idOfCurrentUser;
                update parent;
            }

            reqList[0].Request_Status__c = 'Complete_Info';
            reqList[1].Request_Status__c = 'Needs_mapping';
            update reqList;

            reqList[0].Request_Status__c = 'Needs_mapping';
            update reqList[0];
            reqList[0].Request_Status__c = 'programRequest';
            update reqList[0];
            reqList[0].Request_Status__c = 'CloseRequest';
            update reqList[0];
            Test.stopTest();
        }
    
        @TestSetup
        static void makeData(){
            Account acc = TEST_Utils.createTestAccount(new List<Account>{new Account()})[0];
            insert acc;

            Contact con = TEST_Utils.createTestContact(new List<Contact>{new Contact(AccountId = acc.Id)})[0];
            insert con;

            List<Branch__c> brList = new List<Branch__c>{new Branch__c(Name = 'Test', Account__c = acc.Id, contact_from_request__c = false, Primary_Contact__c = con.Id),
                                                            new Branch__c(Name = 'Test', Account__c = acc.Id, contact_from_request__c = false, Primary_Contact__c = con.Id)};
            insert brList;
        }

}
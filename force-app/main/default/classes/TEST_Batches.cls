/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-04-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class TEST_Batches {

    private static string getCronString(){
        Datetime now = Datetime.now().addMinutes(2);
        Integer second = now.second();
        Integer minute = now.minute();
        Integer hour = now.hour();
        Integer day = now.day();
        Integer year = now.year();
        return '' + second + ' ' + minute + ' ' + hour + ' ' + day + ' * ? ' + year;
    }

    static TestMethod void testSyncCity(){
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true];
        String cronStr = getCronString();
        Test.startTest();
        insert new City__c(Name = 'test');
        Test.setMock(HttpCalloutMock.class, new CityHttpResMockImpl());
        System.runAs(users[0]){
            System.schedule('SCHD_SyncCities'+System.now(), cronStr, new SCHD_SyncCities());
        }
        Test.stopTest(); 
    }
    
    static TestMethod void testSyncStreet(){
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true];
        String cronStr = getCronString();
        Test.startTest();
        insert new City__c(Name = 'test', Code__c = '472');
        insert new Street__c(Name = 'test', Code__c = '472');
        Test.setMock(HttpCalloutMock.class, new StreetHttpResMockImpl());
        System.runAs(users[0]){
            System.schedule('SCHD_SyncStreets'+System.now(), cronStr, new SCHD_SyncStreets());
        }
        Test.stopTest(); 
    }
    
    static TestMethod void testSyncPrograms(){
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true];
        String cronStr = getCronString();
        Test.startTest();
        Program__c pro = new Program__c(External_Program_Id__c = Label_Utils.programs.get('ojt'));
        insert pro;
        Request__c r = new Request__c(ExtId__c = '1234_2');
        insert r;
        insert new ProgramRequest__c(Program__c = pro.Id, Request__c = r.Id, StatusDate__c = System.now(), Mail_Employer__c = false, ExtId__c = '1234_2');
        Test.setMock(HttpCalloutMock.class, new ProgramHttpResMockImpl());
        System.runAs(users[0]){
            System.schedule('SCHD_SyncProgramsFromMagar'+System.now(), cronStr, new SCHD_SyncProgramsFromMagar());
        }
        Test.stopTest();
    }
    
    static TestMethod void testSyncProfessions(){
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true];
        String cronStr = getCronString();
        Test.startTest();
        insert new Account(Name = 'test', Partner__c = true, Service_provider__c = Label_Utils.accServiceProvider.get('מפעיל'), Affiliation_To_Application__c = Label_Utils.accAffilationToApp.get('זירת מעסיקים'));
        insert new ProfessionCourse__c(Name = 'test', code__c = '1234', StatusDate__c = System.now(), Sector__c = 'מחשבים', Domain__c='מחשבים', OJT__c = true);
        Test.setMock(HttpCalloutMock.class, new ProfessionHttpResMockImpl());
        System.runAs(users[0]){
            System.schedule('SCHD_SyncProfessionsFromMagar'+System.now(), cronStr, new SCHD_SyncProfessionsFromMagar());
        }
        Test.stopTest();
    }

    static TestMethod void testEmailVoucherStock(){
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true];
        String cronStr = getCronString();
        Test.startTest();

        Contact con = TEST_Utils.createTestContact(new List<Contact>{new Contact()})[0];
        insert con;
        Program__c pro = TEST_Utils.createTestProgram(new List<Program__c>{new Program__c(Name = 'שובר למעסיק')})[0];
        insert pro;
        List<Voucher_Stock__c> vouchStockList = TEST_Utils.createTestVoucherStock(new List<Voucher_Stock__c>{new Voucher_Stock__c(Initial_amount_vouchers__c = 1, Send_Email__c = true)});
        insert vouchStockList;
        Id proReqShovar_RT = Schema.SObjectType.ProgramRequest__c.getRecordTypeInfosByDeveloperName().get('Shovar_Lamaasik').getRecordTypeId();
        List<ProgramRequest__c> proReqsList = TEST_Utils.createTestProgramRequest(new List<ProgramRequest__c>{new ProgramRequest__c(RecordTypeId = proReqShovar_RT, Primary_Contact_PR__c = con.Id, Program__c = pro.Id, Voucher_Stock__c = vouchStockList[0].Id, Qty_vouchers_requested__c = 5, vouchers_approved__c = 0, Status__c = Label_Utils.programRequestStatus.get('אזל מלאי שוברים'))});
        insert proReqsList;

        System.debug('!!!pro: ' + pro);
        System.debug('!!!proReqsList: ' + proReqsList);
        Test.setMock(HttpCalloutMock.class, new ProfessionHttpResMockImpl());
        System.runAs(users[0]){
            System.schedule('SCHD_sendEmailVoucherStock'+System.now(), cronStr, new SCHD_sendEmailVoucherStock());
        }
        Test.stopTest();
    }
    
    static TestMethod void testResetFieldOnceAYear(){
        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true];
        String cronStr = getCronString();
        Test.startTest();

        Account acc = TEST_Utils.createTestAccount(new List<Account>{new Account(Expired_Vouchers_Counter__c = 16)})[0];
        insert acc;
		System.debug('!!!acc: ' + acc);
        Test.setMock(HttpCalloutMock.class, new ProfessionHttpResMockImpl());
        System.runAs(users[0]){
            System.debug('!!!insert');
            System.schedule('SCHD_ResetFieldOnceAYear'+System.now(), cronStr, new SCHD_ResetFieldOnceAYear());
        }
        Test.stopTest();
    }
}
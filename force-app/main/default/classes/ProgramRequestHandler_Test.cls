/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-17-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class ProgramRequestHandler_Test {
    @isTest
    static void requestTest(){    

        List<ProgramRequest__c> proReqsList = [SELECT Id, vouchers_approved__c FROM ProgramRequest__c Limit 1];
        Test.startTest();
        proReqsList[0].vouchers_approved__c = 4;
        update proReqsList;
        Test.stopTest();
    }

    @TestSetup
    static void makeData(){
        List<City__c> cityList = TEST_Utils.createTestCity(new List<City__c>{new City__c()});
        insert cityList;
        
        Account acc = TEST_Utils.createTestAccount(new List<Account>{new Account()})[0];
        insert acc;

        Contact con = TEST_Utils.createTestContact(new List<Contact>{new Contact(AccountId = acc.Id)})[0];
        insert con;
        
        Program__c pro = TEST_Utils.createTestProgram(new List<Program__c>{new Program__c()})[0];
        insert pro;
        
        Request__c childRequest = TEST_Utils.createTestChildRequest(new List<Request__c>{new Request__c(Account__c = acc.Id, Primary_Contact__c = con.Id, Program__c = pro.Id)})[0];
        insert childRequest;
        
        List<Voucher_Stock__c> vouchStockList = TEST_Utils.createTestVoucherStock(new List<Voucher_Stock__c>{new Voucher_Stock__c()});
        insert vouchStockList;

        Id proReqShovar_RT = Schema.SObjectType.ProgramRequest__c.getRecordTypeInfosByDeveloperName().get('Shovar_Lamaasik').getRecordTypeId();
        List<ProgramRequest__c> proReqsList = TEST_Utils.createTestProgramRequest(new List<ProgramRequest__c>{new ProgramRequest__c(RecordTypeId = proReqShovar_RT, Account__c = acc.Id, Primary_Contact_PR__c = con.Id, Request__c = childRequest.Id, Program__c = pro.Id, Voucher_Stock__c = vouchStockList[0].Id, Qty_vouchers_requested__c = 5, vouchers_approved__c = 0, Status__c = Label_Utils.programRequestStatus.get('הקצאת שוברים חלקית'))});
        insert proReqsList;

        List<Voucher__c> vouchList = TEST_Utils.createTestVoucher(new List<Voucher__c>{new Voucher__c(Voucher_Stock__c = vouchStockList[0].Id, ProgramRequest__c = proReqsList[0].Id, Active__c = true),
                                                                                        new Voucher__c(Voucher_Stock__c = vouchStockList[0].Id, ProgramRequest__c = proReqsList[0].Id, Status__c = Label_Utils.voucherStatus.get('נדחה- פג תוקף'))});
        insert vouchList;
    }
}
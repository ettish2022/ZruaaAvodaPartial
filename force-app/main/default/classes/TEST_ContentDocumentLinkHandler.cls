/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-03-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-02-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@IsTest
public class TEST_ContentDocumentLinkHandler {
    @isTest
    static void contentDocumentLinkTest(){    
 
        Test.startTest();
        Id childRequestRTId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();
        List<ContentVersion> cvList = [SELECT contentdocumentid, VersionData FROM ContentVersion];
        String xml = cvList[0].VersionData.toString();
        String jsonContent = XmlParser.xmlToJson(xml);
        System.debug('///jsonContent1: ' + jsonContent);
        
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = [SELECT Id FROM Request__c WHERE RecordTypeId =: childRequestRTId limit 1].Id;
        contentlink1.contentdocumentid = cvList[0].contentdocumentid;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
        
        ContentDocumentLink contentlink2 = new ContentDocumentLink();
        contentlink2.LinkedEntityId = [SELECT Id FROM Request__c WHERE RecordTypeId =: childRequestRTId order by createdDate desc limit 1].Id;
        contentlink2.contentdocumentid = cvList[1].contentdocumentid;
        contentlink2.ShareType = 'I';
        contentlink2.Visibility = 'AllUsers'; 
        insert contentlink2;
        
        updateBuisnessField.updateAccBuisnessField();

        Test.stopTest();
    }

    @TestSetup
    static void makeData(){
        List<City__c> cityList = TEST_Utils.createTestCity(new List<City__c>{new City__c()});
        insert cityList;
        
        Account acc = TEST_Utils.createTestAccount(new List<Account>{new Account(Business_Id__c = '514712538')})[0];
        insert acc;

        Contact con = TEST_Utils.createTestContact(new List<Contact>{new Contact(AccountId = acc.Id, MobilePhone='052-5214424', Email='ediru10@gmail.com')})[0];
        insert con;
        
        Program__c pro = TEST_Utils.createTestProgram(new List<Program__c>{new Program__c(FG__c = TRUE)})[0];
        insert pro;
        
        Request__c parentRequest = TEST_Utils.createTestParentRequest(new List<Request__c>{new Request__c(Account__c = acc.Id, Primary_Contact__c = con.Id, Program__c = pro.Id)})[0];
        insert parentRequest;
        
        Request__c childRequest = TEST_Utils.createTestChildRequest(new List<Request__c>{new Request__c(Account__c = acc.Id, Primary_Contact__c = con.Id, Request__c = parentRequest.Id, Program__c = pro.Id)})[0];
        insert childRequest;
        
        List<ProgramRequest__c> proReqsList = TEST_Utils.createTestProgramRequest(new List<ProgramRequest__c>{new ProgramRequest__c(Request__c = childRequest.Id, Program__c = pro.Id, API__c = FALSE)});
        insert proReqsList;
        
        system.debug('///pro: ' + pro);
        system.debug('///parentRequest: ' + parentRequest);
        system.debug('///childRequest: ' + childRequest);
        system.debug('///childRequest: ' + childRequest.Account__r.Business_Id__c);
        system.debug('///childRequest: ' + childRequest.Primary_Contact__r.MobilePhone);
        system.debug('///proReqsList: ' + proReqsList);
        system.debug('///proReqsList: ' + proReqsList[0].Request_Status_f__c);
        
        ContentVersion content = new ContentVersion(); 
        content.Title = 'Header_Xml'; 
        content.PathOnClient = '/' + content.Title + '.xml';
        Blob bodyBlob = Blob.valueOf('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root formId="OjtNewRequest@labor.gov.il" formVersion="62" engine="govForms"><MetaData><referenceNumber>1234</referenceNumber><sentDate>15/3/2021 20:42:10</sentDate></MetaData><requestTypeTab><choseFieldType><dataCode>11</dataCode><dataText>עץ</dataText></choseFieldType><approvedProffessionList><dataCode>65</dataCode><dataText>ייצור רהיטים</dataText></approvedProffessionList><howToFillProffessions>1</howToFillProffessions><name>requestTypeTab</name><state>completed</state><next/><prev/><isClosed>true</isClosed></requestTypeTab><employerDetails><contractorTypeId>1</contractorTypeId><contractorHp>514712538</contractorHp><contractorId/><nikuim>910798438</nikuim><companyName>נ.א.אשר בע"מ</companyName><areaOfActivity><dataCode>14</dataCode><dataText>אחר</dataText></areaOfActivity><businessSignerName>נייקוב קלרה או רדימיר</businessSignerName><numberOfEmployees>19</numberOfEmployees><companyCity><dataCode>990</dataCode><dataText>ראס עלי</dataText></companyCity><streetSelect><dataCode>269</dataCode><dataText>קצנשטיין אריה</dataText></streetSelect><houseNum>19</houseNum><companyPhone>054-4710148</companyPhone><companyEmail>ediru10@gmail.com</companyEmail><contactFirstName>אדי</contactFirstName><contactLastName>רובינציק</contactLastName><contactJob>מלווה עסקי</contactJob><contactPhone>052-5214424</contactPhone><contactEmail>ediru10@gmail.com</contactEmail><name>employerDetails</name><state>completed</state><next/><prev/><isClosed>true</isClosed></employerDetails><trainingDetails><approvedProfessionsList><proffessionFieldType><dataCode>11</dataCode><dataText>עץ</dataText></proffessionFieldType><approvedProffessionType><dataCode>65</dataCode><dataText>ייצור רהיטים</dataText></approvedProffessionType><workersNum1>4</workersNum1><addressQuestion1>1</addressQuestion1><branchNumber1>19</branchNumber1><trainingCityTable><dataCode>4000</dataCode><dataText>חיפה</dataText></trainingCityTable><trainingStreetTable><dataCode>269</dataCode><dataText>קצנשטיין אריה</dataText></trainingStreetTable><trainingHouseNumTable>20</trainingHouseNumTable><addressQuestionCheckbox2>true</addressQuestionCheckbox2><mentorFirstNameTable>רדימיר</mentorFirstNameTable><mentorLastNameTable>נייקוב</mentorLastNameTable><mentorIdTable>317141166</mentorIdTable><mentorPhoneNumTable>050-6623716</mentorPhoneNumTable><mentorEmailTable>klara.neikov@gmail.com</mentorEmailTable></approvedProfessionsList><name>trainingDetails</name><state>completed</state><next/><prev/><isClosed>true</isClosed></trainingDetails><workersDetails><appendixB><name>הצהרת מעסיק.PDF</name><size>1285600</size><type>application/pdf</type><uploadedGuid>6fec45b5-2225-45ef-b956-4ec1f6677dd6</uploadedGuid><state>completed</state></appendixB><appendixC><name>תצהיר העדר.PDF</name><size>419151</size><type>application/pdf</type><uploadedGuid>d569fa4e-7059-4e40-9e69-bee9da354eb1</uploadedGuid><state>completed</state></appendixC><legalStatusCertificate><name>התאגדות.pdf</name><size>397560</size><type>application/pdf</type><uploadedGuid>e7707ab5-2444-4ccc-9ff4-4e16cedbec2a</uploadedGuid><state>completed</state></legalStatusCertificate><association><name>התאגדות.pdf</name><size>397560</size><type>application/pdf</type><uploadedGuid>943856b2-ad1f-4b29-9cb4-3022fffa3b79</uploadedGuid><state>completed</state></association><bankApproval><name>בנק לאומי - ריכוז יתרות.pdf</name><size>42174</size><type>application/pdf</type><uploadedGuid>7d58b1ca-dccb-44a2-ac70-9421fcbfaa28</uploadedGuid><state>completed</state></bankApproval><taxApproval><name>ניכוי מס במקור.pdf</name><size>157234</size><type>application/pdf</type><uploadedGuid>f670f2e5-109c-4dc8-b9df-6c7c2812acd8</uploadedGuid><state>completed</state></taxApproval><bookKipping><name>ניכוי מס במקור.pdf</name><size>157234</size><type>application/pdf</type><uploadedGuid>30839937-dc51-4839-bf28-d6b9ac14f619</uploadedGuid><state>completed</state></bookKipping><name>workersDetails</name><state>completed</state><next/><prev/><isClosed>false</isClosed></workersDetails><containersViewModel><showPrintButton>false</showPrintButton><currentContainerName>workersDetails</currentContainerName><validatedStatus>true</validatedStatus></containersViewModel><formInformation><isFormSent>false</isFormSent><loadingDate>15/03/2021</loadingDate><firstLoadingDate/><isMobile>false</isMobile><language>hebrew</language></formInformation><Files><Files id="943856b2-ad1f-4b29-9cb4-3022fffa3b79" fileName="התאגדות.pdf" type="application/pdf" sourceName="association"/><Files id="e7707ab5-2444-4ccc-9ff4-4e16cedbec2a" fileName="התאגדות.pdf" type="application/pdf" sourceName="legalStatusCertificate"/><Files id="6fec45b5-2225-45ef-b956-4ec1f6677dd6" fileName="הצהרת מעסיק.PDF" type="application/pdf" sourceName="appendixB"/><Files id="f670f2e5-109c-4dc8-b9df-6c7c2812acd8" fileName="ניכוי מס במקור.pdf" type="application/pdf" sourceName="taxApproval"/><Files id="7d58b1ca-dccb-44a2-ac70-9421fcbfaa28" fileName="בנק לאומי - ריכוז יתרות.pdf" type="application/pdf" sourceName="bankApproval"/><Files id="d569fa4e-7059-4e40-9e69-bee9da354eb1" fileName="תצהיר העדר.PDF" type="application/pdf" sourceName="appendixC"/><Files id="30839937-dc51-4839-bf28-d6b9ac14f619" fileName="ניכוי מס במקור.pdf" type="application/pdf" sourceName="bookKipping"/></Files></root>'); 
        content.VersionData = bodyBlob;
        content.origin = 'H';
        insert content;
        
        ContentVersion content2 = new ContentVersion(); 
        content2.Title = 'Header_Xml'; 
        content2.PathOnClient = '/' + content.Title + '.xml';
        Blob bodyBlob2 = Blob.valueOf('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root formId="OjtNewRequest@labor.gov.il" formVersion="62" engine="govForms"><MetaData><referenceNumber>1234</referenceNumber><sentDate>15/3/2021 20:42:10</sentDate></MetaData><requestTypeTab><choseFieldType><dataCode>11</dataCode><dataText>עץ</dataText></choseFieldType><approvedProffessionList><dataCode>65</dataCode><dataText>ייצור רהיטים</dataText></approvedProffessionList><howToFillProffessions>1</howToFillProffessions><name>requestTypeTab</name><state>completed</state><next/><prev/><isClosed>true</isClosed></requestTypeTab><employerDetails><contractorTypeId>1</contractorTypeId><contractorHp>514752538</contractorHp><contractorId/><nikuim>910798438</nikuim><companyName>נ.א.אשר בע"מ</companyName><areaOfActivity><dataCode>14</dataCode><dataText>אחר</dataText></areaOfActivity><businessSignerName>נייקוב קלרה או רדימיר</businessSignerName><numberOfEmployees>19</numberOfEmployees><companyCity><dataCode>990</dataCode><dataText>ראס עלי</dataText></companyCity><streetSelect><dataCode>269</dataCode><dataText>קצנשטיין אריה</dataText></streetSelect><houseNum>19</houseNum><companyPhone>054-4710148</companyPhone><companyEmail>ediru10@gmail.com</companyEmail><contactFirstName>אדי</contactFirstName><contactLastName>רובינציק</contactLastName><contactJob>מלווה עסקי</contactJob><contactPhone>052-5254424</contactPhone><contactEmail>e2diru10@gmail.com</contactEmail><name>employerDetails</name><state>completed</state><next/><prev/><isClosed>true</isClosed></employerDetails><trainingDetails><approvedProfessionsList><proffessionFieldType><dataCode>11</dataCode><dataText>עץ</dataText></proffessionFieldType><approvedProffessionType><dataCode>65</dataCode><dataText>ייצור רהיטים</dataText></approvedProffessionType><workersNum1>4</workersNum1><addressQuestion1>1</addressQuestion1><branchNumber1>19</branchNumber1><trainingCityTable><dataCode>4000</dataCode><dataText>חיפה</dataText></trainingCityTable><trainingStreetTable><dataCode>269</dataCode><dataText>קצנשטיין אריה</dataText></trainingStreetTable><trainingHouseNumTable>20</trainingHouseNumTable><addressQuestionCheckbox2>true</addressQuestionCheckbox2><mentorFirstNameTable>רדימיר</mentorFirstNameTable><mentorLastNameTable>נייקוב</mentorLastNameTable><mentorIdTable>317141166</mentorIdTable><mentorPhoneNumTable>050-6623716</mentorPhoneNumTable><mentorEmailTable>klara.neikov@gmail.com</mentorEmailTable></approvedProfessionsList><name>trainingDetails</name><state>completed</state><next/><prev/><isClosed>true</isClosed></trainingDetails><workersDetails><appendixB><name>הצהרת מעסיק.PDF</name><size>1285600</size><type>application/pdf</type><uploadedGuid>6fec45b5-2225-45ef-b956-4ec1f6677dd6</uploadedGuid><state>completed</state></appendixB><appendixC><name>תצהיר העדר.PDF</name><size>419151</size><type>application/pdf</type><uploadedGuid>d569fa4e-7059-4e40-9e69-bee9da354eb1</uploadedGuid><state>completed</state></appendixC><legalStatusCertificate><name>התאגדות.pdf</name><size>397560</size><type>application/pdf</type><uploadedGuid>e7707ab5-2444-4ccc-9ff4-4e16cedbec2a</uploadedGuid><state>completed</state></legalStatusCertificate><association><name>התאגדות.pdf</name><size>397560</size><type>application/pdf</type><uploadedGuid>943856b2-ad1f-4b29-9cb4-3022fffa3b79</uploadedGuid><state>completed</state></association><bankApproval><name>בנק לאומי - ריכוז יתרות.pdf</name><size>42174</size><type>application/pdf</type><uploadedGuid>7d58b1ca-dccb-44a2-ac70-9421fcbfaa28</uploadedGuid><state>completed</state></bankApproval><taxApproval><name>ניכוי מס במקור.pdf</name><size>157234</size><type>application/pdf</type><uploadedGuid>f670f2e5-109c-4dc8-b9df-6c7c2812acd8</uploadedGuid><state>completed</state></taxApproval><bookKipping><name>ניכוי מס במקור.pdf</name><size>157234</size><type>application/pdf</type><uploadedGuid>30839937-dc51-4839-bf28-d6b9ac14f619</uploadedGuid><state>completed</state></bookKipping><name>workersDetails</name><state>completed</state><next/><prev/><isClosed>false</isClosed></workersDetails><containersViewModel><showPrintButton>false</showPrintButton><currentContainerName>workersDetails</currentContainerName><validatedStatus>true</validatedStatus></containersViewModel><formInformation><isFormSent>false</isFormSent><loadingDate>15/03/2021</loadingDate><firstLoadingDate/><isMobile>false</isMobile><language>hebrew</language></formInformation><Files><Files id="943856b2-ad1f-4b29-9cb4-3022fffa3b79" fileName="התאגדות.pdf" type="application/pdf" sourceName="association"/><Files id="e7707ab5-2444-4ccc-9ff4-4e16cedbec2a" fileName="התאגדות.pdf" type="application/pdf" sourceName="legalStatusCertificate"/><Files id="6fec45b5-2225-45ef-b956-4ec1f6677dd6" fileName="הצהרת מעסיק.PDF" type="application/pdf" sourceName="appendixB"/><Files id="f670f2e5-109c-4dc8-b9df-6c7c2812acd8" fileName="ניכוי מס במקור.pdf" type="application/pdf" sourceName="taxApproval"/><Files id="7d58b1ca-dccb-44a2-ac70-9421fcbfaa28" fileName="בנק לאומי - ריכוז יתרות.pdf" type="application/pdf" sourceName="bankApproval"/><Files id="d569fa4e-7059-4e40-9e69-bee9da354eb1" fileName="תצהיר העדר.PDF" type="application/pdf" sourceName="appendixC"/><Files id="30839937-dc51-4839-bf28-d6b9ac14f619" fileName="ניכוי מס במקור.pdf" type="application/pdf" sourceName="bookKipping"/></Files></root>'); 
        content2.VersionData = bodyBlob2;
        content2.origin = 'H';
        insert content2;
    }

}
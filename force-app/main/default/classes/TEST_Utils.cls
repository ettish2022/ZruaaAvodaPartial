/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-02-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class TEST_Utils {
    
    public static List<Account> createTestAccount(List<Account> accountList){
        Integer num = 1;
        for(account thisRecord : accountList){
            integer accNum = Integer.valueof(Math.random() * 100000);
            thisRecord.Name = thisRecord.Name != null ? thisRecord.Name : 'Test' + num;
            thisRecord.Partner__c = true;
            thisRecord.Affiliation_To_Application__c = thisRecord.Affiliation_To_Application__c != null ? thisRecord.Affiliation_To_Application__c : Label_Utils.accAffilationToApp.get('זירת מעסיקים');
            thisRecord.Service_provider__c = thisRecord.Service_provider__c != null ? thisRecord.Service_provider__c :  Label_Utils.accServiceProvider.get('מפעיל');
            thisRecord.NumberOfEmployees = thisRecord.NumberOfEmployees != null ? thisRecord.NumberOfEmployees : 15;
            thisRecord.Phone = thisRecord.Phone != null ? thisRecord.Phone : '054011111' + num;
            thisRecord.Business_Id__c = thisRecord.Business_Id__c != null ? thisRecord.Business_Id__c : '51471253' + num;
            thisRecord.Expired_Vouchers_Counter__c = thisRecord.Expired_Vouchers_Counter__c != null ? thisRecord.Expired_Vouchers_Counter__c : 2;
            num++;
        }
        system.debug('///accountList: ' +accountList);
        return accountList;
    }

    public static List<Contact> createTestContact(List<Contact> contactList){
        Account defaultAccRequest = createTestAccount(new List<Account>{new Account()})[0];
        Integer contactNum = 1;
        for(Contact thisRecord : contactList){
            integer conNum = Integer.valueof((Math.random() * 10000));
            thisRecord.lastname = thisRecord.lastname != null ? thisRecord.lastname : 'Test Contact' + contactNum ;
            thisRecord.firstname = thisRecord.firstname != null ? thisRecord.firstname : 'Test1' + contactNum ;
            thisRecord.Phone = thisRecord.Phone != null ? thisRecord.Phone : '051234567' ;
            thisRecord.MobilePhone = thisRecord.MobilePhone != null ? thisRecord.MobilePhone : '051234567' ;
            thisRecord.email = thisRecord.email != null ? thisRecord.email : String.valueOf(system.now().millisecond())+'test@gmail.com';
            thisRecord.AccountId = thisRecord.AccountId != null ? thisRecord.AccountId : null;
            contactNum++;
        }
        return contactList;
    }

    public static List<Voucher__c> createTestVoucher(List<Voucher__c> vouchList){
        Integer num = 1;
        for(Voucher__c thisRecord : vouchList){
            integer accNum = Integer.valueof(Math.random() * 100000);
            thisRecord.Active__c = thisRecord.Active__c != null ? thisRecord.Active__c : true;
            thisRecord.ProgramRequest__c = thisRecord.ProgramRequest__c != null ? thisRecord.ProgramRequest__c : thisRecord.Id;
            thisRecord.Voucher_Stock__c = thisRecord.Voucher_Stock__c != null ? thisRecord.Voucher_Stock__c : thisRecord.Voucher_Stock__c;
            thisRecord.Rejected_Date__c = thisRecord.Rejected_Date__c != null ? thisRecord.Rejected_Date__c : Date.today();
            thisRecord.Status__c = thisRecord.Status__c != null ? thisRecord.Status__c : Label_Utils.voucherStatus.get('אושר עקרונית וממתין לגיוס עובד') ;
            num++;
        }
        system.debug('///vouchList: ' +vouchList);
        return vouchList;
    }

    public static List<Voucher_Stock__c> createTestVoucherStock(List<Voucher_Stock__c> vouchStockList){
        Integer num = 1;
        for(Voucher_Stock__c thisRecord : vouchStockList){
            integer accNum = Integer.valueof(Math.random() * 100000);
            // thisRecord.Area__c = thisRecord.Area__c != null ? thisRecord.Area__c : 'דרום';
            thisRecord.Initial_amount_vouchers__c = thisRecord.Initial_amount_vouchers__c != null ? thisRecord.Initial_amount_vouchers__c : 50;
            thisRecord.Population_type__c = thisRecord.Population_type__c != null ? thisRecord.Population_type__c : 'חרדים';
            thisRecord.Name = thisRecord.Name != null ? thisRecord.Name : 'חרדים דרום';
            thisRecord.Send_Email__c = thisRecord.Send_Email__c != null ? thisRecord.Send_Email__c : False;
            num++;
        }
        system.debug('///vouchStockList: ' +vouchStockList);
        return vouchStockList;
    }

    public static List<Program__c> createTestProgram(List<Program__c> programList){
        Integer num = 1;
        for(Program__c thisRecord : programList){
            thisRecord.Name = thisRecord.Name != null ? thisRecord.Name : 'הכשרה בעבודה';
            thisRecord.External_Program_Id__c = thisRecord.External_Program_Id__c != null ? thisRecord.External_Program_Id__c : Label_Utils.programs.get('ojt');
            thisRecord.FG__c = thisRecord.FG__c != null ? thisRecord.FG__c : False;
            num++;
        }
        return programList;
    }

    public static List<City__c> createTestCity(List<City__c> cityList){
        Integer num = 1;
        for(City__c thisRecord : cityList){
            thisRecord.Name = thisRecord.Name != null ? thisRecord.Name : 'ראס עלי' + num;
            thisRecord.Code__c = thisRecord.Code__c != null ? thisRecord.Code__c : '990';
            num++;
        }
        return cityList;
    }

    public static List<Request__c> createTestParentRequest(List<Request__c> requestList){
        Id parentRequestRTId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Parent_Request').getRecordTypeId();
        for(Request__c thisRecord : requestList){
            thisRecord.RecordTypeId = parentRequestRTId;
            thisRecord.Request_Details__c = thisRecord.Request_Details__c != null ? thisRecord.Request_Details__c : Label.TestUtils_RequestDetails;
            createRequestData(thisRecord);
        }
        return requestList;
    }

    public static List<Request__c> createTestChildRequest(List<Request__c> requestList){
        Id childRequestRTId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();
        for(Request__c thisRecord : requestList){
            thisRecord.Request_Status__c =  thisRecord.Request_Status__c != null ? thisRecord.Request_Status__c :  Label_Utils.requestStatus.get('סגור');
            thisRecord.Closing_Reason__c =  thisRecord.Closing_Reason__c != null ? thisRecord.Closing_Reason__c : Label_Utils.requestStatus.get('הועבר לטיפול בתוכנית');
            thisRecord.Request_Number__c =  thisRecord.Request_Number__c != null ? thisRecord.Request_Number__c : '1234';
            thisRecord.Employees_Requested_Num__c =  thisRecord.Employees_Requested_Num__c != null ? thisRecord.Employees_Requested_Num__c : 10;
            thisRecord.Job__c =  thisRecord.Job__c != null ? thisRecord.Job__c : 'חשמלאי';
            thisRecord.RecordTypeId = childRequestRTId;

            if(thisRecord.Request__c == null){
                Request__c defaultParentRequest = requestList.size() > 1 ? createTestParentRequest(new List<Request__c>{new Request__c()})[0] : null;
                if(defaultParentRequest != null){
                    if(defaultParentRequest.Id == null && requestList.size() > 1){
                        insert defaultParentRequest;
                    }
                    thisRecord.Request__c = requestList.size() > 1 ? defaultParentRequest.Id : null;
                    thisRecord.Program__c =  thisRecord.Program__c != null ? thisRecord.Program__c : defaultParentRequest.Program__c;
                    thisRecord.Account__c =  thisRecord.Account__c != null ? thisRecord.Account__c : defaultParentRequest.Account__c;
                    thisRecord.Primary_Contact__c =  thisRecord.Primary_Contact__c != null ? thisRecord.Primary_Contact__c : defaultParentRequest.Primary_Contact__c;   
                }
            } else{
                thisRecord.Request__c = thisRecord.Request__c;
                thisRecord.Primary_Contact__c =  thisRecord.Primary_Contact__c != null ? thisRecord.Primary_Contact__c : null;
                thisRecord.Account__c =  thisRecord.Account__c != null ? thisRecord.Account__c : null;
                thisRecord.Program__c =  thisRecord.Program__c != null ? thisRecord.Program__c : null;
            }
        }
        return requestList;
    }

    public static List<ProgramRequest__c> createTestProgramRequest(List<ProgramRequest__c> programRequestList){
        Id proReqOJT_RT = Schema.SObjectType.ProgramRequest__c.getRecordTypeInfosByDeveloperName().get('OJT_Recommendation').getRecordTypeId();
        for(ProgramRequest__c thisRecord : programRequestList){
            thisRecord.Status__c = thisRecord.Status__c != null ? thisRecord.Status__c : Label_Utils.programRequestStatus.get('הועבר לטיפול המפעיל');
            thisRecord.Mail_Employer__c = thisRecord.Mail_Employer__c != null ? thisRecord.Mail_Employer__c : false;
			thisRecord.API__c = thisRecord.API__c != null ? thisRecord.API__c : False;
			thisRecord.Voucher_Stock__c = thisRecord.Voucher_Stock__c != null ? thisRecord.Voucher_Stock__c : null;
			thisRecord.Qty_vouchers_requested__c = thisRecord.Qty_vouchers_requested__c != null ? thisRecord.Qty_vouchers_requested__c : 5;
            thisRecord.vouchers_approved__c = thisRecord.vouchers_approved__c != null ? thisRecord.vouchers_approved__c : 1;
            thisRecord.RecordTypeId = thisRecord.RecordTypeId != null ? thisRecord.RecordTypeId : proReqOJT_RT;
            
            if(thisRecord.Request__c == null){
                Request__c defaultChildRequest = createTestChildRequest(new List<Request__c>{new Request__c()})[0];
                if(defaultChildRequest.Id == null){
                    insert defaultChildRequest;
                }
                thisRecord.Request__c = defaultChildRequest.Id;
                thisRecord.Program__c = thisRecord.Program__c != null ? thisRecord.Program__c : defaultChildRequest.Program__c;
            } else{
                thisRecord.Request__c = thisRecord.Request__c;
                thisRecord.Program__c =  thisRecord.Program__c != null ? thisRecord.Program__c : null;
            }
        }
        return programRequestList;
    }

    private static void createRequestData(Request__c thisRecord){
        Program__c defaultProgram = createTestProgram(new List<Program__c>{new Program__c()})[0];
        Account defaultAccount = createTestAccount(new List<Account>{new Account()})[0];
        Contact defaultContact = createTestContact(new List<Contact>{new Contact()})[0];
        
        if(thisRecord.Program__c == null){
            if(defaultProgram.Id == null){
                insert defaultProgram;
            }
            thisRecord.Program__c = thisRecord.Program__c != null ? thisRecord.Program__c : defaultProgram.Id;
        } else{
            thisRecord.Program__c = thisRecord.Program__c;
        }

        if(thisRecord.Account__c == null){
            if(defaultAccount.Id == null){
                insert defaultAccount;
            }
            thisRecord.Account__c =  thisRecord.Account__c != null ? thisRecord.Account__c : defaultAccount.Id;
        } else{
            thisRecord.Account__c = thisRecord.Account__c;
        }
        
        if(thisRecord.Primary_Contact__c == null){
            if(defaultContact.Id == null){
                insert defaultContact;
            }
            thisRecord.Primary_Contact__c =  thisRecord.Primary_Contact__c != null ? thisRecord.Primary_Contact__c : defaultContact.Id;
        } else{
            thisRecord.Primary_Contact__c = thisRecord.Primary_Contact__c;
        }
    }

	public static List<Occupation__c> createTestOccupation(Integer AMOUNT_OCCUPATIONS_TO_CREATE){
		
        List<Occupation__c> occupationsList = new List<Occupation__c>();

        for (Integer occupationsToCreate = 0; occupationsToCreate < AMOUNT_OCCUPATIONS_TO_CREATE; occupationsToCreate++) {
            Occupation__c occupation = new Occupation__c();
            occupation.OccupationMatrixId__c = String.valueOf(occupationsToCreate);
            occupation.Name = 'Test ' + occupationsToCreate;
            occupationsList.add(occupation);
        }
        insert occupationsList;
        return occupationsList;
	} 



}
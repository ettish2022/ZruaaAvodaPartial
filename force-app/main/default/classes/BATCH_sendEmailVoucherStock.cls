global with sharing class BATCH_sendEmailVoucherStock implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

    global BATCH_sendEmailVoucherStock() {
        initData();
    }

    global void initData(){

    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr = 'SELECT Id FROM Voucher_Stock__c WHERE Send_Email__c = true';
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<Voucher_Stock__c> sobjs){
        Set<Id> vouStoIds = new Set<Id>();
        for(Voucher_Stock__c vs : sobjs){
            vouStoIds.add(vs.Id);
            vs.Send_Email__c = false;
        }

        System.debug('///vouStoIds: ' + vouStoIds);
        String prStatus = Label_Utils.programRequestStatus.get('אזל מלאי שוברים');
        List<ProgramRequest__c> proReqList = [SELECT Id, Status__c, Primary_Contact_PR__c, Primary_Contact_PR__r.Email FROM ProgramRequest__c 
                                                WHERE Program__r.Name = 'שובר למעסיק' AND Status__c =: prStatus AND Voucher_Stock__c in: vouStoIds
                                                AND CreatedDate = LAST_N_DAYS:180];
        System.debug('///proReqList: ' + proReqList);
        for(ProgramRequest__c pr : proReqList){
            if(pr.Primary_Contact_PR__c != null && pr.Primary_Contact_PR__r.Email != null)
                sendEmailStockUpdated(pr.Primary_Contact_PR__c, pr.Id);
        }

        Database.Update(sobjs, false);
    }

    global void finish(Database.BatchableContext bc){
    }

    public void sendEmailStockUpdated(Id contactId, Id prId){
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE Name = 'עדכון מלאי שוברים' limit 1];
 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactId);
        mail.setTemplateId(et.id);
        mail.setWhatId(prId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}
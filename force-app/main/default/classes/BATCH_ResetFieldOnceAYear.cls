/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class BATCH_ResetFieldOnceAYear implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

    global BATCH_ResetFieldOnceAYear() {
        initData();
    }

    global void initData(){

    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr = 'SELECT Id, Expired_Vouchers_Counter__c FROM Account WHERE Expired_Vouchers_Counter__c > 0';
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> sobjs){
        for(Account acc : sobjs){
            acc.Expired_Vouchers_Counter__c = 0;
        }

        Database.Update(sobjs, false);
    }

    global void finish(Database.BatchableContext bc){
    }


}
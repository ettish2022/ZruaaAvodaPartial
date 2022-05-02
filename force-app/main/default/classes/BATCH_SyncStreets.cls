/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-07-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BATCH_SyncStreets implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    
    public String datagov_service_get_streets_url;
    Integer i = 0;

    global BATCH_SyncStreets() {
        initData();
    }

    global void initData(){
        List<Global_Setting__mdt> settings = [select Id, DeveloperName, Value__c from Global_Setting__mdt where DeveloperName like 'datagov%'];
        for(Global_Setting__mdt mysetting : settings){
            if(mysetting.DeveloperName == 'datagov_service_get_streets_url'){
                this.datagov_service_get_streets_url = mysetting.Value__c;
            }
        }
        system.debug('///this.datagov_service_get_streets_url: ' + this.datagov_service_get_streets_url);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr = 'Select Id from Street__c';
        if(true){
            queryStr += ' limit 520 ';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<Street__c> sobjs){
        List<Street> Streets = new List<Street>();
        system.debug('///i before: ' + i);
        system.debug('///i * 100: ' + i * 100);
        Streets = getStreets(datagov_service_get_streets_url + '&limit=100' + '&offset=' + i * 100);
        System.debug('///Streets: ' + Streets);
        Utils.log(Streets);
        updateProfessions(Streets);
        i += 1;
        system.debug('///i after: ' + i);
    }

    global void finish(Database.BatchableContext bc){
    }
    
    public void updateProfessions(List<Street> Streets){
        if(Streets != null && !Streets.isEmpty()){
            List<Street__c> sobjs = new List<Street__c>();
            for(Street c : Streets){
                if(c != null && c.Code != null){
                    sobjs.add(c.getsobj());
                    System.debug('///c.getsobj(): ' + c.getsobj());
                }
            }
            
            if(!sobjs.isEmpty()){
                System.debug('///sobjs.size(): ' + sobjs.size());
                // upsert sobjs;
                Database.upsert(sobjs, Street__c.Code__c, false);	
            }
        }
    }
        
    public List<Street> getStreets(string baseUrl){
        // map<string, string> headers = new Map<String,String>{ 'Authorization' => token};
        system.debug('///baseUrl: ' + baseUrl);
        HttpResponse res = GLOBAL_HttpRequests.HttpReq('GET', baseUrl, null, null);
        String body = res != null ? res.getBody() : null;
        system.debug('///body: ' + body);
        system.debug('///res: ' + res);
        system.debug('///res.getStatusCode: ' + res.getStatusCode());
        if(String.isNotBlank(body) && res.getStatusCode() >= 200 && res.getStatusCode() < 300){
            try{
                body = body.replaceAll('סמל_ישוב', 'CityId');
                body = body.replaceAll('שם_ישוב', 'CityName');
                body = body.replaceAll('סמל_רחוב', 'Code');
                body = body.replaceAll('שם_רחוב', 'NameHalamas');
                DataGovResult dataGovResult = (DataGovResult) json.deserialize(body, DataGovResult.class);    
                system.debug('///dataGovResult: ' + dataGovResult);
                return dataGovResult.result.records;
            }
            catch(Exception e){
                system.debug(e);
                system.debug(e.getMessage());
                return null;
            }
        }
        else{
            return null;
        }
    }

    public class Street{
        public String Code {set;get;}
        public String NameHalamas {set;get;}
        public String CityName {set;get;}
        public String CityId {set;get;}

        public Street__c getsobj(){
            Street__c sobj = new Street__c();
            sobj.Name = this.NameHalamas;
            sobj.Code__c = this.CityId + '_' + this.Code;
            sobj.City__r = new City__c(Code__c = this.CityId);
            return sobj;
        }
    }

    public class DataGovResult{
        public DataGov2Result result {set; get;}
    }

    public class DataGov2Result{
        public List<Street> records {set; get;}
    }

}
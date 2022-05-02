/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-07-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BATCH_SyncCities implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    
    public String datagov_service_get_cities_url;
    Integer i = 0;

    global BATCH_SyncCities() {
        initData();
    }

    global void initData(){
        List<Global_Setting__mdt> settings = [select Id, DeveloperName, Value__c from Global_Setting__mdt where DeveloperName like 'datagov%'];
        for(Global_Setting__mdt mysetting : settings){
            if(mysetting.DeveloperName == 'datagov_service_get_cities_url'){
                this.datagov_service_get_cities_url = mysetting.Value__c;
            }
        }
        system.debug('///this.datagov_service_get_cities_url: ' + this.datagov_service_get_cities_url);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr = 'Select Id from City__c';
        if(true){
            queryStr += ' limit 40 ';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<City__c> sobjs){
        List<City> cities = new List<City>();
        system.debug('///i before: ' + i);
        system.debug('///i * 50: ' + i * 50);
        cities = getCities(datagov_service_get_cities_url + '&limit=50' + '&offset=' + i * 50);
        System.debug('///cities: ' + cities);
        System.debug('///cities.size(): ' + cities.size());
        Utils.log(cities);
        updateProfessions(cities);
        i += 1;
        system.debug('///i after: ' + i);
    }

    global void finish(Database.BatchableContext bc){
    }
    
    public void updateProfessions(List<City> cities){
        if(cities != null && !cities.isEmpty()){
            List<City__c> sobjs = new List<City__c>();
            for(City c : cities){
                if(c != null && c.Code != null){
                    sobjs.add(c.getsobj());
                    System.debug('///c.getsobj(): ' + c.getsobj());
                }
            }
            
            if(!sobjs.isEmpty()){
                System.debug('///sobjs.size(): ' + sobjs.size());
                Database.upsert(sobjs, City__c.Code__c, false);	
            }
        }
    }
        
    public List<City> getCities(string baseUrl){
        // map<string, string> headers = new Map<String,String>{ 'Authorization' => token};
        system.debug('///baseUrl: ' + baseUrl);
        HttpResponse res = GLOBAL_HttpRequests.HttpReq('GET', baseUrl, null, null);
        
        String body = res != null ? res.getBody() : null;
        if(String.isNotBlank(body) && res.getStatusCode() >= 200 && res.getStatusCode() < 300){
            try{
                body = body.replaceAll('גובה', 'Altitude');
                body = body.replaceAll('אזור טבעי', 'AreaNum');
                body = body.replaceAll('סמל יישוב', 'Code');
                body = body.replaceAll('צורת יישוב שוטפת', 'CurrentTypeLocalityNum');
                body = body.replaceAll('מחוז', 'DistrictNum');
                body = body.replaceAll('שיוך מטרופוליני', 'MetropoliticalAssociationNum');
                body = body.replaceAll('מעמד מונציפאלי', 'MunicipalStatusNum');
                body = body.replaceAll('תעתיק', 'NameEng');
                body = body.replaceAll('שם יישוב', 'NameHalamas');
                body = body.replaceAll('השתייכות ארגונית', 'OrganizationalAffiliationNum');
                body = body.replaceAll('ועדת תכנון', 'PlanningCommitteeNum');
                body = body.replaceAll('תחנת משטרה', 'PoliceStationNum');
                body = body.replaceAll('סך הכל אוכלוסייה 2019', 'PopulationNum');
                body = body.replaceAll('דת יישוב', 'ReligionNum');
                body = body.replaceAll('נפה', 'SubDistrictNum');
                body = body.replaceAll('שנת ייסוד', 'YearEstablished');
                body = body.replaceAll('שנה', 'Year');
                DataGovResult dataGovResult = (DataGovResult) json.deserialize(body, DataGovResult.class);    
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

    public class City{
        public String Altitude {set;get;}
        public String AreaNum {set;get;}
        public String Code {set;get;}
        public String CurrentTypeLocalityNum {set;get;}
        public String DistrictNum {set;get;}
        public String MetropoliticalAssociationNum {set;get;}
        public String MunicipalStatusNum {set;get;}
        public String NameEng {set;get;}
        public String NameHalamas {set;get;}
        public String OrganizationalAffiliationNum {set;get;}
        public String PlanningCommitteeNum {set;get;}
        public String PoliceStationNum {set;get;}
        public String PopulationNum {set;get;}
        public String ReligionNum {set;get;}
        public String Religion {set;get;}
        public String SubDistrictNum {set;get;}
        public String SubDistrict {set;get;}
        public String YearEstablished {set;get;}
        public String Year {set;get;}

        public City__c getsobj(){
            City__c sobj = new City__c();
            sobj.Name = this.NameHalamas;
            sobj.NameExtId__c = this.NameHalamas;
            sobj.Altitude__c = this.Altitude;
            sobj.AreaNum__c = this.AreaNum;
            sobj.Code__c = this.Code;
            sobj.CurrentTypeLocalityNum__c = this.CurrentTypeLocalityNum;
            sobj.DistrictNum__c = this.DistrictNum;
            sobj.District_Picklist__c = this.DistrictNum;
            sobj.MetropoliticalAssociationNum__c = this.MetropoliticalAssociationNum;
            sobj.MunicipalStatusNum__c = this.MunicipalStatusNum;
            sobj.NameEng__c = this.NameEng;
            sobj.NameHalamas__c = this.NameHalamas;
            sobj.OrganizationalAffiliationNum__c = this.OrganizationalAffiliationNum;
            sobj.PlanningCommitteeNum__c = this.PlanningCommitteeNum;
            sobj.PoliceStationNum__c = this.PoliceStationNum;
            sobj.PopulationNum__c = this.PopulationNum;
            sobj.ReligionNum__c = this.ReligionNum;
            sobj.SubDistrictNum__c = this.SubDistrictNum;
            sobj.YearEstablished__c = this.YearEstablished.indexOf('.') < 0 ? this.YearEstablished : this.YearEstablished.substring(0, this.YearEstablished.indexOf('.'));
            sobj.Year__c = this.Year;
            return sobj;
        }
    }

    public class DataGovResult{
        public DataGov2Result result {set; get;}
    }

    public class DataGov2Result{
        public List<City> records {set; get;}
    }

}
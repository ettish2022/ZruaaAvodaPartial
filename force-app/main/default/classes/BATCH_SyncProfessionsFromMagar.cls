/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-09-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BATCH_SyncProfessionsFromMagar implements Database.Batchable<SObject>, Database.AllowsCallouts{
    
    public String magar_service_get_professions;
    public String magar_service_get_ojt_data;
    public String magar_service_password;
    public String magar_service_username;
    public String magar_service_url;

    global BATCH_SyncProfessionsFromMagar() {
        initData();
    }

    global void initData(){
        List<Global_Setting__mdt> settings = [select Id, DeveloperName, Value__c from Global_Setting__mdt where DeveloperName like 'magar%'];
        for(Global_Setting__mdt mysetting : settings){
            if(mysetting.DeveloperName == 'magar_service_get_professions'){
                this.magar_service_get_professions = mysetting.Value__c;
            }
            else if(mysetting.DeveloperName == 'magar_service_get_ojt_data'){
                this.magar_service_get_ojt_data = mysetting.Value__c;
            }
            else if(mysetting.DeveloperName == 'magar_service_password'){
                this.magar_service_password = mysetting.Value__c;
            }
            else if(mysetting.DeveloperName == 'magar_service_username'){
                this.magar_service_username = mysetting.Value__c;
            }
            else if(mysetting.DeveloperName == 'magar_service_url'){
                this.magar_service_url = mysetting.Value__c;
            }
        }
	}

    global Database.QueryLocator start(Database.BatchableContext bc){
		String queryStr = 'Select Id, StatusDate__c from ProfessionCourse__c where OJT__c = true order by StatusDate__c desc NULLS Last';

		if(true){
			queryStr += ' limit 1 '; // get only one in order to run the batch only once time
		}
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<ProfessionCourse__c> sobjs){
    	List<Profession> pcs = new List<Profession>();
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        DateTime dt = DateTime.now().addDays(-1);
        //DateTime dt = DateTime.newInstance(2020, 10, 01, 0, 0, 0);
        System.debug('///sobjs: ' + sobjs);
        String formattedDate = sobjs != null && sobjs.size() > 0 && sobjs[0].StatusDate__c != null ? sobjs[0].StatusDate__c.formatGMT(dateFormat) : dt.formatGMT(dateFormat);
        //String formattedDate = dt.formatGMT(dateFormat);
        String url = magar_service_url + magar_service_get_professions + '?$filter= updateDate ge ' + formattedDate;
        url = url.replaceAll(' ', '%20');
        pcs = getProfessions(getAuthHeader(), url);
        System.debug('pcs');
        Utils.log(pcs);
	    updateProfessions(pcs);
    }

	global void finish(Database.BatchableContext bc){
	}
	
	public void updateProfessions(List<Profession> pcs){
		if(pcs != null && !pcs.isEmpty()){
	    	List<ProfessionCourse__c> sobjs = new List<ProfessionCourse__c>();
	    	for(Profession pc : pcs){
	    		if(pc != null && pc.professionId != null){
	    			sobjs.add(pc.getsobj());
	    		}
	    	}
	    	
	    	if(!sobjs.isEmpty()){
                System.debug('///sobjs: ' + sobjs);
				Database.upsert(sobjs, ProfessionCourse__c.Magar_Code__c, false);	
	    	}
	    }
	}
	
	private String getAuthHeader(){
		Blob headerValue = Blob.valueOf(magar_service_username + ':' + magar_service_password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        return authorizationHeader;
	}
    
    public List<Profession> getProfessions(String token, string baseUrl){
        System.debug('///baseUrl: ' + baseUrl);
        map<string, string> headers = new Map<String,String>{ 'Authorization' => token};
        HttpResponse res = GLOBAL_HttpRequests.HttpReq('GET', baseUrl, null, headers);
        
        String body = res != null ? res.getBody() : null;
    	if(String.isNotBlank(body) && res.getStatusCode() >= 200 && res.getStatusCode() < 300){
            try{
                OdataResult odataResult = (OdataResult) json.deserialize(res.getBody(), OdataResult.class);  
                System.debug('///odataResult: ' + odataResult);
			    return odataResult.value;
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

    public class Profession{
        public Decimal professionId {set;get;}
        public DateTime updateDate {set;get;}
        public String professionCode {set;get;}
        public String professionDesc {set;get;}
        public String fieldCode {set;get;}
        public String fieldDesc {set;get;}

        public ProfessionCourse__c getsobj(){
            ProfessionCourse__c sobj = new ProfessionCourse__c();
            //sobj.Code__c = String.valueOf(this.professionId);
            sobj.StatusDate__c = this.updateDate;
            sobj.Magar_Code__c = this.professionCode != null ? this.professionCode : null;
            sobj.Code__c = this.professionCode != null ? 'MC00' + this.professionCode : null;
            sobj.Name = this.professionDesc;
            sobj.OJT__c = true;
            sobj.Sector__c = this.fieldDesc;
            // sobj.ClassificationCode__c = this.fieldCode;
            return sobj;
        }
    }

    public class OdataResult{
        public List<Profession> value {set; get;}
    }

}
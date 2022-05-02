/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-19-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-03-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BATCH_SyncProgramsFromMagar implements Database.Batchable<SObject>, Database.AllowsCallouts{
    
    public String magar_service_get_professions;
    public String magar_service_get_ojt_data;
    public String magar_service_password;
    public String magar_service_username;
    public String magar_service_url;
    final static Id childRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();
    final static Id ojtProgramRequest_RT = Schema.SObjectType.ProgramRequest__c.getRecordTypeInfosByDeveloperName().get('OJT_Recommendation').getRecordTypeId();

    global BATCH_SyncProgramsFromMagar() {
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
		String queryStr = 'Select Id, StatusDate__c  from ProgramRequest__c where Program__r.External_Program_Id__c = \'ojt\' order by StatusDate__c desc NULLS Last';
		if(true){
			queryStr += ' limit 1 '; // get only one in order to run the batch only once time
		}
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<ProgramRequest__c> sobjs){
    	List<ProgramCase> pcs = new List<ProgramCase>();
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        DateTime dt = DateTime.now().addDays(-1);
        //DateTime dt = DateTime.newInstance(2020, 10, 01, 0, 0, 0);
        system.debug('///sobjs: ' + sobjs);
        String formattedDate = sobjs != null && sobjs.size() > 0 && sobjs[0].StatusDate__c != null ? sobjs[0].StatusDate__c.formatGMT(dateFormat) : dt.formatGMT(dateFormat);
        //String formattedDate = dt.formatGMT(dateFormat);
        String url = magar_service_url + magar_service_get_ojt_data + '?$filter= statusDate ge ' + formattedDate;
        url = url.replaceAll(' ', '%20');

        pcs = getProgramCases(getAuthHeader(), url);
        Utils.log(pcs);
        System.debug('///pcs: ' + pcs);
	    updateProgramCases(pcs);
    }

	global void finish(Database.BatchableContext bc){
	}
	
	public void updateProgramCases(List<ProgramCase> pcs){
		if(pcs != null && !pcs.isEmpty()){
	    	List<ProgramRequest__c> sobjs = new List<ProgramRequest__c>();
            Map<String, Request__c> requests = new Map<String, Request__c>();
	    	for(ProgramCase pc : pcs){
	    		if(pc != null && pc.formId != null && pc.requestId != null && pc.requestId.contains('_')){
	    			ProgramRequest__c tmp = pc.getsobj();
                    sobjs.add(tmp);
                    requests.put(tmp.Request__r.ExtId__c, new Request__c(ExtId__c = tmp.Request__r.ExtId__c, RecordTypeId = childRequest_RT));
	    		}
	    	}
	    	
	    	if(!sobjs.isEmpty()){
                Utils.log(sobjs);
                Utils.log(requests);
                System.debug('////requests: ' + requests);
                System.debug('////sobjs: ' + sobjs);
                Database.upsert(requests.values(), Request__c.ExtId__c, false);
                for(ProgramRequest__c pr : sobjs){
                    if(pr.Request__r != null && pr.Request__r.Id == null && pr.Request__r.ExtId__c != null ){
                        Request__c reqTmp = requests.get(pr.Request__r.ExtId__c);
                        if(reqTmp != null && reqTmp.Id != null){
                        	pr.Request__r.Id = reqTmp.Id;
                        }
                    }
                    pr.Request__c = pr.Request__r != null ? pr.Request__r.Id : null;
                    pr.Request__r = null;
                }
                Utils.log(requests);
                Utils.log(sobjs);
				Database.upsert(sobjs, ProgramRequest__c.ExtId__c, false);	
                Utils.log(sobjs);
	    	}
	    }
	}
	
	private String getAuthHeader(){
		Blob headerValue = Blob.valueOf(magar_service_username + ':' + magar_service_password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        return authorizationHeader;
	}
    
    public List<ProgramCase> getProgramCases(String token, string baseUrl){
        map<string, string> headers = new Map<String,String>{ 'Authorization' => token};
        HttpResponse res = GLOBAL_HttpRequests.HttpReq('GET', baseUrl, null, headers);
        
        String body = res != null ? res.getBody() : null;
    	if(String.isNotBlank(body) && res.getStatusCode() >= 200 && res.getStatusCode() < 300){
            try{
                OdataResult odataResult = (OdataResult) json.deserialize(res.getBody(), OdataResult.class);    
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

    public class ProgramCase{
        public String formId {set;get;}
        public String requestId {set;get;}
        public String requestStatus {set;get;}
        public DateTime statusDate {set;get;}
        public String trainingStatus {set;get;}
        public Decimal numOfEmpApproved {set;get;}
        public Decimal numOfEmpAccepted {set;get;}
        public Decimal sumPaidFirstStage {set;get;}
        public Decimal sumPaidSecondStage {set;get;}
        public Decimal numOfEmpArab {set;get;}
        public Decimal numOfEmpHaredMale {set;get;}
        public Decimal numOfEmpHaredFemale {set;get;}
        public Decimal numOfEmpYoBeshala {set;get;}
        public Decimal numOfEmpEthyopian {set;get;}
        public Decimal numOfEmpSocialNeeds {set;get;}
        public Decimal numOfEmpSingleParent {set;get;}
        public Decimal numOfEmpTeenagers {set;get;}
        public Decimal numOfEmpSocialTreat {set;get;}
        public Decimal numOfEmpDisabled {set;get;}
        public Decimal totalSumApproved {set;get;}
        public Decimal totalSumUsed {set;get;}

        public ProgramRequest__c getsobj(){
            ProgramRequest__c sobj = new ProgramRequest__c();
            // sobj.formId__c = this.formId;
            sobj.RecordTypeId = ojtProgramRequest_RT;
            sobj.Request__r = new Request__c(ExtId__c = this.requestId);
            sobj.Program__r = new Program__c(External_Program_Id__c = 'ojt');
            sobj.ExtId__c = this.requestId;
            sobj.StatusDate__c = this.statusDate;
            sobj.Mail_Employer__c = false;
            // sobj.Status__c = this.requestStatus == 'ערעור במשרד' ? 'טיפול בערעור' : this.requestStatus == 'השלמת פרטים' ? 'השלמת מסמכים' : this.requestStatus == 'טיפול מ.חוזר' ? 'בטיפול המשרד' : this.requestStatus == 'טיפול מטה' ?  'הועבר לטיפול המפעיל' : this.requestStatus == 'נדחה' ? 'הבקשה נדחתה' : this.requestStatus == 'נדחה תקציבית' ? 'תקציב נגמר' : this.requestStatus == 'תשובת ערעור' ? 'טיפול בערעור' :  this.requestStatus == 'מבוטלת' ?  'המעסיק לא מעוניין להצטרף' :  this.requestStatus == 'בקשה אושרה' ?  'אושר' :  this.requestStatus == 'טיפול המשרד' ?  'בטיפול המשרד' : 'הבקשה נדחתה';
            sobj.Status__c = this.requestStatus == 'ערעור במשרד' ? Label_Utils.programRequestStatus.get('טיפול בערעור'): this.requestStatus == 'השלמת פרטים' ? Label_Utils.programRequestStatus.get('השלמת מסמכים') : this.requestStatus == 'טיפול מ.חוזר' ? Label_Utils.programRequestStatus.get('בטיפול המשרד'): this.requestStatus == 'טיפול מטה' ? Label_Utils.programRequestStatus.get('הועבר לטיפול המפעיל') : this.requestStatus == 'נדחה' ? Label_Utils.programRequestStatus.get('הבקשה נדחתה') : this.requestStatus == 'נדחה תקציבית' ? Label_Utils.programRequestStatus.get('תקציב נגמר') : this.requestStatus == 'תשובת ערעור' ? Label_Utils.programRequestStatus.get('טיפול בערעור'):  this.requestStatus == 'מבוטלת' ? Label_Utils.programRequestStatus.get('המעסיק לא מעוניין להצטרף') :  this.requestStatus == 'בקשה אושרה' ?  Label_Utils.programRequestStatus.get('אושר') :  this.requestStatus == Label_Utils.programRequestStatus.get('בטיפול המשרד')?  Label_Utils.programRequestStatus.get('בטיפול המשרד'): Label_Utils.programRequestStatus.get('הבקשה נדחתה');
            sobj.Rejection_Reason__c = sobj.Status__c == Label_Utils.rejectReason.get('הבקשה נדחתה') ? Label_Utils.rejectReason.get('התקבל ממגער') : '';
            sobj.NumberApproved__c = this.numOfEmpApproved;
            sobj.NumberAccepted__c = this.numOfEmpAccepted;
            sobj.sumPaidFirstStage__c = this.sumPaidFirstStage;
            sobj.sumPaidSecondStage__c = this.sumPaidSecondStage;
            sobj.NumApprovedFromArabPopulation__c = this.numOfEmpArab;
            sobj.NumApprovedFromHarediPopulationMale__c = this.numOfEmpHaredMale;
            sobj.NumApprovedFromHarediPopulationFemale__c = this.numOfEmpHaredFemale;
            sobj.NumApprovedYotzimBeShela__c = this.numOfEmpYoBeshala;
            sobj.NumApprovedEthyopianPopulation__c = this.numOfEmpEthyopian;
            sobj.NumApprovedSocialNeeds__c = this.numOfEmpSocialNeeds;
            sobj.NumApprovedSingleParents__c = this.numOfEmpSingleParent;
            sobj.NumApprovedTeenagersAtRisk__c = this.numOfEmpTeenagers;
            sobj.NumApprovedSocialyTreated__c = this.numOfEmpSocialTreat;
            sobj.NumApprovedWithDisabilities__c = this.numOfEmpDisabled;
            sobj.TotalSumApproved__c = this.totalSumApproved;
            sobj.TotalSumUsed__c = this.totalSumUsed;
            return sobj;
        }
    }

    public class OdataResult{
        public List<ProgramCase> value {set; get;}
    }

}
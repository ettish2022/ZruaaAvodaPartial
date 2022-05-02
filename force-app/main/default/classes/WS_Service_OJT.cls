/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-23-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-12-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class WS_Service_OJT extends RestClient{
    final static Id parentRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Parent_Request').getRecordTypeId();
    final static Id childRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();
    final static Id ojtProgramRequest_RT = Schema.SObjectType.ProgramRequest__c.getRecordTypeInfosByDeveloperName().get('OJT_Recommendation').getRecordTypeId();
    
    public WS_Service_OJT() {
        super(null, null);
    }

    public WS_Service_OJT(RestRequest request, RestResponse response, String objectExtId) {
		super(request,response);
    }
    
    public override object get(){
        return null;
    }

    public override object post(){
        List<Request__c> reqsToInsert = new List<Request__c>();
        List<ProgramRequest__c> progReqsToInsert = new List<ProgramRequest__c>();
        Request__c parentReqToInsert = new Request__c();
        try{
            Map<String, Object> jsonrequest = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
            Decimal reqNum = Decimal.valueOf(String.valueOf(jsonrequest.get('professionsCnt')));
            system.debug('///reqNum: ' + reqNum);
            system.debug('///jsonrequest: ' + jsonrequest);
            //if(jsonrequest.get('newValues') instanceOf List<Object>){//If there are more than one element
            if(reqNum > 1){//If there are more than one element
                system.debug('///inside1 ');
                parentReqToInsert = createParentRequest(jsonrequest, (List<Object>)jsonrequest.get('newValues'));
				Database.upsert(parentReqToInsert, Request__c.ExtId__c, false); //Insert the parent's list
                for(Object newReq : (List<Object>)jsonrequest.get('newValues')){
                    reqsToInsert.add(createChildRequest((Map<String, Object>)newReq, parentReqToInsert.Id));
                }
            } else{
                system.debug('///inside2 ');
                //Object newReq = jsonrequest.get('newValues');
                //reqsToInsert.add(createChildRequest((Map<String, Object>)newReq, null));
                for(Object newReq : (List<Object>)jsonrequest.get('newValues')){
                    reqsToInsert.add(createChildRequest((Map<String, Object>)newReq, null));
                }
            }

            //Insert Request Lists + create related Program Request Lists
            if(reqsToInsert.size() > 0){
				Database.upsert(reqsToInsert, Request__c.ExtId__c, false);	
                for(Request__c req : reqsToInsert){
                    progReqsToInsert.add(createProgramRequest(req.Id, req));
                }
            }
            //Insert Program Request Lists
            if(progReqsToInsert.size() > 0){
				Database.upsert(progReqsToInsert, ProgramRequest__c.ExtId__c, false);	
            }

            //Return Request Id
            if(parentReqToInsert.Id != null){//If there are more than one element - return the parent
                return returnId(parentReqToInsert.Id);
            } else if(!reqsToInsert.isEmpty() && reqsToInsert[0].Id != null){
                return returnId(reqsToInsert[0].Id);
            }
        }
        catch(Exception e){
            //Return Error + Request Id
            System.debug('///' + e.getMessage());
            if(parentReqToInsert.Id != null){//If there are more than one element - return the parent
            	return returnErrorId(parentReqToInsert.Id, e.getMessage());
            } else if(!reqsToInsert.isEmpty() && reqsToInsert[0].Id != null){
                return returnErrorId(reqsToInsert[0].Id, e.getMessage());
            }
            return s500();
        }

        return s404();
    }
    
    private Request__c createParentRequest(Map<String, Object> jsonrequest, List<Object> newReqs){
        Object newReq = newReqs != null && newReqs.size() > 0 ? newReqs[0] : null;
        Map<String, Object> newReqMap = (Map<String, Object>)newReq;
        Request__c parentReq = new Request__c();
        parentReq.RecordTypeId = parentRequest_RT;
        parentReq.Request_Status__c = Label_Utils.requestStatus.get('סגור');
        parentReq.JSON__c = Json.serializePretty(jsonrequest);
        parentReq.Program__r = new Program__c(External_Program_Id__c = Label_Utils.programs.get('ojt'));
        parentReq.Request_Details__c = Label.TestUtils_RequestDetails;
        parentReq.ExtId__c = newReqMap.get('RequestNumber') != null ? String.valueOf(newReqMap.get('RequestNumber')).substringBefore('_') : null;
        parentReq.Website_Request__c = true;
        system.debug('///parentReq: ' + parentReq);
        return parentReq;
    }
    
    private Request__c createChildRequest(Map<String, Object> jsonrequest, Id parentId){
        Request__c req = new Request__c();
        req.JSON__c = Json.serializePretty(jsonrequest);
        req.Program__r = new Program__c(External_Program_Id__c = Label_Utils.programs.get('ojt'));
        req.Request_Status__c = Label_Utils.requestStatus.get('סגור');
        req.Request_Number__c = String.valueOf(jsonrequest.get('RequestNumber')).substringBefore('_');
        req.ExtId__c = (String)jsonrequest.get('RequestNumber');
        req.Employees_Requested_Num__c = Decimal.valueOf(String.valueOf(jsonrequest.get('NumofEmployyesInTraining')));
        req.Employees__c = Decimal.valueOf(String.valueOf(jsonrequest.get('NumofEmployyesInTraining')));
        req.Job__c = jsonrequest.get('ProfessionName') != null ? String.valueOf(jsonrequest.get('ProfessionName')).replaceAll('[0-9]', '') : '';
        req.RecordTypeId = childRequest_RT;
        req.Request__c = parentId;
        req.Closing_Reason__c = Label_Utils.reqsClosingReason.get('הועבר לטיפול בתוכנית');
        req.Website_Request__c = true;
        system.debug('///req: ' + req);
        return req;
    }
    
    private ProgramRequest__c createProgramRequest(Id reqId, Request__c req){
        ProgramRequest__c pr = new ProgramRequest__c();
        pr.RecordTypeId = ojtProgramRequest_RT;
        pr.Program__r = new Program__c(External_Program_Id__c = Label_Utils.programs.get('ojt'));
        pr.Status__c = Label_Utils.programRequestStatus.get('הועבר לטיפול המפעיל');
        pr.Request__c = reqId;
        pr.ExtId__c = req.ExtId__c;
        pr.Mail_Employer__c = false;
        pr.API__c = true;
        system.debug('///pr: ' + pr);
        return pr;
    }

}
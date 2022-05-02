/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@RestResource(urlMapping='/onlineForms/*')
global with sharing class WF_FG_OnlineForms {
    global WF_FG_OnlineForms() {}

    @HttpPost
    global static void mPost(){
        system.debug(RestContext.request.requestBody != null ? RestContext.request.requestBody.tostring() : null);
        try{
            System.debug(JSON.serializePretty(Json.deserializeUntyped(RestContext.request.requestBody.toString())));
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        RestClient service = getService(RestContext.request, RestContext.response);
        RestContext.response.addHeader('Content-Type', 'application/json');
        if (service == null) {
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new RestClient.RestResult(false, null)));
            return;
        }
        Object obj = service.post();
        Map<String, Object> obj2 = obj != null ? (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj)) : null;
        map<String, Object> res = obj2 != null && obj2.get('result') != null ? (map<String, Object>)obj2.get('result') : null;
        createApiLog(obj2, RestContext.request);
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res)); 
    }

    public static RestClient getService(RestRequest request, RestResponse response){
        String serviceName = RestClient.getServiceName(request.requestURI);
        String objectExtId = RestClient.getObjectExtId(request.requestURI);
        String relatedList = RestClient.getRelatedListName(request.requestURI);
        system.debug(serviceName);
        system.debug(objectExtId);
        if(serviceName == 'ojt'){
            return new WS_Service_OJT(request, response, objectExtId);
        }
        else if (serviceName == 'green'){
            return null;
        }
        else{
            return null;
        }
    }

    private static void createApiLog(Map<String, Object> obj2, RestRequest request){
        try{
            Map<String, Object> jsonrequest = request != null && request.requestBody != null ? (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString()) : null;
            String body = jsonrequest != null ? Json.serializePretty(jsonrequest) : 'not body';
            String mess = obj2 != null && obj2.get('message') != null ? String.valueOf(obj2.get('message')) : 'not get message';
            String code = obj2 != null && obj2.get('statusCode') != null ? String.valueOf(obj2.get('statusCode')) : 'not get statusCode';
            String res = obj2 != null && obj2.get('result') != null ? String.valueOf(obj2.get('result')) : 'not get result';
            createLog(body, request.requestURI, mess, code, res);
        } catch(Exception e){
            system.debug(e.getMessage());
        }
    }

    private static void createLog(String body, String url, String mess, String stat, String result){
        ApiLog__c log = new ApiLog__c();
        log.Body__c = body;
        log.Url__c = url;
        log.Message__c = mess;
        log.Status_code__c = stat;
        log.Result_Data__c = result;
        System.debug('///log: ' + log);
        Database.insert(log, false);
    }
}
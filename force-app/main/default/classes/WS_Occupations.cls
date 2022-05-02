/* Rest Controller for getting and proccecing a JSON Object for "Holland questionnaire" */

/*  API Version:V1 - For developing. Client is curretnly using "OccupationalRestPOC" (No version number) */


@RestResource(urlMapping='/V1/Occupations/*')
global with sharing class WS_Occupations {    
    @HttpPost
    global static ResponseWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ResponseWrapper resWrap = new ResponseWrapper();
        try {
            String contentType = req.headers.get('Content-Type').replaceAll( '\\s+', '').toLowerCase();
            if (!contentType.equals('application/json;charset=utf-8')) {
                resWrap = return405(resWrap, res);
                return resWrap;
            }
            /* --- Hers Logic for success input from Client ---*/
            Blob body = req.requestBody;
            String jsonString = body.toString(); 
            Holland holland = Holland.parse(jsonString);
            if (holland == null) {
                resWrap = return405(resWrap, res);
                return resWrap;
            }
            
            resWrap = return200(resWrap, res);
            System.debug('Success: ' + res.responseBody.toString());

            List<Holland> hollandList = new List<Holland>();
            hollandList.add(holland);
            HollandHelper.buildHolland(hollandList, jsonString);

            return resWrap;
            
        } catch (Exception e) {
            resWrap = return405(resWrap, res);
            System.debug('error: ' + e);
            return resWrap;    
        }
        
    }
    
    
    global class ResponseWrapper{
        public boolean isSuccess ;
        public string message;
        public integer code;
        public ResponseWrapper(){
            isSuccess= true;
        }
        
    }
    
    
    private static ResponseWrapper return405(ResponseWrapper resWrap, RestResponse res){
        resWrap.code = 405;
        resWrap.message = 'Invalid input';
        resWrap.isSuccess = false;
        res.responseBody = Blob.valueOf(resWrap.message); 
        res.statusCode = resWrap.code;
        return resWrap;
    } 
    private static ResponseWrapper return200(ResponseWrapper resWrap, RestResponse res){
        resWrap.code = 200;
        resWrap.message = 'Data has been received by the server';
        resWrap.isSuccess = true;
        res.responseBody = Blob.valueOf(resWrap.message); 
        res.statusCode = resWrap.code;
        return resWrap;
    } 
}
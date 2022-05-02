/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-09-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing abstract class RestClient {
    protected RestRequest request;
    protected RestResponse response;

    public RestClient (RestRequest request, RestResponse response) {
        this.request = request;
        this.response = response;
        for(String paramKey : request.params.keySet()){
        	String value = request.params.get(paramKey);
        	request.params.put(paramKey, value != null ? String.escapeSingleQuotes(value) : null);
        }
    }

    public abstract object get();
    public abstract object post();
    
    public class RestResult {
        public RestResult (Boolean suc, String msg, String code, Object data) {
            this.success = suc;
            this.message = msg;
            this.statusCode = code;
            this.result = data;
            //this.isLast = null;
        }

        public RestResult (Boolean suc, String msg, String code) {
            this.success = suc;
            this.message = msg;
            this.statusCode = code;
        }

        public RestResult (Boolean suc, String msg) {
            this.success = suc;
            this.message = msg;
        }

        public Boolean success;
        public String message;
        public String statusCode;
        public Object result;
        //public Boolean isLast;
    }
    
    public void s200(){
    	response.statusCode = 200;
    }
    
    public object s400(){
    	response.statusCode = 400;
    	return new RestResult(false, 'Bad Request');
    }
    
    public object s401(){
    	response.statusCode = 401;
    	return new RestResult(false, 'Unauthorized');
    }
    
    public object s403(){
    	response.statusCode = 403;
    	return new RestResult(false, 'Forbidden');
    }
    
    public object s404(){
    	response.statusCode = 404;
    	return new RestResult(false, 'Not Found', '404');
    }
    
    public object s405(){
    	response.statusCode = 405;
    	return new RestResult(false, 'Method Not Allowed');
    }
    
    public object s500(){
    	response.statusCode = 500;
    	return new RestResult(false, 'Internal Server Error', '500');
    }

    public object returnId(String id){
    	response.statusCode = 200;
    	// return new map<String, String>{'Id' => id};
    	return new RestResult(true, 'Success', '200', new map<String, String>{'Id' => id});

    }
    
    public object returnErrorId(String id, String mess){
    	response.statusCode = 500;
    	// return new map<String, String>{'Id' => id};
    	return new RestResult(false, mess, '500', new map<String, String>{'Id' => id});

    }
    
    public static String getServiceName(String uri){
        if(!String.isEmpty(uri)){
            String[] uriSplitted = uri.split('/');
            return uriSplitted.size() > 2 ? uriSplitted[2] : null;
        }
        else{
            return null;
        }
    }
    
    public static String getObjectExtId(String uri){
        if(!String.isEmpty(uri)){
            String[] uriSplitted = uri.split('/');
            return uriSplitted.size() > 3 ? uriSplitted[3] : null;
        }
        else{
            return null;
        }
    }

    public static String getRelatedListName(String uri){
        if (!String.isEmpty(uri)){
            String[] uriSplitted = uri.split('/');
            return uriSplitted.size() > 4 ? uriSplitted[4] : null;
        }
        else{
            return null;
        }
    }
}
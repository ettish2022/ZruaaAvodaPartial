@isTest
public class TEST_WS {

    static TestMethod void testLogin(){
		Test.startTest();
		
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		string uri = '/api/login';
		req.requestURI = uri;
		WS_Login.LoginCredentials loginReq = new WS_Login.LoginCredentials();
		loginReq.username = 'test@test.com';
		loginReq.password = 'test2345667';
		req.requestBody = Blob.valueOf(JSON.serialize(loginReq));
		req.httpMethod = 'POST';

		RestContext.request = req;
		RestContext.response = res;
		
        WS_Login.mPost();
        
        RestContext.request.headers.put('Host', 'test.gov.il');
        WS_Login.mPost();
        
        loginReq.password = null;
		RestContext.request.requestBody = Blob.valueOf(JSON.serialize(loginReq));
        WS_Login.mPost();
        
        RestContext.request.requestBody = Blob.valueOf('blabla');
        WS_Login.mPost();
        
        RestContext.request.requestBody = null;
        WS_Login.mPost();
        
        Test.stopTest();
	}
    
    static TestMethod void testonlineforms(){
		Test.startTest();
		
        insert new Program__c(External_Program_Id__c = 'ojt');
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		string uri = '/onlineForms/ojt';
		req.requestURI = uri;
        req.requestBody = Blob.valueOf('{}');
		req.httpMethod = 'POST';

		RestContext.request = req;
		RestContext.response = res;
		
        WF_FG_OnlineForms.mPost();
        
        RestContext.request.headers.put('Host', 'test.gov.il');
        WF_FG_OnlineForms.mPost();
        
        RestContext.request.requestBody = Blob.valueOf('{ \"professionsCnt\" : \"2\",  \"newValues\" : [ {      \"FormId\" : \"4212\",     \"NumofEmployyesInTraining\" : \"10\",    \"ProfessionName\" : \"66גינון ושזירת פרחים\",    \"ProfessionDomain\" : \"אילנאות\",    \"Municipality\" : \"0\",    \"EmploymentInBranch\" : \"False\",    \"NumOfEmployees\" : \"35\",    \"BusinessDomain\" : \"חינוך\",    \"BusinessID\" : \"510122765\",    \"EmployerName\" : \"כפר סילבר בית ספר תיכון\",    \"RequestNumber\" : \"4212_1\",    \"howToFillProffessions\" : \"מקצוע מאושר\",    \"Title\" : null  }]}');
                                                       
        WF_FG_OnlineForms.mPost();
        
        uri = '/onlineForms/error';
		req.requestURI = uri;
        WF_FG_OnlineForms.mPost();
        //RestClient.s200();
        //RestClient.s400();
        //RestClient.s401();
        //RestClient.s403();
        //RestClient.s404();
        //RestClient.s405();
        //RestClient.returnErrorId('123456', 'Error Message');
        Test.stopTest();
	}
    
    static TestMethod void testGlobalHttpRequest(){
        map<string, string> headers = new Map<String,String>{ 'Authorization' => 'newToken'};
        map<string, Object> newParams = new Map<String,Object>{ 'Authorization' => new CustomObj('Test')};
        String baseUrl = 'https://develop-ministryoflabor.cs81.force.com/api';
        Test.startTest();
        String res1 = GLOBAL_HttpRequests.getSessionFromSoapResponseString('TestRes');
        String res2 = GLOBAL_HttpRequests.getSessionFromSoapResponseString(String.valueOf(GLOBAL_HttpRequests.soapLogin('test@test.com', 'test2345667')));
        String res3 = GLOBAL_HttpRequests.getSessionFromSoapResponse(GLOBAL_HttpRequests.soapLogin('test@test.com', 'test2345667', 'https://develop-ministryoflabor.cs81.force.com/api'));
        Map<String,Object> res4 = GLOBAL_HttpRequests.returnMapFromResponse(GLOBAL_HttpRequests.soapLogin('test@test.com', 'test2345667', 'https://develop-ministryoflabor.cs81.force.com/api'));
        Map<String,Object> res5 = GLOBAL_HttpRequests.returnMapFromString(null);
        HttpResponse res6 = GLOBAL_HttpRequests.HttpReq('GET', baseUrl, null, headers);
        Map<String,String> res7 = GLOBAL_HttpRequests.getHeaders('Token', true);
        Map<String,String> res8 = GLOBAL_HttpRequests.getHeaders('Token', true, false);
        String res9 = GLOBAL_HttpRequests.getParamsForURL(newParams);
        Test.stopTest();
    }
    
    public class CustomObj {
        public String name;
        public customObj(String n) {
            name = n;
    	}
    }
}
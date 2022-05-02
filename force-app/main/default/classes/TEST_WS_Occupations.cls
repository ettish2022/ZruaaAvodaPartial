@isTest
public class TEST_WS_Occupations {
    
    @TestSetup
    static void makeData(){
        final Integer AMOUNT_OCCUPATIONS_TO_CREATE = 3;
        List<Occupation__c> occupationsList = TEST_Utils.createTestOccupation(AMOUNT_OCCUPATIONS_TO_CREATE);
        
    }
    
    @isTest
    static void testPostRequestFromClient() {
        System.debug('');
        System.debug('TEST METHOD: testPostRequestFromClient');


        /* ORIGINAL SAMPLE FROM TECH SPECK */
		// String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":2,"title":"מנהל אזור","fit":"Great"},{"code_occupation":16,"title":"מנהל פרסום","fit":"Great"}]}';

        /* JSON Client input test case*/
		String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":0,"title":"מנהל אזור","fit":"Great"},{"code_occupation":1,"title":"מנהל פרסום","fit":"Great"}]}';

        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        

        Test.startTest();
        WS_Occupations.doPost();
        Test.stopTest();

        List<Occupation__c> occupationsList = [SELECT OccupationMatrixId__c, Id, Name FROM Occupation__c];
        System.debug('Occupations:');
        for (Occupation__c occ : occupationsList) {
            System.debug('# ' + occ);
        }
        
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        System.debug('Holland Que:');
        for (Holland_questionnaire__c hollandQue : hollandQueList) {
            System.debug('# ' + hollandQue);
        }

        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        System.debug('Occupations Reccomendation:');
        for (Occupation_recommendation__c occupationsRec : occupationsRecList) {
            System.debug('# ' + occupationsRec);
        }
      
        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];
        System.debug('HollandLog:');
        for (HollandLog__c hollandLog : hollandLogList) {
            System.debug('# ' + hollandLog);
        }
        
        System.assert(hollandLogList.size() == 0, 'Expecting to got 0 holland Error Log');
        System.assert(hollandQueList.size() == 1 , '1 record of Holland_questionnaire__c SHOULD have been created');
        System.assert(occupationsRecList.size() == 2, '2 records of Occupation_recommendation__c SHOULD have been created');
        
    }

    @isTest
    static void testPostRequestFromClientMissingFields() {
        System.debug('');
        System.debug('TEST METHOD: testPostRequestFromClientMissingFields');

        String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4, "profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":2,"title":"מנהל אזור","fit":"Great"},{"code_occupation":16,"title":"מנהל פרסום","fit":"Great"}]}';

        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        

        Test.startTest();
        WS_Occupations.ResponseWrapper resWrap = WS_Occupations.doPost();
        Test.stopTest();

        List<Occupation__c> occupationsList = [SELECT OccupationMatrixId__c, Id, Name FROM Occupation__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];

        
        System.assert(hollandLogList.size() == 0, 'Expecting to got 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');
        System.assert(resWrap.code == 405);
        
        
    }

    @isTest
    static void testPostRequestFromClientWronFieldName() {
        System.debug('');
        System.debug('TEST METHOD: testPostRequestFromClientWronFieldName');


		String input_jsonString = '{"identification_number":"","WRONG_FIELD_NAME":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":0,"title":"מנהל אזור","fit":"Great"},{"code_occupation":1,"title":"מנהל פרסום","fit":"Great"}]}';


        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        

        Test.startTest();
        WS_Occupations.ResponseWrapper resWrap = WS_Occupations.doPost();
        Test.stopTest();

        List<Occupation__c> occupationsList = [SELECT OccupationMatrixId__c, Id, Name FROM Occupation__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];

        
        System.assert(hollandLogList.size() == 0, 'Expecting to got 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');
        System.assert(resWrap.code == 405);
        
        
    }

    @isTest
    static void testConvertJsonToObject_VerifyScheme(){
        System.debug('');
        System.debug('TEST METHOD: testConvertJsonToObject_VerifyScheme');

		String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":2,"title":"מנהל אזור","fit":"Great"},{"code_occupation":16,"title":"מנהל פרסום","fit":"Great"}]}';
       
		Holland obj = Holland.parse(input_jsonString);
        System.assert(obj != null);
	}

    @isTest
    static void testNoMatchinCodeForOccupationCode(){
        System.debug('');
        System.debug('TEST METHOD: testNoMatchinCodeForOccupationCode');

        String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":999,"title":"מנהל אזור","fit":"Great"},{"code_occupation":1,"title":"מנהל פרסום","fit":"Great"}]}';
        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        
        Test.startTest();
        WS_Occupations.doPost();
        Test.stopTest();

        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];

        System.assert(hollandLogList.size() == 1, 'Expecting to got 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');

    }

    @isTest
    static void testCorrectLenghOfAnswersCodes(){
        System.debug('');
        System.debug('TEST METHOD: testCorrectLenghOfAnswersCodes');

        /* JSON Client input test case*/
        String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"31155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":999,"title":"מנהל אזור","fit":"Great"},{"code_occupation":1,"title":"מנהל פרסום","fit":"Great"}]}';

        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        
        Test.startTest();
        WS_Occupations.doPost();
        Test.stopTest();

        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        System.assert(hollandLogList.size() == 1, 'Expecting to got 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');

    }

    @isTest
    static void testCorrectAmountOfAreaFields(){
        System.debug('');
        System.debug('TEST METHOD: testCorrectAmountOfAreaFields');

        /* JSON Client input test case*/
        String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"SOME WRONG VALUE","score":13},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":0,"title":"מנהל אזור","fit":"Great"},{"code_occupation":1,"title":"מנהל פרסום","fit":"Great"}]}';

        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        
        Test.startTest();
        WS_Occupations.doPost();
        Test.stopTest();

        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        System.assert(hollandLogList.size() == 1, 'Expecting to get 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');

    }
    
    @isTest
    static void testAmountOfOccupationsReccomendation() {
        System.debug('');
        System.debug('TEST METHOD: testAmountOfOccupationsReccomendation');


        /* ORIGINAL SAMPLE FROM TECH SPECK */
		// String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":2,"title":"מנהל אזור","fit":"Great"},{"code_occupation":16,"title":"מנהל פרסום","fit":"Great"}]}';

        /* JSON Client input test case*/
		String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":27},{"area":"Investigative ","score":13},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[]}';

        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        

        Test.startTest();
        WS_Occupations.doPost();
        Test.stopTest();

        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        
        System.assert(hollandLogList.size() == 1, 'Expecting to get 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');
        
    }

    @isTest
    static void testValidateAllAreasContainsScore(){
        System.debug('');
        System.debug('TEST METHOD: testValidateAllAreasContainsScore');

        /* JSON Client input test case*/
        String input_jsonString = '{"identification_number":"","gender":1,"age":2,"education":4,"answers":"553421321134342523523523254115342111351145453111231155343444","profile_score":[{"area":"realistic","score":13},{"area":"Investigative ","score":null},{"area":"Artistic","score":23},{"area":"Social","score":25},{"area":"Enterprising","score":14},{"area":"Conventional","score":14}],"occupations":[{"code_occupation":0,"title":"מנהל אזור","fit":"Great"},{"code_occupation":1,"title":"מנהל פרסום","fit":"Great"}]}';

        RestRequest req =  RestContext.request = new System.RestRequest();
        RestResponse res = RestContext.response = new System.RestResponse();
        Map<String, String> headers = RestContext.request.headers;
        
        headers.put('Content-Type', 'application/json;charset=utf-8');
        string uri = '/V1/Occupations/*';
        RestContext.request.requestURI = uri;
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(input_jsonString);
        
        Test.startTest();
        WS_Occupations.doPost();
        Test.stopTest();

        List<HollandLog__c> hollandLogList = [SELECT JSON__c, ErrorMessage__c FROM HollandLog__c];
        List<Holland_questionnaire__c> hollandQueList = [SELECT A1__c, ArtisticProfileScore__c FROM Holland_questionnaire__c];
        List<Occupation_recommendation__c> occupationsRecList = [SELECT ProfessionalFitDescription__c, Id ,ProfessionId__c, Holland_questionnaire__c FROM Occupation_recommendation__c];
        System.assert(hollandLogList.size() == 1, 'Expecting to get 1 holland Error Log');
        System.assert(hollandQueList.size() == 0 , 'Holland_questionnaire__c should not be created');
        System.assert(occupationsRecList.size() == 0, 'Occupation_recommendation__c should not be created');

    }

}
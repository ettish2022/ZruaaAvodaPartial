@isTest
global class ProgramHttpResMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse httpR = new HttpResponse();
        httpR.setStatusCode(200);
        
        BATCH_SyncProgramsFromMagar.OdataResult odataResult = new BATCH_SyncProgramsFromMagar.OdataResult();
        List<BATCH_SyncProgramsFromMagar.ProgramCase> pcs = new List<BATCH_SyncProgramsFromMagar.ProgramCase>();
        BATCH_SyncProgramsFromMagar.ProgramCase pc = new BATCH_SyncProgramsFromMagar.ProgramCase();
        pc.requestId =  '1234_2';
        pc.formId =  '1234';
        pcs.add(pc);
        odataResult.value = pcs;
        String body = json.serialize(odataResult);
        //httpR.setBodyAsBlob(Blob.valueOf(body));
        httpR.setBody(body);
        return httpR;
    }
}
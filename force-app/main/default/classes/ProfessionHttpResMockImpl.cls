@isTest
global class ProfessionHttpResMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse httpR = new HttpResponse();
        httpR.setStatusCode(200);
        
        BATCH_SyncProfessionsFromMagar.OdataResult odataResult = new BATCH_SyncProfessionsFromMagar.OdataResult();
        List<BATCH_SyncProfessionsFromMagar.Profession> pcs = new List<BATCH_SyncProfessionsFromMagar.Profession>();
        BATCH_SyncProfessionsFromMagar.Profession pc = new BATCH_SyncProfessionsFromMagar.Profession();
        pc.professionId =  15454;
        pcs.add(pc);
        odataResult.value = pcs;
        String body = json.serialize(odataResult);
        //httpR.setBodyAsBlob(Blob.valueOf(body));
        httpR.setBody(body);
        return httpR;
    }
}
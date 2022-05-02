@isTest
global class StreetHttpResMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse httpR = new HttpResponse();
        httpR.setStatusCode(200);
        String body = '{"help": "https://data.gov.il/api/3/action/help_show?name=datastore_search", "success": true, "result": {"include_total": false, "resource_id": "351d4347-8ee0-4906-8e5b-9533aef13595", "records_format": "objects", "records": [{"_id":3,"טבלה":"טבלת רחובות ","סמל_ישוב":472,"שם_ישוב":"אבו גוש","סמל_רחוב":159,"שם_רחוב":"אל רשיד"}], "_links": {"start": "/api/3/action/datastore_search?resource_id=351d4347-8ee0-4906-8e5b-9533aef13595", "next": "/api/3/action/datastore_search?offset=100&resource_id=351d4347-8ee0-4906-8e5b-9533aef13595"}}}';
        //httpR.setBodyAsBlob(Blob.valueOf(body));
        httpR.setBody(body);
        return httpR;
    }
}
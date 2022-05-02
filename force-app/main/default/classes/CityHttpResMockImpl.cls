@isTest
global class CityHttpResMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse httpR = new HttpResponse();
        httpR.setStatusCode(200);
        String body = '{"help": "https://data.gov.il/api/3/action/help_show?name=datastore_search", "success": true, "result": {"include_total": false, "resource_id": "351d4347-8ee0-4906-8e5b-9533aef13595", "records_format": "objects", "records": [{"_id":1,"שם יישוב":"אבו גווייעד (שבט)","סמל יישוב":967,"תעתיק":"ABU JUWEIID","מחוז":6,"נפה":62,"אזור טבעי":623,"מעמד מונציפאלי":null,"שיוך מטרופוליני":null,"דת יישוב":3,"סך הכל אוכלוסייה 2019":null,"יהודים ואחרים":null,"מזה: יהודים":null,"ערבים":null,"שנת ייסוד":"","צורת יישוב שוטפת":460,"השתייכות ארגונית":null,"קואורדינטות":2040057100,"גובה ממוצע":null,"ועדת תכנון":699,"מרחב משטרה":15003711,"שנה":2019,"שם יישוב באנגלית":"Abu Juwaad","אשכול רשויות מקומיות":null}], "_links": {"start": "/api/3/action/datastore_search?resource_id=351d4347-8ee0-4906-8e5b-9533aef13595", "next": "/api/3/action/datastore_search?offset=100&resource_id=351d4347-8ee0-4906-8e5b-9533aef13595"}}}';
        //httpR.setBodyAsBlob(Blob.valueOf(body));
        httpR.setBody(body);
        return httpR;
    }
}
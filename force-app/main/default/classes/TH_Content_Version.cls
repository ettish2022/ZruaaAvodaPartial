public with sharing class TH_Content_Version {
    
    public static void addContentDocumentLink(List<ContentVersion> lst){
        map<String, ContentVersion> relatedobject2contentversion = new map<string, ContentVersion>();
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for(ContentVersion cv : lst){
            if(String.isNotBlank(cv.RelatedObjectId__c)){
                relatedobject2contentversion.put(cv.RelatedObjectId__c, cv);
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = cv.RelatedObjectId__c;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.Visibility = 'InternalUsers';
                cdl.ShareType = 'V';
                cdls.add(cdl);
            }
        }

        if(!cdls.isEmpty()){
            Database.insert(cdls, false);
        }
    }
}
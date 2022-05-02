/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-15-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-12-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class updateBuisnessField{
        
    
    public static void updateAccBuisnessField(){
        Set<Id> requestDocumentIds = new Set<Id>();
        Map<Id, Request__c> conLinkReqsMap = new Map<Id, Request__c>();
        Map<Id, Request__c> reqsIdMap = new Map<Id, Request__c>();
        List<String> extIds = new List<String>{'4081', '4208_1', '4081_1', '4081_2', '4081_3','4117_1', '4147_1', '4165_1', '4212', '4212_1', '4212_2', '4212_3', '7387_1', '7112_1'};
        List<Request__c> reqs = new List<Request__c>();
        reqs = [SELECT Id, ExtId__c, Account__c, Account__r.Business_Fields__c FROM Request__c 
                WHERE createdDate >= LAST_N_DAYS:13 AND Account__c = null AND createdById = '0054K0000046nOdQAI' 
                AND ExtId__c not in: extIds order by ExtId__c asc limit 10];
        if(Test.isRunningTest()){
            reqs = [SELECT Id, ExtId__c, Account__c, Account__r.Business_Fields__c FROM Request__c 
                    	WHERE createdDate >= LAST_N_DAYS:13 order by ExtId__c asc limit 10];
        }
        Set<Id> reqsId = new Set<Id>();
        for(Request__c rq : reqs){
            reqsId.add(rq.Id);
            reqsIdMap.put(rq.Id, rq);
        }
        System.debug('///reqsId: ' + reqsId);
        if(reqsId.size() > 0){
            List<ContentDocumentLink> conDocLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: reqsId];
            System.debug('///conDocLinks: ' + conDocLinks);
    
            for(ContentDocumentLink cdl : conDocLinks){
                Id objectId = cdl.LinkedEntityId;
                //Get only Document related to Request object
                if(objectId != null && objectId.getSObjectType().getDescribe().getName() == 'Request__c'){
                    requestDocumentIds.add(cdl.ContentDocumentId);
                    conLinkReqsMap.put(cdl.ContentDocumentId, reqsIdMap.get(cdl.LinkedEntityId));
                }
            }
            System.debug('///requestDocumentIds: ' + requestDocumentIds);
            If(requestDocumentIds.size() > 0){
                parseDocumentToJson(getXMLDocuments(requestDocumentIds), conLinkReqsMap);
            }
        }
    }

    private static List<ContentVersion> getXMLDocuments(Set<Id> requestDocumentIds){
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, FileType, VersionData
                                        FROM ContentVersion
                                        WHERE ContentDocumentId in: requestDocumentIds AND FileType = 'XML' AND isLatest = true limit 10];
        return cvList;
    }

    public static void parseDocumentToJson(List<ContentVersion> cvList, Map<Id, Request__c> conLinkReqsMap){
        System.debug('///cvList: ' + cvList);
        Set<String> streetAdd = new Set<String>();
        List<Account> accList = new List<Account>();
        for(ContentVersion cv : cvList){
            try{
                System.debug('///cv: ' + cv);
                String xml = cv.VersionData.toString();
                System.debug('///xml: ' + xml);
                xml = xml.replaceAll('\\r', ' ');
                xml = xml.replaceAll('\\n', ' ');
                String jsonContent = XmlParser.xmlToJson(xml);
                System.debug('///jsonContent1: ' + jsonContent);
                jsonContent = jsonContent.replaceAll('"type"', '"customType"');
                jsonContent = jsonContent.replaceAll('"id"', '"customId"');
                if(jsonContent.contains('"newProfessionRequest": ['))
                    jsonContent = jsonContent.replaceAll('"newProfessionRequest"', '"newProfessionRequestCustomList"');
                if(jsonContent.contains('"trainingDetails": ['))
                    jsonContent = jsonContent.replaceAll('"trainingDetails"', '"trainingDetailsCustomList"');
                System.debug('///jsonContent2: ' + jsonContent);
                ContentDocumentLinkHandler.Root xmlDocumentDeserializable = (ContentDocumentLinkHandler.Root)json.deserialize(jsonContent, ContentDocumentLinkHandler.Root.class);
                System.debug('///xmlDocumentDeserializable: ' + xmlDocumentDeserializable);
                updateBuisnessFields(xmlDocumentDeserializable.root, cv.ContentDocumentId, conLinkReqsMap, accList);
            } catch(Exception e){
                System.debug('///Exception: ' + e);
            }
        }
		System.debug('///accList Final: ' + accList);
        update accList;
    }

    private static void updateBuisnessFields(ContentDocumentLinkHandler.xmlDocument docData, Id cvId, Map<Id, Request__c> conLinkReqsMap, List<Account> accList){
        if(docData != null && docData.EmployerDetails != null){
            Request__c rq = conLinkReqsMap.get(cvId);
            System.debug('///rq: ' + rq);
            String bf = docData.EmployerDetails.areaOfActivity != null && docData.EmployerDetails.areaOfActivity.dataText != null ? docData.EmployerDetails.areaOfActivity.dataText != 'אחר (ציינו איזה)' ? docData.EmployerDetails.areaOfActivity.dataText : 'אחר' : null;
            if(bf != null && rq != null){
                if(!accList.contains(new Account(Id = rq.Account__c, Business_Fields__c = bf)))
                	accList.add(new Account(Id = rq.Account__c, Business_Fields__c = bf));
            }
            System.debug('///accList: ' + accList);
        }
    }
}
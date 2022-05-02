/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-28-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-12-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class ContentDocumentLinkHandler extends TriggerHandler{
    
    final static Id parentRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Parent_Request').getRecordTypeId();
    final static Id childRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();
    final static Id employAcc_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
    static Map<String, Account> accsFromOrg;
    static Map<String, Contact> consFromOrg;
    static Map<String, List<Request__c>> jsonTodayReq;
    static Map<String, List<Request__c>> hpPhoneRequestSiblingMap;
    static List<Request__c> parentReqIdsToDelete;

    public override void afterInsert(){
        checkRequestDocument(Trigger.new);
    }

    //------------After Insert--------------
    private void checkRequestDocument(List<ContentDocumentLink> newContentDocumentLink){
        Set<Id> requestDocumentIds = new Set<Id>();
        for(ContentDocumentLink cdl : newContentDocumentLink){
            Id objectId = cdl.LinkedEntityId;
            //Get only Document related to Request object
            System.debug('///objectId.getSObjectType().getDescribe().getName(): ' + objectId.getSObjectType().getDescribe().getName());
            if(objectId != null && objectId.getSObjectType().getDescribe().getName() == 'Request__c'){
                requestDocumentIds.add(cdl.ContentDocumentId);
            }
        }
        System.debug('///requestDocumentIds: ' + requestDocumentIds);
        If(requestDocumentIds.size() > 0){
            Set<Id> requestDocumentXMLIds = getXMLDocumentIds(requestDocumentIds);
            if(requestDocumentXMLIds.size() > 0){
                parseDocumentToJson(requestDocumentXMLIds);
            }
        }
    }

    private Set<Id> getXMLDocumentIds(Set<Id> requestDocumentIds){
        Set<Id> requestDocumentXMLIds = new Set<Id>();
        for(ContentVersion cv :  [SELECT Id, ContentDocumentId
                                        FROM ContentVersion
                                        WHERE ContentDocumentId in: requestDocumentIds AND FileType = 'XML' AND isLatest = true]){
            requestDocumentXMLIds.add(cv.ContentDocumentId);
        }
        return requestDocumentXMLIds;
    }

    @future
    public static void parseDocumentToJson(Set<Id> requestDocumentXMLIds){
        List<ContentVersion> cvList = getXMLDocuments(requestDocumentXMLIds);
        System.debug('///cvList: ' + cvList);
        List<xmlDocument> xmlDocumentList = new List<xmlDocument>();
        Set<String> streetAdd = new Set<String>();
        for(ContentVersion cv : cvList){
            try{
                System.debug('///cv: ' + cv);
                String xml = cv.VersionData.toString();
                System.debug('///xml: ' + xml);
                //xml = xml.replaceAll('<Files>[\\s\\S]*?</Files>','');
                xml = xml.replaceAll('<state>[\\s\\S]*?</state>','');
                xml = xml.replaceAll('<name>[\\s\\S]*?</name>','');
                xml = xml.replaceAll('<isClosed>[\\s\\S]*?</isClosed>','');
                //System.debug('///xml: ' + xml);
                xml = xml.replaceAll('\\r', ' ');
                xml = xml.replaceAll('\\n', ' ');
                Dom.Document doc = new Dom.Document();
        		doc.load(xml);
                String jsonContent = XMLToJson.parseDocumentToJson(doc);
                
                System.debug('///jsonContent1: ' + jsonContent);
                jsonContent = jsonContent.replaceAll('"type"', '"customType"');
                jsonContent = jsonContent.replaceAll('"id"', '"customId"');
                if(jsonContent.contains('"otherProfNameList":[')){
                    jsonContent = jsonContent.replaceAll('"otherProfNameList"', '"otherProfNameListCustom"');
                }
                if(jsonContent.contains('"approvedProfessionsList":[')){
                    jsonContent = jsonContent.replaceAll('"approvedProfessionsList"', '"approvedProfessionsListCustom"');
                }
                System.debug('///jsonContent2: ' + jsonContent);
                xmlDocument xmlDocumentDeserializable = (xmlDocument)json.deserialize(jsonContent, xmlDocument.class);
                System.debug('///xmlDocumentDeserializable: ' + xmlDocumentDeserializable);
                xmlDocumentList.add(xmlDocumentDeserializable);
            } catch(Exception e){
                System.debug('///Exception: ' + e);
            }
        }
        System.debug('///xmlDocumentList: ' + xmlDocumentList);
        getRelatedDataFromOrg(xmlDocumentList, streetAdd);
        createObjectsFromXML(xmlDocumentList, streetAdd);
    }

    private static List<ContentVersion> getXMLDocuments(Set<Id> requestDocumentXMLIds){
        List<ContentVersion> cvList = [SELECT Id, FileType, VersionData
                                        FROM ContentVersion
                                        WHERE ContentDocumentId in: requestDocumentXMLIds AND FileType = 'XML' AND isLatest = true];
        return cvList;
    }
    
    //Get related data from org for tests
    private static void getRelatedDataFromOrg(List<xmlDocument> xmlDocumentList, Set<String> streetAdd){
        Set<String> accBuisnessIds = new Set<String>();
        Set<String> contactPhone = new Set<String>();
        Set<String> contactMail = new Set<String>();

        for(xmlDocument docData : xmlDocumentList){
            if(docData != null && docData.EmployerDetails != null){
                String hp = docData.EmployerDetails.contractorHp != null ? docData.EmployerDetails.contractorHp.leftPad(9, '0') : docData.EmployerDetails.contractorId.leftPad(9, '0');
                accBuisnessIds.add(hp);
                String ph = docData.EmployerDetails.contactPhone.replace('-','');
                system.debug('ph' + ph);
                contactPhone.add(ph);
                contactMail.add(docData.EmployerDetails.contactEmail);
                String str = docData.EmployerDetails.streetSelect != null && docData.EmployerDetails.companyCity != null && docData.EmployerDetails.streetSelect.dataCode != null && docData.EmployerDetails.companyCity.dataCode != null ? docData.EmployerDetails.companyCity.dataCode + '_' + docData.EmployerDetails.streetSelect.dataCode : null;//need to be unique
                streetAdd.add(str);
            }
        }
        System.debug('///accBuisnessIds: ' + accBuisnessIds);
        System.debug('///contactPhone: ' + contactPhone);
        System.debug('///contactMail: ' + contactMail);
        getAccsFromOrg(accBuisnessIds);
        getConsFromOrg(contactPhone, contactMail);
        getRequestFromOrg(accBuisnessIds, contactPhone);
        System.debug('///accsFromOrg: ' + accsFromOrg);
        System.debug('///consFromOrg: ' + consFromOrg);
        System.debug('///jsonTodayReq: ' + jsonTodayReq);
        System.debug('///hpPhoneRequestSiblingMap: ' + hpPhoneRequestSiblingMap);
    }

    private static void getAccsFromOrg(Set<String> accBuisnessIds){
        accsFromOrg = new Map<String, Account>();
        for(Account acc : [SELECT Id, Business_Id__c FROM Account WHERE Business_Id__c in: accBuisnessIds]){
            accsFromOrg.put(acc.Business_Id__c, acc);
        }
    }

    private static void getConsFromOrg(Set<String> contactPhone, Set<String> contactMail){
        consFromOrg = new Map<String, Contact>();
        for(Contact con : [SELECT Id, Phone, MobilePhone, Email FROM Contact WHERE MobilePhone in: contactPhone OR Email in: contactMail OR Phone in: contactPhone]){
            if(con.MobilePhone != null){
            	consFromOrg.put(con.MobilePhone.replace('-',''), con);
            }
            if(con.Phone != null){
            	consFromOrg.put(con.Phone.replace('-',''), con);
            }
            if(con.Email != null)
            	consFromOrg.put(con.Email, con);
        }
    }

    private static void getRequestFromOrg(Set<String> accBuisnessIds, Set<String> contactPhone){
        jsonTodayReq = new Map<String, List<Request__c>>();
        hpPhoneRequestSiblingMap = new Map<String, List<Request__c>>();
        String pro = Label_Utils.programs.get('ojt');
        String reqClose = Label_Utils.requestStatus.get('סגור');
        String proReqState1 = Label_Utils.programRequestStatusF.get('הועבר למילוי טפסים');
        String proReqState2 = Label_Utils.programRequestStatusF.get('המלצת רכז');

        for(Request__c req : [SELECT Id, OwnerId, Account__c, Area__c, Business_Name__c, Primary_Contact__c, Program__c, Request_Details__c, Request__c, Request_Number__c, Request__r.OwnerId, Request__r.Request_Status__c, Request__r.Primary_Contact__c, Request__r.Account__c, Job__c,
                                (SELECT Id, Opened_Following_Recomme__c FROM ProgramRequests__r)
                                FROM Request__c 
                                WHERE  RecordTypeId =: childRequest_RT AND createdDate = TODAY
                                AND Program__r.External_Program_Id__c =: pro AND Request_Status__c =: reqClose]){
            if(!jsonTodayReq.containsKey(req.Request_Number__c))
                jsonTodayReq.put(req.Request_Number__c, new List<Request__c>());
            jsonTodayReq.get(req.Request_Number__c).add(req);
        }
      
        for(Request__c req : [SELECT Id, Account__r.Business_Id__c, Primary_Contact__r.Phone, Primary_Contact__r.MobilePhone, Request__c, Request__r.OwnerId, Request__r.Request_Status__c, OwnerId, Account__c, Area__c, Business_Name__c, Primary_Contact__c, Program__c, Request_Details__c, Job__c,
                                (SELECT Id FROM ProgramRequests__r WHERE (Request_Status_f__c =: proReqState1 OR Request_Status_f__c =: proReqState2 ) AND Program__r.External_Program_Id__c =: pro AND createdDate >= LAST_N_DAYS:14)
                                FROM Request__c 
                                WHERE RecordTypeId =: childRequest_RT AND createdDate >= LAST_N_DAYS:14
                                AND Account__r.Business_Id__c in: accBuisnessIds AND Primary_Contact__r.MobilePhone in: contactPhone Order By createdDate asc]){
            String key = '' + req.Account__r.Business_Id__c + req.Primary_Contact__r.MobilePhone;
            if(req.ProgramRequests__r != null && req.ProgramRequests__r.size() > 0){ //If the req have PR related
                if(!hpPhoneRequestSiblingMap.containsKey(key))
                    hpPhoneRequestSiblingMap.put(key, new List<Request__c>());
                hpPhoneRequestSiblingMap.get(key).add(req);
            }
        }
    }

    private static void createObjectsFromXML(List<xmlDocument> xmlDocumentList, Set<String> streetAdd){
        parentReqIdsToDelete = new List<Request__c>();
        List<Account> accs = new List<Account>();
        List<Contact> cons = new List<Contact>();
        List<ProgramRequest__c> proReqToUpdate = new List<ProgramRequest__c>();
        Map<Id, Request__c> reqs = new Map<Id, Request__c>();
        Map<Request__c, Account> newReqsAccMap = new Map<Request__c, Account>();
        Map<Request__c, Contact> newReqsConMap = new Map<Request__c, Contact>();
        for(xmlDocument docData : xmlDocumentList){
            if(docData != null && docData.EmployerDetails != null){
                String hp = docData.EmployerDetails.contractorHp != null ? docData.EmployerDetails.contractorHp.leftPad(9, '0') : docData.EmployerDetails.contractorId.leftPad(9, '0');
                System.debug('///hp: ' + hp);
                System.debug('///docData: ' + docData);
                System.debug('///!!docData.trainingDetails: ' + docData.trainingDetails);
                System.debug('///!!docData.newProfessionRequest: ' + docData.newProfessionRequest);
                if(docData.newProfessionRequest != null)
                    System.debug('///!!docData.newProfessionRequest.otherProfNameListCustom: ' + docData.newProfessionRequest.otherProfNameListCustom);
                // System.debug('///!!docData.trainingDetailsCustomList: ' + docData.trainingDetailsCustomList);
                Account acc = checkAccountCreation(docData, accs, hp, streetAdd);
                Contact con = checkContactCreation(docData, cons, hp);
                System.debug('///acc: ' + acc);
                System.debug('///con: ' + con);
                checkRequestParentCreation(docData, reqs, hp, acc, con, newReqsAccMap, newReqsConMap, proReqToUpdate);
                System.debug('///newReqsAccMap: ' + newReqsAccMap);
            }
        }

        System.debug('///accs: ' + accs);
        System.debug('///cons: ' + cons);
        System.debug('///reqs: ' + reqs);
        System.debug('///parentReqIdsToDelete: ' + parentReqIdsToDelete);
        System.debug('///newReqsAccMap: ' + newReqsAccMap);
        System.debug('///newReqsConMap: ' + newReqsConMap);

        //Upsert Data
        Database.upsert(accs, Account.Business_Id__c, false);
        Database.upsert(cons, false);
        Database.delete(parentReqIdsToDelete, false);
        Database.upsert(reqs.values(), false);
        updateProReqFields(proReqToUpdate);        

        System.debug('///accs: ' + accs);
        System.debug('///cons: ' + cons);
        System.debug('///reqs: ' + reqs);
        System.debug('///parentReqIdsToDelete: ' + parentReqIdsToDelete);
        System.debug('///newReqsAccMap: ' + newReqsAccMap);
        System.debug('///newReqsConMap: ' + newReqsConMap);
        //Update the lookup of contact and account with the new values from XML
        updateRequest(newReqsAccMap, newReqsConMap); 
    }

    private static Account checkAccountCreation(xmlDocument docData, List<Account> accs, String hp, Set<String> streetAdd){
        Set<String> streetCodes = getStreetsCodeFromOrg(streetAdd);
        Set<String> citiyCodes = getCitiesCodeFromOrg();
        if(!accsFromOrg.keySet().contains(hp)){
            Account acc = new Account();
            acc.Id = null;
            acc.RecordTypeId = employAcc_RT;
            acc.Business_Id__c = hp;
            acc.Name = docData.EmployerDetails.companyName;
            acc.Deduction_file_ID__c = docData.EmployerDetails.nikuim;
            acc.NumberOfEmployees = docData.EmployerDetails.numberOfEmployees != null ? Integer.valueOf(docData.EmployerDetails.numberOfEmployees) : 0;
            acc.Account_City__r = docData.EmployerDetails.companyCity != null  && docData.EmployerDetails.companyCity.dataCode != null && citiyCodes != null && citiyCodes.size() > 0  && citiyCodes.contains(docData.EmployerDetails.companyCity.dataCode) ? new City__c(Code__c = docData.EmployerDetails.companyCity.dataCode) : null;
            acc.Address_Home_Num__c = docData.EmployerDetails.houseNum;
            acc.Account_Address__c = docData.EmployerDetails.addressNotFoundRadio != null && docData.EmployerDetails.addressNotFoundRadio.dataCode == '1' ? docData.EmployerDetails.otherEmployerAddressDetails : '';//??
            acc.Phone = docData.EmployerDetails.companyPhone;
            acc.Partner__c = false;
            acc.Employer__c = true;
            acc.Affiliation_To_Application__c = Label_Utils.accAffilationToApp.get('זירת מעסיקים'); 
            //acc.Service_provider__c = Label_Utils.accServiceProvider.get('מפעיל');
            acc.Account_Street__r = docData.EmployerDetails.streetSelect != null && docData.EmployerDetails.companyCity != null  && docData.EmployerDetails.streetSelect.dataCode != null && docData.EmployerDetails.companyCity.dataCode != null  && streetCodes != null && streetCodes.size() > 0 && citiyCodes != null && citiyCodes.size() > 0  && streetCodes.contains(docData.EmployerDetails.companyCity.dataCode + '_' + docData.EmployerDetails.streetSelect.dataCode) && citiyCodes.contains(docData.EmployerDetails.companyCity.dataCode)? new Street__c(Code__c = docData.EmployerDetails.companyCity.dataCode + '_' + docData.EmployerDetails.streetSelect.dataCode) : null;//need to be unique
            acc.Business_Fields__c = docData.EmployerDetails.areaOfActivity != null && docData.EmployerDetails.areaOfActivity.dataText != null && docData.EmployerDetails.areaOfActivity.dataText != 'אחר (ציינו איזה)' ? docData.EmployerDetails.areaOfActivity.dataText : null;
            
            //acc.PersonEmail = docData.EmployerDetails.companyEmail;//Not have email field apropriate
    
            accs.add(acc);
            return acc;
        }
        return accsFromOrg.get(hp);
    }
    
    private static Contact checkContactCreation(xmlDocument docData, List<Contact> cons, String hp){
        String ph = docData.EmployerDetails.contactPhone.replace('-','');
        String email = docData.EmployerDetails.contactEmail;
        if(!consFromOrg.keySet().contains(ph) && !consFromOrg.keySet().contains(email)){
            Contact con = new Contact();
            con.Id = null;
            con.FirstName = docData.EmployerDetails.contactFirstName;
            con.LastName = docData.EmployerDetails.contactLastName;
            con.Job__c = docData.EmployerDetails.contactJob;
            con.MobilePhone = ph;
            // con.Phone = ph;
            con.Email = docData.EmployerDetails.contactEmail;
    
            cons.add(con);
            return con;
        }
        Contact con = consFromOrg.get(ph) != null ? consFromOrg.get(ph) : consFromOrg.get(email);
        return con;
    }
    
    private static void checkRequestParentCreation(xmlDocument docData, Map<Id, Request__c> reqs, String hp, Account acc, Contact con, Map<Request__c, Account> newReqsAccMap, Map<Request__c, Contact> newReqsConMap, List<ProgramRequest__c> proReqToUpdate){
        String ph = docData.EmployerDetails.contactPhone.replace('-','');
        String key = hp + ph;
        List<Request__c> newReqs = jsonTodayReq.get(docData.MetaData.referenceNumber);
        List<Request__c> reqSibling = hpPhoneRequestSiblingMap.get(key);
        System.debug('///key: ' + key);
        System.debug('///newReqs: ' + newReqs);
        System.debug('///reqSibling: ' + reqSibling);

        if(newReqs != null && newReqs.size() > 0){
            if(reqSibling != null && reqSibling.size() > 0){ //If the new req have siblings
                updateSiblings(reqSibling, newReqs, reqs, docData);
                for(Request__c req : newReqs){
                    if(req.ProgramRequests__r.Size() > 0){
                        proReqToUpdate.addAll(req.ProgramRequests__r);
                    }
                }
            } else{ //If not find sibling
                updateNewReqs(newReqs, reqs, acc, con, newReqsAccMap, newReqsConMap, docData);
                System.debug('///newReqsAccMap: ' + newReqsAccMap);
            }
        }
    }

    private static void updateSiblings(List<Request__c> reqSibling, List<Request__c> newReqs, Map<Id, Request__c> reqs, xmlDocument docData){
        //1. Delete old parent request
        if(reqSibling[0].Request__c != null)
        	parentReqIdsToDelete.add(new Request__c(Id = reqSibling[0].Request__c));
        System.debug('///parentReqIdsToDelete: ' + parentReqIdsToDelete);
        //Create Parent if not have (only one request was created)
        Request__c newPar;
        if(newReqs[0].Request__c == null && newReqs.size() == 1){
            newPar = createParentRequest(reqSibling[0].Account__c, reqSibling[0].Primary_Contact__c, newReqs[0].Request_Number__c, reqSibling);
            Database.upsert(newPar, Request__c.ExtId__c, false);	
        }
        
        //2. Update Parent and childs requests with Contact and Account
        for(Request__c req : newReqs){
            req.Account__c = reqSibling[0].Account__c;
            req.Primary_Contact__c = reqSibling[0].Primary_Contact__c;
            req.Request__c = req.Request__c == null && newPar != null && newPar.Id != null ? newPar.Id : req.Request__c;
            updateNewReqsFields(docData, req);
            if(!reqs.containsKey(req.Id))
                reqs.put(req.Id, req);
        }
        //3. Update new parent with old parent's Owner, Contact and Account
        if(!reqs.containsKey(newReqs[0].Request__c) && newPar == null){
            if(reqSibling[0].Request__c != null){
                reqs.put(newReqs[0].Request__c, new Request__c(Id = newReqs[0].Request__c, OwnerId = reqSibling[0].Request__r.OwnerId, Request_Status__c = reqSibling[0].Request__r.Request_Status__c, Account__c = reqSibling[0].Account__c, Primary_Contact__c = reqSibling[0].Primary_Contact__c));
            } else{
                reqs.put(newReqs[0].Request__c, new Request__c(Id = newReqs[0].Request__c, Account__c = reqSibling[0].Account__c, Primary_Contact__c = reqSibling[0].Primary_Contact__c));
            }            
        }
        //4. Update siblings with new parent request
        for(Request__c sbReq : reqSibling){
            sbReq.Request__c = newReqs[0].Request__c == null && newPar != null && newPar.Id != null ? newPar.Id : newReqs[0].Request__c;
            if(!reqs.containsKey(sbReq.Id))
                reqs.put(sbReq.Id, sbReq);
        }
        System.debug('///reqs: ' + reqs);
    }

    private static void updateNewReqs(List<Request__c> newReqs, Map<Id, Request__c> reqs, Account acc, Contact con, Map<Request__c, Account> newReqsAccMap, Map<Request__c, Contact> newReqsConMap, xmlDocument docData){
        //Update Parent and childs requests with new Contact and Account from XML
        System.debug('///acc: ' + acc);
        System.debug('///con: ' + con);
        for(Request__c req : newReqs){
            System.debug('///req: ' + req);
            Boolean flag = false;
            Boolean insertAcc = false;
            Boolean insertCon = false;
            if(acc != null && acc.Id != null){
                System.debug('///if1');
                flag = true;
                req.Account__c = acc.Id;
                if(!reqs.containsKey(req.Id)){
                    System.debug('///if11');
                    updateNewReqsFields(docData, req);
                    reqs.put(req.Id, req);
                }
            } else{
                System.debug('///else1');
                // newReqsAccMap.put(req, acc);
                insertAcc = true;
                System.debug('///newReqsAccMap: ' + newReqsAccMap);
            }
            if(con != null && con.Id != null){
                System.debug('///if2');
                req.Primary_Contact__c = con.Id;
                if(flag == false){
                    System.debug('///if22');
                    flag = true;
                    if(!reqs.containsKey(req.Id)){
                        updateNewReqsFields(docData, req);
                        reqs.put(req.Id, req);
                    }
                }
            } else{
                System.debug('///else2');
                insertCon = true;
                // newReqsConMap.put(req, con);
            }
			System.debug('///req2: ' + req);
            //Update new parent with Contact and Account
            if(flag == true){
                if(!reqs.containsKey(req.Request__c) && req.Request__c != null)
                    reqs.put(req.Request__c, new Request__c(Id = req.Request__c, Account__c = req.Account__c, Primary_Contact__c = req.Primary_Contact__c));
            }
            if(insertAcc)
                newReqsAccMap.put(req, acc);
            if(insertCon)
                newReqsConMap.put(req, con);
            System.debug('///reqs: ' + reqs);
            System.debug('///newReqsAccMap: ' + newReqsAccMap);
        }
    }

    private static void updateNewReqsFields(xmlDocument docData, Request__c req){
        System.debug('///!!docData.newProfessionRequest: ' + docData.newProfessionRequest);
        if(docData.newProfessionRequest != null && docData.newProfessionRequest.otherProfNameList != null){
            req.Job_Description__c = docData.newProfessionRequest.otherProfNameList.explanation;
            // req.Hiring_Reason__c = docData.newProfessionRequest.otherProfNameList.requiresTraining.dataCode;
            // req.Other_Reason__c = docData.newProfessionRequest.otherProfNameList.other;
        } else if(docData.newProfessionRequest != null && docData.newProfessionRequest.otherProfNameListCustom != null){
            for(OtherProfName op : docData.newProfessionRequest.otherProfNameListCustom){
                System.debug('///!!op: ' + op);
                if(op.newProfName == req.Job__c){
                    req.Job_Description__c = op.explanation;
                    // req.Hiring_Reason__c = op.requiresTraining.dataCode;
                    // req.Other_Reason__c = op.other;
                }
            }
        }
        System.debug('///!!req: ' + req);
    }

    //Update the lookup fields with new values
    private static void updateRequest(Map<Request__c, Account> newReqsAccMap, Map<Request__c, Contact> newReqsConMap){
        Map<Id, Request__c> reqsToUpdate = new Map<Id, Request__c> ();
        for(Request__c req : newReqsAccMap.keySet()){
            //1. Update Parent and childs requests with Account
            Id accId = req.Account__c == null ? newReqsAccMap.get(req) != null ? newReqsAccMap.get(req).Id : null : req.Account__c;
            reqsToUpdate.put(req.Id, new Request__c(Id = req.Id, Account__c = accId));
            //2. Update new parent with old parent's Account
            if(req.Request__c != null)
            	reqsToUpdate.put(req.Request__c, new Request__c(Id = req.Request__c, Account__c = accId));
        }
        System.debug('///reqsToUpdate2: ' + reqsToUpdate);
        for(Request__c req : newReqsConMap.keySet()){
            //1. Update Parent and childs requests with Contact
            Id conId = req.Primary_Contact__c == null ? newReqsConMap.get(req) != null ? newReqsConMap.get(req).Id : null : req.Primary_Contact__c;
            if(reqsToUpdate.containsKey(req.Id)){
                reqsToUpdate.get(req.Id).Primary_Contact__c = conId;
            } else{
                reqsToUpdate.put(req.Id, new Request__c(Id = req.Id, Primary_Contact__c = conId));
            }
            //2. Update new parent with old parent's Contact
            if(req.Request__c != null){
                if(reqsToUpdate.containsKey(req.Request__c)){
                    reqsToUpdate.get(req.Request__c).Primary_Contact__c = conId;
                } else{
                    reqsToUpdate.put(req.Request__c, new Request__c(Id = req.Request__c, Primary_Contact__c = conId));
                }
        	}
        }
        System.debug('///reqsToUpdate3: ' + reqsToUpdate);
        if(reqsToUpdate.size() > 0)
            Database.update(reqsToUpdate.values(), false);
    }

    private static Request__c createParentRequest(Id acc, Id con, String extId, List<Request__c> reqSibling){
        Request__c parentReq = new Request__c();
        parentReq.RecordTypeId = parentRequest_RT;
        parentReq.Request_Status__c = Label_Utils.requestStatus.get('סגור');
        parentReq.Program__r = new Program__c(External_Program_Id__c = Label_Utils.programs.get('ojt'));
        parentReq.Request_Details__c = Label.TestUtils_RequestDetails;
        parentReq.ExtId__c = extId;
        parentReq.Website_Request__c = true;
        parentReq.Account__c = acc;
        parentReq.Primary_Contact__c = con;
        if(reqSibling[0].Request__c != null)
        	parentReq.OwnerId = reqSibling[0].Request__r.OwnerId;
        system.debug('///parentReq: ' + parentReq);
        return parentReq;
    }

    private static Set<String> getCitiesCodeFromOrg(){
        Set<String> citiesCode = new Set<String>();
        for(City__c c : [SELECT Id, Code__c FROM City__c WHERE Code__c != null]){
            citiesCode.add(c.Code__c);
        }
        System.debug('///citiesCode: ' + citiesCode);
        return citiesCode;
    }

    private static Set<String> getStreetsCodeFromOrg(Set<String> streetAdd){
        Set<String> streetsCode = new Set<String>();
        for(Street__c c : [SELECT Id, Code__c FROM Street__c WHERE Code__c != null AND Code__c in: streetAdd]){
            streetsCode.add(c.Code__c);
        }
        System.debug('///streetsCode: ' + streetsCode);
        return streetsCode;
    }

    private static void updateProReqFields(List<ProgramRequest__c> proReqToUpdate){
        System.debug('///proReqToUpdate1: ' + proReqToUpdate);
        if(proReqToUpdate.Size() > 0){
            for(ProgramRequest__c pr : proReqToUpdate){
                pr.Opened_Following_Recomme__c = true;
            }
            System.debug('///proReqToUpdate2: ' + proReqToUpdate);
            Database.upsert(proReqToUpdate, false);
        }
    }

    //----------------------------------------JSON Desarilizable Classes--------------------------------------

    public class Root{
        public xmlDocument root {set; get;}
    }

    public class xmlDocument{
        public MetaData metaData {set; get;}
        public RequestTypeTab requestTypeTab {set; get;}
        public EmployerDetails employerDetails {set; get;}
        public TrainingDetails trainingDetails {set; get;}
        public NewProfessionRequest newProfessionRequest {set; get;}
        // public List<ApprovedProffession> trainingDetailsCustomList {set; get;}
        // public List<OtherProfName> newProfessionRequestCustomList {set; get;}
        public String name {set; get;}
        public String state {set; get;}
        public String isClosed {set; get;}
        public WorkersDetails workersDetails {set; get;}
        public ContainersViewModel containersViewModel {set; get;}
        public FormInformation formInformation {set; get;}
        public List<FileCustom> Files {set; get;}
        public String formId {set; get;}
        public String formVersion {set; get;}
        public String engine {set; get;}
    }

    public class MetaData{
        public String referenceNumber {set; get;}
        public String sentDate {set; get;}
    }
    
    public class RequestTypeTab{
        public PicklistValue chosenFieldType {set; get;}
        public PicklistValue approvedProffessionList {set; get;}
        public String howToFillProffessions {set; get;}
        public String name {set; get;}
        public String state {set; get;}
        public String isClosed {set; get;}
    }
    
    public class EmployerDetails{
        public PicklistValue contractorTypeId {set; get;}
        public String contractorHp {set; get;}
        public String contractorId {set; get;}
        public String nikuim {set; get;}
        public String companyName {set; get;}
        public String numberOfEmployees {set; get;}
        public PicklistValue isWorkPlaceNameDifferent {set; get;}
        public String workPlaceOtherName {set; get;}
        public PicklistValue areaOfActivity {set; get;}
        public String otherBusinessField {set; get;}
        public String businessSignerName {set; get;}
        public PicklistValue companyCity {set; get;}
        public PicklistValue streetSelect {set; get;}
        public String houseNum {set; get;}
        public PicklistValue addressNotFoundRadio {set; get;}
        public String otherEmployerAddressDetails {set; get;}
        public String companyPhone {set; get;}
        public String companyEmail {set; get;}
        public String contactFirstName {set; get;}
        public String contactLastName {set; get;}
        public String contactJob {set; get;}
        public String contactPhone {set; get;}
        public String contactEmail {set; get;}
        public String name {set; get;}
        public String state {set; get;}
        public String isClosed {set; get;}
    }
    
    public class TrainingDetails{
        public ApprovedProffession approvedProfessionsList {set; get;}
        public List<ApprovedProffession> approvedProfessionsListCustom {set; get;}
        public String name {set; get;}
        public String state {set; get;}
        public String isClosed {set; get;}
    }

    public class ApprovedProffession{
        public PicklistValue professionFieldType {set; get;}
        public PicklistValue approvedProffessionType {set; get;}
        public String workersNum1 {set; get;}
        public String addressQuestion1 {set; get;}
        public String branchNumber1 {set; get;}
        public PicklistValue trainigCityTable {set; get;}
        public PicklistValue trainingStreetTable {set; get;}
        public String trainingHouseNumTable {set; get;}
        public String addressQuestionCheckbox2 {set; get;}
        public String mentorFirstNameTable {set; get;}
        public String mentorLastNameTable {set; get;}
        public String mentorIdTable {set; get;}
        public String mentorPhoneNumTable {set; get;}
        public String mentorEmailTable {set; get;}
    }

    public class NewProfessionRequest{
        public OtherProfName otherProfNameList {set; get;}
        public List<OtherProfName> otherProfNameListCustom {set; get;}
        public String name {set; get;}
        public String state {set; get;}
        public String isClosed {set; get;}
    }

    public class OtherProfName{
        public String newProfName {set; get;}
        public String licensingOrCertification {set; get;}
        public String explanation {set; get;}
        public PicklistValue requiresTraining {set; get;}
        public String doesProfessionRequestSpecialDegree {set; get;}
        public String specialDegreeDetails {set; get;}
        public String environmentRisks {set; get;}
        public PicklistValue demandForProfession {set; get;}
        public String trainingTime {set; get;}
    }

    public class ProfessionalTtasksRequiredList{
        public String otherTasks {set; get;}
    }
    
    public class WorkersDetails{
        public apendix apendixB {set; get;}
        public apendix apendixC {set; get;}
        public apendix legalStatusCertificate {set; get;}
        public apendix association {set; get;}
        public apendix bankApproval {set; get;}
        public apendix taxApproval {set; get;}
        public apendix booKipping {set; get;}
        public String name {set; get;}
        public String state {set; get;}
        public String isClosed {set; get;}
    }

    public class apendix{
        public String name {set; get;}
        public String size {set; get;}
        public String uploadedGuid {set; get;}
        public String state {set; get;}
    }
    
    public class ContainersViewModel{
        public String showPrintButton {set; get;}
        public String currentContainerName {set; get;}
        public String validatedStatus {set; get;}
    }
    
    public class FormInformation{
        public String isFormSent {set; get;}
        public String loadingDate {set; get;}
        public String isMobile {set; get;}
        public String language {set; get;}
    }
    
    public class PicklistValue{
        public String dataCode {set; get;}
        public String dataText {set; get;}
    }

    public class FileCustom{
        public String sourceName {set; get;}
        public String customType {set; get;}
        public String fileName {set; get;}
        public String customId {set; get;}
    }
}
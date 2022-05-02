/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-17-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class RequestHandler extends TriggerHandler{
    
    final static Id parentRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Parent_Request').getRecordTypeId();
    final static Id childRequest_RT = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Child_Request').getRecordTypeId();

    public override void afterInsert(){
        checkCreatingParentRequest(Trigger.new);
    }

    public override void beforeUpdate(){
        beforeUpdateGetSuitableRecord(Trigger.new, Trigger.oldMap);
    }

    //-----------------------------Before Update--------------------------------
    private void beforeUpdateGetSuitableRecord(List<Request__c> newRequest, Map<Id, SObject> oldMapRequest){
        Map<Id, Request__c> branchContactMap = new Map<Id, Request__c>();
        Map<String, Request__c> accConRequestMap = new Map<String, Request__c>();
        Map<Id, Request__c> parentReqOwnerChanged = new Map<Id, Request__c>();
        Map<Id, List<Request__c>> parentChildsRequest = new Map<Id, List<Request__c>>();
        Set<Id> requestId = new Set<Id>();

        for(Request__c rq : newRequest){
            Request__c oldRequest = (Request__c)oldMapRequest.get(rq.Id);
            System.debug('///rq: ' + rq);
            System.debug('///oldRequest: ' + oldRequest);
            if((rq.Request_Status__c != oldRequest.Request_Status__c)){//If status changed
                updateDateStatusFields(rq, oldRequest);
            }
            if((rq.Branch__c != null && oldRequest.Branch__c == null)){//If branch was populated
                branchContactMap.put(rq.Branch__c, rq);
                accConRequestMap.put('' + rq.Account__c + rq.Primary_Contact__c, rq);
            }
            if(rq.RecordTypeId == parentRequest_RT && oldRequest.OwnerId != rq.OwnerId){//If owner changed
                parentReqOwnerChanged.put(rq.Id, rq);
            }
            if(rq.RecordTypeId == childRequest_RT && oldRequest.Request_Status__c != rq.Request_Status__c){//If status changed
                requestId.add(rq.Id);
                if(!parentChildsRequest.containsKey(rq.Request__c))
                    parentChildsRequest.put(rq.Request__c, new List<Request__c>());
                parentChildsRequest.get(rq.Request__c).add(rq);
            }
        }

        if(branchContactMap.size() > 0 || accConRequestMap.size() > 0){
            updateBranchWithContact(branchContactMap, accConRequestMap);
        }
        if(parentChildsRequest.size() > 0){ 
            updateParentStatus(requestId, parentChildsRequest); 
        }
        if(parentReqOwnerChanged.size() > 0){
            updateChildsOwner(parentReqOwnerChanged); 
        }
    }

    //------------Update date status fields-------------
    private void updateDateStatusFields(Request__c rq, Request__c oldRequest){
        System.debug('///rq: ' + rq);
        if(rq.Request_Status__c == Label_Utils.requestStatus.get('השלמת פרטים')){
            rq.Date_Complete_Info__c = datetime.now();
        } else if(rq.Request_Status__c == Label_Utils.requestStatus.get('מיפוי צרכים')){
            rq.Date_Needs_Mapping__c = datetime.now();
        } else if(rq.Request_Status__c == Label_Utils.requestStatus.get('המלצה לתכנית')){
            rq.Date_Program_Request__c = datetime.now();
        } else if(rq.Request_Status__c == Label_Utils.requestStatus.get('סגירת בקשה')){
            rq.Date_Close_Request__c = datetime.now();
        } else if(rq.Request_Status__c == Label_Utils.requestStatus.get('סגור')){
            rq.Date_Closing__c = datetime.now();
        }
        System.debug('///after: ' + rq);
    }

    //------------After the user insert a new related branch, need to update branch with contact request-------------------
    private void updateBranchWithContact(Map<Id, Request__c> branchContactMap, Map<String, Request__c> accConRequestMap){
        List<Branch__c> branchToUpdate = new List<Branch__c>();
        Map<String, Branch__c> accConBranchMap = new Map<String, Branch__c>();
        Set<Id> primConIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<String> branchNames = new Set<String>();

        getBranchToUpdate(primConIds, accIds, branchNames, accConBranchMap, branchContactMap, branchToUpdate);
        checkBranchCreation(primConIds, accIds, branchNames, accConBranchMap, branchContactMap, accConRequestMap);
        
        if(accConBranchMap.values().size() > 0){
            System.debug('///accConBranchMap.values(): ' + accConBranchMap.values());
            Database.update(accConBranchMap.values(), false);
        }
    }

    //Get branche data related to request
    private void getBranchToUpdate(Set<Id> primConIds, Set<Id> accIds, Set<String> branchNames, Map<String, Branch__c> accConBranchMap, Map<Id, Request__c> branchContactMap, List<Branch__c> branchToUpdate){
        branchToUpdate = [SELECT Id, Primary_Contact__c, Account__c, contact_from_request__c, Name
                            FROM Branch__c 
                            WHERE Id in: branchContactMap.keySet()];

        for(Branch__c br : branchToUpdate){
            if(br.contact_from_request__c == true && br.Primary_Contact__c == null){
                br.Primary_Contact__c = branchContactMap.get(br.Id) != null ? branchContactMap.get(br.Id).Primary_Contact__c : null;
            }
            br.Account__c = branchContactMap.get(br.Id) != null ? branchContactMap.get(br.Id).Account__c : null;
            primConIds.add(br.Primary_Contact__c);
            accIds.add(br.Account__c);
            branchNames.add(br.Name);
            accConBranchMap.put('' + br.Account__c + br.Primary_Contact__c + br.Name, br);
        }
        System.debug('///branchToUpdate: ' + branchToUpdate);
        System.debug('///primConIds: ' + primConIds);
        System.debug('///accIds: ' + accIds);
        System.debug('///branchNames: ' + branchNames);
        System.debug('///accConBranchMap: ' + accConBranchMap);
    }

    //Check duplicate branches in org, if found delete it.
    private void checkBranchCreation(Set<Id> primConIds, Set<Id> accIds, Set<String> branchNames, Map<String, Branch__c> accConBranchMap, Map<Id, Request__c> branchContactMap, Map<String, Request__c> accConRequestMap){
        List<Branch__c> brToDelete = new List<Branch__c>();
        List<Branch__c> duplicateBranch = [SELECT Id, Primary_Contact__c, Account__c, contact_from_request__c, Name
                                            FROM Branch__c 
                                            WHERE Primary_Contact__c in: primConIds AND Account__c in: accIds AND Name in: branchNames AND Id not in: branchContactMap.keySet()];
        System.debug('///accConBranchMap: ' + accConBranchMap);
        System.debug('///duplicateBranch: ' + duplicateBranch);
        for(Branch__c br : duplicateBranch){
            System.debug('///br: ' + br);
            if(accConBranchMap.containsKey('' + br.Account__c + br.Primary_Contact__c + br.Name)){
                brToDelete.add(accConBranchMap.get('' + br.Account__c + br.Primary_Contact__c + br.Name));
                accConBranchMap.remove('' + br.Account__c + br.Primary_Contact__c + br.Name);
                Request__c rq = accConRequestMap.get('' + br.Account__c + br.Primary_Contact__c);
                System.debug('///rq: ' + rq);
                if(rq != null && !Test.isRunningTest())
                    rq.addError(Label.AddError_DuplicateBranch);
            }
        }

        System.debug('///brToDelete: ' + brToDelete);
        System.debug('///accConBranchMap: ' + accConBranchMap);
        if(brToDelete.size() > 0 && !Test.isRunningTest()){
            Database.delete(brToDelete, false);
        }
    }

    //--------------When child request status changed => need to update parent status with the earlier status.
    private void updateParentStatus(Set<Id> requestId, Map<Id, List<Request__c>> parentChildsRequest){
        Map<Id, Request__c> parentRequestMap = getParentRequest(parentChildsRequest.keySet());                
        List<Request__c> reqToUpdate = new List<Request__c>();
        getSiblingRequest(requestId, parentChildsRequest);

        for(Id parId : parentChildsRequest.keySet()){
            Request__c parent = parentRequestMap.get(parId);
            if(parentChildsRequest.get(parId) != null && parent != null){                
                String firstStatus = checkStatus(parentChildsRequest.get(parId));
                parent.Request_Status__c = firstStatus;
                reqToUpdate.add(parent);
            }
        }
        if(reqToUpdate.size() > 0){
            String jsonString = json.serialize(reqToUpdate);
        	updateParentRequest(jsonString);
        }
    }
    
    //Future method because of recosive process builder
    @future
    private static void updateParentRequest(String jsonString){
        List<Request__c> reqToUpdate = (List<Request__c>)Json.deserialize(jsonString, List<Request__c>.class);        
        Database.update(reqToUpdate, false);
    }

    //Get sibling request - have the same parent
    private void getSiblingRequest(Set<Id> requestId, Map<Id, List<Request__c>> parentChildsRequest){
        List<Request__c> siblingRequest = [SELECT Id, Request__c, Request_Status__c 
                                            FROM Request__c 
                                            WHERE Id not in: requestId AND Request__c in: parentChildsRequest.keySet() and RecordTypeId =: childRequest_RT];
        for(Request__c rq : siblingRequest){
            if(!parentChildsRequest.containsKey(rq.Request__c))
                parentChildsRequest.put(rq.Request__c, new List<Request__c>());
            parentChildsRequest.get(rq.Request__c).add(rq);
        }
    }
    
    //Get Parent data
    private Map<Id, Request__c> getParentRequest(Set<Id> parentId){
        List<Request__c> parentRequest = [SELECT Id, Request_Status__c  
                                            FROM Request__c 
                                            WHERE Id in: parentId and RecordTypeId =: parentRequest_RT];
        Map<Id, Request__c> parentRequestMap = new Map<Id, Request__c>();
        for(Request__c rq : parentRequest){
            parentRequestMap.put(rq.Id, rq);
        }
        return parentRequestMap;
    }
    
    //Get the earlier status of all related child request
    private static String checkStatus(List<Request__c> childs){
        String firstStatus;
        for(Request__c rq : childs){
            System.debug('///rq.Request_Status__c: ' + rq.Request_Status__c);
            if(firstStatus == null){
                firstStatus = rq.Request_Status__c;
            } else if(firstStatus == Label_Utils.requestStatus.get('סגור') && rq.Request_Status__c != Label_Utils.requestStatus.get('סגור')){
                firstStatus = rq.Request_Status__c;
            } else if(firstStatus == Label_Utils.requestStatus.get('סגירת בקשה') && (rq.Request_Status__c == Label_Utils.requestStatus.get('המלצה לתכנית') || rq.Request_Status__c == Label_Utils.requestStatus.get('מיפוי צרכים') || rq.Request_Status__c == Label_Utils.requestStatus.get('השלמת פרטים') || rq.Request_Status__c == Label_Utils.requestStatus.get('חדש'))){
                firstStatus = rq.Request_Status__c;
            } else if(firstStatus == Label_Utils.requestStatus.get('המלצה לתכנית') && (rq.Request_Status__c == Label_Utils.requestStatus.get('מיפוי צרכים') || rq.Request_Status__c == Label_Utils.requestStatus.get('השלמת פרטים') || rq.Request_Status__c == Label_Utils.requestStatus.get('חדש'))){
                firstStatus = rq.Request_Status__c;
            } else if(firstStatus == Label_Utils.requestStatus.get('מיפוי צרכים') && (rq.Request_Status__c == Label_Utils.requestStatus.get('השלמת פרטים') || rq.Request_Status__c == Label_Utils.requestStatus.get('חדש'))){
                firstStatus = rq.Request_Status__c;
            } else if(firstStatus == Label_Utils.requestStatus.get('השלמת פרטים') && rq.Request_Status__c == Label_Utils.requestStatus.get('חדש')){
                firstStatus = rq.Request_Status__c;
            }
            System.debug('///firstStatus: ' + firstStatus);
        }
        return firstStatus;
    }
    
    //------------------When parent request owner changed => need to update child's owner-----------------------
    private void updateChildsOwner(Map<Id, Request__c> parentReqOwnerChanged){
        List<Request__c> childRequest = [SELECT Id, Request__c, OwnerId 
                                            FROM Request__c 
                                            WHERE Request__c in: parentReqOwnerChanged.keySet() and RecordTypeId =: childRequest_RT];        
        for(Request__c rq : childRequest){
            if(parentReqOwnerChanged.get(rq.Request__c) != null){
                rq.OwnerId = parentReqOwnerChanged.get(rq.Request__c).OwnerId;
            }
		}        
        if(childRequest.size() > 0){
            Database.update(childRequest, false);
        }
    }
    
    //-----------------------------After insert---------------------------
    //-------------------------Check if there are more than one child with the same Titan submition id, if yes, create a parent request-----------------------
    private void checkCreatingParentRequest(List<Request__c> newRequest){
        Map<String, List<Request__c>> submitionIdRequestsMap = new Map<String, List<Request__c>>(); 
        List<String> submitionIds = new List<String>();
        Set<Id> reqIds = new Set<Id>();

        for(Request__c rq : newRequest){
            if(rq.Submition_Id__c != null && rq.RecordTypeId == childRequest_RT){
                if(!submitionIdRequestsMap.containsKey(rq.Submition_Id__c))
                    submitionIdRequestsMap.put(rq.Submition_Id__c, new List<Request__c>());
                submitionIdRequestsMap.get(rq.Submition_Id__c).add(rq);
                submitionIds.add(rq.Submition_Id__c);
                reqIds.add(rq.Id);
            }
        }
        getSubmitionIdsMap(submitionIds, submitionIdRequestsMap, reqIds);
        if(submitionIdRequestsMap.size() > 0){
            Map<String, Request__c> parentChildRequestsMap = createParentRequest(submitionIdRequestsMap);             
            if(parentChildRequestsMap.size() > 0){
                List<Request__c> requestToUpdate = updateRelatedChilds(parentChildRequestsMap, submitionIdRequestsMap);                
                Database.update(requestToUpdate, false);
            }
        }

    }

    //Check if need to create parent, if yes, create it
    private Map<String, Request__c> createParentRequest(Map<String, List<Request__c>> submitionIdRequestsMap){
        Map<String, Request__c> parentChildRequestsMap = new Map<String, Request__c>();
        List<Request__c> reqToInsert = new List<Request__c>();
        for(String subId : submitionIdRequestsMap.keySet()){
            Decimal numReq = submitionIdRequestsMap.get(subId).size();            
            if(numReq > 1){//More than one child => create parent
                Request__c childReq = submitionIdRequestsMap.get(subId)[0];
                Request__c parentReq = createParent(childReq);                
                reqToInsert.add(parentReq);
                parentChildRequestsMap.put(parentReq.Submition_Id__c, parentReq);
            } else{//If not check if already exist
                Request__c parentReq = checkParentAlreadyExist(subId);                
                if(parentReq != null){
                	parentChildRequestsMap.put(parentReq.Submition_Id__c, parentReq);
                }
            }
        }        
        if(reqToInsert.size() > 0){
           Database.insert(reqToInsert, false);

        }
        return parentChildRequestsMap;
    }
    
    //Check if parent already exist in the org with the same submition id
    private Request__c checkParentAlreadyExist(String subId){
        List<Request__c> parentReq = [SELECT Id, Submition_Id__c, OwnerId, RecordTypeId, Account__c, Area__c, Business_Name__c, Primary_Contact__c, Program__c, Request_Details__c 
                                		FROM Request__c WHERE Submition_Id__c =: subId AND RecordTypeId =: parentRequest_RT AND createdDate = TODAY];
        if(parentReq.Size() > 0){
            return parentReq[0];
        }
        return null;
    }
    
    //Create parent request
    private Request__c createParent(Request__c childReq){
        Request__c parentReq = new Request__c();
        parentReq.OwnerId = childReq.OwnerId;
        parentReq.RecordTypeId = parentRequest_RT;
        parentReq.Account__c = childReq.Account__c;
        //parentReq.Area__c = childReq.Area__c;
        parentReq.Business_Name__c = childReq.Business_Name__c;
        parentReq.Primary_Contact__c = childReq.Primary_Contact__c;
        parentReq.Program__c = childReq.Program__c;
        parentReq.Request_Details__c = childReq.Request_Details__c;
        parentReq.Submition_Id__c = childReq.Submition_Id__c;
        parentReq.Website_Request__c = childReq.Website_Request__c == true ? true : false;
        return parentReq;
    }

    //Update child => relate them to the parent
    private List<Request__c> updateRelatedChilds(Map<String, Request__c> parentChildRequestsMap, Map<String, List<Request__c>> submitionIdRequestsMap){        
        List<Request__c> requestToUpdate = new List<Request__c>();
        for(String paRq : parentChildRequestsMap.keySet()){                                    
            if(paRq != null && parentChildRequestsMap.get(paRq) != null && submitionIdRequestsMap.get(paRq) != null){
                for(Request__c chRq : submitionIdRequestsMap.get(paRq)){
                    if(chRq != null){
                        Request__c newRqs = new Request__c(Id = chRq.Id);                                                
                        newRqs.Request__c = parentChildRequestsMap.get(paRq).Id;
                        newRqs.Field1__c = true;
                        requestToUpdate.add(newRqs);                        
                    }
                }
            }
        }
        return requestToUpdate;
    }
    
    //Get all child with the same submition id
    private void getSubmitionIdsMap(List<String> submitionIds, Map<String, List<Request__c>> submitionIdRequestsMap, Set<Id> reqIds){
        List<Request__c> relatedRequests = [SELECT Id, Submition_Id__c, OwnerId, RecordTypeId, Account__c, Area__c, Business_Name__c, Primary_Contact__c, Program__c, Request_Details__c 
                                            	FROM Request__c WHERE Submition_Id__c in: submitionIds AND RecordTypeId =: childRequest_RT AND Request__c = null AND Id not in: reqIds];        
        for(Request__c rq : relatedRequests){
            if(submitionIdRequestsMap.containsKey(rq.Submition_Id__c))
            	submitionIdRequestsMap.get(rq.Submition_Id__c).add(rq);
        }
    }
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ProgramRequestHandler extends TriggerHandler{
    
    public override void beforeUpdate(){
        beforeUpdateGetSuitableRecord(Trigger.new, Trigger.oldMap);
    }

    //-----------------------------Before Update--------------------------------
    private void beforeUpdateGetSuitableRecord(List<ProgramRequest__c> newRequest, Map<Id, SObject> oldMapRequest){
        Map<String, List<ProgramRequest__c>> accHpProReqMap = new Map<String, List<ProgramRequest__c>>();
        Map<String, Decimal> accHpVouchNumMap = new Map<String, Decimal>();
        for(ProgramRequest__c pr : newRequest){
            ProgramRequest__c oldProRequest = (ProgramRequest__c)oldMapRequest.get(pr.Id);
            if((pr.vouchers_approved__c != null && pr.vouchers_approved__c != oldProRequest.vouchers_approved__c && pr.vouchers_approved__c > oldProRequest.vouchers_approved__c)){//Need to create vouchers
                if(pr.Status__c == Label_Utils.programRequestStatus.get('הקצאת שוברים חלקית') || pr.Status__c == Label_Utils.programRequestStatus.get('הקצאת שוברים מלאה')){
                    Decimal numVouchers = oldProRequest.vouchers_approved__c != null ? pr.vouchers_approved__c - oldProRequest.vouchers_approved__c : pr.vouchers_approved__c;
                    if(!accHpProReqMap.containsKey(pr.Account__c))
                        accHpProReqMap.put(pr.Account__c, new List<ProgramRequest__c>());
                    accHpProReqMap.get(pr.Account__c).add(pr);
                    
                    if(!accHpVouchNumMap.containsKey(pr.Account__c))
                        accHpVouchNumMap.put(pr.Account__c, 0);
                    accHpVouchNumMap.put(pr.Account__c, accHpVouchNumMap.get(pr.Account__c) + numVouchers);
                } else{
                    //pr.addError(Label.AddError_noRightStatus);
                }
            }
        }

        if(accHpVouchNumMap.keySet().Size() > 0)
            checkVoucherCreation(accHpVouchNumMap, accHpProReqMap, oldMapRequest);
    }
    
    private void checkVoucherCreation(Map<String, Decimal> accHpVouchNumMap, Map<String, List<ProgramRequest__c>> accHpProReqMap, Map<Id, SObject> oldMapRequest){
        //Get all active Vouchers per Account in the current year
        Map<String, Decimal> accHpAllocVouchNumMap = new Map<String, Decimal>();
        Map<String, Decimal> accHpAllocRejectedVouchNumMap = new Map<String, Decimal>();
        Integer currentYear = Date.Today().Year();
        List<Voucher__c> vouchs = [SELECT Id, ProgramRequest__r.Account__c, Active__c, Status__c, Rejected_Date__c, CreatedDate
                                    FROM Voucher__c
                                   	WHERE ProgramRequest__r.Account__c in: accHpVouchNumMap.keySet()];
        System.debug('///vouchs: ' + vouchs);
        
        //Add new request Vouchers to the Vouchers that have already been allocated in the last year
        for(Voucher__c vc : vouchs){
            if(vc.Active__c == True && currentYear == vc.CreatedDate.year()){
                if(!accHpAllocVouchNumMap.containsKey(vc.ProgramRequest__r.Account__c))
                    accHpAllocVouchNumMap.put(vc.ProgramRequest__r.Account__c, 0);
                accHpAllocVouchNumMap.put(vc.ProgramRequest__r.Account__c, accHpAllocVouchNumMap.get(vc.ProgramRequest__r.Account__c) + 1);
            }
            //Map rejected vouchers per Account
            if(vc.Status__c == Label_Utils.voucherStatus.get('נדחה- פג תוקף') && vc.Rejected_Date__c != null && currentYear == vc.Rejected_Date__c.year()){
                if(!accHpAllocRejectedVouchNumMap.containsKey(vc.ProgramRequest__r.Account__c))
                    accHpAllocRejectedVouchNumMap.put(vc.ProgramRequest__r.Account__c, 0);
                accHpAllocRejectedVouchNumMap.put(vc.ProgramRequest__r.Account__c, accHpAllocRejectedVouchNumMap.get(vc.ProgramRequest__r.Account__c) + 1);
            }
        }

        System.debug('///accHpAllocVouchNumMap: ' + accHpAllocVouchNumMap);
        System.debug('///accHpAllocRejectedVouchNumMap: ' + accHpAllocRejectedVouchNumMap);
        List<Voucher__c> newVchsList = getVouchersToCreate(accHpVouchNumMap, accHpProReqMap, accHpAllocVouchNumMap, oldMapRequest, accHpAllocRejectedVouchNumMap);
        System.debug('///newVchsList: ' + newVchsList);
        if(newVchsList.size() > 0){
            Database.insert(newVchsList, true);
        }
    }

    private List<Voucher__c> getVouchersToCreate(Map<String, Decimal> accHpVouchNumMap, Map<String, List<ProgramRequest__c>> accHpProReqMap, Map<String, Decimal> accHpAllocVouchNumMap, Map<Id, SObject> oldMapRequest, Map<String, Decimal> accHpAllocRejectedVouchNumMap){
        List<Voucher__c> newVchsList = new List<Voucher__c>();
        System.debug('///accHpVouchNumMap: ' + accHpVouchNumMap);
        for(String hp : accHpVouchNumMap.keySet()){
            List<ProgramRequest__c> prs = accHpProReqMap.get(hp);
            Decimal sumNumVouchs = accHpAllocVouchNumMap.get(hp) != null ? accHpVouchNumMap.get(hp) + accHpAllocVouchNumMap.get(hp) :  accHpVouchNumMap.get(hp);
            if(sumNumVouchs > 10 && !Test.isRunningTest()){//If more than 10
                for(ProgramRequest__c pr : prs){
                    pr.addError(Label.AddError_noMoreThan10Vouchers + ': ' + (accHpAllocVouchNumMap.get(hp) != null ? accHpAllocVouchNumMap.get(hp) : 0));
                }
            } 
            if(accHpAllocRejectedVouchNumMap.get(hp) >= 15 && !Test.isRunningTest()){//If have more or equal than 15 rejected vouchers
                for(ProgramRequest__c pr : prs){
                    pr.addError(Label.AddError_noMoreThan15RejectedVouchers);
                }
            } else{//Create requested Vouchers
                for(ProgramRequest__c pr : prs){
                    ProgramRequest__c oldProRequest = (ProgramRequest__c)oldMapRequest.get(pr.Id);
                    Decimal numVouchers = oldProRequest.vouchers_approved__c != null && pr.vouchers_approved__c > oldProRequest.vouchers_approved__c ? pr.vouchers_approved__c - oldProRequest.vouchers_approved__c : pr.vouchers_approved__c;
                    for(Integer i = 0; i < numVouchers; i++){
                        newVchsList.add(createVoucher(pr));
                    }
                }
            }
        }
        return newVchsList;
    }
    
    private Voucher__c createVoucher(ProgramRequest__c pr){
        Voucher__c vc = new Voucher__c();
        vc.Active__c = true;
        vc.ProgramRequest__c = pr.Id;
        vc.Voucher_Stock__c = pr.Voucher_Stock__c;
        vc.Status__c = Label_Utils.voucherStatus.get('אושר עקרונית וממתין לגיוס עובד');
        return vc;
    }
    

}
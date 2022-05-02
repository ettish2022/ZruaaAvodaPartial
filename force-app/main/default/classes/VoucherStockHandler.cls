public with sharing class VoucherStockHandler extends TriggerHandler{
    
    public override void beforeUpdate(){
        beforeUpdateGetSuitableRecord(Trigger.new, Trigger.oldMap);
    }

    //-----------------------------Before Update--------------------------------
    private void beforeUpdateGetSuitableRecord(List<Voucher_Stock__c> newRequest, Map<Id, SObject> oldMapRequest){
        for(Voucher_Stock__c vs : newRequest){
            Voucher_Stock__c oldProRequest = (Voucher_Stock__c)oldMapRequest.get(vs.Id);
            if(vs.Qty_vouchers_available__c != oldProRequest.Qty_vouchers_available__c){
                if(vs.Qty_vouchers_available__c > 0 && oldProRequest.Qty_vouchers_available__c == 0){
                    vs.Send_Email__c = true;
                } else if(vs.Qty_vouchers_available__c == 0 && oldProRequest.Qty_vouchers_available__c > 0){
                    vs.Send_Email__c = false;
                }
            }
        }
    }
    
}
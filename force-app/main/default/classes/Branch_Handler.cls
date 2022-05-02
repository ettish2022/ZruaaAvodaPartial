/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-11-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class Branch_Handler extends TriggerHandler{

    public override void beforeInsert(){
        checkConnectionContactToBranch(Trigger.new);
    }

    //Throw error if the user choise two contacts
    private void checkConnectionContactToBranch(List<Branch__c> newBranchs){
        List<Branch__c> branchToConnect = new List<Branch__c>();
        for(Branch__c br : newBranchs){
            if(br.contact_from_request__c == true && br.Primary_Contact__c != null){
                br.addError(Label.AddError_OnlyOneContact);
            }
        }
    }
}
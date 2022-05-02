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
trigger RequestTrigger on Request__c (after insert, before update) {
    new RequestHandler().run();
}
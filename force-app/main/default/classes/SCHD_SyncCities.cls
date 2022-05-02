/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   04-07-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class SCHD_SyncCities implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new BATCH_SyncCities(), 1);
    }
}
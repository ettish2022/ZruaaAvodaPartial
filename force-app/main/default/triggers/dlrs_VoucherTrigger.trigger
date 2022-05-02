/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_VoucherTrigger on Voucher__c
    (before delete, before update, after delete, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Voucher__c.SObjectType);
}
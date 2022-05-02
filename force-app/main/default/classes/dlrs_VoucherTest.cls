/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_VoucherTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_VoucherTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        List<Voucher_Stock__c> vouchStockList = TEST_Utils.createTestVoucherStock(new List<Voucher_Stock__c>{new Voucher_Stock__c()});
        insert vouchStockList;
        
        dlrs.RollupService.testHandler(new Voucher__c(Voucher_Stock__c = vouchStockList[0].Id));
    }
}
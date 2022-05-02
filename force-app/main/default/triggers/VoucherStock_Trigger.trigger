trigger VoucherStock_Trigger on Voucher_Stock__c (before update) {
    new VoucherStockHandler().run();
}
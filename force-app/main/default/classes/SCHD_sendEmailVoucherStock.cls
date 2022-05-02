global class SCHD_sendEmailVoucherStock implements Schedulable {
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new BATCH_sendEmailVoucherStock());
    }
}
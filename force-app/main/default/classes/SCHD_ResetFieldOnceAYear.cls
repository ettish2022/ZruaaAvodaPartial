global class SCHD_ResetFieldOnceAYear implements Schedulable {
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new BATCH_ResetFieldOnceAYear());
    }
}
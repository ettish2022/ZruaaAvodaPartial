global class SCHD_SyncProgramsFromMagar implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new BATCH_SyncProgramsFromMagar(), 1);
    }
}
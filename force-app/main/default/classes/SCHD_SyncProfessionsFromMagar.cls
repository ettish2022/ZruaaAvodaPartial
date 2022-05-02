global class SCHD_SyncProfessionsFromMagar implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new BATCH_SyncProfessionsFromMagar());
    }
}
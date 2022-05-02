public class DAL_Courses {
	
    public static List<Course__c> getCourses(String fields, String whereCondition){
        String queryStr = 'SELECT Id ';
        if (fields != null){
            queryStr += fields;
        }
        queryStr += ' FROM Course__c ';
        if (String.isNotBlank(whereCondition)){
            queryStr += whereCondition;
        }
        return Database.query(queryStr);
    }
}
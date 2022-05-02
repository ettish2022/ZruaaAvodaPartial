@isTest
public class TEST_Content_Version {
	
    static TestMethod void testContentVersions(){
        Test.startTest();
        Account acc = new Account(Name = 'test', Partner__c = true, Service_provider__c = 'מפעיל', Affiliation_To_Application__c = 'זירת מעסיקים');
       	insert acc;
        List<ContentVersion> contentVersions = createContentVersions(3, acc.Id);
		insert contentVersions;
        Test.stopTest();
    }
    
    public static List<ContentVersion> createContentVersions(Integer numFiles, String relatedObjectId){
		List<ContentVersion> contentFiles = new List<ContentVersion>();
		for (Integer i = 0; i < numFiles; i++){
			ContentVersion cv = new ContentVersion(
				Title = 'Test Content Version ' + string.valueOf(i), 
				Description = 'Test Content Description ' + string.valueOf(i), 
                RelatedObjectId__c = relatedObjectId,
				PathOnClient = '/docs' + string.valueOf(i),
				VersionData = Blob.valueOf('String o')
				);
			contentFiles.add(cv);
		}
		return contentFiles;
	}
    
}
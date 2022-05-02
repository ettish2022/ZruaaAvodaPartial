public inherited sharing class TestUtils {
    public static List<Account> createAccounts(Integer numAccs){
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numAccs; i++){
			Account acc = new Account(Name = 'Test Acount '+String.valueOf(i),
				Phone = '1234567', Partner__c = true, Service_provider__c = 'מפעיל', Affiliation_To_Application__c = 'זירת מעסיקים');
			accounts.add(acc);
		}
		return accounts;
	}
}
@isTest
private class Utils_TestClass{

	static TestMethod void testGeolocation(){
		Utils.Geolocation geo1 = new Utils.Geolocation(1.1, 1.1, 'test description');
		Utils.CityGeolocation geo2 = new Utils.CityGeolocation(1.1, 1.1, 'test description');
		Utils.CityGeolocation geo3 = new Utils.CityGeolocation(1.1, 1.1, 'test description', 'Test');
	}

	static TestMethod void testLabelValue(){
		Utils.LabelValueSlider labelValue0 = new Utils.LabelValueSlider('Tooltip', (Object)1, 'Tooltip');
        Utils.LabelValueSlider labelValue1 = new Utils.LabelValueSlider((Object)1, (Object)1, 'Tooltip');
		Utils.LabelValueParent labelValue2  = new Utils.LabelValueParent('label', (Object)1, (Object)1);
		Utils.LabelValueParent labelValue3 = new Utils.LabelValueParent((Object)1, (Object)1, (Object)1);
		Utils.LabelValueIndex labelValue4 = new Utils.LabelValueIndex('label', (Object)1, 1);
		Utils.LabelValueIndex labelValue5 = new Utils.LabelValueIndex((Object)1, (Object)1, 1);
        Utils.LabelValue labelValue6 = new Utils.LabelValue('Tooltip', (Object)1);
        Utils.LabelValue labelValue7 = new Utils.LabelValue((Object)1, (Object)1);
        labelValue7.compareTo(new Utils.LabelValue('Tooltip', (Object)1));
	}

	static TestMethod void testGetters(){
		List<String> list1 = Utils.getListFromString('String input', ' ');
		List<String> list2 = Utils.getListFromString(JSON.serialize(list1));
		List<SObject> objList = new List<SObject>();
		List<Utils.LabelValue> list3 = Utils.getListLabelValue(objList, 'fieldNameLabel', 'fieldNameValue', true);
		List<Utils.LabelValue> list4 = Utils.getListLabelValue(objList, 'fieldNameLabel', 'fieldNameValue', 'fieldNameParent');
		Utils.SafeDecimal((Object)0.1);
		Utils.SafeDouble((Object)0.1);
		Utils.SafeInteger((Object)1);
		Utils.SafeString('Object x');
		List<String> list5 = Utils.split('String input', 1);
		Map<String, Object> map1 = new Map<string, Object>{
            'Key1' => 1,
            'Key2' => 2
        };
        Map<String, Object> map2 = Utils.deserializeUntypedMap(JSON.serialize(map1));
        List<Object> list6 = Utils.deserializeUntypedList(JSON.serialize(list5));
        Utils.getPicklistDefaultValue('Account', 'AccountSource');
        Map<String, Set<String>> map3 = new Map<String, Set<String>>{
        	'Key1'=> new Set<String>{'value1', 'value2'},
        	'Key2'=> new Set<String>{'value1', 'value2'}
        };
        Set<String> set1 = Utils.getAllMapValues(map3);
        List<Account> accs = TEST_Utils.createTestAccount(new List<Account>{new Account(), new Account(), new Account(), new Account(), new Account()});
        Map<String, SObject> map4 = Utils.mapList(accs, 'Name');
        List<Object> list7 = new List<Object>{map2};
        Utils.addKeyValueToList(list7, 'Key3', 'Value3');
        Set<String> set2 = Utils.splitToSet(null, '');
        set2 = Utils.splitToSet('String str', '');
        set2 = Utils.splitToSet('String str', ' ');
        Integer int1 = Utils.getDurationInMinutes(Datetime.now().addHours(3), Datetime.now());
        Long long1 = Utils.getMinutes(Datetime.now(), Datetime.now().addHours(3));
        Set<String> set3 = Utils.getValuesSet(list7, 'Key1');
        Set<String> set4 = Utils.getValuesSet(accs, 'Name');
        Map<String, Object> map5= Utils.toMap(list7, 'Key1');
        Utils.getStreet('String str');
        Utils.getStreet('1 String str');
        Utils.sendEmailToAdmins('Test subject', 'String body');
        Utils.sendEmail('email@email.email', 'Test subject', 'String body');
        Utils.sendEmail('email@email.email', 'Test subject', 'String body', null);
        Utils.isValidEmail('String emailAddress');
        Utils.isValidEmail('');
        Utils.removeAllUnexpectedCharacters('test');
        Utils.getStandardUrl('https://sssss');
        Utils.getStandardUrl('test');
        Utils.getPicklistLabel(City__c.District_Picklist__c.getDescribe().getPicklistValues(), '1');
        Utils.getPicklistValue(City__c.District_Picklist__c.getDescribe().getPicklistValues(), 'דרום');
        
        
        Map<String, object> objMap = new map<String, object>();
        List<Map<String, object>> objList2 = new List<Map<String, object>>{objMap};
        Datetime now = Datetime.now();
        objMap.put('now', now);
        Utils.toMapFilter(objList2, 'now', 'now', now);
	}

	static TestMethod void testGetRealObject(){
		List<Account> accounts = TEST_Utils.createTestAccount(new List<Account>{new Account()});
		insert accounts;
		Utils.getRealObject(accounts[0], 'Account', 'Name');
		Utils.getRealObject(accounts[0], 'Account', 'LastModifiedDate');
		Utils.getRealObject(accounts[0], 'Account', 'AnnualRevenue');
		Utils.getRealObject(accounts[0], 'Account', 'NumberOfEmployees');
		Utils.getRealObject(accounts[0], 'Account', 'Site');
		Utils.getRealObject(accounts[0], 'Account', 'IsPartner');
	}

	
}
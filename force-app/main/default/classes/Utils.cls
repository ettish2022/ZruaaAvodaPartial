public class Utils {
	
	public static final string CHATTER_DELEGATED_PROFILE_NAME = 'Chatter Delegated';
	public static final string CHATTER_USERNAME_SUFFIX = '.j@chatter.com';
	
	public class MyException extends Exception{}
	
	public virtual class Geolocation{
		public decimal lat;
		public decimal lng;
		public String description;
		
		public Geolocation(decimal lat, decimal lng, String description){
			this.lat = lat;
			this.lng = lng;
			this.description = description;
		}
	}
	
	public class CityGeolocation extends Geolocation{
		public String cityName;
		
		public CityGeolocation(decimal lat, decimal lng, String description){
			super(lat, lng, description);
		}
		
		public CityGeolocation(decimal lat, decimal lng, String description, String cityName){
			super(lat, lng, description);
			this.cityName = cityName;
		}
	}
	
	public virtual class LabelValue implements Comparable{
    	public String label;
    	public object value;
    	
    	public LabelValue(string label, object value){
    		this.label = label;
    		this.value = value;
    	}
    	
    	public LabelValue(object label, object value){
    		this.label = String.valueOf(label);
    		this.value = value;
    	}
    	
    	public Integer compareTo(Object compareToObj) {
	        LabelValue compareTo = (LabelValue)compareToObj;
	        // The return value of 0 indicates that both elements are equal.
	        Integer returnValue = 0;
	        if (label > compareTo.label) {
	            // Set return value to a positive value.
	            returnValue = 1;
	        } else if (label < compareTo.label) {
	            // Set return value to a negative value.
	            returnValue = -1;
	        }
	        
	        return returnValue;       
	    }
    }
    
    public class LabelValueSlider extends LabelValue{
    	public String tooltip;
    	
    	public LabelValueSlider(String label, object value, String tooltip){
    		super(label, value);
    		this.tooltip = tooltip;
    	}
    	
    	public LabelValueSlider(object label, object value, String tooltip){
    		super(label, value);
    		this.tooltip = tooltip;
    	}
    }
    
    public class LabelValueParent extends LabelValue{
    	public object parent;
    	
    	public LabelValueParent(String label, object value, object parent){
    		super(label, value);
    		this.parent = parent;
    	}
    	
    	public LabelValueParent(object label, object value, object parent){
    		super(label, value);
    		this.parent = parent;
    	}
    }
    
    public class LabelValueIndex extends LabelValue{
    	public Integer index;
    	
    	public LabelValueIndex(String label, object value, Integer index){
    		super(label, value);
    		this.index = index;
    	}
    	
    	public LabelValueIndex(object label, object value, Integer index){
    		super(label, value);
    		this.index = index;
    	}
    }

    public static List<String> getListFromString(String input){
        return getListFromString(input, ',');
    }
    public static List<String> getListFromString(String input, string delimeter){
        List<String> returnList = new List<String>();
        if (String.isBlank(input)) return returnList;
        if(input.startsWith('[')){
            returnList = (List<String>)JSON.deserialize(input, List<String>.class);
        }
        else{
            returnList = input.split(delimeter);
        }
        return returnList;
    }
    
    public static List<LabelValue> getListLabelValue(List<sObject> sobjs, String fieldNameLabel, String fieldNameValue){
    	return getListLabelValue(sobjs, fieldNameLabel, fieldNameValue, null, true);
    }
    
    public static List<LabelValue> getListLabelValue(List<sObject> sobjs, String fieldNameLabel, String fieldNameValue, boolean needUnique){
    	return getListLabelValue(sobjs, fieldNameLabel, fieldNameValue, null, needUnique);
    }
    
    public static List<LabelValue> getListLabelValue(List<sObject> sobjs, String fieldNameLabel, String fieldNameValue, String fieldNameParent){
    	return getListLabelValue(sobjs, fieldNameLabel, fieldNameValue, fieldNameParent, true);
    }
    
    public static List<LabelValue> getListLabelValue(List<sObject> sobjs, String fieldNameLabel, String fieldNameValue, String fieldNameParent, boolean needUnique){
    	Map<object, LabelValue> myMap = new Map<object, LabelValue>();
    	List<LabelValue> myList = new List<LabelValue>();
    	if(sobjs != null && !sobjs.isEmpty()){
    		for(sObject sobj : sobjs){
    			object value = sobj.get(fieldNameValue);
    			object label = sobj.get(fieldNameLabel);
    			object parent = String.isNotBlank(fieldNameParent) ? sobj.get(fieldNameParent) : null;
    			if(parent != null){
    				if(value != null){
    					// without filtering the value if exist because the filtering will be in the client side
    					//i.e. the secondary classification has some different parents for the same value
	    				if(needUnique){
				    		myMap.put(value, new LabelValueParent(label, value, parent));
				    	}
				    	else{
				    		myList.add(new LabelValueParent(label, value, parent));
				    	}
	    			}
    			}
    			else{
	    			if(needUnique){
	    				if(value != null && !myMap.containsKey(value)){
		    				myMap.put(value, new LabelValue(label, value));
		    			}
			    	}
			    	else{
			    		myList.add(new LabelValue(label, value));
			    	}
    			}
    		}
    	}
    	
    	if(needUnique){
    		return myMap.values();
    	}
    	else{
    		return myList;
    	}
    }
        
    public static List<LabelValue> getListLabelValue(List<Schema.PicklistEntry> entries){
    	List<LabelValue> lst = new List<LabelValue>();
    	if(entries != null && !entries.isEmpty()){
    		for(Schema.PicklistEntry entry : entries){
    			lst.Add(new LabelValue(entry.getLabel(), entry.getValue()));
    		}
    	}
    	return lst;
    }
		
	public static void log(Object info) {
        System.debug('\n\n\n\n\n\n'+ json.serialize(info) +'\n\n\n\n\n\n');
    }
    
    public static void log(String description, Object info) {
        System.debug('\n'+ description +'\n');
        log(info);
    }
    
    public static String removeAllUnexpectedCharacters(String input){
    	String output = input;
    	if(String.isNotBlank(input)){
    		output = input.replaceAll('[()}{|><#^~]', '');
    	}
    	return output;
    }

    public static string getStandardUrl(string url){
        if (String.isBlank(url) || url.startsWithIgnoreCase('http')){
            return url;
        }
        return 'https://' + url;
    }
    
    public static String getDateTimeStr(DateTime dt){
        if(dt != null){
            String dtStr = String.valueOf(dt);
            dtStr = dtStr.replace(' ', 'T');
            if(dtStr.indexOf('.') > 0){
            	dtStr = dtStr.substring(0, dtStr.indexOf('.'));    
            }
            return dtStr + 'Z';
        }
        else{
            return null;
        }
    }

    public static Decimal SafeDecimal(Object value) { return SafeDecimal(value, 2); }
    public static Decimal SafeDecimal(Object value, Integer scale) { return (value == null || string.valueOf(value).length() == 0 ? 0.0 : Decimal.valueOf(Double.valueOf(value))).setScale(scale); }

    public static Double SafeDouble(Object value) { return SafeDouble(value, 2); }
    public static Double SafeDouble(Object value, Integer scale) { return SafeDecimal(value, scale).doubleValue(); }

    public static Integer SafeInteger(Object i) { return i == null || string.valueOf(i).length() == 0 ? 0 : Integer.valueOf(i); }

    public static String SafeString(Object x) { return x == null ? '' : String.valueOf(x); }
    
    public static List<String> split(String input, Integer separatorChar) {
		
		List<String> resultList = new List<String>();
		List<Integer> buffer = new List<Integer>();
		List<Integer> inputChars = input.getChars();
		Integer length = inputChars.size();

		for (Integer i = 0; i < length; i++) {
			if (inputChars[i] == separatorChar) {
				resultList.add(String.fromCharArray(buffer));
				buffer = new List<Integer>();
			} else {
				buffer.add(inputChars[i]);
			}
		}
		if (buffer.size() > 0) {
			resultList.add(String.fromCharArray(buffer));
		}
		return resultList;
	}

    public static string getGUID(string uniqueString){
        string str = '';
        Blob blobText = Blob.valueOf(String.valueOf(Crypto.getRandomInteger()));
        Blob hashed = Crypto.generateDigest('SHA-256',blobText);
        string tmp = EncodingUtil.convertToHex(hashed);
        System.debug(tmp);
        str += tmp.substring(0,15);
        str += '-';
        str += tmp.substring(15, 31);
        str += '-';
        str += String.isNotBlank(uniqueString) ? EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256',Blob.valueOf(uniqueString))) + '-' : '';
        str += tmp.substring(31, 47);
        str += '-';
        str += tmp.substring(47, 64);
        return str;
    }

	/**
	 * Sorts a List of sObjects into a map.
	 * It gets a list of sObjects, and returns a map containing the sObject whose *sortField* has the highest value for every group of *keyField*.
	 * For example: sortSObjects(contactList, Age_In_Years__c, AccountId) will return a map of sorted contacts.
	 * Each Account will have one Contact in the map, and that Contact record will be the contact who is the oldest.
	 * @param  objList   The list of sObjects to be sorted.
	 * @param  sortField The field on the sObject that will be used to sort the list.
	 * @param  keyField  The field on the sObject that will be used as the key in the returned map.
	 * @return           A map containing a single sObject for every key. That sObject has the highest value of *sortField* for that key.
	 */
	public static Map<Object, SObject> sortSObjects(List<SObject> objList, string sortField, string keyField){
		Map<Object, SObject> returnMap = new Map<Object, SObject>();
		Object key;
		for (SObject sobj : objList){
			key = sobj.get(keyField);
			if (returnMap.containsKey(key)){
				if (string.valueOf(returnMap.get(key).get(sortField)) < string.valueOf(sobj.get(sortField))){
					returnMap.put(key, sobj);
				}
			}
			else{
				returnMap.put(key, sobj);
			}
		}
		return returnMap;
	}

    public static List<String> sortListDescending(List<String> unorderedList){
        if (unorderedList == null){
            return null;
        }
        List<String> orderedList = new List<String>();
        unorderedList.sort();
        for (Integer i=unorderedList.size()-1; i>=0; i--){
            orderedList.add(unorderedList[i]);
        }
        return orderedList;
    }
	
	public static map<String, object> deserializeUntypedMap(String jsonStr){
        map<String, object> myMap = new map<String, Object>();
        try{
            if(!String.isEmpty(jsonStr)){
                myMap = (map<String, Object>) JSON.deserializeUntyped(jsonStr.replaceAll('&quot;','"'));
            }
        }
        catch(Exception e){Utils.log('ERROR: deserializeUntypedMap not success');}
        return myMap;
    }

    public static list<object> deserializeUntypedList(String jsonStr){
        list<object> myList = new list<object>();
        try{
            if(!String.isEmpty(jsonStr)){
                myList = (list<object>) JSON.deserializeUntyped(jsonStr.replaceAll('&quot;','"'));
            }
        }
        catch(Exception e){Utils.log('ERROR: deserializeUntypedList not success');}
        return myList;
    }

    public static string getPicklistDefaultValue(string objectName, string fieldName){
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> pickVals = fieldMap.get(fieldName).getDescribe().getPickListValues();
        String defaultVal;

        for (Schema.PicklistEntry av: pickVals) {
            if (av.isDefaultValue()) {
                return av.getValue();
            }
        }
        return '';
    }
    
    public static string getPicklistLabel(list<Schema.PicklistEntry> pickVals, string value){
        String result;
        if(pickVals != null && String.isNotBlank(value)){
	        for (Schema.PicklistEntry av: pickVals) {
	            if (av.isActive() && value.equalsIgnoreCase(av.getValue())) {
	                result = av.getLabel();
	                break;
	            }
	        }
        }
        return result;
    }
    
    public static string getPicklistValue(list<Schema.PicklistEntry> pickVals, string label){
        String result;
        if(pickVals != null && String.isNotBlank(label)){
	        for (Schema.PicklistEntry av: pickVals) {
	            if (av.isActive() && label.equalsIgnoreCase(av.getLabel())) {
	                result = av.getValue();
	                break;
	            }
	        }
        }
        return result;
    }

    public static set<String> getAllMapValues(map<String, set<String>> myMap){
        if(myMap == null){return null;}
        set<String> mySet = new set<String>();
        for(set<String> s : myMap.values()){
            mySet.addAll(s);
        }
        return mySet;
    }
    
    public static map<String,sObject> mapList(List<sObject> myList, String fieldName_unique) {

        map<String,sObject> myMap = new map<String,sObject>();

        String key;
        for (sObject obj: myList) {
            key = (String)obj.get(fieldName_unique);
            if(key != null){
                myMap.put(key, obj);
            }
        }
        return myMap;
    }
    
    public static void addKeyValueToList(List<object> myList, String key, String value) {
		if(myList != null && !String.isEmpty(key)){
	        for (object obj: myList) {
	        	Map<String, Object> myMap = (Map<String, Object>) obj;
	        	myMap.put(key, value);
	        }
		}
    }
    
    public static Set<String> splitToSet(String str, String separator) {
        if (str == null)
            return new Set<String>();

        if (String.isEmpty(separator))
            return new Set<String> { str };

        List<String> values = str.split(separator);
        return new Set<String>(values);
    }

    public static Set<Id> getSetIDs(List<SObject> lst){
        if(lst == null){return null;}
        Set<Id> ids = new Set<Id>();
        for(SObject obj : lst){
            ids.add(obj.Id);
        }
        return ids;
    }
    
    public static Set<Id> getSetIDs(List<sObject> lst, String fieldName) {
    	Set<Id> mySet = new Set<Id>();
        for (sObject obj : lst) {
    		mySet.add(String.valueOf(obj.get(fieldName)));
        }
        return mySet;
    }

    public static Integer getDurationInMinutes(DateTime endTime, DateTime startTime) {
        return Integer.valueOF((endTime.getTime() - startTime.getTime()) / 60 / 1000);
    }
    
    public static Set<String> getValuesSet(List<Object> objects, String fieldName) {
    	Set<String> mySet = new Set<String>();
        for (Object obj : objects) {
        	if(obj instanceof map<String, object>){
        		mySet.add(String.valueOf(((map<String, object>)obj).get(fieldName)));
        	}
        }
        return mySet;
    }
    
    public static Set<String> getValuesSet(List<sObject> objects, String fieldName) {
    	Set<String> mySet = new Set<String>();
        for (sObject obj : objects) {
    		mySet.add(String.valueOf(obj.get(fieldName)));
        }
        return mySet;
    }

    public static Map<String, Object> toMap(List<Object> objects, String fieldName) {
        Map<String, Object> myMap = new Map<String, Object>();
        for (Object obj : objects) {
        	if(obj instanceof map<String, object>){
        		myMap.put(String.valueOf(((map<String, object>)obj).get(fieldName)), obj);
        	}
        }
        return myMap;
    }
    
    public static Map<String, Object> toMapFilter(List<Object> objects, String fieldName, String filterFieldName, object filterValue) {
        Map<String, Object> myMap = new Map<String, Object>();
        for (Object obj : objects) {
        	if(obj instanceof map<String, object>){
        		map<String, object> tmpMap = (map<String, object>)obj;
        		if(tmpMap.get(filterFieldName) != null && tmpMap.get(filterFieldName) == filterValue ){
					myMap.put(String.valueOf(tmpMap.get(fieldName)), obj);        			
        		}
        	}
        }
        return myMap;
    }

    public static Map<String, List<SObject>> toMapList(List<SObject> objects, String fieldName) {
        Map<String, List<SObject>> myMap = new Map<String, List<SObject>>();
        for (SObject obj : objects) {
            String key = String.valueOf(obj.get(fieldName));
            if(!myMap.containsKey(key)){
                myMap.put(key, new List<SObject>());
            }
            myMap.get(key).add(obj);
        }
        return myMap;
    }

    public static Long getMinutes(DateTime startDate, DateTime endDate){
        if(startDate != null && endDate != null && endDate > startDate){
            return ( endDate.getTime() - startDate.getTime() ) / (1000 * 60) ;
        }
        return 0;
    }

    public static Street getStreet(String str){
        Street myStreet = new Street();
        if(!String.isEmpty(str)){
            if(str.contains(' ')){
                List<String> strLst = str.split(' ');
                if(strLst[0].replaceAll('/', '').isNumeric()){
                    myStreet.streetNumber = strLst[0];
                    strLst.remove(0);
                }
                else if(strLst[strLst.size() - 1].replaceAll('/', '').isNumeric()){
                    myStreet.streetNumber = strLst[strLst.size() - 1];
                    strLst.remove(strLst.size() - 1);
                }

                myStreet.streetName = String.join(strLst, ' ');
            }
        }
        return myStreet;
    }

    public class Street{
        public String streetName {set;get;}
        public String streetNumber {set;get;}
    }
    
    public static void sendEmailToAdmins(String subject, String body) {
    	Profile sys_adm_profile = [SELECT Id FROM Profile WHERE Name Like 'System Administrator'];
		List<User> sys_adm = [SELECT id, Email FROM User WHERE ProfileId = :sys_adm_profile.Id and IsActive = true];
		Set<String> emails = getValuesSet(sys_adm, 'Email');
		String[] recipients = new List<String>(emails);
        sendEmail('', '', recipients, subject, body, null);
    }
    
    public static void sendEmail(String recipient, String subject, String body) {
        sendEmail('', '', new String[] { recipient }, subject, body, null);
    }

    public static void sendEmail(String recipient, String subject, String body, Attachment attachment) {
        sendEmail('', '', new String[] { recipient }, subject, body, attachment);
    }
    
    public static void sendEmail(String senderName, String senderEmail, String[] recipients, String subject, String body, Attachment attachment) {
        try {
            // create message object
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setUseSignature(true);

            // set message deatils
            message.setSubject(subject);
            message.setPlainTextBody(body);
            message.setToAddresses(recipients);
            if (String.isNotEmpty(senderName))
                message.setSenderDisplayName(senderName);
            if (String.isNotEmpty(senderEmail))
                message.setReplyTo(senderEmail);
            if (attachment != null) {
                Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
                fileAttachment.setFileName(attachment.Name);
                fileAttachment.setBody(attachment.Body);

                message.setFileAttachments(new Messaging.EmailFileAttachment[] { fileAttachment });
            }

            // send message
            Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[] { message };
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        } catch (EmailException ce) {
            log('Utils.sendEmail', ce.getDmlMessage(0));
        }
    }
    
    public static object getRealObject(object value, String sObjectName, String fieldName){
    	if(value != null){
	    	Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
			Schema.DescribeSObjectResult r = t.getDescribe();
			Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
			try{
				if (f.getType() == Schema.DisplayType.String){
					//no need to convert it
				    //return String.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Date){
				    return DateTime.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.DateTime){
					String UTCString = (String) value;
					if(UTCString.contains('T')){
						UTCString = UTCString.replaceAll('T', ' ');
					}
					if(UTCString.contains('.')){
						UTCString = UTCString.substring(0, UTCString.indexof('.'));
					}
	        		return DateTime.valueOfGmt(UTCString);
				}
				else if (f.getType() == Schema.DisplayType.Double){
				    return Double.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Integer){
				    return Integer.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Long){
				    return Double.valueOf(value).longValue();
				}
				else if (f.getType() == Schema.DisplayType.MultiPicklist){
				    //return DateTime.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Boolean){
				    return Boolean.valueOf(value);
				}
				else if (f.getType() == Schema.DisplayType.Currency){
				    return Double.valueOf(value);
				}
			}
			catch(Exception e){
				log(e.getMessage());
			}
    	}
		return value;
    }

    public static Boolean isValidEmail(String emailAddress){
        if (String.isBlank(emailAddress)){
            return false;
        }
        String emailRegex = '^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(emailAddress);
        return emailMatcher.matches();
    }

}
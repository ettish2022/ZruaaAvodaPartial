public with sharing class Holland {
	
	public class ParsingException extends Exception {}

	public class Profile_score {
		public String area;
		public Integer score;
	}

	public String identification_number;
	public Integer gender;
	public Integer age;
	public Integer education;
	public String answers;
	public List<Profile_score> profile_score;
	public List<Occupations> occupations;

	public class Occupations {
		public Integer code_occupation ;
		public String title ;
		public String fit;
	}

	
	public static Holland parse(String json) {
		Holland obj;
		try {
			obj = (Holland) System.JSON.deserializeStrict(json, Holland.class); /* Strict! Json keys must exactly much the class defenition */
			if (obj.profile_score == null || obj.answers == null || obj.occupations == null || obj.identification_number == null || obj.answers == null) {
				throw new ParsingException('Error: missing mandatory fields');
			}
		}
		catch (Exception ex) {
			System.debug('in Holland: ERROR: ' + ex.getMessage());
			return null;
		}
		return obj;
	}
}
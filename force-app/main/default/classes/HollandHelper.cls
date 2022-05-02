public without sharing class HollandHelper {
    
    public class ParsingException extends Exception {}
    
    public HollandHelper() {
        
    }
    
    
    public static void buildHolland(List<Holland> hollandInputDataList, String jsonString){
        System.debug('IN buildHolland()');
        List<Holland_questionnaire__c> hollandQuestionnairsToInsert = new List<Holland_questionnaire__c>();
        List<Occupation_recommendation__c> OccupationRecommendationToInsert = new List<Occupation_recommendation__c>();
        
        Savepoint savePoint = Database.setSavepoint(); /* RollBack insertion of records as the Apex Transaction will not roll back due to the try/catch block*/
        
        try {
            for (Integer i = 0; i < hollandInputDataList.size(); i++) {
                hollandQuestionnairsToInsert.add(buildResultObject(hollandInputDataList[i])); /* add and Procces each Holland input to create the final Holland_questionnaire__c */
            }
            insert hollandQuestionnairsToInsert; 
            
            List<Occupation_recommendation__c> occReccListToInsert = new List<Occupation_recommendation__c>();
            for (Integer i = 0; i < hollandQuestionnairsToInsert.size(); i++) { /* Proccess the Occupation_recommendations for each Holland_questionnaire__c */
                List<Occupation_recommendation__c> reccomendationsPerHolland = assignOccupationRecommendations(hollandQuestionnairsToInsert[i], hollandInputDataList[i]); /*  List of reccommendation per Holland_questionnaire__c */
                occReccListToInsert.addAll(reccomendationsPerHolland);
            }
            insert occReccListToInsert;
            
        } catch (Exception ex) {
            System.debug('IN HollandHelper: Error while building Holland. Message: ' + ex.getMessage());
            System.debug('IN HollandHelper: Creating Log in HollandLog__c ...');
            Database.rollback(savepoint); 
            createErrorLog(jsonString, ex);
            return;
        }      
        
    }
    
    
    private static Holland_questionnaire__c buildResultObject(Holland hollanData){
        Holland_questionnaire__c hollandQuestionnaire = new Holland_questionnaire__c();
        hollandQuestionnaire.QuestionedGender__c = hollanData.gender == 0 ? null : String.valueOf(hollanData.gender);
        hollandQuestionnaire.QuestionedAgeGroup__c = hollanData.age == 0 ? null : String.valueOf(hollanData.age);
        hollandQuestionnaire.QuestionaireEducation__c = hollanData.education == 0 ? null : String.valueOf(hollanData.education);
        
        hollandQuestionnaire = assignAnswers(hollandQuestionnaire, hollanData); /* Parse the 60 Chars String Answers and assign for the matching fields in Holland_questionnaire__c */
        hollandQuestionnaire = assignProfileScore(hollandQuestionnaire, hollanData);
        return hollandQuestionnaire;
    } 
    
    
    private static Holland_questionnaire__c assignAnswers(Holland_questionnaire__c hollandQuestionnaire, Holland hollandData){
        String answers = hollandData.answers;
        if (answers.length() != 60) {
            throw new ParsingException(Label.Did_not_received_full_answers_data);
        }
        
        
        Map<String, Schema.SObjectField> hollandQuestionnaireFields = Schema.SObjectType.Holland_questionnaire__c.fields.getMap();
        List<String> answersCodeCharArray = answers.split(''); /* String -> List of 60 Chars. Each char is a code to an answer  -> */
        
        /* Assigns each AnswerCode to the appropriate field (Fields names for answers are "A1__c" to "A60__c" ) */
        for (Integer indexOfCodeAnswer = 0; indexOfCodeAnswer < answersCodeCharArray.size(); indexOfCodeAnswer++) {
            hollandQuestionnaire.put('A' + (indexOfCodeAnswer+1) + '__c', answersCodeCharArray[indexOfCodeAnswer]);
        }
        
        
        return hollandQuestionnaire;
        
        
    } 
    
    private static Holland_questionnaire__c assignProfileScore(Holland_questionnaire__c hollandQuestionnaire, Holland hollandData){
        Map<String, Integer> profileScoreMap = new Map<String, Integer>();
        final List<String> AVAILIBLE_AREA_VALUES = new List<String>{'realistic','investigative','artistic','social','enterprising','conventional'};
        for (Holland.Profile_score profileScore : hollandData.profile_score) { /* Iterating on user input */
            String profileScoreArea = profileScore.area.replaceAll( '\\s+', '').toLowerCase(); /* Ignore white space and Letter Case in JSON */
            if (!AVAILIBLE_AREA_VALUES.contains(profileScoreArea)) {
                throw new ParsingException(String.Format(Label.No_matching_area_field_for_the_user_input, new List<String>{profileScore.area}));
                
            }
            if (profileScore.score == null) {
                String message = Label.No_score_value_for_Area_Field;
                throw new ParsingException(String.format(message, new List<String>{profileScore.area}));
            }
            profileScoreMap.put(profileScoreArea, profileScore.score);
        }
        if (profileScoreMap.size() != AVAILIBLE_AREA_VALUES.size()) {
            throw new ParsingException(String.Format(Label.expecting_for_X_fields_areas_from_input, new List<String>{ String.valueOf(AVAILIBLE_AREA_VALUES.size())}));
            
        }
        else {
            for (String area : AVAILIBLE_AREA_VALUES) {
                hollandQuestionnaire.put(area + 'ProfileScore__c', profileScoreMap.get(area));
            }
            return hollandQuestionnaire;
        }
        
    } 
    
    /* Iterates on Jsons Occupoations reccomendations and create Occupations <-> Holland Junctions object records for each one */
    private static List<Occupation_recommendation__c> assignOccupationRecommendations(Holland_questionnaire__c hollandQuestionnaire, Holland hollandData){
        List<Occupation_recommendation__c> occupationRecList = new List<Occupation_recommendation__c>();
        
        if (hollandData.occupations.size() == 0) {
            throw new ParsingException('occupations List must not be empty');
        }
        for (Holland.Occupations occupationFromInput : hollandData.occupations) {
            Occupation_recommendation__c occupationReccomendation = new Occupation_recommendation__c();
            occupationReccomendation.ProfessionalFitDescription__c = occupationFromInput.fit;
            occupationReccomendation.Holland_questionnaire__c = hollandQuestionnaire.Id;
            occupationReccomendation.ProfessionId__r = new Occupation__c(OccupationMatrixId__c = String.valueOf(occupationFromInput.code_occupation)); //TDOO: Change in SF UI External ID Code to be Number instead of String
            occupationRecList.add(occupationReccomendation);
        }
        
        return occupationRecList;
    } 
    
    
    
    /* Log errors if can't manage to build "Holland_questionnaire__c" or related records */
    private static void createErrorLog(String jsonStringFromClient, Exception ex){
        HollandLog__c hollandLog = new HollandLog__c();
        hollandLog.JSON__c = jsonStringFromClient;
        hollandLog.ErrorMessage__c = ex.getMessage();
        insert hollandLog;
    } 
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-20-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-18-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class TEST_Courses {
    
    static TestMethod void testCourses(){
    	Test.startTest();
        insert new Global_Settings__c(Name = 'CoursesURL', Value__c = 'https://courses.labor.gov.il');	
        Ctrl_Courses ctrl = new Ctrl_Courses();
        List<ProfessionCourse__c> profCourses = getProfessionCourses(100);
        system.debug('///profCourses: ' + profCourses);
        insert profCourses;
        List<Course__c> courses = getCourses(100, profCourses);
        system.debug('///courses: ' + courses);
        insert courses;
        Ctrl_Courses.getCourses();
        
        Ctrl_Courses.CourseContact cc = new Ctrl_Courses.CourseContact();
        cc.contactEmail = 's@s.com';
        cc.contactName = 'test';
        cc.contactPhone = '0585858588';
        cc.courseId = courses[0].Id;
        cc.mailingConfirmation = true;
        Ctrl_Courses.contact(json.serialize(cc));
        
        Ctrl_Courses.getCoursesConfig();
        
        List<Utils.LabelValue> options = Utils.getListLabelValue(Course__c.CourseDistrict__c.getDescribe().getPicklistValues());
        Set<Utils.LabelValue> optionsSet = new Set<Utils.LabelValue>(options);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', options);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', optionsSet);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', options, 'valueOther');
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', options, 'valueOther', false);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', optionsSet, 'valueOther', false);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', options, 'valueOther', false, true);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', optionsSet, 'valueOther', false,true);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', options, 'valueOther', false, true, true);
        new SiteUtils.ConfigDropdown('apiName', 'label', 'tooltip', options, '', false);
        new SiteUtils.ConfigSort('district', 'אזור גאוגרפי', 'name', '', false);
        new SiteUtils.ConfigSort('district', 'אזור גאוגרפי', 'name', '');
        new SiteUtils.ConfigCheckbox('apiName', 'label', 'tooltip');
        new SiteUtils.ConfigCheckbox('apiName', 'label', 'tooltip', 'category', false);
        new SiteUtils.ConfigSlider('apiName', 'label', 'tooltip', 0, 2);
        new SiteUtils.ConfigSlider('apiName', 'label', 'tooltip', options);
        new SiteUtils.ConfigSlider('apiName', 'label', 'tooltip', options, '', false);
        
        new SiteUtils.ConfigAutoComplete('apiName', 'label', 'tooltip', 'functionFullName', 'functionReverseFullName');
        new SiteUtils.ConfigAutoComplete('apiName', 'label', 'tooltip', 'functionFullName', 'functionReverseFullName', 'category', true);
        
        Test.stopTest();
    }
    
    static List<ProfessionCourse__c> getProfessionCourses(integer counter){
        List<ProfessionCourse__c> lst = new List<ProfessionCourse__c>();
        for(integer i = 0 ; i < counter ; i++){
            ProfessionCourse__c tmp = new ProfessionCourse__c();
            tmp.Name = 'Test';
            tmp.Code__c = String.valueOf(i);
            tmp.Details__c = String.valueOf(i);
            tmp.Nickname__c = String.valueOf(i);
            tmp.Numeric_index__c = i;
            tmp.SyllabusUrl__c = String.valueOf(i);
            tmp.Tags__c = String.valueOf(i);
            tmp.Url__c = String.valueOf(i);
            tmp.Domain__c = 'הוראה';
            
            lst.Add(tmp);
        }
        return lst;
    }
	
    
    static List<Course__c> getCourses(integer counter, List<ProfessionCourse__c> profCourses){
        List<Course__c> lst = new List<Course__c>();
        for(integer i = 0 ; i < counter && i < profCourses.size() ; i++){
            Course__c tmp = new Course__c();
            // tmp.Name = 'Test';
            tmp.CityName__c = String.valueOf(i);
            tmp.Details__c = String.valueOf(i);
            tmp.PopulationType__c = 'עולים חדשים';
            tmp.StudiesType__c = 'פרונטלי';
            tmp.IsTvaIncluded__c = true;
            tmp.InstitutionNickname__c = String.valueOf(i);
            tmp.CandidatesNumber__c = i;
            tmp.StudentsCount__c = i;
            tmp.AbsorbedNumber__c = i;
            tmp.isInPublicSite__c = true;
            tmp.ProfessionCourse__c = profCourses[i].Id;
            tmp.CourseDistrict__c = 'דרום';
            tmp.StartDate_Estimated__c = System.today();
            
            
            lst.Add(tmp);
        }
        return lst;
    }
}
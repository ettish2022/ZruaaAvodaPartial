/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-09-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Ctrl_Courses{
	
    public Ctrl_Courses (){ getMeta(); }
    public final String coursesUrl = (string)Global_Settings__c.getAll().get('CoursesURL').get('Value__c'); //'https://courses.labor.gov.il'; 
    
    public String anchorElement;
    public String originalUrl {set;get;}
    public String title {set;get;}
    public String description {set;get;}
    public String favicon {set;get;}
    public String canonicalUrl {set;get;}
    public Map<String, String> pageParams {get; set;}
    
    //public Ctrl_Courses (CTRL ctrl){ getMeta();}
    public void getMeta(){
        
        title = Label.SiteCourses_Title;
        description = Label.SiteCourses_Description;
        
        PageReference currentPage = Apexpages.CurrentPage();
        pageParams = currentPage.getParameters();
        originalUrl = Site.getOriginalUrl();
        Utils.log(originalUrl);
        String base64Url = currentPage.getParameters().get('number');
        if(String.isNotBlank(base64Url)){
            originalUrl = EncodingUtil.base64Decode(base64Url).toString();
        }
        
        system.debug(originalUrl);
        if(String.isNotBlank(base64Url) && originalUrl.indexOf(';') > -1){
            originalUrl = originalUrl.substring(0, originalUrl.indexOf(';'));
        }
        canonicalUrl = coursesUrl;
        canonicalUrl += originalUrl != null ? originalUrl : '';
        originalUrl = String.isNotBlank(originalUrl) && originalUrl.startsWith('/') ? originalUrl.substring(1) : originalUrl;
        system.debug(originalUrl);
    }
    
    @RemoteAction
    public static List<Course> getCourses(){
        List<String> fields = new List<String>();
        fields.Add('name');
		fields.Add('ProfessionCourse__r.Url__c');
        fields.Add('ProfessionCourse__r.Nickname__c');
        fields.Add('ProfessionCourse__r.Tags__c');
        fields.Add('StudiesType__c');
        fields.Add('CityName__c');
        fields.Add('CourseDistrict__c');
        fields.Add('ProgramName__c');
        fields.Add('lastModifiedDate');
        fields.Add('ProfessionCourse__r.StudiesScope__c');
        fields.Add('InstitutionNickname__c');
        fields.Add('Timing__c');
        fields.Add('toLabel(Timing__c) timingLabel');
        fields.Add('ProfessionCourse__r.Name');
        fields.Add('toLabel(ProfessionCourse__r.Domain__c)');
        fields.Add('City__r.Name');
        fields.Add('StartDate_Estimated__c');
        fields.Add('StatusText__c');
        fields.Add('IsStatusActive__c');
        fields.Add('toLabel(PopulationType__c)');
        fields.Add('ProfessionCourse__r.Details__c');
        fields.Add('ProfessionCourse__r.SyllabusUrlFormula__c');
        fields.Add('RecordType.DeveloperName');
        DateTime dtnow = DateTime.now();
        DateTime dtStartOfMonth = DateTime.newInstance(dtnow.year(), dtnow.month(), 1);
        String dnowStr = String.valueOf(dtStartOfMonth.date());
        List<Course__c> openCourses = DAL_Courses.getCourses(' , ' + String.join(fields, ', '), 
                                                         ' where IsForWebsite__c = true and IsStatusActive__c = true and (StartDate_Estimated__c >= ' 
                                                         +  dnowStr 
                                                         + ' OR RecordType.DeveloperName = \'Digital_Course\')' );
        
        List<Course__c> closedCourses = DAL_Courses.getCourses(' , ' + String.join(fields, ', '), 
                                                         ' where IsForWebsite__c = true and IsStatusActive__c = false ' );
        
        List<Course__c> courses = new List<Course__c>(openCourses);
        courses.AddAll(closedCourses);
            
        return getCoursesCustom(courses);
    }
    
    @RemoteAction
    public static Id contact(String courseContactJson){
        if(courseContactJson != null){
            CourseContact courseContactCustom = (CourseContact) Json.deserialize(courseContactJson, CourseContact.class);
        	CourseContact__c cc = courseContactCustom.getObject();
            insert cc;
            return cc.Id;   
        }
        else{
            return null;
        }
    }
    
    public Class CourseContact{
        
        public String courseId {get; set;}
        public String contactName {get; set;} 
        public String contactPhone {get; set;}
        public String contactEmail {get; set;}
        public Boolean mailingConfirmation {get; set;}
        
        public CourseContact(){}
        public CourseContact__c getObject(){
            CourseContact__c cc = new CourseContact__c();
            cc.Course__c = this.courseId;
            cc.ContactName__c = this.contactName;
			cc.ContactPhone__c = this.contactPhone;
			cc.ContactEmail__c = this.contactEmail;            
            cc.Mailing_confirmation__c = this.mailingConfirmation != null && this.mailingConfirmation == true ? true : false;
            cc.ProfessionCourse__c = getProfessionCourseId();
            return cc;
        }

        private Id getProfessionCourseId(){
            return [SELECT ProfessionCourse__c FROM Course__c WHERE Id =: this.courseId Limit 1].ProfessionCourse__c;
        }
    }
    
    public Class Course{
        public String id {get; set;}
        public String name {get; set;} 
        public String scope {get; set;} // תחום
        public String city {get; set;} // מיקום גיאוגרפי
        public String tags {get; set;} // תגיות
        public DateTime startDate {get; set;}
        public String audience {get; set;} // קהל יעד
        public String scopeOfActivity {get; set;} //היקף פעילות
        public String learningHours {get; set;} //שעות לימוד
        public String learningHoursLabel {get; set;} //שעות לימוד
        public String academyName {get; set;} //שם מכללה
        public String details {get; set;} 
        public String silabusUrl {get; set;}
        public String studiesType {get; set;} //אופי הלימודים
        public String programName {get; set;} //תוכנית הכשרה
        public String district {get; set;} //מחוז
        public String nickname {get; set;} 
        public String courseUrl {get; set;}
        public String statusText {get; set;}
        public Boolean isStatusActive {get; set;}
        public String startDateDigital {get; set;}
        
        public Course(){}
        public Course(Course__c c){
            this.id = c.Id;
            if(c.ProfessionCourse__r != null){
                this.name = c.ProfessionCourse__r.Name;
                this.details = c.ProfessionCourse__r.Details__c;
            	this.scope = c.ProfessionCourse__r.Domain__c;
                this.tags = c.ProfessionCourse__r.Tags__c;
                this.scopeOfActivity = c.ProfessionCourse__r.StudiesScope__c != null ? String.valueOf(c.ProfessionCourse__r.StudiesScope__c) + ' שעות': null;// היקף שעות
                this.silabusUrl = c.ProfessionCourse__r.SyllabusUrlFormula__c;// empty
                this.nickname = c.ProfessionCourse__r.Nickname__c;
                this.courseUrl = c.ProfessionCourse__r.Url__c;
            }
            
            this.city = c.City__r != null ? c.City__r.Name : c.CityName__c; //empty
            this.startDate = c.StartDate_Estimated__c;
            this.audience = c.PopulationType__c;
            this.learningHours = c.Timing__c;
            this.learningHoursLabel = (string) c.get('timingLabel');
            this.academyName = c.InstitutionNickname__c;
            this.studiesType = c.StudiesType__c;
            this.programName = c.ProgramName__c;//empty
            this.district = c.CourseDistrict__c;
            this.statusText = c.StatusText__c;
            this.isStatusActive = c.IsStatusActive__c;
            
            if(c.RecordType.DeveloperName == 'Digital_Course'){
                this.studiesType = 'מקוון';
                this.city = 'מקוון';
                this.academyName = 'קמפוס IL';
                this.startDateDigital = 'זמין בכל עת';
                DateTime tmp = DateTime.now().addMonths(1);
                this.startDate = tmp;
                this.learningHoursLabel = 'לימוד עצמי';
                this.learningHours = 'עצמי';
                if(String.isBlank(this.audience)){
                   this.audience = 'אוכלוסיה כללית'; 
                }
            }
        }
    }
    
    
    public static List<Course> getCoursesCustom(List<Course__c> lst){
        Utils.log(lst);
        List<Course> result = new List<Course>();
        if(lst != null){
            for(Course__c c : lst){
                result.add(new Course(c));
            }
        }
        utils.log(result);
        return result;
    }
    
    @RemoteAction
    public static List<SiteUtils.ConfigField> getCoursesConfig(){
        List<SiteUtils.ConfigField> configLst = new List<SiteUtils.ConfigField>();
        configLst.add(new SiteUtils.ConfigDropdown('scope', 'תחום', null, Utils.getListLabelValue(ProfessionCourse__c.Domain__c.getDescribe().getPicklistValues())));
        configLst.add(new SiteUtils.ConfigDropdown('district', 'אזור גאוגרפי', null, Utils.getListLabelValue(Course__c.CourseDistrict__c.getDescribe().getPicklistValues())));
        configLst.add(new SiteUtils.ConfigDropdown('audience', 'קהל יעד', null, Utils.getListLabelValue(Course__c.PopulationType__c.getDescribe().getPicklistValues())));
        configLst.add(new SiteUtils.ConfigDropdown('learningHours', 'שעות לימוד', null, Utils.getListLabelValue(Course__c.Timing__c.getDescribe().getPicklistValues())));
        configLst.add(new SiteUtils.ConfigDropdown( 'statusText', 'סטטוס הרשמה', null, new List<Utils.LabelValue>{
        	new Utils.LabelValue('הרשמה פתוחה', 'הרשמה פתוחה'),
            new Utils.LabelValue('הרשמה נסגרה', 'הרשמה נסגרה')
        }));
        return configLst;
    }
}
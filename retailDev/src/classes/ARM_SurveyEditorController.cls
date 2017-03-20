/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_SurveyEditorController
 * Description: Controller class of visualforce page ARM_SurveyEditor
 *              This class handles addition/removal/change logic of 
 *              question from survey editor.
 *              It also contains logic for condition questuon handling.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
global class ARM_SurveyEditorController {
    
    private static final string NEED_VALID_BRAND_NAME = 'Need a valid brand name.';
    private static final string GOAL_BRAND_IS_REQUIRED = 'Goal brand is required.';
    private static final string GOAL_BRAND = 'goalBrand';
    private static final string level7 = 'L7';
    private static final string levelNH = 'NH';
    private static final string NEED_A_VALID_QUESTION = 'Need a valid question ID.';
    private static final string QUESTION_NOT_FOUND = 'Question not found.';
    private static final string levelL1 = 'L1';
    private static final string levelL2 = 'L2';
    private static final string levelL3 = 'L3';
    private static final string levelL4 = 'L4';
    private static final string levelL5 = 'L5';
    private static final string levelL6 = 'L6';

    
    public ARM_SurveyEditorController(ApexPages.StandardController controller){}

    //  Class to contain the survey name and list of SurveyQuestion(inner class) related to a survey
    global class Survey{
        global Survey(){
            this.questions = new List<SurveyQuestion>();
        }
        global List<SurveyQuestion> questions{get;Set;}
        global String surveyName{get;Set;}
    }

    //  Class to contain the details of a survey questions that are used on the editor.
    global class SurveyQuestion{
        
        global String id{get;set;}
        global String surveyId{get;set;}
        global String nextId{get;set;}
        global String parentId{get;set;}
        global String name{get;set;}
        global String conditionalAnswer{get;set;}
        global String conditionalAnswerBrandId{get;set;}
        global String text{get;set;}
        global String type{get;set;}
        global String answers{get;set;}
        global String commentsLabel{get;set;}
        global String createdBy{get;set;}
        global String updatedBy{get;set;}
        global Boolean includeNone{get;set;}
        global Boolean includePhotos{get;set;}
        global Boolean requirePhotos{get;set;}
        global String questionNumber{get;set;}
        global Decimal totalScore{get;set;}
        global Decimal maxScore{get;set;}

        global Decimal maxGoalScore{get;set;}
        global Boolean isGoal{get;set;}
        global String goalName{get;set;}
        global String goalType{get;set;}
        global String goalBrand{get;set;}
        global String goalBrandId{get;set;}
        /*global String goalStartDate{get;set;}
        global String goalEndDate{get;set;}*/
        
        public SurveyQuestion(){} // contructor without parameter
        
        public SurveyQuestion(ARM_Question__c sq){// contructor with survey question as parameter
            this.id = sq.Id;
            this.surveyId = sq.Survey__c;
            this.nextId = sq.NEXT_Question__c;
            this.parentId = sq.Parent_Question__c;
            this.name = sq.Name;
            this.conditionalAnswer = sq.Conditional_Answer__c;
            this.conditionalAnswerBrandId = sq.Conditional_Answer_Brand__c;
            this.text = sq.Question_Text__c;
            this.type = sq.Question_Type__c;
            this.answers = sq.Answer_Options__c;
            this.commentsLabel = sq.Label_for_Add_l_Comments__c;
            this.createdBy = sq.CreatedBy.Alias+' '+ sq.CreatedDate;
            this.updatedBy = sq.LastModifiedBy.Alias+' '+ sq.LastModifiedDate;
            this.questionNumber = sq.Question_Number__c;
            this.includeNone = sq.Include_None_of_the_Above__c;
            this.includePhotos = sq.Include_Photos__c;
            this.requirePhotos = sq.Require_Photos__c;
            this.maxScore = sq.Max_Score__c;

            this.maxGoalScore = sq.Max_Goal_Score__c;
            this.isGoal = sq.Is_Goal__c;
            this.goalName = sq.Goal_Name__c;
            this.goalType = sq.Goal_Type__c;

            this.goalBrand = ((String.isNotBlank(sq.Goal_Brand__r.level__c)?sq.Goal_Brand__r.level__c:'') + (String.isNotBlank(sq.Goal_Brand__r.name)?': '+ sq.Goal_Brand__r.name:''));

            this.goalBrandId = sq.Goal_Brand__r.id;
            /*if(sq.Goal_Start_date__c!=null){
                this.goalStartDate = datetime.newInstance(sq.Goal_Start_date__c, time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
            }
            if(sq.Goal_End_Date__c!=null){
                this.goalEndDate = datetime.newInstance(sq.Goal_End_Date__c, time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
            }*/

        }
        
        // This inner class method is used to retrieve/upsert
        // the Survey question and its related answers in remote method upsertQuestion 
        public ARM_Question__c getSObject(){
            ARM_Question__c sq = new ARM_Question__c();
            sq.Id=this.id;
            if(sq.Id == null) sq.Survey__c= this.surveyId ;
            sq.NEXT_Question__c= this.nextId;
            sq.Parent_Question__c= this.parentId;
            sq.Conditional_Answer__c= this.conditionalAnswer;
            if(this.conditionalAnswerBrandId == '') {
                sq.Conditional_Answer_Brand__c = null;
             } else {
                sq.Conditional_Answer_Brand__c = this.conditionalAnswerBrandId;
            }
            sq.Question_Text__c= this.text;
            sq.Question_Type__c= this.type;
            sq.Label_for_Add_l_Comments__c = this.commentsLabel;
            sq.Question_Number__c = this.questionNumber;
            sq.Max_Score__c = this.maxScore;

            if(this.answers!=null){
                sq.Answer_Options__c= processAnswerJson(this.answers);
            }

            // adding Conditional_Answer_Brand__c field value for child conditional questions.
            // TODO remove conditional text for non first question.
            if(this.parentId!=null && this.parentId.length()>0){
                List<ARM_Question__c> parentQuestions = [select Answer_Options__c from ARM_Question__c where id=:this.parentId];
                if(parentQuestions.size()>0){
                    ARM_Question__c parent = parentQuestions[0];

                    List<Answer> answers = (List<Answer>)JSON.deserialize(parent.Answer_Options__c, List<Answer>.class);
                    for(integer i = 0; i < answers.size() ; i++){
                        Answer ans = answers[i];
                        if(this.conditionalAnswer!=null && this.conditionalAnswer.equals(ans.value)){
                            //sq.Conditional_Answer_Brand__c = ans.valueBrandId;
                            //check for empty string so we don't try to assign that to a lookup field; --tscott
                            if(ans.valueBrandId == '') {
                                sq.Conditional_Answer_Brand__c = null;
                             } else {
                                sq.Conditional_Answer_Brand__c = ans.valueBrandId;
                             }
                        }
                    }
                }
            }

            //Answer
            sq.Goal_Brand__c = null;
            sq.Is_Goal__c = false;
            sq.Max_Goal_Score__c = null;
            sq.Goal_Name__c = null;
            sq.Goal_Type__c = null;
            String LevelSelected; //Added by Nishank for Case:-00109862(Appirio) / Case:00012999 (Diageo) / DE2084
            if(String.isNotBlank(this.goalBrand)){
                if(this.goalBrand.indexOf(': ')>-1){
                   LevelSelected =this.goalBrand.subString(0,2); //Modified by Nishank for Case:-00109862(Appirio) / Case:00012999 (Diageo) / DE2084
                   this.goalBrand = this.goalBrand.subString(this.goalBrand.indexOf(': ')+2);                   
                }
                //Modified by Nishank for Case:-00109862(Appirio) / Case:00012999 (Diageo) / DE2084
                List<ARM_Brand__c> brand = [select id,name from ARM_Brand__c where name =:this.goalBrand and Level__c=:LevelSelected limit 1];
                //System.debug('Goal Brand ID'+goalBrandId);
                //List<Brand__c> brand = [select id,name from Brand__c where name =:this.goalBrand limit 1]; //Commented by Nishank for Case:-00109862(Appirio) / Case:00012999 (Diageo) / DE2084
                if(brand.size()>0){
                   sq.Goal_Brand__c = brand[0].id;
                }else{
                    throw new CustomException(prepareJsonResponse(NEED_VALID_BRAND_NAME, true, new List<String>{'goalBrand'} ));
                }
            }
			
            if(this.isGoal){
                if(!String.isNotBlank(this.goalBrand)){
                    throw new CustomException(prepareJsonResponse(GOAL_BRAND_IS_REQUIRED, true, new List<String>{'goalBrand'} ));
                }
                sq.Is_Goal__c = this.isGoal;
                sq.Max_Goal_Score__c = this.maxGoalScore;
                sq.Goal_Name__c = this.goalName;
                sq.Goal_Type__c = this.goalType;
            }

            system.debug('WOOT include none: '+this.includeNone);
            if(this.includeNone != null){
                sq.Include_None_of_the_Above__c = this.includeNone;
            }

            if(this.includePhotos != null){
                sq.Include_Photos__c = this.includePhotos;
            }
            
            if(this.requirePhotos != null){
                sq.Require_Photos__c = this.requirePhotos;
            }

            return sq;
        }
    }
    
    //  Returns the instance of inner class Survey.This class contains the list of questions
    //  related to the survey whose id is passed.
    //  @param id : a Survey Id
    //  @return instance of inner class Survey.

    @RemoteAction
    global static Survey getSurvey(String id){
        Survey result = new Survey();
        if(String.isBlank(id)){
            throw new CustomException('Need a valid survey ID.');
        }
        try{

            //mapping response
              //     id:                 'a4dK00000000JBX'                     Salesforce ID
              //     surveyId:           'a2dK00000000JBW'                     DMS Survey
              //     nextId:             'a5dK00000000JBS'                     NEXT Question
              //     parentId:           'a3dK00000000JBR'                     Parent Question
              //     name:               'Q-0027'                              DMS Question Name
              //     conditionalAnswer:  'NO'                                  Conditional Answer
              //     text:               Do you like?                          Question Text
              //     type:               text/price/number/select/multiselect  Question Type
              //     answers:            'Yes,No'                              Answer Options
              //     commentsLabel:      'Comments'                            Label for Add'l Comments
              //     createdBy:          'Matt Smith, 11/5/2013 1:55 PM'       Created By
              //     updatedBy:          'Matt Smith, 11/5/2013 1:57 PM'       Last Modified By
              //     questionNumber:     '1.1'                                 Question Number

            List<ARM_Survey__c> surveyList =  [Select Id, Name, First_Question__c, (Select Id, Name, Answer_Options__c, Conditional_Answer__c, Conditional_Answer_Brand__c, Survey__c, Label_for_Add_l_Comments__c,
                                    NEXT_Question__c, Parent_Question__c, Question_Text__c, Question_Type__c, CreatedDate, CreatedBy.Alias, LastModifiedBy.Alias,
                                    LastModifiedDate, Include_Photos__c, Require_Photos__c, Include_None_of_the_Above__c, Question_Number__c, Max_Score__c, Goal_Name__c, Goal_Type__c,
                                    Goal_Brand__r.name, Goal_Brand__r.Level__c, Max_Goal_Score__c, Is_Goal__c From ARM_Question__r order by createddate)
                                    From ARM_Survey__c Where Id = :id ];

            if(surveyList.size()==0) throw new CustomException('No survey found. Retry.');
            ARM_Survey__c s = surveyList[0];

            result.surveyName = s.Name;
            for(ARM_Question__c sq : s.ARM_Question__r){
                SurveyQuestion q = new SurveyQuestion(sq);
                result.questions.add(q);
                system.debug('Queried Question: '+q.text);
            }

            List<SurveyQuestion> questions = new List<SurveyQuestion>();
            //search for the first
            for(SurveyQuestion sq : result.questions){
                if(s.First_Question__c == sq.id){
                    questions.add(sq);
                    break;
                }
            }
            sortQuestions(result.questions, questions);

            Map<String, ARM_Brand__c> brandMap = new Map<String, ARM_Brand__c>([select id, name, Level__c from ARM_Brand__c]);
            for(SurveyQuestion sq : questions){
                String brandId = sq.goalBrand;
                ARM_Brand__c brand = brandMap.get(brandId);
                if(brand!=null){
                    Boolean flag= false;
                    sq.goalBrand = brand.Level__c +': ' + brand.name;
                }
            }
            result.questions = questions;

            //for(SurveyQuestion sq : result.questions){
            //    system.debug('Sorted Question: '+sq.text);
            //}
        }
        catch(Exception e){
            throw new CustomException('Unexpected error: '+e.getMessage());
        }
        return result;
    }

    //  Sort the Survey question list passed by recusrsively calling the same method
    //  @param id : questions : list of Survey questions (inner class)
    //              sorted : List of Survey questions (inner class) sorted out  
    //  @return nothing
    private static void sortQuestions(List<SurveyQuestion> questions, List<SurveyQuestion> sorted){
        if(sorted.size()==0) return;
        SurveyQuestion firstQ = sorted[sorted.size()-1];
        if(firstQ == null) return;

        //search for children
        for(SurveyQuestion sq : questions){
            if(sq.parentId == firstQ.id && sq.conditionalAnswer != null){
                sorted.add(sq);
                sortQuestions(questions,sorted);
            }
        }

        //search for the next one
        for(SurveyQuestion sq : questions){
            if(sq.id == firstQ.nextId){
                //don't add the Q if its already in there!
                //boolean foundQ = false;
                /*for(SurveyQuestion s : sorted){
                    if(s.id == sq.id){
                        foundQ = true;
                    }
                }
                if(!foundQ){

                }*/
                sorted.add(sq);
                sortQuestions(questions,sorted);
            }

        }
    }
    
    //Upserts the question in case of a question is updated/inserted  in editor
    @RemoteAction
    global static SurveyQuestion upsertQuestion(SurveyQuestion question){

        SurveyQuestion result = new SurveyQuestion();
        if(question == null){
            throw new CustomException(prepareJsonResponse('Need a valid question object.', true, null ));
        }

        try{
            ARM_Question__c sq = question.getSObject();

            List<ARM_Question__c> originalQuestionList = [select id,Answer_Options__c from ARM_Question__c where id =:sq.id];
            Boolean isOldQuestion = originalQuestionList.size()>0;
            system.debug('upserting this question data: '+sq);
            upsert sq;

            if(sq.id!=null && isOldQuestion){
                ARM_Question__c originalQuestion = originalQuestionList[0];
                // Handling answer change usecase, Updating child question's conditional answer field value if someone changes answer text.
                List<Answer> newAnswers = (List<Answer>)JSON.deserialize(sq.Answer_Options__c, List<Answer>.class);
                List<Answer> OldAnswers = null;
                Map<String, String> answerMap = new Map<String, String>();
                Map<String, String> answerBrandMap = new Map<String, String>();

                if(originalQuestion!=null && originalQuestion.Answer_Options__c!=null){
                    OldAnswers = (List<Answer>)JSON.deserialize(originalQuestion.Answer_Options__c, List<Answer>.class);
                    // checking for answer value change at same index in both old and new lists.
                    if(OldAnswers!=null && newAnswers!=null){
                        for(integer i = 0; i< OldAnswers.size(); i++){
                            if(newAnswers.size()>i){
                                answerMap.put(OldAnswers[i].value, newAnswers[i].value);
                                answerBrandMap.put(OldAnswers[i].valueBrandId, newAnswers[i].valueBrandId);
                            }
                        }
                    }

                    // updating child question's conditional answer fields
                    ARM_Question__c[] opChild = [select id, Conditional_Answer__c, Parent_Question__c, Conditional_Answer_Brand__c from ARM_Question__c where Parent_Question__c=:sq.id];
                    for(ARM_Question__c tQuestion : opChild){
                        tQuestion.Conditional_Answer__c = answerMap.get(tQuestion.Conditional_Answer__c);
                        tQuestion.Conditional_Answer_Brand__c = answerBrandMap.get(tQuestion.Conditional_Answer_Brand__c);
                    }

                    upsert opChild;
                }

            }

            result = new SurveyQuestion(sq);
            result.surveyId = question.surveyId;
        } catch(DMLException e){
            throw new CustomException(prepareJsonResponse('Unexpected error: '+e.getDMLMessage(0), true, null ));
        }
        return result;
    }
    
    
    // Fetches and returns the first question to be displayed on 
    @RemoteAction
    global static void setFirstQuestion(String questionID){

        if(String.isBlank(questionID)){
            throw new CustomException(NEED_A_VALID_QUESTION);
        }
        try{
            List<ARM_Question__c> qList = [Select Id, Survey__r.Id, Survey__r.First_Question__c From ARM_Question__c
                                            where Id = :questionID];
            if(qList.size()==0){
                throw new CustomException(QUESTION_NOT_FOUND);
            }
            qList[0].Survey__r.First_Question__c= qList[0].Id;
            update qList[0].Survey__r;

        } catch(DMLException e){
            throw new CustomException('Unexpected error: '+e.getDMLMessage(0));
        } catch(Exception e){
            throw new CustomException('Unexpected error: '+e.getMessage());
        }
    }
    
    // This method deletes a Survey question  based on question id passed .
    @RemoteAction
    global static void removeQuestion(String questionID){

        if(String.isBlank(questionID)){
            throw new CustomException(NEED_A_VALID_QUESTION);
        }
        try{
            delete new ARM_Question__c(Id = questionID);
        } catch(DMLException e){
            throw new CustomException('Unexpected error: '+e.getDMLMessage(0));
        }
    }

    // get picklist valies of Goal type field defined on Survey question
    public List<String> getGoalTypes(){
        List<String> typeList = new List<String>();
        Schema.DescribeFieldResult result = ARM_Question__c.Goal_Type__c.getDescribe();
        List<Schema.PicklistEntry> entryList = result.getPicklistValues();
        for(Schema.PicklistEntry entry : entryList){
            typeList.add(entry.getValue());
        }
        return typeList;
    }

    // Search brands based on term and level
    @RemoteAction
    global static List<String> searchBrands(String term, String level){
        User currentUser = [select Default_Country__c from User where id=:UserInfo.getUserId()];
        List<String> brandList = new List<String>();
        String queryString = String.escapeSingleQuotes(term);
        queryString = queryString.replace('*', '%');
        //system.debug('BRAND QUERY');
        //system.debug('SELECT Id, Name, Level__c FROM ARM_Brand__c WHERE Level__c != \'L7\' AND country__c=\''+currentUser.Default_Country__c+ '\' AND Name LIKE \'%'+queryString+'%\' order by Level__c' );
        //List<ARM_Brand__c> blst = Database.query('SELECT Id, Name, Level__c FROM ARM_Brand__c WHERE Level__c != \'L7\' AND country__c=\''+currentUser.Default_Country__c+ '\' AND Name LIKE \'%'+queryString+'%\' order by Level__c' );
        
        string userCountry = currentUser.Default_Country__c;
        string nameQuery = '%' + queryString + '%';
        List<ARM_Brand__c> blst = [SELECT Id, Name, Level__c 
                                    FROM ARM_Brand__c 
                                    WHERE Level__c != :level7 AND country__c = :userCountry AND Name LIKE :nameQuery 
                                    order by Level__c];
        
        for(ARM_Brand__c brand : blst){
            brandList.add(brand.Level__c +': '+  brand.name);
        }

        List<String> returnList =  brandList;
        if(level!=null && level!=''){
            returnList = new List<String>();
            //Modified by Shashank Singhal for DE2088
            Integer baseLevel;
            if(!level.startsWith(levelNH)){
                baseLevel = Integer.valueOf(level.subString(1,2));
            }
            
            for(String brand : brandList){
                Integer brandLevel;
                if(!brand.startsWith(levelNH)){
                    brandLevel = Integer.valueOf(brand.subString(1,2));
                }
                
                if(brandLevel>baseLevel || brand.startsWith(levelNH)){
                    returnList.add(brand);
                }
            }
            //End of DE2088
        }
        return returnList;
    }

    // return brands based on question brand , level and count value
    @RemoteAction
    global static List<Answer> getBrands(String questionBrand, String brandLevel, String goalCountValue){

        List<Answer> returnList = new List<Answer>();
        String questionBrandLevel = questionBrand.subString(0,2);

        Id questionBrandId;
        if(String.isNotBlank(questionBrand)){
            //Case 00012303/00106632/DE2058 - DE2078- smeers - New Query starts with Level # when questionBrand is received from VF page in case of duplicate names
            String BrandQuery = 'select id,name from ARM_Brand__c where Level__c = \''+ questionBrand.subString(0,2) +'\' ';

            if(questionBrand.indexOf(': ')>-1){
               questionBrand = questionBrand.subString(questionBrand.indexOf(': ')+2);
            }

            //Case 00012303/00106632/DE2058 - smeers - Takes query from above and combines with modified questionBrand name to return result and commented out original query
            List<ARM_Brand__c> brand = Database.query(BrandQuery + 'AND name = :questionBrand limit 1');
            //List<Brand__c> brand = [select id,name from Brand__c where name =:questionBrand limit 1];

            if(brand.size()>0){
                questionBrandId = brand[0].id;
            }else{
                throw new CustomException(prepareJsonResponse('Need a valid brand name.', true, null ));
            }
        }
        String brandCondition = '';
        if(questionBrandLevel.equals(levelL1)){
            brandCondition += ' and L1_Classification__c = \'' + questionBrandId + '\'' ;
        } else if(questionBrandLevel.equals(levelL2)){
            brandCondition += ' and L2_Group_Type__c = \'' + questionBrandId + '\'' ;
        } else if(questionBrandLevel.equals(levelL3)){
            brandCondition += ' and L3_Brand__c = \'' + questionBrandId + '\'' ;
        } else if(questionBrandLevel.equals(levelL4)){
            brandCondition += ' and L4_Brand_Variant__c = \'' + questionBrandId + '\'' ;
        } else if(questionBrandLevel.equals(levelL5)){
            brandCondition += ' and L5_Individual_Variant__c = \'' + questionBrandId + '\'' ;
        } else if(questionBrandLevel.equals(levelL6)){
            brandCondition += ' and L6_Volume__c = \'' + questionBrandId + '\'' ;
        }

        List<ARM_Brand__c> brandList = Database.query('SELECT Id, Name, Level__c FROM ARM_Brand__c WHERE Level__c =\''+ brandLevel + '\'' + brandCondition);
        for(ARM_Brand__c br :brandList){
            Answer ans = new Answer();
            ans.value = br.Level__c+': ' + br.Name ;
            ans.valueBrandId = '' + br.Id;
            ans.score = '0';
            ans.goalScore = ''+ goalCountValue;
            returnList.add(ans);
        }

        return returnList;
    }
    
    // Prepare a JSON response in case an exception occurs. 
    @TestVisible
    private static String prepareJsonResponse(String message,Boolean isError, String[] fields){
        Message msg = new Message();
        msg.message = message;
        msg.isError = isError;
        msg.fields = fields;
        return JSON.serialize(msg);
    }
    // This method process the user selected answers that are received in JSON format
    // and returns a JSON string back after processing. 
    @TestVisible
    private static String processAnswerJson(String jsonstring){
            List<Answer> answers = (List<Answer>)JSON.deserialize(jsonstring, List<Answer>.class);

            String condition = '';
            String orString = '';
            for(Answer ans : answers){
                if(ans.value.indexOf(': ')>-1){
                   ans.value = ans.value.subString(ans.value.indexOf(': ')+2);
                }
                condition = condition + orString + 'name = \'' + ans.value + '\'';
                orString = ' or ';
            }

            User currentUser = [select Default_Country__c from User where id=:UserInfo.getUserId()];

            String query  = 'SELECT Id, Name FROM ARM_Brand__c WHERE country__c=\''+currentUser.Default_Country__c+'\' AND (' + condition + ')';
            List<ARM_Brand__c> brandList = database.query(query);

            for(Answer ans : answers){
                //ans.valueBrandId = '';
                for(ARM_Brand__c brand : brandList){
                    String escapedString = ans.value.replace('\\','');
                    if(!String.isNotBlank(ans.valueBrandId) && escapedString.equals(brand.name)){
                        ans.valueBrandId = brand.id;
                    }
                    ans.value = escapedString;
                }
            }
            return JSON.serialize(answers);
    }
    
    // class to throw the custom exception
    public class CustomException extends Exception{}
    // class used to prepare JSON in case of failure  
    public class Message{
        public String message{get;set;}
        public Boolean  isError{get;set;}
        public String[] fields{get;set;}
    }
    // Answers JSON is processed using this wrapper class
    global class Answer{
        public String value{get;set;}
        public String valueBrandId{get;set;}
        public String score{get;set;}
        public String goalScore{get;set;}
    }
}
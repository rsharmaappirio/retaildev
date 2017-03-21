/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_IdentityController
 * Description: Controller class of lighting component ARM_Survey_Question_Detail
 *              TODO : update Class description and add static Constants variables
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
public class ARM_Survey_Question_Detail_Controller {
    //Public static final String ENDPOINT = 'http://api.cloudinary.com/v1_1/';
    
    @auraEnabled
    public static String getQuestions(String surveyId){
        // TODO : Update method Description
        //Query the survey and its related all questions
        List<ARM_Survey__c> surveyList =  [Select Id, Name,Account__c, First_Question__c, (Select Id, Name, Answer_Options__c, Conditional_Answer__c, 
                                           Conditional_Answer_Brand__c, Survey__c, Label_for_Add_l_Comments__c, NEXT_Question__c, Parent_Question__c, 
                                           Question_Text__c, Question_Type__c, CreatedDate, CreatedBy.Alias, LastModifiedBy.Alias,LastModifiedDate, 
                                           Include_Photos__c, Require_Photos__c, Include_None_of_the_Above__c, Question_Number__c, Max_Score__c, Goal_Name__c,
                                           Goal_Type__c, Goal_Brand__r.name, Goal_Brand__r.Level__c, Max_Goal_Score__c, Is_Goal__c 
                                           From ARM_Question__r order by createddate) 
                                           From ARM_Survey__c 
                                           Where Id = :surveyId ];
        
        Map<String,Map<String,QuestionWrapper>> dependentQuestionsMap = new Map<String,Map<String,QuestionWrapper>>();
        Map<String,QuestionWrapper> resultMap = new Map<String,QuestionWrapper>();
        
        if(surveyList != null && surveyList.size()>0){
            //go through all the questions and prepare wrapper list
            for(ARM_Question__c question : surveyList[0].ARM_Question__r){
                //if question is a condition question, and also first question then put it in map with its parent id
                /*
                * for example lets say question 1 have 2 conditional question . on 'YES' --> 1.1,1.2 , on  'NO' -->1.3
                * then dependentQuestionsMap will be a map like this
                *     1  --> 'YES' --> 1.1
                * 		 |
                * 		  --> 'NO'  --> 1.3
                * it will contain only the first condition question for condition as we can get its next question id from its field. so it wont contain 1.2 anywhere.
                * */
                if(question.Parent_Question__c != null && question.Conditional_Answer__c != null && question.Conditional_Answer__c != ''){
                    Map<String,QuestionWrapper>  dependentsOnThisParent = dependentQuestionsMap.get(question.Parent_Question__c);
                    if(dependentsOnThisParent == null){
                        dependentsOnThisParent = new Map<String,QuestionWrapper>();
                        dependentQuestionsMap.put(question.Parent_Question__c,dependentsOnThisParent);
                    }
                    dependentsOnThisParent.put(question.Conditional_Answer__c,new QuestionWrapper(question));
                }
                resultMap.put(question.Id,new QuestionWrapper(question));
            }
        }
        //prepare the result wrapper,serialize it  and return it
        resultWrapper result = new resultWrapper();
        result.surveyName = surveyList[0].Name;
        result.surveyId = surveyList[0].Id;
        result.accountId = surveyList[0].Account__c;
        result.firstQuestionId = surveyList[0].First_Question__c;
        result.parentQuestions = resultMap;
        result.dependentQuestionsMap = dependentQuestionsMap;
        return JSON.serialize(result);
    }
    
    /*
* Wrapper class to wrap Survey with Questions
* firstQuestionId : provide the first question to load of the survey
* parentQuestions : provides all the question related to that survey.
* dependentQuestionsMap : provide a map for conditional first question for a question
*/
    public class ResultWrapper{
        @auraEnabled
        public String surveyName{get;set;}
        @auraEnabled
        public String surveyId{get;set;}
        @auraEnabled
        public String accountId{get;set;}
        @auraEnabled
        public String firstQuestionId{get;set;}
        @auraEnabled
        public Map<String,QuestionWrapper> parentQuestions{get;set;}
        @auraEnabled
        public Map<String,Map<String,QuestionWrapper>> dependentQuestionsMap{get;set;}
    }
    
    /*
* Wrapper class to wrap the questions with a list to hold photos, id of its previous question and a List to hold its options with answers
*/
    public class QuestionWrapper{
        @auraEnabled
        Public ARM_Question__c question{get;set;}
        @auraEnabled
        Public List<String> photos{get;set;}
        @auraEnabled
        public List<String> imageURLs{get;set;}
        @auraEnabled
        Public List<Answer_Options_Wrapper> answer_options{get;set;}
        @auraEnabled
        public String prevQuestionId{get;set;}
        @auraEnabled
        public String nextQuestionId{get;set;}
        @auraEnabled
        public String answer{get;set;}
        @auraEnabled
        public Boolean isDone{get;set;}
        public QuestionWrapper(ARM_Question__c question){
            answer_options = new List<Answer_Options_Wrapper>();
            photos = new List<String>();
            imageURLs = new List<String>();
            isDone = false;
            this.question = question;
            List<Answer> answers = (List<Answer>)JSON.deserialize(question.Answer_Options__c, List<Answer>.class);
            for(Answer ans : answers){
                Answer_Options_Wrapper ansWrapper = new Answer_Options_Wrapper(ans.value,false); 
                answer_options.add(ansWrapper);
            } 
            if(question.Include_None_of_the_Above__c){
                answer_options.add(new Answer_Options_Wrapper('None of the Above',false));
            }
        }
    }
    // will contain checbox and radio value with its true or false values
    public class Answer_Options_Wrapper{
        @auraEnabled
        public String option{get;set;}
        @auraEnabled
        public Boolean value{get;set;}
        
        public Answer_Options_Wrapper(string option,Boolean value){
            this.option = option;
            this.value = value;
        }
    }
    
    //Answer options are already a JSON , so class to parse them.
    public  class Answer{
        public String value{get;set;}
        public String valueBrandId{get;set;}
        public String score{get;set;}
        public String goalScore{get;set;}
    }
    
    /* 
     * method to save the results
     * */
    @auraEnabled
    public static String SaveSurveyResult(String answers){
        // TODO : Update method description and try to break it if possible
        Savepoint sp = Database.setSavepoint();
        try{
            if(answers != null && answers.trim() != ''){
                ResultWrapper answersToWrapper = (ResultWrapper) JSON.DeSerialize(answers,ResultWrapper.class);
                if(answersToWrapper != null  && answersToWrapper.parentQuestions != null ){
                    ARM_Survey_Submission__c surveySubmission = new ARM_Survey_Submission__c();
                    surveySubmission.Survey__c = answersToWrapper.surveyId;
                    insert surveySubmission;
                    
                    Map<String,QuestionWrapper> questions = (Map<String,QuestionWrapper>) answersToWrapper.parentQuestions;
                    List<ARM_Survey_Result__c>  surveyResultsList = new List<ARM_Survey_Result__c>();
                    List<String> images = new List<String>();
                    List<PhotoWithParentWrapper> photoWrapper = new List<PhotoWithParentWrapper>();
                    for(String questionId : questions.keySet()){
                        if(questions.get(questionId).isDone){
                            //create new survey result record
                            ARM_Question__c questionDetail = (questions.get(questionId)).question;
                            String answer = questions.get(questionId).answer;
                            ARM_Survey_Result__c surveyResult = new ARM_Survey_Result__c();
                            surveyResult.Question__c = questionDetail.Id;
                            surveyResult.Survey_Date__c = System.today();
                            surveyResult.Question_Text__c = questionDetail.Question_Text__c;
                            surveyResult.Question_Type__c = questionDetail.Question_Type__c;
                            surveyResult.survey__c    = answersToWrapper.surveyId;
                            surveyResult.Account__c    = answersToWrapper.accountId;
                            surveyResult.Survey_Submission__c = surveySubmission.Id;
                            //if question is of count or price type, save to Answer_value__c
                            if(questionDetail.Question_Type__c =='Count' || questionDetail.Question_Type__c =='Price'){
                                surveyResult.Answer_value__c = Integer.valueOf(answer);
                            }
                            //if question is of text type , save to Answer_Text__c
                            else if(questionDetail.Question_Type__c =='Text'){
                                surveyResult.Answer_Text__c = answer;
                            }
                            //other save the selected options ';' seperated
                            else{
                                String selectedAnswerString = '';
                                String possibleAnswers = '';
                                for(Answer_Options_Wrapper option : questions.get(questionId).answer_options){
                                    possibleAnswers += option.option+';';
                                    if(option.value){
                                        selectedAnswerString += option.option +';';
                                    }
                                }
                                surveyResult.Answer_Text__c = selectedAnswerString;
                            }
                            //if question requires photo, JOSN will be having Cloudinary photo url
                            //create new DD_Survey_Result_Photos__c for survey result for all photos
                            if(questionDetail.Require_Photos__c || questionDetail.Include_Photos__c){
                                for(String imgURL : (questions.get(questionId)).imageURLs){
                                    ARM_Survey_Result_Photos__c photo = new ARM_Survey_Result_Photos__c();
                                    photo.Photo_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + imgURL;
                                    PhotoWithParentWrapper photoWithParent = new PhotoWithParentWrapper();
                                    photoWithParent.photo = photo;
                                    photoWithParent.surveyResult = surveyResult;
                                    photoWrapper.add(photoWithParent);
                                }
                            }   
                            surveyResultsList.add(surveyResult);
                        }
                    }
                    //insert survey results and photos
                    if(surveyResultsList.size()>0){
                        insert surveyResultsList;
                    }
                    List<ARM_Survey_Result_Photos__c> photos = new List<ARM_Survey_Result_Photos__c>();
                    if(photoWrapper.size()>0){
                        for(PhotoWithParentWrapper photoWithParent : photoWrapper){
                            photoWithParent.photo.Survey_Result__c = photoWithParent.surveyResult.Id;
                            photos.add(photoWithParent.photo);
                        }
                    } 
                    if(photos.size()>0)
                        insert photos;
                }
            }
            return 'SUCCESS';
        }
        catch(Exception e){
            Database.rollback( sp );
            return e.getMessage();
        }
        
    }
    
    public class PhotoWithParentWrapper{
        public ARM_Survey_Result_Photos__c photo{get;set;}
        public ARM_Survey_Result__c surveyResult{get;set;}
    }
    
    
    /*@auraEnabled
    public static String uploadImages(String pictureString,String attachId,Id parentId){
        try{
            //specify the cloud name,apikey and apisecret (Stored in custom labels, you can change as of your account)
            String cloudName=Label.ARM_CloudinaryCloudName;
            String apiKey=Label.ARM_CloudinaryApiKey;
            String apiSecret=Label.ARM_CloudinaryApiSecret;
            String existingPhoto = '';
            if(attachId != ''){
                Attachment a = [SELECT Id, Body FROM Attachment WHERE Id = :attachId ];
        		existingPhoto = EncodingUtil.base64Encode(a.Body);
                //delete a;
        	}
            
            pictureString = existingPhoto+EncodingUtil.urlDecode(pictureString, 'UTF-8');
            /* upload image to cloudinary */
            // Instantiate a new http object
           // Http h = new Http();
            // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
           /* HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT+cloudname+'/image/upload');
            req.setMethod('POST');
            System.debug(existingPhoto.length());
            String timeStmp=String.valueOf(System.NOW().getTime() / 1000);
            String myData = 'public_id='+parentId+'-'+timeStmp+'&timestamp='+timeStmp+apiSecret;
            Blob hash = Crypto.generateDigest('SHA1',Blob.valueOf(myData));
            String hexDigest = EncodingUtil.convertToHex(hash);
            String fileString = 'data:image/png;base64,';
            pictureString= EncodingUtil.urlEncode(pictureString, 'UTF-8');
            String finalBodyString ='public_id='+parentId+'-'+timeStmp+'&api_key='+apiKey+'&timestamp='+EncodingUtil.urlEncode(timeStmp, 'UTF-8')+'&signature='+EncodingUtil.urlEncode(hexDigest, 'UTF-8')+'&file='+EncodingUtil.urlEncode(fileString, 'UTF-8')+pictureString;
            req.setBody(finalBodyString);
            HttpResponse res = h.send(req);
            //get the URL from response and return it.
            CloudinaryResultWrapper responseWrapper = (CloudinaryResultWrapper) JSON.deSerialize(res.getBody(),CloudinaryResultWrapper.class);
            return responseWrapper.url;
        }
        catch(Exception e){
            return e.getMessage();
        }
    }*/
    
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;
 
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
        
        return a.Id;
    }
    
    @AuraEnabled
    public static String saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, Boolean isLastChunk) { 
        System.debug(base64Data.length());
        //if(!isLastChunk){
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
        //}//else{
          //  fileId = uploadImages(base64Data,fileId,parentId);
        //}
        return fileId;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
     	String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;
    }
    
    /*public class ImageWrapper{
        public String imgString{get;set;}
        public String queId{get;set;}
    }*/
    
    /*public class CloudinaryResultWrapper{
        public String url{get;set;}
        public String secure_url{get;set;}
        public String public_id{get;set;}
    }*/
}
/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_Question_Detail_ControllerTest
 * Description: Includes all test methods to perform unit test over ARM_TemplateController class.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/

@isTest
private class ARM_Survey_Question_DetailControllerTest{
    private final static string PROFILE_SYS_ADMIN = 'System Administrator';
    private static User sysAdmin;
    private static final string SURVEY_TYPE_NON_SCAN = 'Non Scan';

    
 private static testmethod void testSurveyQuestionController(){
       
       sysAdmin= getSysAdminUser();
       System.runAs(sysAdmin){
        ARM_Survey__c rF = [select id from ARM_Survey__c LIMIT 1];  
         test.startTest();
            
            String jsonQuestions = ARM_Survey_Question_Detail_Controller.getQuestions(rF.id);
            ARM_Survey_Question_Detail_Controller.ResultWrapper answersToWrapper = (ARM_Survey_Question_Detail_Controller.ResultWrapper) JSON.DeSerialize(jsonQuestions,ARM_Survey_Question_Detail_Controller.ResultWrapper.class);
            Map<String,ARM_Survey_Question_Detail_Controller.QuestionWrapper> questions = (Map<String,ARM_Survey_Question_Detail_Controller.QuestionWrapper>) answersToWrapper.parentQuestions;
                    for(String questionId : questions.keySet()){
                        questions.get(questionId).isDone = true;
                        questions.get(questionId).answer = '1';
                        if(questions.get(questionId).question.Include_Photos__c == true){
                            list<string> imgURLS = new list<string>();
                            imgURLS.add('/test');
                            questions.get(questionId).imageURLs = imgURLS ;
                        }
                    }
            String jsonQuestionsSerialize = JSON.serialize(answersToWrapper);
            system.assertEquals('SUCCESS',ARM_Survey_Question_Detail_Controller.SaveSurveyResult(jsonQuestionsSerialize) ,'Error occured while saving the file');
            Id parentId = (new list<string>(questions.keySet()) )[0];
            Id fileId = ARM_Survey_Question_Detail_Controller.saveTheChunk(parentId, 'test','test','jpeg', '', true);
            system.assertEquals(fileId, ARM_Survey_Question_Detail_Controller.saveTheChunk(parentId, 'test','test','jpeg',fileId, true) ,'Incorrect file id');
            system.assert(ARM_Survey_Question_Detail_Controller.saveTheFile(parentId,'test','test','jpeg')!=null ,'Attachment can not be null');
         test.stopTest();
         

         
       }
 }
 

  private static User getSysAdminUser(){
      User admin=[Select Id from user where firstName='test user' AND lastname='Testing'];
      return admin;
  }
 
    @testSetup
    private static void createTestData(){
        User testUser = ARM_Retail_Test_Utils.insertUser(PROFILE_SYS_ADMIN, false);
        testUser.ARM_physicalDeliveryOfficeName__c = 'Joes Coffee' ;
        insert testUser;
        
        Account a = ARM_Retail_Test_Utils.insertAccount(true);
        ARM_Survey__c rF = ARM_Retail_Test_Utils.insertSurvey('Mini Survey', system.today(), system.today(), SURVEY_TYPE_NON_SCAN , a.id, true);
        ARM_Question__c parentQuestion = ARM_Retail_Test_Utils.insertSurveyQuestion(rF.Id , 'Count' , false);
        parentQuestion.Answer_Options__c = '[{"valueBrandId":"","value":"Yes","score":"0","goalScore":"0"},{"valueBrandId":"","value":"No","score":"0","goalScore":"0"}]' ;
        parentQuestion.Question_Text__c = 'How many sessions were held this week?';
        insert parentQuestion;   
        
        ARM_Question__c question = ARM_Retail_Test_Utils.insertSurveyQuestion(rF.Id , 'Text' , false);
        question.Answer_Options__c = '[{"valueBrandId":"","value":"Yes","score":"0","goalScore":"0"},{"valueBrandId":"","value":"No","score":"0","goalScore":"0"}]' ;
        question.Question_Text__c = 'Satisfied with trainer?';
        question.Parent_Question__c = parentQuestion.id;
        question.Conditional_Answer__c = 'Yes';
        question.Include_None_of_the_Above__c = true;
        question.Include_Photos__c = true;
        insert question;      

        ARM_Question__c selectQuestion = ARM_Retail_Test_Utils.insertSurveyQuestion(rF.Id , 'Select' , false);
        selectQuestion.Answer_Options__c = '[{"valueBrandId":"","value":"Yes","score":"0","goalScore":"0"},{"valueBrandId":"","value":"No","score":"0","goalScore":"0"}]' ;
        selectQuestion.Question_Text__c = 'Want to join?';
        selectQuestion.Parent_Question__c = parentQuestion.id;
        selectQuestion.Include_None_of_the_Above__c = true;
        insert selectQuestion;     

        

    }
    

}
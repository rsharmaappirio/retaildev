/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_SurveyEditorControllerTest
 * Description: Includes all test methods to perform unit test over ARM_SurveyEditorController class.
 * Created Date: Mar 08, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/

@isTest
private class ARM_SurveyEditorControllerTest{
    private final static string PROFILE_SYS_ADMIN = 'System Administrator';
    private static User sysAdmin;
    private static final string SURVEY_TYPE_NON_SCAN = 'Non Scan';

    
 private static testmethod void testSurveyQuestionController(){
       
       sysAdmin= getSysAdminUser();
       System.runAs(sysAdmin){
        ARM_Survey__c rF = [select id from ARM_Survey__c LIMIT 1];  
         test.startTest();
            ARM_SurveyEditorController aSE = new ARM_SurveyEditorController(new ApexPages.StandardController(rF));
            system.assert(ARM_SurveyEditorController.getSurvey(rF.id)!=null , 'No survey result is retuned');
            ARM_SurveyEditorController.SurveyQuestion innerQuestionClass= new ARM_SurveyEditorController.SurveyQuestion();
            
            ARM_Question__c quesId = [SELECT Id,
                                            Survey__c,
                                            NEXT_Question__c,
                                            Parent_Question__c,
                                            Name,
                                            Conditional_Answer__c,
                                            Conditional_Answer_Brand__c,
                                            Question_Text__c,
                                            Question_Type__c,
                                            Answer_Options__c,
                                            Label_for_Add_l_Comments__c,
                                            CreatedBy.Alias,CreatedDate ,
                                            LastModifiedDate,
                                            Question_Number__c,
                                            Include_None_of_the_Above__c,
                                            Include_Photos__c,
                                            Require_Photos__c,
                                            LastModifiedBy.Alias,
                                            Max_Score__c,
                                            Max_Goal_Score__c,
                                            Is_Goal__c,
                                            Goal_Name__c,
                                            Goal_Type__c,
                                            Goal_Brand__r.level__c,
                                            Goal_Brand__r.id
                                    FROM ARM_Question__c where Parent_Question__c!=null 
                                    //AND  Is_Goal__c = true
                                    LIMIT 1];
            
            ARM_SurveyEditorController.SurveyQuestion innerQuestionClassWithQues= new ARM_SurveyEditorController.SurveyQuestion(quesId);
            ARM_Question__c question = innerQuestionClassWithQues.getSObject();
            system.assert(ARM_SurveyEditorController.upsertQuestion(innerQuestionClassWithQues)!=null , 'Question could not get updated successfully');
            ARM_SurveyEditorController.setFirstQuestion(quesId.id);
            //catching exception in case of wrong qiestion Id
            try{
                ARM_SurveyEditorController.setFirstQuestion('invalidId');
            }catch(exception e){
                String error = e.getMessage();
                system.assert(true == error.contains('Unexpected error: Question not found') , e.getMessage() );
            }
            ARM_SurveyEditorController.removeQuestion(quesId.id);
            //catching exception for In-valid question
            try{
                ARM_SurveyEditorController.upsertQuestion(null);
            }catch(exception e){
                String error = e.getMessage();
                system.assert(true == error.contains('Need a valid question object') , e.getMessage() );
            }
            
            
            ARM_SurveyEditorController.getBrands('NHtest' , 'NH' , '1');
            ARM_SurveyEditorController.searchBrands('NHtest' , '11' );
            aSE.getGoalTypes();
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
        parentQuestion.Is_Goal__c = true;
        insert parentQuestion;  
        
        rF.First_Question__c = parentQuestion.id;
        update rF;
        
        ARM_Question__c question = ARM_Retail_Test_Utils.insertSurveyQuestion(rF.Id , 'Text' , false);
        question.Answer_Options__c = '[{"valueBrandId":"","value":"Yes","score":"0","goalScore":"0"},{"valueBrandId":"","value":"No","score":"0","goalScore":"0"}]' ;
        question.Question_Text__c = 'Satisfied with trainer?';
        question.Parent_Question__c = parentQuestion.id;
        question.Conditional_Answer__c = 'Yes';
        //question.Is_Goal__c = true;
        question.Include_None_of_the_Above__c = true;
        question.Include_Photos__c = true;
        insert question;
        
        parentQuestion.NEXT_Question__c = question.id;
        update parentQuestion;

        ARM_Question__c selectQuestion = ARM_Retail_Test_Utils.insertSurveyQuestion(rF.Id , 'Select' , false);
        selectQuestion.Answer_Options__c = '[{"valueBrandId":"","value":"Yes","score":"0","goalScore":"0"},{"valueBrandId":"","value":"No","score":"0","goalScore":"0"}]' ;
        selectQuestion.Question_Text__c = 'Want to join?';
        selectQuestion.Parent_Question__c = parentQuestion.id;
        //selectQuestion.Is_Goal__c = true;
        selectQuestion.Include_None_of_the_Above__c = true;
        insert selectQuestion;     
        
        
        ARM_Brand__c test_Brand = ARM_Retail_Test_Utils.insertBrand('NHtest' , false);
        test_Brand.Hierarchy_Code__c = '';
        insert test_Brand;

        

    }
    

}
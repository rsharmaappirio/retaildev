/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_List_ControllerTest
 * Description: Includes all test methods to perform unit test over ARM_TemplateController class.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/

@isTest
private class ARM_Survey_List_ControllerTest{
    private final static string PROFILE_SYS_ADMIN = 'System Administrator';
    private static final string SURVEY_TYPE_NON_SCAN = 'Non Scan';
    private static User sysAdmin;

 private static testmethod void testTemplateController(){
       
       sysAdmin= getSysAdminUser();
       System.runAs(sysAdmin){
           
         test.startTest();
           List<Account> accountList = ARM_Survey_List_Controller.getAccounts();
           system.assertEquals(accountList.size() , 1 , 'Number of accounts retrieved is not as expected.' );
           List<ARM_Survey__c> getSurveys = ARM_Survey_List_Controller.getSurveys(accountList[0].id);
           system.assertEquals(getSurveys[0].name , 'Mini Survey' , 'The assesement retrieved is not as expected.' );
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
        ARM_Retail_Test_Utils.insertSurvey('Mini Survey', system.today(), system.today(), SURVEY_TYPE_NON_SCAN , a.id, true);
    }
  
 
}
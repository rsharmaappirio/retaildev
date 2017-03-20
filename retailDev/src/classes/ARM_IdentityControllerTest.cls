/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_IdentityControllerTest
 * Description: Includes all test methods to perform unit test over ARM_IdentityController class.
 * Created Date: Mar 03, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/

@isTest
private class ARM_IdentityControllerTest{
    private final static string PROFILE_SYS_ADMIN = 'System Administrator';
    private final static string PROFILE_PORTAL = 'Portal Profile';
    private static final string DESIGNATED_CONTACT = 'Designated Contact';
    private static User sysAdmin;
    private static ARM_Navigation_Item__c test_NavigationItem;
    private static ARM_Sub_Navigation_Item__c test_SubNavigationItem;
    
    
 private static testmethod void testIdentityController(){
       
       sysAdmin= getSysAdminUser();
       System.runAs(sysAdmin){
           
         test.startTest();
             ARM_IdentityController.getCurrentUser();
             system.assert(ARM_IdentityController.getNumberRestaurants() == 0, 'Number of Accounts where current user is a Designated Contact should be 0 as the logged in user is System Admin ');
             system.assert(ARM_IdentityController.getFranchiseInfo().Franchise_title__c == 'Stores' , 'Franchise title is not as expected');
         test.stopTest();

       }
 }
    

  private static User getSysAdminUser(){
      User admin=[Select Id from user where firstName='test user' AND lastname='Testing'];
      return admin;
  }
  
    @testSetup
    private static void createTestData(){
        Account a = ARM_Retail_Test_Utils.insertAccount(true);
        Contact c = ARM_Retail_Test_Utils.insertContact(a.id , true);
        
        User testUser = ARM_Retail_Test_Utils.insertUser(PROFILE_SYS_ADMIN, false);
        testUser.ARM_physicalDeliveryOfficeName__c = 'Joes Coffee' ;
        insert testUser;
        
        ARM_Retail_Function__c test_RetailFunction = ARM_Retail_Test_Utils.insertRetailFunction('Joes Coffee' , false);
        test_RetailFunction.Franchise_title__c = 'Stores';
        insert test_RetailFunction ;
    }
    

}
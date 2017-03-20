/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_TemplateControllerTest
 * Description: Includes all test methods to perform unit test over ARM_TemplateController class.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/

@isTest
private class ARM_TemplateControllerTest{
    private final static string PROFILE_SYS_ADMIN = 'System Administrator';
    private static final string DESIGNATED_CONTACT = 'Designated Contact';
    private static User sysAdmin;

 private static testmethod void testTemplateController(){
       
       sysAdmin= getSysAdminUser();
       System.runAs(sysAdmin){
           
         test.startTest();
            User u = ARM_TemplateController.getCurrentUser();
            system.assertEquals(sysAdmin.id, u.id, 'System admin user is expected. Received something else.');

            list<ARM_Navigation_Item__c> lstNavigationItems = ARM_TemplateController.getNavigationList();
            system.assert(true ,lstNavigationItems.size()>0);
            system.assertEquals(lstNavigationItems[0].Attachments.size() , 1 , 'Atleast one attachmnet should be found');

            list<ARM_Sub_Navigation_Item__c> lstSubNavs =  ARM_TemplateController.getSubNavigationList(lstNavigationItems[0].id);
            system.assertEquals(lstSubNavs[0].Attachments.size() , 1 , 'Atleast one attachmnet should be found');

            list<ARM_Navigation_Item__c> navItemList = ARM_TemplateController.getCurrentNavigationItemId('/s/dashboard');
            system.assertEquals(navItemList[0].id, lstNavigationItems[0].id , 'Incorrect navigation item is retrieved');
            
            ARM_Retail_Function__c rF = ARM_TemplateController.getBrandAttributes();
            rF = [select name from ARM_Retail_Function__c LIMIT 1] ;
            system.assertEquals(rF.name, 'Joes Coffee' , 'Incorrect retail function is retrieved');

            system.assert(ARM_TemplateController.getNumberRestaurants() == 0, 'Number of Accounts where current user is a Designated Contact should be 0 as the logged in user is System Admin ');
            system.assert(ARM_TemplateController.getBrandImageURL() != '/s.gif', 'Default logo URL is not as expected');
            system.assert(ARM_TemplateController.getBrandMobileImageURL() != '/s.gif', 'Default mobile logo URL is not as expected');
            system.assert(ARM_TemplateController.getBannerImageURL() != '/s.gif', 'Default banner URL is not as expected' );
            system.assert(ARM_TemplateController.getBannerMobileLogoURL() != '/s.gif', 'Default mobile banner URL is not as expected' );

            
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
        
        ARM_Navigation_Item__c test_NavigationItem = ARM_Retail_Test_Utils.insertNavigationItemn(test_RetailFunction, 'HOME', '/s/dashboard', true);
        ARM_Sub_Navigation_Item__c test_SubNavigationItem = ARM_Retail_Test_Utils.insertSubNavigationItemn(test_NavigationItem, 'Advocacy', '/s/advocacy-center', true);
        
        list<ARM_Brand_Image__c> lstBrandImages = new list<ARM_Brand_Image__c>();
        lstBrandImages.add(ARM_Retail_Test_Utils.insertAccountContactRole(test_RetailFunction, 'Logo', false));
        lstBrandImages.add(ARM_Retail_Test_Utils.insertAccountContactRole(test_RetailFunction, 'Mobile Logo', false));
        lstBrandImages.add(ARM_Retail_Test_Utils.insertAccountContactRole(test_RetailFunction, 'Banner', false));
        lstBrandImages.add(ARM_Retail_Test_Utils.insertAccountContactRole(test_RetailFunction, 'Mobile Banner Logo', false));
        insert lstBrandImages;
        
        AccountContactRole accountRole = ARM_Retail_Test_Utils.insertAccountContactRole(a.id, c.id, false);
        accountRole.role = DESIGNATED_CONTACT;
        insert accountRole;
        
        list<Attachment> lstBrandImagesAttachment = new  list<Attachment>();
        for(ARM_Brand_Image__c brandImage : lstBrandImages){
            lstBrandImagesAttachment.add( ARM_Retail_Test_Utils.insertAttachment(brandImage.id,brandImage.Image_Type__c , false ) );
        }
        lstBrandImagesAttachment.add( ARM_Retail_Test_Utils.insertAttachment(test_NavigationItem.id,'Navigation attachment' , false ) );
        lstBrandImagesAttachment.add( ARM_Retail_Test_Utils.insertAttachment(test_SubNavigationItem.id,'Sub-Navigation attachment' , false ) );
        insert lstBrandImagesAttachment;
    }
    

}
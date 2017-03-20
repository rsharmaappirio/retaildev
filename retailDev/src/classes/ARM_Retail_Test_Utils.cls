/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Retail_Test_Utils
 * Description: Utility class for Test data
 * Created Date: Mar 03, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
@isTest
public with sharing class ARM_Retail_Test_Utils /* TODO : Rename class to ARM_Test_Utils */ {
   
   
  //insert Account
  public static Account insertAccount(Boolean isInsert) {
    Account defaultAccount = new Account();
    defaultAccount.Name = 'Test Account'+randomNumber();
    if(isInsert) {
      insert(defaultAccount);
    }
    return defaultAccount;
  }
   
  //insert Contact
  public static Contact insertContact(Id accountId, Boolean isInsert){
    Contact contact = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                  FirstName='firstname'+randomNumber(),Salutation='Mr.',LastName='test'+randomNumber(),
                                  email='test@'+randomNumber()+'test.com' , AccountId = accountId);
    if(isInsert) {                                  
      insert(contact);
    }
    return contact;
  }
  
  //insert attachments
  public static Attachment insertAttachment(Id parentId, String name, Boolean isInsert){
        Attachment attach=new Attachment();   	
    	attach.Name ='Unit Test Attachment';
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	attach.body = bodyBlob;
        attach.parentId = parentId;

    if(isInsert) {                                  
      insert(attach);
    }
    return attach;
  }
  
  //insert Brand Image
  public static ARM_Brand_Image__c insertAccountContactRole(ARM_Retail_Function__c test_RetailFunction, String imageType, Boolean isInsert){
    ARM_Brand_Image__c test_BrandImage = new ARM_Brand_Image__c (Image_Type__c = imageType,
                                                                 Retail_Function__c = test_RetailFunction.Id,
                                                                 Is_Active__c = true);

    if(isInsert) {                                  
      insert(test_BrandImage);
    }
    return test_BrandImage;
  }
  
  
  //insert AccountContactRole
  public static AccountContactRole insertAccountContactRole(Id accountId, Id contactId, Boolean isInsert){
    AccountContactRole test_AccountContactRole = new AccountContactRole (AccountId = accountId,
                                                                         ContactId = contactId);
    if(isInsert) {                                  
      insert(test_AccountContactRole);
    }
    return test_AccountContactRole;
  }
   
    
  //insert Sub Navigation Item
  public static ARM_Sub_Navigation_Item__c insertSubNavigationItemn(ARM_Navigation_Item__c test_NavigationItem, String displayName, String pageURL, Boolean isInsert){
      
    //ARM_Navigation_Item__c test_NavigationItem = insertNavigationItemn('Advocacy' , '/s/advocacy-center' , true);
    ARM_Sub_Navigation_Item__c test_SubNavigationItem = new ARM_Sub_Navigation_Item__c (Navigation_Item__c = test_NavigationItem.Id,
                                                                                        Display_Name__c = displayName,
                                                                                        Page_URL__c = pageURL,
                                                                                        Is_Active__c = true);
    if(isInsert) {                                  
      insert(test_SubNavigationItem);
    }
    return test_SubNavigationItem;
  }
    
    
  //insert Navigation Item
  public static ARM_Navigation_Item__c insertNavigationItemn(ARM_Retail_Function__c test_RetailFunction, String displayName, String pageURL, Boolean isInsert){
      
    //ARM_Retail_Function__c test_RetailFunction = insertRetailFunction('Joes Coffee' , true);
    ARM_Navigation_Item__c test_NavigationItem = new ARM_Navigation_Item__c ( Retail_Function__c = test_RetailFunction.Id,
                                                                              Display_Name__c = displayName,
                                                                              Page_URL__c = pageURL,
                                                                              Is_Active__c = true);    
    if(isInsert) {                                  
      insert(test_NavigationItem);
    }
    return test_NavigationItem;
  }
    
    
  //insert Retail function
  public static ARM_Retail_Function__c insertRetailFunction(String name, Boolean isInsert){
    ARM_Retail_Function__c test_RetailFunction = new ARM_Retail_Function__c (Name = name);
    
    if(isInsert) {                                  
      insert(test_RetailFunction);
    }
    return test_RetailFunction;
  }
    
  //insert User
  public static User insertUser(String profileName, Boolean isInsert){

    User testUser = new User();
    Profile p = [SELECT id from profile where name =: profileName ];

    testUser = new User(alias = 'testUser', email='standarduser' + randomNumber()  + '@testorg.com',
                             emailencodingkey='UTF-8', firstName='test user', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                             username='teststandarduser' + randomNumber() + '@testorg.com', IsActive=true,
                             CompanyName = 'test Company');
    
    if(isInsert) {                                  
      insert(testUser);
    }
    return testUser;
  }
  
  //insert Survey
  public static ARM_Survey__c insertSurvey(String name, Date startDate, Date endDate, String surveyType, Id accId, Boolean isInsert){

    ARM_Survey__c test_Assessment = new ARM_Survey__c (Name = name,
                                                       Active__c = true,
                                                       Start_Date__c = startDate,
                                                       End_Date__c = endDate,
                                                       Survey_Type_Editable__c= surveyType,
                                                       TDLinx_Acct_Level_E__c = accId);
    
    if(isInsert) {                                  
      insert(test_Assessment);
    }
    return test_Assessment;
  }
  
  //insert Survey Question
  public static ARM_Question__c insertSurveyQuestion(Id surveyId, String questionType, Boolean isInsert){

    ARM_Question__c test_SurveyQuestion = new ARM_Question__c (Survey__c = surveyId,
                                                               Question_Type__c = questionType );

    
    if(isInsert) {                                  
      insert(test_SurveyQuestion);
    }
    return test_SurveyQuestion;
  }
  
  
  //insert ARM Brand
  public static ARM_Brand__c insertBrand(String name, Boolean isInsert){
    ARM_Brand__c test_Brand = new ARM_Brand__c (Name = name);

    
    if(isInsert) {                                  
      insert(test_Brand);
    }
    return test_Brand;
  }
  
  
  // util method to get random number
  public static double randomNumber() {
    return Math.random();
  }
    
    

}
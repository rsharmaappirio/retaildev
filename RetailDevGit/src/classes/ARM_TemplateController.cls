/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_TemplateController
 * Description: Controller class of lighting component ARM_Template
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
public without sharing class ARM_TemplateController {
    private static final string DESIGNATED_CONTACT = 'Designated Contact';
    @AuraEnabled
    public static User getCurrentUser() {
        User u = [SELECT id, FirstName, LastName, Name, FullPhotoUrl  
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        return u;
    }
   
    @AuraEnabled 
   public static List<ARM_Navigation_Item__c> getNavigationList() {
        String officeLocation = getOfficeLocation();
        return [SELECT Id, Display_Name__c, 
                  Page_URL__c, Order__c, 
                (SELECT Id 
                 FROM Attachments order by CreatedDate desc LIMIT 1)
                  FROM ARM_Navigation_Item__c 
                  WHERE Retail_Function__r.Name = :officeLocation
                  AND Is_Active__c = true
                  ORDER BY ORDER__c ASC];
        
   }
    
   @AuraEnabled 
   public static List<ARM_Sub_Navigation_Item__c> getSubNavigationList(String navigationId) {
       System.debug('navigationId::::' + navigationId);
       if(!String.isBlank(navigationId)){
          return [SELECT Id, Display_Name__c, 
                  Page_URL__c, Order__c, 
                   (SELECT Id 
                 FROM Attachments order by CreatedDate desc LIMIT 1) 
                  FROM ARM_Sub_Navigation_Item__c 
                  WHERE Navigation_Item__c = :navigationId
                  AND Is_Active__c = true
                  ORDER BY ORDER__c ASC];
       }else{
          return new List<ARM_Sub_Navigation_Item__c>();  
       }
   }  
   
   @AuraEnabled 
   public static List<ARM_Navigation_Item__c> getCurrentNavigationItemId(String pageURL) {
       
       String officeLocation = getOfficeLocation();
       List<ARM_Navigation_Item__c> lst = [SELECT Id, Display_Name__c  
                  FROM ARM_Navigation_Item__c 
                  WHERE Page_URL__c = :pageURL
                  AND Retail_Function__r.Name = : officeLocation];
       
        
       return lst;
   }
    
    @AuraEnabled
    public static Integer getNumberRestaurants() {
        /*  Retrieve the number of Accounts where current user is a Designated Contact contact role */
        User u = [SELECT ContactId 
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        
        List<AccountContactRole> AccountContactRoles = [ 
            SELECT AccountId 
            FROM AccountContactRole
            WHERE ContactId = :u.ContactId
            AND Role = :DESIGNATED_CONTACT
        ];
        return AccountContactRoles.size();
    }
    
    @AuraEnabled
    public static String getOfficeLocation() {
        /*  Retrieve the Account where current user is a Designated Contact contact role */
        User u = [ SELECT ARM_physicalDeliveryOfficeName__c 
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        return u.ARM_physicalDeliveryOfficeName__c ;
    }
    
    @AuraEnabled
    public static ARM_Retail_Function__c getBrandAttributes() {
        String officeLocation = getOfficeLocation();
        
        ARM_Retail_Function__c retailFunction = new ARM_Retail_Function__c( SubNavigationBackgroundColor__c = '',
                                                 NavigationBackgroundColor__c = '',
                                                 LogoBackgroundColor__c = '',
                                                 SelectedNavBackgroundColor__c = '',
                                                 SelectedNavFontColor__c = '',
                                                 NavLinkFontSize__c = '',
                                                 NavLinkColor__c = '',
                                                 SubNavFontSize__c = '',
                                                 SubNavFontColor__c = '', 
                                                 WelcomeTextColor__c = '');
        if(!String.isBlank(officeLocation)){
            
            List<ARM_Retail_Function__c> lst = [SELECT id , 
                  SubNavigationBackgroundColor__c, 
                  NavigationBackgroundColor__c,
                  LogoBackgroundColor__c,
                  SelectedNavBackgroundColor__c,
                  SelectedNavFontColor__c, 
                  NavLinkFontSize__c,
                  NavLinkColor__c,
                  SubNavFontSize__c,
                  SubNavFontColor__c,
                  WelcomeTextColor__c
                  FROM ARM_Retail_Function__c 
                  WHERE Name = : officeLocation];
            if(!lst.isEmpty()){
               retailFunction = lst[0];
            }
            
        }
            
        return retailFunction;
    }
    
    @AuraEnabled
    public static String getBrandImageURL() {
        
        
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Logo'
                  AND Retail_Function__r.Name = : officeLocation];
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
            }
            
        }
            
        return imageUrl;
        
    }
    
    @AuraEnabled
    public static String getBrandMobileImageURL() {
        
        
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Mobile Logo'
                  AND Retail_Function__r.Name = : officeLocation];
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
            }
            
        }
            
        return imageUrl;
        
    }
    
    
    @AuraEnabled
    public static String getBannerImageURL() {
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Banner'
                  AND Retail_Function__r.Name = : officeLocation];
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
               
            }
            
        }
            
        return imageUrl;
    }
    
    @AuraEnabled
    public static String getBannerMobileLogoURL() {
        String officeLocation = getOfficeLocation();
        
        String imageUrl = '/s.gif';
        if(officeLocation != NULL){
            
            List<ARM_Brand_Image__c> lst = [SELECT id , (Select id from attachments)
                  FROM ARM_Brand_Image__c 
                  WHERE Is_Active__c = true
                  AND Image_Type__c = 'Mobile Banner Logo'
                  AND Retail_Function__r.Name = : officeLocation];
            if(!lst.isEmpty() && !lst[0].attachments.isEmpty()){
               imageUrl = '/servlet/servlet.FileDownload?file=' + lst[0].attachments[0].id;
               
            }
            
        }
            
        return imageUrl;
    }
}
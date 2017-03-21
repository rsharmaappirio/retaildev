/**=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_IdentityController
 * Description: Controller class of lighting component ARM_Identity
 *              This class is used to fetch the User details such as Name , 
 *              franchise name , Number of franchise locations etc. These 
 *              are shown on the Top most manner.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
public without sharing class ARM_IdentityController {
    //  Constants
    private static final string DESIGNATED_CONTACT = 'Designated Contact';
    private static final string DEFAULT_IMAGEURL = '/s.gif';
    private static final string BASE_IMAGEURL = '/servlet/servlet.FileDownload?file=';
    private static final string IMAGE_TYPE_LOGO = 'Logo';
    private static final string IMAGE_TYPE_MOBILE_LOGO = 'Mobile Logo';
    private static final string IMAGE_TYPE_BANNER = 'Banner';
    
    @AuraEnabled
    public static User getCurrentUser() {
        User u = [SELECT id, FirstName, LastName, Name, FullPhotoUrl  
                  FROM User 
                  WHERE id = :UserInfo.getUserId() 
                  LIMIT 1];
        return u;
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
    public static ARM_Retail_Function__c getFranchiseInfo() {
        String officeLocation = getOfficeLocation();
        /*  Retrieve franchise title */
        ARM_Retail_Function__c rF =  [SELECT Franchise_title__c ,
                                             Display_Franchise_title__c  
                                      FROM ARM_Retail_Function__c  
                                      WHERE Name = :officeLocation
                                      LIMIT 1];

        return rF;
    }
}
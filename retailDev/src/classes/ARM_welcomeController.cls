public with sharing class ARM_welcomeController {
// TODO : delete class if not in use
//Use @AuraEnabled to enable client- and server-side access to the method
  @AuraEnabled
  public static String getUserName() {
    return userinfo.getFirstName();
  }
  @AuraEnabled
  public static String getUserPhoto(){
      User u = [Select FullPhotoUrl from user where id =:userinfo.getUserId()];
      return u.FullPhotoUrl;
  }
 }
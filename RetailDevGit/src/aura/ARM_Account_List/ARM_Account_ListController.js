/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_Question_Detail.js
 * Description: Controller for ARM_Account_List
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    loadAccounts : function(component, event, helper) {
        helper.getAccounts(component);
    },
    
    //redirect to list of surveys available
    goToSurveyList : function(component, event, helper) {
    	helper.redirectToSurveyList(component, event);
    }
})
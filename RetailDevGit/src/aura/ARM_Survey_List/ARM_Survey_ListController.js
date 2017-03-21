/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_ListController.js
 * Description: Controller for ARM_Survey_List
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    loadSurveys : function(component, event, helper) {
    	helper.getAccountSurveys(component);
    },
    
    //redirect to question detail page
    goToSurveyQuestionsPage : function(component, event, helper) {
    	helper.redirectToSurveyQuestionDetail(component, event);
    },
    
    //redirect to list of accounts
    goToAccountPage : function(component,event,helper){
    	helper.redirectToAccountList(component,event);
    },
})
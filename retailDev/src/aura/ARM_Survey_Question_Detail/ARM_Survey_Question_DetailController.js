/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_Question_DetailController.js
 * Description: Controller/handler for ARM_Survey_Question_Detail component 
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  ===================================================================== */
({
    loadQuestions : function(component, event, helper) {
    	helper.getSurveyQuestions(component, event);
    },
    
    //Method to call when user click next button
    next : function(component, event, helper){
       helper.toggleSpinnerCSS(component, event);
       helper.nextHandler(component, event);
    },
    
    //method calls when user press previous button
    previous : function(component, event, helper){
       helper.previousHandler(component, event);    
    },
    
    //For the radio buttons, if user clicks on other option, it was not removing the current option
    //so write this method to set current option as false
    removeCheck  : function(component, event, helper){
        helper.radioButtonHandler(component, event);
    },
    
    //set file to none so that he can upload the same file again
    //otherwise onchange event of file wont fire
    setFileToNone : function(component, event, helper){
        helper.setFileNone(component, event);
    },
    
    //when user uploads the photo, preview it 
    previewImage : function(component, event, helper){
    	helper.previewImage(component, event); 
    },
    
    //to to the list of surveys
    goToSurveyPage : function(component, event, helper){
        helper.surveyListRedirect(component, event);
    },
    
    // from questions summary , hide that and show question details
    goToQuestionsDetailPage : function(component, event, helper) {
    	helper.questionDetailRedirect(component, event);
    },
    
    //save the survey results
    saveSurvey : function(component, event, helper) {
        helper.saveSurvey(component, event);
    },
    
    toggleConfirmationModal : function(component,event,helper){
        $('#modal-div').toggle();
    }
})
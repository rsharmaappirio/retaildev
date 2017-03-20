/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_ListHelper.js
 * Description: Helper for ARM_Survey_List
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
	 // function to notify if any errors comes
    notifyErrors : function(a){
        //show some error messages
        var errors = a.getError();
        if (errors) {
            $A.log("Errors", errors);
            if (errors[0] && errors[0].message) {
                $A.error("Error message: " +errors[0].message);
            }
        }
        else {
            $A.error("Unknown error");
        }
    },
    
    getAccountSurveys : function(component){
    	var action = component.get("c.getSurveys"); // method in the apex class
        var self = this;
        var accId = component.get("v.accId");
        action.setParams({"accId":accId});
        try{
        	action.setCallback(this, this.getAccountsSurveys_callback(component));
        	$A.enqueueAction(action);
        }catch(e){
            console.log('error',e);
        }
    },
    
    getAccountsSurveys_callback : function(component){
        return(function(a) {
            if(a.getState() == "SUCCESS"){
                var arr = a.getReturnValue();
                component.set("v.surveyList", arr);
                if(arr.length > 0){
                  component.set("v.showRecordNotFound", false);
                }else{
                  component.set("v.showRecordNotFound", true);
                }
            }else{
                //if there is any error, show that
                this.notifyErrors(a);
            } 
        });
    },
    
    redirectToSurveyQuestionDetail : function(component, event){
    	var surveyId = event.getSource().get("v.alt");
        var accId = component.get("v.accId");
        var changeCompEvent = $A.get("e.c:ARM_ChangeComponent");
        changeCompEvent.setParams({ "Comp_to_Load" : 'ARM_Survey_Question_Detail' , 
                                   "surveyId" : surveyId,
                                   "accId" : accId});
        changeCompEvent.fire();
    },
    
    redirectToAccountList : function(component, event){
    	var changeCompEvent = $A.get("e.c:ARM_ChangeComponent");
        changeCompEvent.setParams({ "Comp_to_Load" : 'ARM_Account_List'});
        changeCompEvent.fire();
    }
})
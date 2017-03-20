/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Account_ListHelper.js
 * Description: Helper for ARM_Account_ListController.js
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
                $A.error("Error message: " +
                         errors[0].message);
            }
        }
        else {
            $A.error("Unknown error");
        }
    },
    
    getAccounts : function (component){
        var action = component.get("c.getAccounts"); // method in the apex class
        action.setCallback(this, this.getAccounts_callback(component));
        $A.enqueueAction(action);
    },
    
    getAccounts_callback : function(component){
        return(function(response) {
            //console.log( response.getReturnValue());
            //console.log( response.state);
            if(response.getState() == "SUCCESS"){
                //console.log('ARR:::'+ response.getReturnValue());
                component.set("v.accountList", response.getReturnValue());
            }else{
                //if there is any error, show that
                this.notifyErrors(response);
            } 
        });
    },
    
    redirectToSurveyList : function(component, event){
    	var accId = event.getSource().get("v.alt");
        var changeCompEvent = $A.get("e.c:ARM_ChangeComponent");
        changeCompEvent.setParams({ "Comp_to_Load" : 'ARM_Survey_List' , "accId" : accId});
        changeCompEvent.fire();
    }
})
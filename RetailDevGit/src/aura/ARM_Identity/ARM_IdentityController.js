/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_IdentityController.js
 * Description: Controller for ARM_Identity.cmp
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/

({
	doInit : function(component, event, helper) {
		helper.getCurrentUser(component);
        helper.getNumberRestaurants(component);
        helper.getFranchiseInfo(component);
	},
    
    clickHandler:function(component, event, helper){
        //{!$SfdcSite.pathPrefix + '/s/profile/' + v.currentUser.Id} 
        //var pathPrefix = $A.get('$SfdcSite.pathPrefix');
        var currentUserId = component.get('v.currentUser.Id');
        
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": '/profile/' + currentUserId
        });
        urlEvent.fire();
        
        /**
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": currentUserId
        });
        editRecordEvent.fire();
        **/
    },
    
    updateCurrentUser: function(component, event, helper){
        helper.getCurrentUser(component);
    }
})
/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_IdentityHelper.js
 * Description: Helper for ARM_Identity
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
	getCurrentUser : function(cmp) {
		var action = cmp.get("c.getCurrentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
            	var u = response.getReturnValue();
                console.log(u);
                cmp.set("v.currentUser", u);
            }
        })
        $A.enqueueAction(action);
	},
	getNumberRestaurants : function(cmp) {
		var action = cmp.get("c.getNumberRestaurants");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
            	var n = response.getReturnValue();
                console.log(n);
                cmp.set("v.numberRestaurants", n);
            }
        })
        $A.enqueueAction(action);
	},
	getFranchiseInfo : function(cmp) {
		var action = cmp.get("c.getFranchiseInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
            	var n = response.getReturnValue();
                console.log('franchise Info' , n);
                cmp.set("v.franchiseInformation", n);
            }
        })
        $A.enqueueAction(action);
	},
    
})
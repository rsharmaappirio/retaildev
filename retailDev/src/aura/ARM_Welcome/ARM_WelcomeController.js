({
	doInit : function(cmp) {
		var action = cmp.get("c.getUserName");
        var action2 = cmp.get("c.getUserPhoto");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.firstName", response.getReturnValue());
             }
          });
        action2.setCallback(this, function(response2){
            var state2 = response2.getState();
            if (state2 === "SUCCESS") {
                console.log('success');
                cmp.set("v.photoURL", response2.getReturnValue());
            }else{
                console.log('error', state2);
            }
          });
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
	}
})
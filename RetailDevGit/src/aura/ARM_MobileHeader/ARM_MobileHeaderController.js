/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_MobileHeaderController.js
 * Description: Controller for ARM_MobileHeader
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    showHideSideBar : function(component, event, helper) {
        try{
            $(".aside-menu").addClass("mobile-open");
            $(".mask-layer").removeClass("hide");
        }catch(e){
            console.log(e);
        }
        
    },
})
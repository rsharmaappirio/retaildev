/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_NavBarComponentController.js
 * Description: Controller for ARM_NavBarComponent.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    clickHandler: function(component, event, helper){ 
        helper.onNewNavigationItemSelected(component, event); 
    }
})
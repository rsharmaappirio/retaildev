/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_Components_ParentController.js
 * Description: Controller for ARM_Survey_Components_Parent.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    changeComponent : function(component, event, helper) {
        var pageName = "c:" + event.getParam("Comp_to_Load");
        var surveyId = event.getParam("surveyId");
        var accId = event.getParam("accId");
        
        helper.changeComponent(component, pageName, surveyId, accId); 
    }

})
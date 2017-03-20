/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_Survey_Components_ParentHelper.js
 * Description: Helper for ARM_Survey_Components_Parent.js
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
	changeComponent : function(component, pageName, surveyId, accId) {
		$A.createComponent(
            pageName,
            {"surveyId" : surveyId, "accId" : accId},
            function(newCmp){
                if (component.isValid()) {
                    var content = component.find("content");
                    content.set("v.body", newCmp);
                }
            }
        );
	}
})
/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_TemplateController.js
 * Description: Controller for ARM_Template.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({  
    doneRendering : function(component, event, helper) {
        if(typeof $ == 'function' && $(window).width() > 1023 && ($(document).height() > $(".purple-bar").height())){
            $(".purple-bar").height($(document).height());
        }
    },
    
    refreshViewOnStandardChange : function(component, event, helper) {
        helper.getCurrentUser(component);
    },
    
    
    
    doInit : function(component, event, helper) {
        helper.getBrandAttributes(component);
        helper.getBrandImage(component);
        helper.getBannerImage(component);
        helper.getBannerMobileLogo(component);
        helper.getBrandMobileImage(component);
        helper.getNavigationList(component);
    },
    
    showHideSubNav: function(component, event, helper) {
        
        var subNavVisibility = event.getParam("SubNavVisibility");
        var selectedNavId = event.getParam("selectedNavigationId");
        var selectedNavName = event.getParam("selectedNavigationName");
        helper.showHideSubNav(component, subNavVisibility, selectedNavId, selectedNavName);
        
    },
    
    toggle: function(component, event, helper) {
        helper.showHideSpinner(component);
    }
})
/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_TemplateHelper.js
 * Description: Helper for ARM_TemplateController.js
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    
    PROFILE_IMAGE_UPDATE_MESSAGE : 'User profile image has been successfully updated' ,
    
    showHideSpinner : function(component) {
        var spinner = component.find("spinner");
        console.log(spinner)
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    getCurrentUser : function(cmp) {
        var action = cmp.get("c.getCurrentUser");
        action.setCallback(this, this.getCurrentUser_Callback(cmp));
        $A.enqueueAction(action);
    },
    
    getCurrentUser_Callback: function(cmp){
        return(function(response){
            var state = response.getState();
            if ( state === "SUCCESS") {
                var u = response.getReturnValue();
                cmp.find('SubNavBar').find('IdentityComp').set("v.currentUser", u);
                //this.showToast("Image Update", this.PROFILE_IMAGE_UPDATE_MESSAGE); 
            } 
        });
        
    },
    
    showToast: function(title, message){  
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message
        });
        resultsToast.fire();
        
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();       
    },
    
    showHideSubNav: function(component, subNavVisibility, selectedNavId, selectedNavName){
        component.find('NavBar').set('v.selectedNavigationItemId', selectedNavId);
        component.find('MobileHeader').set('v.title', selectedNavName);
        this.getSubNavigationList(component, selectedNavId);  
    },
    
    
    getBrandAttributes: function(cmp) {
        var action = cmp.get("c.getBrandAttributes");
        action.setCallback(this, this.getBrandAttributes_Callback(cmp));
        $A.enqueueAction(action);
    },
    
    getBrandAttributes_Callback: function(cmp){
        return(function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
                var r = response.getReturnValue();
                cmp.find("NavBar").set("v.navBackgroundColor", r.NavigationBackgroundColor__c);
                cmp.find("NavBar").set("v.navLinkColor", r.NavLinkColor__c);
                cmp.find("NavBar").set("v.navFontSize", r.NavLinkFontSize__c);
                cmp.find("NavBar").set("v.currentNavBackgroundColor", r.SelectedNavBackgroundColor__c);
                cmp.find("NavBar").set("v.currentNavLinkColor", r.SelectedNavFontColor__c);
                cmp.find("SubNavBar").set("v.navBackgroundColor", r.SubNavigationBackgroundColor__c);
                cmp.find("SubNavBar").set("v.subNavLinkColor", r.SubNavFontColor__c);
                cmp.find("SubNavBar").set("v.subNavFontSize", r.SubNavFontSize__c);
                //cmp.find("SubNavBar").find("IdentityComp").set("v.welcomeTextColor", r.WelcomeTextColor__c);
                cmp.find("SubNavBar").set("v.welcomeTextColor", r.WelcomeTextColor__c);
                cmp.find("MobileHeader").set("v.navBackgroundColor", r.NavigationBackgroundColor__c);
                cmp.find("Branding").set("v.logoBackgroundColor", r.LogoBackgroundColor__c);
                
            }
        });
    },
    
    getBrandImage : function(cmp) {
        var action = cmp.get("c.getBrandImageURL");
        action.setCallback(this, this.getBrandImage_Callback(cmp));
        $A.enqueueAction(action);
    },
    
    getBrandImage_Callback: function(cmp){
        return(function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
                var r = response.getReturnValue();
                cmp.find("Branding").set("v.brandImage", r);
            }
        });
    },
    
    getBannerImage : function(cmp) {
        var action = cmp.get("c.getBannerImageURL");
        action.setCallback(this, this.getBannerImage_Callback(cmp));
        $A.enqueueAction(action);
    },
    
    getBannerImage_Callback: function(cmp){
        return(function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
                var r = response.getReturnValue();
                cmp.find("Branding").set("v.bannerImage", r);
            }
        });
    },
    
    getBannerMobileLogo : function(cmp) {
        var action = cmp.get("c.getBannerMobileLogoURL");
        action.setCallback(this, this.getBannerMobileLogo_Callback(cmp));
        $A.enqueueAction(action);
    },
    
    getBannerMobileLogo_Callback: function(cmp){
        return(function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
                var r = response.getReturnValue();
                cmp.find("Branding").set("v.bannerMobileLogo", r);
            }
        });
    },
    getBrandMobileImage: function(cmp){
        var action = cmp.get("c.getBrandMobileImageURL");
        action.setCallback(this, this.getBrandMobileImage_Callback(cmp));
        $A.enqueueAction(action);
    },
    
    getBrandMobileImage_Callback: function(cmp){
        return(function(response) {
            var state = response.getState();
            if ( state === "SUCCESS") {
                var r = response.getReturnValue();
                console.log('Mobilebrand====='+r);
                cmp.find("NavBar").set("v.brandMobileImage", r);
            }
        });
    },
    

    
    getNavigationList: function(cmp){
        var action = cmp.get("c.getNavigationList");
        action.setCallback(this, this.getNavigationList_Callback(cmp));  
        $A.enqueueAction(action);
    },
    
    getNavigationList_Callback: function(cmp){
        return(function(response){
            var state = response.getState();
            if ( state === "SUCCESS") {
                var arr = response.getReturnValue();
                
                cmp.find('NavBar').set('v.sidebarNavList', arr);
                try{
                    var sitePrefix = $A.get('$SfdcSite.pathPrefix');   
                    var currentPageURL = window.location.pathname.replace(sitePrefix, "");
                    this.getCurrentNavigationItemId(cmp, currentPageURL);
                }catch(e){
                    console.log('EXCEPTION::::' + e);
                }
            }
        });
    },
    
    getCurrentNavigationItemId: function(cmp, currentPageURL){
        var action = cmp.get("c.getCurrentNavigationItemId");
        action.setParams({pageURL : currentPageURL});
        action.setCallback(this, this.getCurrentNavigationItemId_Callback(cmp));  
        $A.enqueueAction(action);
    },
    
    getCurrentNavigationItemId_Callback: function(cmp){
        return (function(response){
            var state = response.getState();
            if ( state === "SUCCESS") {
                var arr = response.getReturnValue();
                if(arr.length > 0){
                    var u = arr[0].Id;
                    var z = arr[0].Display_Name__c;
                    cmp.find('NavBar').set('v.selectedNavigationItemId', u);
                    cmp.find('MobileHeader').set('v.title', z);
                    this.getSubNavigationList(cmp, u);
                }
            }
        });
    },
    
    getSubNavigationList: function(cmp, navId){
        var action = cmp.get("c.getSubNavigationList");
        action.setParams({navigationId : navId});
        action.setCallback(this, this.getSubNavigationList_Callback(cmp));  
        $A.enqueueAction(action);
    },
    
    getSubNavigationList_Callback: function(cmp){
        return (function(response){
            
            var state = response.getState();
            cmp.find('SubNavBar').set("v.showSubNav", true);
            if ( state === "SUCCESS") {
                var arr = response.getReturnValue();
                
                for(var indx = 0; indx < arr.length; indx++){
                    console.log('OBJECT:' , arr[indx]);  
                    if(typeof arr[indx].Attachments != 'undefined' && arr[indx].Attachments.length > 0){
                        var attachmentId = arr[indx].Attachments[0].Id;
                        arr[indx]['Icon_URL__c'] = '/servlet/servlet.FileDownload?file=' + attachmentId;
                    }
                } 
                
                cmp.find('SubNavBar').set('v.sidebarNavList', arr);
                if(arr.length > 0){
                    cmp.find('SubNavBar').set("v.showSubNav", true);
                    cmp.set("v.applyMargin", true);
                }else{
                    cmp.find('SubNavBar').set("v.showSubNav", false);
                    cmp.set("v.applyMargin", false);
                    
                }
            }
        });
    }
})
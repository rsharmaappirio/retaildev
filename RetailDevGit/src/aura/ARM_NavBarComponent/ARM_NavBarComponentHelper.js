/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_NavBarComponentHelper.js
 * Description: Helper for ARM_NavBarComponentController.js
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    reloadScriptForSidebar: function(cmp) {
        //hover on left sidebar
        $(".aside-menu").hover(function() {
            //show full menu
            $(".aside-menu").addClass("open");
        }, function() {
            //show simple menu
            $(".aside-menu").removeClass("open");
        });

        //click on menu icon in mobile view

        /*$(".btn-icon-menu").click(function(){
          $(".aside-menu").addClass("mobile-open");
          $(".mask-layer").removeClass("hide");
        });*/

        //click on mask layer of menu popup in mobile view
        $(".mask-layer").click(function() {
            $(".aside-menu").removeClass("mobile-open");
            $(".mask-layer").addClass("hide");
        });


        //set sidebar height in pages except login page
        if ($(".login-wrapper").length === 0) {
            //$(".aside-menu").attr("style","");
            //$(".purple-bar").attr("style","");

            try {

                //if($(window).width()>1023 && ($(".main-container").height()>$(window).height()))


                /*if($(window).width() > 1023){
                  setTimeout(function(){  
                      //content higher than browser height
                      //$(".aside-menu").height($(".main-container").height());
                      //$(".purple-bar").height($(".main-container").height());
                      $(".purple-bar").height($(document).height());
                  }, 2000); 
                }*/



            } catch (e) {
                console.log('Exception::::' + e);
            }
        }



    },



    onNewNavigationItemSelected: function(comp, event) {
        try {

            var selectedNavId = event.getSource().get('v.alt'); 
            var selectedNavName = event.getSource().get('v.label'); 

            var changeCompEvent = $A.get("e.c:ARM_Show_Sub_Nav");
            changeCompEvent.setParams({"SubNavVisibility": true,
                                       "selectedNavigationId": selectedNavId,
                                       "selectedNavigationName": selectedNavName});

            changeCompEvent.fire();


        } catch (e) {
            console.log('exception:::' + e);
        }
        $(".aside-menu").removeClass("open").removeClass("mobile-open");
    }


})
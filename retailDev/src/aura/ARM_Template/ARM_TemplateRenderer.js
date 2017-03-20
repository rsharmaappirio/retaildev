/*=====================================================================
 * (c) 2017 Appirio - A Wipro Company, Inc
 * Name: ARM_TemplateRenderer.js
 * Description: Modifies the DOM elements when the component is rerendered.
 * Created Date: Mar 07, 2017
 * Created By: Gaurav Gupta (Appirio - A Wipro Company)
 * 
 * Date Modified      Modified By                  Description of the update
 *  =====================================================================*/
({
    // Your renderer method overrides go here
    // The base component in the framework is aura:component. Every component extends this base component.
    //The renderer for aura:component is in componentRenderer.js. This renderer has base implementations for the four phases
    //of the rendering and rerendering cycles:
    //• render()
    //• rerender()
    //• afterRender()
    //• unrender()
    //The framework calls these functions as part of the rendering and rerendering lifecycles and we will learn more about them soon. You
    //can override the base rendering functions in a custom renderer
    render: function(cmp, helper){
        /// Overriding render is removing the javascript event attached 
        /// on the nav bars
        var ret = this.superRender();
        //console.log('ARM_TEMPLATE render called'); 
        return ret;
        
    },
    rerender: function(cmp, helper){
        this.superRerender();
    },
    afterRender: function(cmp, helper){
        this.superAfterRender();
        console.log('ARM_TEMPLATE afterRender called');
        try{
            setTimeout(function(){
                
                $(window).resize(function(){
                    if($(window).width() > 1023){
                        $(".purple-bar").height($(document).height());
                    }else{
                        $(".purple-bar").height(''); 
                    }
                });
                
            }, 2000);    
            
        }catch(e){console.log(e);}
    },
    
    unrender: function(cmp, helper){
        this.superUnrender();
    }
    
})
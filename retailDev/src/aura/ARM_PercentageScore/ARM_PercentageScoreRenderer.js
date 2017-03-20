({
	afterRender: function (component, helper) {
        this.superAfterRender();
        var percentage = component.get('v.percentage');
        if (percentage>0) helper.animate(component);
    },
})
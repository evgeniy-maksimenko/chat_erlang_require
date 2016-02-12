define([
    'jquery',
    'backbone',
    'text!modules/chat/modules/contacts/templates/viewTemplate.html',

], function($, Backbone, ViewTemplate){
    var PageView = Backbone.View.extend({
        viewTemplate: _.template(ViewTemplate),
        events: {
        },
        initialize: function() {            
        },
        render: function() {
            this.$el.html(this.viewTemplate());
            return this;
        },
        
    });
    return PageView;
});
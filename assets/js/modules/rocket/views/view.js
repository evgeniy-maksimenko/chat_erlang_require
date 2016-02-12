define([
    'jquery',
    'backbone',
    'text!modules/rocket/templates/viewTemplate.html',

], function($, Backbone, ViewTemplate){
    var PageView = Backbone.View.extend({

        viewTemplate: _.template(ViewTemplate),

        tagName: 'tr',

        events: {
            'click .changeSize' : 'changeSize',
            'click .deleteRow' : 'deleteRow',
            'blur .desc, .name, .size'        : 'editValue',
        },


        initialize: function() {

            this.listenTo(this.model, "change", this.render);
            this.listenTo(this.model, "destroy", this.remove);
        },

        render: function() {
            var json = this.model.toJSON();
            this.$el.html(this.viewTemplate(json));
            return this;
        },

        changeSize: function(event) {
            var diff = parseInt($(event.target).attr('data-rel'));
            var size = parseInt(this.model.get('size'));
            var res = this.model.set({
                size: size + diff,
            }, {validate: true});
            if(!res) this.render();
        },
        deleteRow: function() {
            this.model.destroy();
        },
        editValue: function() {
            var res = this.model.set({
                name: this.$('.name').text(),
                description: this.$('.desc').text(),
                size: parseInt(this.$('input.size').attr('value')),
            }, {validate: true});
            if(!res) this.render();
        },
    });

    return PageView;
});
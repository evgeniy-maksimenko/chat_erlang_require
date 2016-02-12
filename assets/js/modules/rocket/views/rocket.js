define([
    'backbone',
    'text!modules/rocket/templates/rocketTemplate.html',
    'modules/rocket/collections/rockets',
    'modules/rocket/collections/rocket',
    'modules/rocket/views/view',

], function(Backbone, ViewTemplate, Collection, Model, ItemView){
    var PageView = Backbone.View.extend({

        events: {
            'click .addObject'      : 'addObject',
            'click .toJSON'         : 'toJSON',
            'click [data-sort]'     : 'renderList',
        },

        template: _.template(ViewTemplate),

        initialize: function() {
            this.$el.html(this.template(this));
            this.coll = new Collection();
            this.listenTo(this.coll, 'all', this.render);
            this.listenTo(this.coll, 'add', this.addOne);
        },

        render: function() {
            var size = 0;
            this.coll.each(function(obj, index){
                size += obj.get('size');
            });
            this.$('.rockets-count').text(this.coll.length);
            this.$('.rockets-size').text(size);
            return this;
        },

        addObject: function() {
            this.coll.add({});
        },

        addOne: function(model) {
            var itemView = new ItemView({
                model: model
            });
            $(".rocketsList").append(itemView.render().el);
        },

        renderList: function(e) {
            this.$('.rocketsList').html('');
            this.coll.sortParam = $(e.target).attr('data-sort');
            this.coll.sortMode = this.coll.sortMode*(-1);
            this.coll.sort();
            var that = this;
            this.coll.each(function(model, index){
                that.addOne(model);
            })
        },

        toJSON: function() {
            var json = this.coll.toJSON();
            $(".json-out").html(JSON.stringify(json));
        }
    });

    return PageView;
});
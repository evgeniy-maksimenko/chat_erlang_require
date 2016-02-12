define([

    'backbone',

], function(Backbone){
    var Model = Backbone.Model.extend({
        defaults: {
            name : "name",
            description: "description",
            size : 100
        },

        validate: function(attrs) {
            if(!(attrs.size) > 0) {
                console.log('incorrect size');
                return 'incorrect size';
            }
        }

    });

    return Model;
});
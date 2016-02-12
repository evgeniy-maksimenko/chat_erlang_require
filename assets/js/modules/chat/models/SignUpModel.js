define([

    'backbone',

], function(Backbone){
    var Model = Backbone.Model.extend({
    	validate: function(attrs) {
            if(!attrs.login) {
                return 'Логин не может быть пустым';
            }
            var re = /^[a-zA-Z]+$/;
            if (!re.test(attrs.login)) {
            	return 'Допускаются только символы a-zA-Z';
            }
        }
    });

    return Model;
});
define([
    'router',
    'jquery',
    'backbone',
    'modules/chat/models/SignUpModel',
    'text!modules/chat/templates/signinTemplate.html',

], function(router, $, Backbone, SignUpModel, ViewTemplate){
    var PageView = Backbone.View.extend({
        viewTemplate: _.template(ViewTemplate),
        
        model: new SignUpModel(),
        events: {
            'submit' : function(e) {
                e.preventDefault();
                this.signUp();    
            }
        },
        initialize: function(){
            this.model.on("invalid", function(model, error) {
              $(".control-group").addClass('error');
              $(".help-inline").show().html(error);
            },this);
        },
        signUp : function(e) {
            var res = this.model.set({
                login: this.$('#login').val()
            }, {validate: true});
           if(res) {
            login = $.cookie('login');

                if(login != undefined){
                    window.location = "/";
                } else {
                    $.cookie('login', $("#login").val(), {
                        
                        path: '/',
                    });
                    
                    window.location = "/";
                }
           }  
        },
        render: function() {
            this.$el.html(this.viewTemplate());
            return this;
        }
    });
    return PageView;
});

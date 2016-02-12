define(function(require) {
  'use strict';
  var Backbone      = require('backbone'),
      _             = require('underscore'),
      homeTemplate  = require('text!templates/homeTemplate.html'),
      Layout        = require('layouts/layoutBasic/layout');

  var HomePage = Backbone.View.extend({
    template: _.template(homeTemplate),

    render: function() {
      this.$el.html(this.template(this));
      return this;
    }
  });

  return Layout.extend({
    content: HomePage
  })
});
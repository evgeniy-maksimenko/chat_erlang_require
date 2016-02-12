

define([], function() {
  	'use strict';
	
	requirejs.config({
	    urlArgs: "bust=" + (new Date()).getTime(), // отключить кеширование
		paths: {
			'jquery' 			    : 'libs/jquery/jquery-1.11.1.min',
			'underscore' 		    : 'libs/underscore/underscore',
			'backbone' 			    : 'libs/backbone/backbone',
			'bootstrap'			    : 'libs/bootstrap/bootstrap.min',
			'bootstrap-select' 	    : 'libs/bootstrap/bootstrap-select.min',
			'backgrid_paginator'	: 'libs/backgrid/backgrid-paginator.min',
			'jquery-cookie'		    : 'libs/jquery/jquery.cookie',
			'jquery-ui'			    : 'libs/jquery/jquery-ui',
			'jquery-color'		    : 'libs/jquery/jquery-color',
			'bootstrap-datepicker' 	: 'libs/bootstrap/bootstrap-datepicker',
			'alertify' 				: 'libs/alertify/alertify.min',
			'router' 		        : 'libs/rjs/rjs-router',
			'text' 			        : 'libs/rjs/rjs-text'
		},

		shim: {
			'backbone' : {
				deps 	: ['jquery', 'underscore','bootstrap','bootstrap-select','jquery-cookie', 'bootstrap-datepicker','jquery-color','alertify'],
				exports : 'Backbone'
			}
		},
    	waitSeconds: 0
	});

	require([
		'jquery',
		'router'
	], function($, router) {
		var view;
		router.registerRoutes({
		    rocket: 		        { path: '/rocket', 					moduleId: 'modules/rocket/views/rocket'},
		    home: 		            { path: '/', 					    moduleId: 'modules/chat/views/index'},
		    ya:                 	{ path: '/yandex_7fe8acd062d7f8f1.html', 					moduleId: 'modules/chat/views/verif'},
			notFound: 	            { path: '*',					    moduleId: 'views/notFound'},
		
		}).on('routeload', function onRouteLoad(View, routeArguments) {
			if (view) {
	          view.remove();
	        }
	        view = new View(null, routeArguments);
	        view.render();
	        $('body').append(view.el);
		}).init();
		
	},
	function(error){
            console.log('Custom ERROR handler',error);
            var failedId = error.requireModules && error.requireModules[0];
            console.log(failedId);
            console.log(error.message);
        }
	);
	
	
});
define([
    'jquery',
    'backbone',
    'text!modules/chat/templates/viewTemplate.html',
    'text!modules/chat/templates/mainTemplate.html',
    'modules/chat/modules/contacts/views/index',
    'alertify',
    'modules/chat/views/signin',

], function($, Backbone, ViewTemplate, MainTemplate, ContactsView, alertify, SigninView){

    var websocket;

    function init() {
        connect();
        $("#connected").hide();
        $("#content").hide();
    };

    function connect()
    {
        wsHost = "ws://" + window.location.host + "/websocket";
        websocket = new WebSocket(wsHost);

        websocket.onopen    = function(evt) { onOpen(evt) };
        websocket.onclose   = function(evt) { onClose(evt) };
        websocket.onmessage = function(evt) { onMessage(evt) };
        websocket.onerror   = function(evt) { onError(evt) };
    };

    function disconnect() {
        websocket.close();
    };

    function toggle_connection(){
        if(websocket.readyState == websocket.OPEN){
            disconnect();
        } else {
            connect();
        };
    };

    function onOpen(evt) {
        $("#connected").fadeIn('slow');
        $("#content").fadeIn('slow');
        login = $.cookie('login');
        if(login != undefined){
            websocket.send(JSON.stringify({"requestType": 1,"login": login}));    
            websocket.send(JSON.stringify({"requestType": 17, "login":login}));    
        } else {
            signinView = new SigninView();
            $('body').html(signinView.render().el);
        }
    };

    function onClose(evt) {
        showScreen('<span style="color: red;">DISCONNECTED </span>');
    };

    function soundClick() {
      var audio = new Audio(); 
      audio.src = '/assets/sounds/vk_msg.mp3'; 
      audio.autoplay = true; 
    }

    function onMessage(evt) {
        var Message = null;
        var Time = null;
        var Login   = $.cookie('login');
        var LoginCompany = $("#ChannelId").html();
        var Channel = null;
        Response  = $.parseJSON(evt.data);
        console.log(Response);
        if (Response.responseType == 101) {
            // Msg = "Привет господин.";
        }
        if (Response.responseType == 100) {
            
            websocket.send(JSON.stringify({"requestType": 15,"login": Login}));
        }
        if (Response.responseType == 108) {
            
            // Msg = "Вы добавили к себе в друзья " + Response.login;
        }
        if (Response.responseType == 109) {
            ResponseLength = Response.values.length
            for (var i = 0; i < ResponseLength; i++) {               
                Channel   = parseMessage(Response,i)[1];
                Message   = parseMessage(Response,i)[0];
                Time      = parseMessage(Response,i)[2];
                ChannelFrom      = parseMessage(Response,i)[3];
                if(Message != null && Time != null){
                    if(LoginCompany == Channel) {
                        showScreen('<div style="margin-left: 20px;"><img class="img-circle" src="/assets/img/logo.jpg" style="height:30px;float: left;margin-top: 4px;"/><div class="alert alert-info" style="margin-left: 50px; margin-bottom:10px;">' + Message + '<div class="pull-right"><small>' + Time + '</small></div></div></div>');    
                    } 
                    else if(LoginCompany == ChannelFrom){
                        showScreen('<div class="alert alert-info" style="margin-left: 50px;margin-bottom:10px;background-color: #fff;">' + Message + '<div class="pull-right"><small>' + Time + '</small></div></div>');    
                    }
                }                
            }
        }
        if (Response.responseType == 114) { 
            try {

                Channel   = parseMessage(Response,0)[1];
                Message   = parseMessage(Response,0)[0];
                Time      = parseMessage(Response,0)[2]; 
                ChannelLoginFrom = parseMessage(Response,0)[3];
                

                if(Message!=null && Time!=null){
                    if(LoginCompany == Channel) {
                        soundClick();
                        showScreen('<div style="margin-left: 20px;><img class="img-circle" src="/assets/img/logo.jpg" style="height:30px;float: left;margin-top: 4px;"/><div class="alert alert-info" style="margin-left: 50px; margin-bottom:10px;"">' + Message + '<div class="pull-right"><small>' + Time + '</small></div></div></div>');    
                    } 
                    else if( LoginCompany == ChannelLoginFrom) {
                        showScreen('<div class="alert alert-info" style="margin-left: 50px;background-color: #fff; margin-bottom:10px;"">' + Message + '<div class="pull-right"><small>' + Time + '</small></div></div>');    
                    } else {
                        alertify.message('<div style="text-align:left;"><img class="img-circle" src="/assets/img/logo.jpg" style="height:30px;float: left;"/><div class="" style="margin-left:40px;">'+Channel + ' ' + Message + '<div class="pull-right"><small>' + Time + '</small></div></div></div>');
                    }
                }        
            } catch(e) {

              console.log('Ошибка ' + e.name + ":" + e.message); // (3) <--

            }
                   
        }
        if (Response.responseType == 115) {                
            ResponseLength = Response.values.length

            for (var i = 0; i < ResponseLength; i++) {
                Contact = Response.values[i];   
                Login   = $.cookie('login');         
                data = Contact.split(":");
                Channel = data[1];

        
                if(Login != Channel)
                {
                    $('#contacts-block .table #list').append('<tr><td>'+Channel+'</td><td><button class="btn btn-success pull-right contactBtnId" id="'+Channel+'" style="border-radius: 50%;"><i class="icon-user icon-white"></i>+</button></td></tr>');
                    $("#contacts-block").scrollTop($('#contacts-block')[0].scrollHeight);    
                }
                
            }
        }

        if (Response.responseType == 116) {                
            ResponseLength = Response.values.length
            for (var i = 0; i < ResponseLength; i++) {
                Contact = Response.values[i];
                $("#contactsBook").append('<li class="contactId" id="'+Contact+'"><a><img src="/assets/img/logo.jpg" style="height:30px" class="img-circle">'+Contact+'</a></li>');
            }

        }

        if (Response.responseType == 117) {
            $("#contactsBook").append('<li class="contactId" id="'+Response.loginTo+'"><a><img src="/assets/img/logo.jpg" style="height:30px" class="img-circle">'+Response.loginTo+'</a></li>');
        }                
    };

    function parseMessage(Response, i){        
        Msg = Response.values[i];                    
        var data = Msg.split(";");
        Channel     = data[2];
        Message     = data[5];
        Time        = data[6];
        ChannelFrom = data[3];
        return [Message, Channel, Time, ChannelFrom];        
    }

    function onError(evt) {
        showScreen('<span style="color: red;">ERROR: ' + evt.data+ '</span>');
    };

    function showScreen(Msg) {
        ChannelId = $("#ChannelId").html();
        // Channel   = ChannelId.split("+");
        $('#channel_'+ChannelId).append(Msg);
        $(".prokrutka").scrollTop($('.prokrutka')[0].scrollHeight);
    };

    function clearScreen()
    {
        $('#output').html("");
    };


    var PageView = Backbone.View.extend({
        viewTemplate: _.template(ViewTemplate),
        mainTemplate: _.template(MainTemplate),
        events: {
            'keypress #MessageId' : 'sendMessageEnter',
            'click #send_btn'     : 'sendMessageBtn',
            'click .contactId'    : 'getContactBtn',
            'click .contactBtnId' : 'getContactBtnId',
            'click #contacts'     : 'showAddContacts'
        },
        showAddContacts: function() {
            contactsView = new ContactsView();
            $("#main-block").html(contactsView.render().el);
            login = $.cookie('login');
            websocket.send(JSON.stringify({"requestType": 16, "login":login}));    
        },
        getContactBtnId: function(e){
            loginTo = e.currentTarget.id;
            login = $.cookie('login');
            websocket.send(JSON.stringify({"requestType": 5, "login": login, "loginTo": loginTo}));    
        },
        getContactBtn: function(e) {
            $("#main-block").html(this.mainTemplate());
            ChannelId     = e.currentTarget.id;
            // ChannelArray  = ChannelId.split("+");
            Channel       = "channel_" + ChannelId;

            proktutka = $('.prokrutka');

            proktutka.empty();
            proktutka.attr('id',Channel);
            $("#ChannelId").html(ChannelId);
            login = $.cookie('login');
            websocket.send(JSON.stringify({"requestType": 4, "login": login, "syncId": 1}));   

        },
        sendMessageEnter: function(e) {
            var messageId = $("#MessageId");
            if (e.keyCode == 13 && messageId.val() != "") {
                this.sendMessage();
            }
        },
        sendMessageBtn: function(){
            this.sendMessage();
        },
        sendMessage: function(){
            if(websocket.readyState == websocket.OPEN){
                    messageId   = $("#MessageId");
                    message     = messageId.val();
                    login       = $.cookie('login');
                    channelId   = $("#ChannelId").html();
                    
                    d = new Date();
                    initialLiveTime = d.getHours() + ":" + d.getMinutes();
                    
                    MSG = JSON.stringify({"requestType": 6,"login": login,"loginTo": channelId,"message": message,"tmpId": 200,"date": "2015-01-18","initialLiveTime": initialLiveTime,"messageType": "text"})    
                    
                    messageId.val("");
                    ProtectedMsg = this.protection_xss_atack(MSG);
                   
                    websocket.send(ProtectedMsg);

                    
                } else {
                    showScreen('websocket is not connected');
                };
        },
        initialize: function() {     
            
            init();    
        },
        render: function() {
            
            $("#main-block").html(this.mainTemplate());
            this.$el.html(this.viewTemplate());
            return this;
        },
        protection_xss_atack: function(Msg) {
            /* закрытие XSS-атак */
            Msg = Msg.replace(/<!--[\w\W]*-->/,"");
            //Msg = Msg.replace(/<[^>]+?src[\w\W]+\/\/[^>]+?>/i,""); //открыл youtube
            // Msg = Msg.replace(/<[^>]+[^->a-z0-9\/\.\:\;\"\=\%\#\s]+[^>]+?>/i,"");
            Msg = Msg.replace(/<[^>]+?\.[a-z ]+?\=[^>]+?>/i,"");
            Msg = Msg.replace(/<[^>]+?\%[a-z0-9]+?[^>]+?>/i,"");
            Msg = Msg.replace(/<[^>]*?script[^>]*?>/i,"");
            Msg = Msg.replace(/<[^>]*?js:[^>]*?>/i,"");
            Msg = Msg.replace(/<[^a-z\/]{1}[^>]*?>/i,"");
            return Msg;
        }
    });
    return PageView;
});
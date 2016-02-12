-module(protocol).

-export([parse/2]).
-include("config.hrl").

parse(?kServerRequestType_LogIn, Data)                    -> handle_log_in_request(Data);
parse(?kServerRequestType_AddContact, Data)               -> handle_add_contact(Data);
parse(?kServerRequestType_Sync, Data)                     -> handle_sync_request(Data);
parse(?kServerRequestType_ReceivedMessage, Data)          -> handle_message_received(Data);
parse(?kServerRequestType_AddMessage, Data)               -> handle_add_message(Data);
parse(?kServerRequestType_GetMessage, Data)               -> handle_get_message(Data);
parse(?kServerRequestType_GetContacts, Data)              -> handle_get_contacts(Data);
parse(?kServerRequestType_GetContactsBook, Data)          -> handle_get_contacts_book(Data).

-define(separator, ":").
-define(KEY(RedisKey, ClientKey), RedisKey ++ ?separator ++ cz_types:to_list(ClientKey)).

-record(handle_sync_request,{
  login :: binary(),
  syncTableResults :: list(),
  contactResults :: list()
}).

%% Авторизация
handle_log_in_request(Data) ->
  ?LOG_INFO("Login request",[]),
  Login             = cz_types:get_value(<<"login">>, Data),
  redis:set(?KEY(?kRedisKey_Login, Login), 25),

  redis:incr(cz_types:to_binary(?kRedisKey_Session)),
  
  redis:subscribe(sub, "chanel:"++cz_types:to_list(Login)),
  ws_handler:subscribe(cz_types:to_binary("chanel:"++cz_types:to_list(Login))),
  
  jsx:encode([{<<"responseType">>, ?kServerResponseType_LogIn_AcceptedForVerification},{<<"login">>, Login}]).

%% Добавление контакта
handle_add_contact(Data) ->
  ?LOG_INFO("Add Contact if possible ~p",[Data]),
  Login         = cz_types:get_value(<<"login">>, Data),
  LoginTo       = cz_types:get_value(<<"loginTo">>, Data),
  Res           = redis:get(?KEY(?kRedisKey_Login, LoginTo)),

  case login_exists(Res) of
    true->
      ?LOG_INFO("Contact found ~p",[LoginTo]),
      GlobalId = redis:incr(cz_types:to_binary(?kRedisKey_GlobalId)),
      redis:zadd(?KEY(?kRedisKey_Contact, Login), GlobalId, cz_types:to_binary(LoginTo)),
      redis:publish(pub, "chanel:"++cz_types:to_list(Login), 1),
      redis:zadd(?KEY(?kRedisKey_Contact, LoginTo), GlobalId, cz_types:to_binary(Login)),
      redis:publish(pub, "chanel:"++cz_types:to_list(LoginTo), 1),
      jsx:encode([{<<"responseType">>, ?kServerResponseType_Added_Contacts_Done},{<<"login">>, Login},{<<"loginTo">>, LoginTo}]);
    false ->
      ?LOG_INFO("Contact not found ~p",[LoginTo]),
      jsx:encode([{<<"responseType">>, ?kServerResponseType_Contact_Undefined},{<<"login">>, Login},{<<"loginTo">>, LoginTo}])
  end.

%% Синхронизация сообщений
handle_sync_request(Data) ->
  ?LOG_INFO("Sync request",[]),
  Login = cz_types:get_value(<<"login">>, Data),
  SyncId  = cz_types:get_value(<<"syncId">>, Data),

%%   ContactResults   = redis:zrangebyscore(?KEY(?kRedisKey_Contact, Login), "(" ++ cz_types:to_list(SyncId) , inf, withscores),
  SyncTableResults = redis:zrangebyscore(?KEY(?kRedisKey_SyncTable, Login), "(" ++ cz_types:to_list(SyncId) , inf, withscores),

  jsx:encode([{<<"responseType">>, ?kServerResponseType_Sync_Messages},{<<"login">>, Login},{<<"values">>, SyncTableResults}]).
%%   get_response_sync(
%%     length(ContactResults) == 0,
%%     length(SyncTableResults) > 0,
%%     #handle_sync_request{login = Login, syncTableResults = SyncTableResults, contactResults = ContactResults}
%%   ).

%% получить все контакты
handle_get_contacts(Data) ->
  ?LOG_INFO("Get all contacts",[]),
  Login = cz_types:get_value(<<"login">>, Data),
  SyncTableResults = redis:keys(?kRedisKey_Contacts),

  jsx:encode([{<<"responseType">>, ?kServerResponseType_Get_Contacts},{<<"login">>, Login},{<<"values">>, SyncTableResults}]).

%% получить все контакты телефонной книги
handle_get_contacts_book(Data) ->
  ?LOG_INFO("Get all contacts books",[]),
  Login = cz_types:get_value(<<"login">>, Data),
  SyncTableResults = redis:zrange(?KEY(?kRedisKey_Contact, Login), 0, -1),

  jsx:encode([{<<"responseType">>, ?kServerResponseType_Get_Contacts_Book},{<<"login">>, Login},{<<"values">>, SyncTableResults}]).



%% получить сообщение
handle_get_message(Data) ->
  ?LOG_INFO("Get message",[]),
  Login   = cz_types:get_value(<<"login">>, Data),
  SyncId  = redis:get(cz_types:to_binary(?kRedisKey_GlobalId)),

%%   ContactResults   = redis:zrangebyscore(?KEY(?kRedisKey_Contact, Login), cz_types:to_list(SyncId) , inf, withscores),
  SyncTableResults = redis:zrangebyscore(?KEY(?kRedisKey_SyncTable, Login), cz_types:to_list(SyncId) , inf, withscores),

  jsx:encode([{<<"responseType">>, ?kServerResponseType_Get_Messages},{<<"login">>, Login},{<<"values">>, SyncTableResults}]).

%% Отправка сообщения
handle_add_message(Data)->
  ?LOG_INFO("Add Message if Possible",[]),
  Login             = cz_types:get_value(<<"login">>, Data),
  Text              = cz_types:get_value(<<"message">>, Data),
  Date              = cz_types:get_value(<<"date">>, Data),
  LoginTo           = cz_types:get_value(<<"loginTo">>, Data),
  InitialLiveTime   = cz_types:get_value(<<"initialLiveTime">>, Data),
  MessageType       = cz_types:get_value(<<"messageType">>, Data),
  TmpId             = cz_types:get_value(<<"tmpId">>, Data),
  Res = redis:get(?KEY(?kRedisKey_Login, LoginTo)),

  case (login_exists(Res) orelse LoginTo =:= <<"-1">>) of
    true ->
      Message =
        cz_types:to_list(MessageType) ++ ";" ++
        cz_types:to_list(TmpId) ++ ";" ++
        cz_types:to_list(Login) ++ ";" ++
        cz_types:to_list(LoginTo) ++ ";" ++
        cz_types:to_list(Date) ++ ";" ++
        cz_types:to_list(Text) ++ ";" ++
        cz_types:to_list(InitialLiveTime),

      GlobalId = redis:incr(cz_types:to_binary(?kRedisKey_GlobalId)),
      redis:zadd(?KEY(?kRedisKey_SyncTable, Login), GlobalId, cz_types:to_binary(Message)),
      redis:publish(pub, "chanel:" ++ cz_types:to_list(Login), 1),
      redis:zadd(?KEY(?kRedisKey_SyncTable, LoginTo), GlobalId, cz_types:to_binary(Message)),
      redis:publish(pub, "chanel:" ++ cz_types:to_list(LoginTo), 1),
      jsx:encode([{<<"responseType">>, 120},{<<"login">>, Login}]);
    false ->
      ?LOG_INFO("Contact not found ~p Unable To Send Message", [LoginTo])
  end.

%% сообщение доставлено
handle_message_received(Data) ->
  ?LOG_INFO("Message received",[]),
  Login         = cz_types:get_value(<<"login">>, Data),
  LoginTo       = cz_types:get_value(<<"loginTo">>, Data),
  SyncId        = cz_types:get_value(<<"syncId">>, Data),
  Res = redis:get(?KEY(?kRedisKey_Login, LoginTo)),

  case login_exists(Res) orelse LoginTo =:= <<"-1">> of
    true ->
      MessageType = ?kMessageType_TextMessageReceived,
      Message =
        cz_types:to_list(MessageType)   ++ ";" ++
        cz_types:to_list(Login)         ++ ";" ++
        cz_types:to_list(LoginTo)       ++ ";" ++
        cz_types:to_list(SyncId),

      GlobalId = redis:incr(cz_types:to_binary(?kRedisKey_GlobalId)),
      redis:zadd(?KEY(?kRedisKey_SyncTable, Login), GlobalId, cz_types:to_binary(Message)),
      redis:publish(pub, "chanel:"++cz_types:to_list(Login), 1),
      redis:zadd(?KEY(?kRedisKey_SyncTable, LoginTo), GlobalId, cz_types:to_binary(Message)),
      redis:publish(pub, "chanel:"++cz_types:to_list(LoginTo), 1),
      jsx:encode([{<<"responseType">>, 120},{<<"login">>, Login}]);
    false ->
      ?LOG_INFO("Contact not found ~p Unable To Send Message",[LoginTo])
  end.

login_exists(B) when is_binary(B) -> true;
login_exists(_)  -> false.

get_response_sync(true, true, H) ->
  ?LOG_INFO("Sync messages",[]),
  jsx:encode([{<<"responseType">>, ?kServerResponseType_Sync_Messages},{<<"login">>, H#handle_sync_request.login},{<<"values">>, H#handle_sync_request.syncTableResults}]);
get_response_sync(true, false, H) ->
  jsx:encode([{<<"responseType">>, ?kServerResponseType_Sync_None},{<<"login">>, H#handle_sync_request.login}]);
get_response_sync(false, _, H) ->
  jsx:encode([{<<"responseType">>, ?kServerResponseType_Sync_Contacts},{<<"login">>, H#handle_sync_request.login},{<<"values">>, H#handle_sync_request.contactResults}]).

-define(WS_SERVICE, ws_service).
-define(WS_CONFIG, ws_controller).
-record(ws_controller_config,{
  chanel,
  pid
}).

-define(app_name, webserver).
-define(pool_name,redis_conf).


-define(LOG_ERROR(Format, Data),
  lager:log(error, [], "~p:~p(): " ++ Format ++ "~n~n", [?MODULE, ?LINE] ++ Data)).
-define(LOG_WARNING(Format, Data),
  lager:log(warning, [], "~p:~p(): " ++ Format ++ "~n~n", [?MODULE, ?LINE] ++ Data)).
-define(LOG_INFO(Format, Data),
  lager:log(info, [], "~p.erl:~p: " ++ Format ++ "~n~n", [?MODULE, ?LINE] ++ Data)).


%% Request const
-define(kServerRequestType_LogIn,                   1).
-define(kServerRequestType_LogIn_Verification,      2).
-define(kServerRequestType_SignUp_PersonalInfo,     3).
-define(kServerRequestType_Sync,                    4).
-define(kServerRequestType_AddContact,              5).
-define(kServerRequestType_AddMessage,              6).
-define(kServerRequestType_ReceivedMessage,         7).
-define(kServerRequestType_SeenMessage,             8).
-define(kServerRequestType_RemoveAutodeleteMessage, 9).
-define(kServerRequestType_LogInWithCode,           10).
-define(kServerRequestType_BlackAndWhiteAdd,        11).
-define(kServerRequestType_BlackAndWhiteList,       12).
-define(kServerRequestType_BlackAndWhiteRemove,     13).
-define(kServerRequestType_ChatNow,                 14).
-define(kServerRequestType_GetMessage,              15).
-define(kServerRequestType_GetContacts,             16).
-define(kServerRequestType_GetContactsBook,         17).

%% Response const
-define(kServerResponseType_SyncAvailable,                  100).
-define(kServerResponseType_LogIn_AcceptedForVerification,  101).
-define(kServerResponseType_LogIn_Verification_Invalid,     102).
-define(kServerResponseType_LogIn_LogInCode_Invalid,        103).
-define(kServerResponseType_SignUp_Done,                    104).
-define(kServerResponseType_LogIn_Done,                     105).
-define(kServerResponseType_SignUp_PersonalInfo_Accepted,   106).
-define(kServerResponseType_SignUp_PersonalInfo_Invalid,    107).
-define(kServerResponseType_Sync_Contacts,                  108).
-define(kServerResponseType_Sync_Messages,                  109).
-define(kServerResponseType_Sync_None,                      110).
-define(kServerResponseType_Contact_Undefined,              111).
-define(kServerResponseType_BlackAndWhite,                  112).
-define(kServerResponseType_ChatNow,                        113).
-define(kServerResponseType_Get_Messages,                   114).
-define(kServerResponseType_Get_Contacts,                   115).
-define(kServerResponseType_Get_Contacts_Book,              116).
-define(kServerResponseType_Added_Contacts_Done,            117).

-define(kRedisKey_Login,              "login").
-define(kRedisKey_Phone_Info,         "phoneInfo").
-define(kRedisKey_Session,            "session").
-define(kRedisKey_SyncTable,          "syncTable").
-define(kRedisKey_Contact,            "contact").
-define(kRedisKey_GlobalId,           "globalId").
-define(kRedisKey_LogInCode,          "logInCode").
-define(kRedisKey_BlackList,          "blackList").
-define(kRedisKey_Contacts,          "login:*").

-define(kMessageType_TextMessage,                 1).
-define(kMessageType_TextMessageReceived,         2).
-define(kMessageType_TextMessageSeen,             3).
-define(kMessageType_TextMessageRemoveAutodelete, 4).

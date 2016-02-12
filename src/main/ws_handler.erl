-module(ws_handler).

-include("config.hrl").

-export([init/3, subscribe/1]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
  {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
  ?LOG_INFO("FROM CLIENT ==> TO SOCKET = ~p", [Msg]),
  Response = response(jsx:is_json(Msg), Msg),

  ResponseMsg = case is_binary(Response) of
                  true -> Response;
                  false -> <<"ok">>
                end,
%% 	published(Msg),
%%   {ok, Req, State};
  {reply, {text, <<ResponseMsg/binary>>}, Req, State};
websocket_handle(_Data, Req, State) ->
  {ok, Req, State}.

websocket_info({text, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};
websocket_info({timeout, _Ref, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
  {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
  ok.

response(true, Msg) ->
  RequestData = jsx:decode(Msg),
  protocol:parse(cz_types:get_value(<<"requestType">>, RequestData), RequestData);
response(false, _Msg) -> <<"json is not valid">>.

subscribe(Chanel) ->
  protocol_service:subscribe(Chanel, self()).

%% published(Msg) ->
%%   List = ets:tab2list(ws_service),
%%   published_msg(Msg, List).
%%
%% published_msg(_Msg, []) -> [];
%% published_msg(Msg, [H | Tail]) ->
%%   {ws_config, Pid} = H,
%%   Pid ! {text, Msg},
%%   published_msg(Msg, Tail).
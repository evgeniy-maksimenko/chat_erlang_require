-module(webserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/websocket", ws_handler, []},
      {"/assets/[...]", cowboy_static, {dir, "assets/"}},
      {"/[...]", cowboy_static, {file, "priv/index.html"}}
      
    ]}
  ]),
  Port = 80,
  {ok, _} = cowboy:start_http(http_listener, 100,
    [{port, Port}],
    [{env, [{dispatch, Dispatch}]}]
  ),
  webserver_sup:start_link().

stop(_State) ->
    ok.

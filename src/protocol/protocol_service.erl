-module(protocol_service).

-include("config.hrl").

-export([subscribe/2]).

subscribe(Chanel, Pid) ->
  WsControllerConfig = #ws_controller_config{chanel = Chanel, pid = Pid},
  ets:insert(?WS_CONFIG, WsControllerConfig).

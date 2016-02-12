%%
%% Супервайзер коннектов
%% Следит за супервайзером редиса
%%
-module(connectors_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

-include("config.hrl").

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  ets:new(?WS_CONFIG, [set, named_table, public, {keypos, #ws_controller_config.chanel}]),
  
  Flags = {one_for_one, 5, 10},
  {ok, { Flags , [
    ?CHILD(redis_sup, supervisor)
  ]} }.
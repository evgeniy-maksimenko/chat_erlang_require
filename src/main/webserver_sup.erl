-module(webserver_sup).
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-include("config.hrl").

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

  
  Flags = {one_for_one, 5, 10},
  {ok, { Flags , [
    ?CHILD(connectors_sup, supervisor)
  ]} }.


-module(redis_sup).
-behaviour(supervisor).
-export([start_link/0, cache_query/2, start/0, stop/0, start/2, stop/1]).
-export([init/1]).
-include("config.hrl").

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start() ->
  application:start(?MODULE).

stop() ->
  application:stop(?MODULE).

start(_Type, _Args) ->
  supervisor:start_link({?MODULE, redis_sup_cli}, ?MODULE, []).

stop(_State) ->
  ok.

init([]) ->
  {ok, Pools} = application:get_env(?app_name, pools),
  PoolSpecs = lists:map(fun({Name, SizeArgs, WorkerArgs}) ->
    PoolArgs = [{name, {local, Name}},
      {worker_module, redis_sup_cli}] ++ SizeArgs,
    poolboy:child_spec(Name, PoolArgs, WorkerArgs)
  end, Pools),
  {ok, {{one_for_one, 1000, 3600}, PoolSpecs}}.


cache_query(Client, Query) ->
  ?LOG_INFO("Request to redis ==> From Client ~p, Query ~p", [Client, Query]),
  CALL = poolboy:transaction(?pool_name, fun(Worker) ->
    gen_server:call(Worker, {Client, Query}, 1000)
  end),
  ?LOG_INFO("Response from redis <== ~p", [CALL]),
  case CALL of
    Response when is_binary(Response) orelse is_atom(Response) orelse is_list(Response)-> Response;
    {ok, Resp} when is_binary(Resp) orelse is_atom(Resp) orelse is_list(Resp) -> Resp;
    {error, _} = ErrResp -> ErrResp;
    no_connection ->
      {error, <<"redis worker connection lost">>};
    ErrorResp ->
      erlang:error("cache_query error occured with reason ~p", [ErrorResp]),
      ErrorResp
  end.
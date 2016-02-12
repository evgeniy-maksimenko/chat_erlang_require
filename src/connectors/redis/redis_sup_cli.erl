%%
%% Ген сервер редиса
%% Создает подклчение к редису
%% Отправляет запросы в редис
%% Подписывает на канал
%% Публикует сообщения в канал

-module(redis_sup_cli).
-behaviour(gen_server).
-behaviour(poolboy_worker).
-export([start_link/1]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-include("config.hrl").
-record(state, {
  pub,
  global,
  sub
}).

start_link(Args) ->
  gen_server:start_link(?MODULE, Args, []).

init(Args) ->
  process_flag(trap_exit, true),
  Host      = cz_types:get_value(host, Args),
  Port      = cz_types:get_value(port, Args),
  Password  = cz_types:get_value(password, Args),
  Database  = cz_types:get_value(database, Args, 0),

  {ok, GlobalRedisClient} = eredis:start_link(Host, Port, Database, Password),
  {ok, RedisSubClient}    = eredis_sub:start_link(Host, Port, Password),
  {ok, RedisPubClient}    = eredis:start_link(Host, Port, Database, Password),

  {ok, #state{pub = RedisPubClient, sub = RedisSubClient, global = GlobalRedisClient}}.

handle_call({global, Query}, _From, State) ->
  {reply, eredis:q(State#state.global, Query), State};
handle_call({pub, Query}, _From, State) ->
  eredis_sub:controlling_process(State#state.sub),
  {reply, eredis:q(State#state.pub, Query), State};
handle_call({sub, Query}, _From, State) ->
  eredis_sub:controlling_process(State#state.sub),
  {reply, eredis_sub:subscribe(State#state.sub, Query), State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info({message, ChanelKeyBin, _ChanelValBin, _Pid}, State) ->
  [{_, _, Pid}] = ets:lookup(?WS_CONFIG, ChanelKeyBin),
  Pid ! {text, jsx:encode([{<<"responseType">>, ?kServerResponseType_SyncAvailable}])},
  {noreply, State};
handle_info(_Info, State) ->
  ?LOG_INFO("CHANNEL <== ~p", [_Info]),
  {noreply, State}.

terminate(Reason, _State) ->
  ?LOG_INFO("redis worker ~p terminated wtih reason ~p", [self(), Reason]),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
-module(redis).
-export([incr/1, set/2, set/3, get/1, setex/2, getset/2, setnx/2, hmset/2, subscribe/1, zadd/3, zrangebyscore/4, publish/2, sadd/2, sadd/2, smembers/1, srem/2, zrem/2, sismember/2, zrange/3, keys/1]).
-export([subscribe/2, publish/3]).
-export([cache_query/1, cache_query/2]).

sadd(Key, Value) ->
  Query = ["SADD",  Key, Value],
  cache_query(Query).

srem(Key, Value) ->
  Query = ["SREM",  Key, Value],
  cache_query(Query).

zrem(Key, Value) ->
  Query = ["ZREM",  Key, Value],
  cache_query(Query).

smembers(Key) ->
  Query = ["SMEMBERS", Key],
  cache_query(Query).

sismember(Key, Value) ->
  Query = ["SISMEMBER", Key, Value],
  cache_query(Query).

incr(Key) ->
  Query = ["INCR", Key],
  cache_query(Query).

get(Key) ->
  Query = ["GET", Key],
  cache_query(Query).

set(Key, Value) ->
  Query = ["SET", Key, Value],
  cache_query(Query).

keys(Value) ->
  Query = ["KEYS", Value],
  cache_query(Query).


set(Key, Value, Timeout) ->
  Query = ["SET", Key, Value],
  QueryRes = cache_query(Query),
  case QueryRes of
    <<"OK">> -> setex(Key, Timeout);
    _ ->QueryRes
  end.

getset(Key, Value) ->
  Query = ["GETSET", Key, Value],
  cache_query(Query).

setnx(Key, Value) ->
  Query = ["SETNX", Key, Value],
  Result = cache_query(Query),
  case Result of
    <<"0">> -> false;
    <<"1">> -> true
  end.

setex(Key, Timeout) ->
  Query = ["EXPIRE", Key, Timeout],
  cache_query(Query).

hmset(Key, FieldValues) when length(FieldValues) > 0 ->
  Query = ["HMSET" | [Key|field_value_args(FieldValues)]],
  cache_query(Query).

field_value_args(FieldValues) ->
  lists:concat([[Field, Value] || {Field, Value} <- FieldValues]).

subscribe(Channels) ->
  Query = ["SUBSCRIBE" , Channels],
  cache_query(Query).

subscribe(Client, Channels) ->
  Query = ["SUBSCRIBE" , Channels],
  cache_query(Client, Query).

publish(Channel, Message) ->
  Query = ["PUBLISH" , Channel, Message],
  cache_query(Query).

publish(Client, Channel, Message) ->
  Query = ["PUBLISH" , Channel, Message],
  cache_query(Client, Query).

zadd(Key, Score, Member) ->
  zmadd(Key, [{cz_types:to_integer(Score), Member}]).

zmadd(Key, Members) when length(Members) > 0 ->
  Query = ["ZADD" | [Key|scored_members_args(Members)]],
  cache_query(Query).

scored_members_args(Members) ->
  scored_members_args(Members, []).



scored_members_args([], Acc) -> lists:concat(lists:reverse(Acc));
scored_members_args([{Score, Member}|Rest], Acc) when is_number(Score) -> scored_members_args(Rest, [[format_number(Score), Member]|Acc]);
scored_members_args([Other |_], _) -> error({badarg, Other}).


format_number(I) when is_integer(I) -> list_to_binary(integer_to_list(I));
format_number(F) when is_float(F) -> io_lib:format("~8.f",[F]);
format_number(Other) -> Other.


zrangebyscore(Key, Min, Max, Options) ->
  Query = ["ZRANGEBYSCORE" | [Key, format_min_score(Min), format_max_score(Max), withscores_args(Options)]],
  cache_query(Query).


zrange(Key, Min, Max) ->
  Query = ["ZRANGE" | [Key, format_min_score(Min), format_max_score(Max)]],
  cache_query(Query).


format_min_score(infinity) -> "-inf";
format_min_score(Min) -> format_number(Min).


format_max_score(infinity) -> "+inf";
format_max_score(Max) -> format_number(Max).


withscores_args(withscores) -> "WITHSCORES";
withscores_args(Other) -> Other.



cache_query(Query) -> redis_sup:cache_query(global, Query).
cache_query(Client, Query) -> redis_sup:cache_query(Client, Query).

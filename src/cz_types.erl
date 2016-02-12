%%
%% Модуль преобразование типов
%%
-module(cz_types).
-export([to_integer/1]).
-export([get_value/2]).
-export([get_value/3]).
-export([to_list/1]).
-export([to_binary/1]).
-export([to_atom/1]).

get_value(Key, Value) ->
  get_value(Key, Value, undefined).

get_value(Key, List, Default) ->
  case lists:keyfind(Key, 1, List) of
    false -> Default;
    {Key, Value} -> Value
  end.


to_list(Value) when is_list(Value) -> Value;
to_list(Value) when is_binary(Value) -> binary_to_list(Value);
to_list(Value) when is_atom(Value) -> atom_to_list(Value);
to_list(Value) when is_integer(Value) -> integer_to_list(Value);
to_list(Value) when is_tuple(Value) -> tuple_to_list(Value).

to_binary(Value) when is_binary(Value) -> Value;
to_binary(Value) when is_list(Value) -> list_to_binary(Value);
to_binary(Value) when is_atom(Value) -> list_to_binary(atom_to_list(Value));
to_binary(Value) when is_integer(Value) -> integer_to_binary(Value);
to_binary(Value) when is_tuple(Value) -> list_to_binary(tuple_to_list(Value)).

to_atom(Value) when is_atom(Value) -> Value;
to_atom(Value) when is_list(Value) -> list_to_atom(Value);
to_atom(Value) when is_binary(Value) -> binary_to_list(list_to_atom(Value));
to_atom(Value) when is_integer(Value) -> integer_to_list(list_to_atom(Value));
to_atom(Value) when is_tuple(Value) -> tuple_to_list(list_to_atom(Value)).

to_integer(Value) when is_integer(Value) -> Value;
to_integer(Value) when is_binary(Value) -> binary_to_integer(Value);
to_integer(Value) when is_atom(Value) -> list_to_integer(atom_to_list(Value));
to_integer(Value) when is_list(Value) -> list_to_integer(Value).
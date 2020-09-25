%%%-------------------------------------------------------------------
%%% @author m7azeem
%%%
%%% @end
%%% Created : 08. Sep 2020 7:51 PM
%%%-------------------------------------------------------------------
-module(test).
-author("m7azeem").

%% API
-export([bench/2]).

bench(Host, Port) ->
  Start = erlang:system_time(micro_seconds),
  run(100, Host, Port),
  Finish = erlang:system_time(micro_seconds),
  io:format("total time taken: ~w microseconds~n", [Finish - Start]),
  Finish - Start.

run(N, Host, Port) ->
%%  io:format("running ~w~n", [N]),
  if
    N == 0 ->
      ok;
    true ->
      request(Host, Port),
      run(N-1, Host, Port)
  end.

request(Host, Port) ->
  Opt = [list, {active, false}, {reuseaddr, true}],
  {ok, Server} = gen_tcp:connect(Host, Port, Opt),
  gen_tcp:send(Server, http:get("foo")),
  Recv = gen_tcp:recv(Server, 0),
  case Recv of
    {ok, _} ->
      ok;
    {error, Error} ->
      io:format("test: error: ~w~n", [Error]),
      error
  end,
  gen_tcp:close(Server).
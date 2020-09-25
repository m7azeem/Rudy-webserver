%%%-------------------------------------------------------------------
%%% @author m7azeem
%%%
%%% @end
%%% Created : 08. Sep 2020 5:12 PM
%%%-------------------------------------------------------------------
-module(rudy).
-author("m7azeem").

%% API
-export([start/1, stop/0]).

start(Port) ->
  register(rudy, spawn(fun() -> init(Port) end)),
  io:format("Rise and sunshine Rudy ~n").


stop() ->
  exit(whereis(rudy), "Nighty night Rudy!").

super() ->
  receive
    stop ->
      ok
  end.

init(Port) ->
  Opt = [list, {active, false}, {reuseaddr, true}],
  case gen_tcp:listen(Port, Opt) of
    {ok, Listen} ->
      spawn(fun() -> handler(Listen) end),
      super();
    {error, Error} ->
      io:format("Rudy: Failed to open socket ~w~n", [Error]),
      error
  end.

handler(Listen) ->
  case gen_tcp:accept(Listen) of
    {ok, Client} ->
      request(Client),
      handler(Listen);
    {error, Error} ->
      io:format("Rudy: Failed to listen ~w~n", [Error]),
      error
  end.

request(Client) ->
  Recv = gen_tcp:recv(Client, 0),
  case Recv of
    {ok, Str} ->
      Request = http:parse_request(Str),
%%      Uncomment this line (and comment the lower line) to enable reading of files (the filename will have to equal to the URI)
%%      Response = send_file(Request),
      Response = reply(Request),
      gen_tcp:send(Client, Response);
    {error, Error} ->
      io:format("rudy: error: ~w~n", [Error]),
      error
  end,
  gen_tcp:close(Client).

reply({{get, URI, _}, _, _}) ->
%% Sleep time added to simulate io calls
  timer:sleep(40),
  http:ok("<html><head><title><Rudy></title></head><body>Request URI is: "++ URI ++ "</body></html>").


%%Following methods are to read files.
reply_without_file(URI) ->
  http:ok("<html><head><title><Rudy></title></head><body>Request URI is: "++ URI ++ "<br>No related file!</body></html>").

send_file({{get, URI, _}, _, _}) ->
  case file:open(URI, [read]) of
    {ok, Device} ->
      io:format("tring to read"),
      File = read_lines(Device),
      file:close(Device),
      http:ok([File]);
    {error, Error} ->
      io:format("Rudy: No such file!~n"),
      reply_without_file(URI)
  end.

read_lines(Device) ->
  case io:get_line(Device) of
    eof -> [];
    {ok, Line} -> [Line ++ read_lines(Device)]
  end.
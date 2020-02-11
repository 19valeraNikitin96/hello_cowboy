%%%-------------------------------------------------------------------
%%% @author erlang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Feb 2020 11:59
%%%-------------------------------------------------------------------
-module(post_test).
-author("erlang").

%% API
-export([init/2]).
-export([allowed_methods/2, content_types_provided/2, content_types_accepted/2]).
-export([func1/2]).

init(Req0, Opts)->
  {cowboy_rest,Req0,Opts}.

allowed_methods(Req, State) ->
  {[<<"POST">>],Req,State}.

content_types_provided(Req, State) ->
  {[
    {{<<"application">>,<<"json">>,[]},func1}
  ], Req, State}.

content_types_accepted(Req, State) ->
  {[{{<<"application">>,<<"json">>, '*'},func1}],
    Req, State}.

func1(Req0,State)->
  {ok, KeyValues, Req1} = cowboy_req:read_urlencoded_body(Req0),
  [{Data, _}|[]] = KeyValues,
  Map = jsx:decode(Data, [return_maps]),
  {ok,Value}=maps:find(<<"data">>, Map),
  Req2 = cowboy_req:set_resp_body(jsx:encode([{<<"echo">>, Value}]), Req1),
  {true,Req2,State}.
%%%-------------------------------------------------------------------
%%% @author erlang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Feb 2020 13:38
%%%-------------------------------------------------------------------
-module(web_server_tests).
-author("erlang").

-include_lib("eunit/include/eunit.hrl").

first_test() ->
%%  hello_cowboy_app:start(undefined,undefined).
  inets:start(),
  Method = post,
  URL = "http://localhost:8080/api/cache_server",
  Header = [{<<"Accept">>,<<"application/json">>}],
  Type = "application/json",
  Body = "{
    \"action\": \"insert\",
    \"key\": 11349,
    \"value\": 1149
  }",
  HTTPOptions = [],
  Options = [],
  R = httpc:request(Method, {URL, Header, Type, Body}, HTTPOptions, Options),
  {ok, {{"HTTP/1.1", ReturnCode, _State}, _Head, _RBody}} = R,
  ?assertEqual(200, ReturnCode).
%%  ?assertEqual("{\"result\": \"ok\"}",Body).



%%================================================
%%-include_lib("common_test/include/ct.hrl").
%%
%%% etest macros
%%-include_lib ("etest/include/etest.hrl").
%%% etest_http macros
%%-include_lib ("etest_http/include/etest_http.hrl").
%%%-------------------------------------------------------------------
%%% @author erlang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Feb 2020 12:46
%%%-------------------------------------------------------------------
-module(cache_server).
-author("erlang").
-include("header.hrl").
%% API
-export([init/2]).
-export([]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	HasBody = cowboy_req:has_body(Req0),
	Req = handler(Method, HasBody, Req0),
	{ok, Req, Opts}.

handler(<<"POST">>, true, Req0)->
	{ok, KeyValues, Req1} = cowboy_req:read_urlencoded_body(Req0),
	[{Data, _}|[]] = KeyValues,
	Map = jsx:decode(Data, [return_maps]),
	{_,Act}=maps:find(<<"action">>,Map),
	Body = data_handler(Act, maps:remove(Act, Map)),
	cowboy_req:reply(200,#{<<"content-type">> => <<"application/json">>},Body,Req1).

data_handler(<<"insert">>, Map) ->
	{_, K} = maps:find(<<"key">>, Map),
	{_, V} = maps:find(<<"value">>, Map),
	my_cache:insert(K, V, 3600),
	jsx:encode([{<<"result">>, <<"ok">>}]);
data_handler(<<"lookup">>, Map)->
	{_, K} = maps:find(<<"key">>, Map),
	{_, _, {_, DataList}} = my_cache:lookup(K),
	case DataList == [] of
		true -> jsx:encode([{<<"result">>, undefined}]);
		false -> [H|[]] = DataList,
			{_, V2,_} = H,
			jsx:encode([{<<"result">>, V2}])
	end;
data_handler(<<"lookup_by_date">>, Map)->
	{_, DF} = maps:find(<<"date_from">>, Map),
	{_, DT} = maps:find(<<"date_to">>, Map),
	jsx:encode([{<<"result">>, my_cache:lookup(DF, DT)}]).

%%Not WORKING REST VARIANT. Server error during request. Returns proper response.
%%content_types_provided(Req, State) ->
%%	{[
%%%%		{{<<"application">>,<<"json">>, []}, response_json}
%%		{<<"application/json">>, response_json}
%%	], Req, State}.
%%
%%allowed_methods(Req, State) ->
%%	Methods = [<<"POST">>],
%%	{Methods, Req, State}.
%%
%%content_types_accepted(Req, State) ->
%%	{[
%%		{{<<"application">>,<<"json">>, '*'}, response_json}
%%	], Req, State}.
%%
%%response_json(Req, State) ->
%%	{ok, KeyValues, Req1} = cowboy_req:read_urlencoded_body(Req),
%%	[{Data, _}|[]] = KeyValues,
%%	Map = jsx:decode(Data, [return_maps]),
%%	{_,Act}=maps:find(<<"action">>,Map),
%%	Body = data_handler(Act, maps:remove(Act, Map)),
%%%%	Req2 = cowboy_req:reply(200,#{<<"content-type">> => <<"application/json">>},Body,Req1),
%%	{Body, Req1, State}.
%%
%%data_handler(<<"insert">>, Map) ->
%%	{_, K} = maps:find(<<"key">>, Map),
%%	{_, V} = maps:find(<<"value">>, Map),
%%	my_cache:insert(K, V, 3600),
%%	jsx:encode([{<<"result">>, <<"ok">>}]);
%%data_handler(<<"lookup">>, Map)->
%%	{_, K} = maps:find(<<"key">>, Map),
%%	{_, _, {_, DataList}} = my_cache:lookup(K),
%%	case DataList == [] of
%%		true -> jsx:encode([{<<"result">>, undefined}]);
%%		false -> [H|[]] = DataList,
%%			{_, V2,_} = H,
%%			jsx:encode([{<<"result">>, V2}])
%%	end;
%%data_handler(<<"lookup_by_date">>, Map)->
%%	{_, DF} = maps:find(<<"date_from">>, Map),
%%	{_, DT} = maps:find(<<"date_to">>, Map),
%%	jsx:encode([{<<"result">>, my_cache:lookup(DF, DT)}]).
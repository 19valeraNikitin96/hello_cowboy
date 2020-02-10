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
-export([content_types_provided/2, response_json/2, allowed_methods/2, content_types_accepted/2]).

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
	{[
		{<<"application/json">>, response_json}
	], Req, State}.

allowed_methods(Req, State) ->
	Methods = [<<"POST">>],
	{Methods, Req, State}.

content_types_accepted(Req, State) ->
	{[
		{<<"application/json">>, response_json}
%%		{<<"application/x-www-form-urlencoded">>, response_json}
	], Req, State}.

response_json(Req, State) ->
	{ok, KeyValues, _Req1} = cowboy_req:read_urlencoded_body(Req),
	[{Data, _}|[]] = KeyValues,
	Map = jsx:decode(Data, [return_maps]),
	{_,Act}=maps:find(<<"action">>,Map),
	Body = data_handler(Act, maps:remove(Act, Map)),
	{Body, Req, State}.

data_handler(<<"insert">>, Map) ->
	{_, K} = maps:find(<<"key">>, Map),
	{_, V} = maps:find(<<"value">>, Map),
	my_cache:insert(K, V, 60),
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
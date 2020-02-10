-module(hello_handler).
%%-behavior(cowboy_handler).

-export([init/2]).
-export([hello_to_html/2, content_types_provided/2, hello_to_json/2, hello_to_text/2, read_body_to_console/1]).
%%=================================================
%%EXAMPLE chunked hello world
%%init(Req0, Opts) ->
%%	Req = cowboy_req:stream_reply(200, Req0),
%%	cowboy_req:stream_body("Hello\r\n", nofin, Req),
%%	timer:sleep(1000),
%%	cowboy_req:stream_body("World\r\n", nofin, Req),
%%	timer:sleep(1000),
%%	cowboy_req:stream_body("Chunked!\r\n", fin, Req),
%%	{ok, Req, Opts}.

init(Req, Opts) ->
	{cowboy_rest, Req, Opts}.

%%===================================================================
%%EXAMPLE rest hello world

content_types_provided(Req, State) ->
%%	read_body_to_console(Req),
%%	io:format("~s", [Req]),
	{[
		{<<"text/html">>, hello_to_html},
		{<<"application/json">>, hello_to_json},
		{<<"text/plain">>, hello_to_text}
	], Req, State}.

read_body_to_console(Req0) ->
	case cowboy_req:read_body(Req0) of
		{ok, Data, Req} ->
			io:format("~s", [Data]),
			Req;
		{more, Data, Req} ->
			io:format("~s", [Data]),
			read_body_to_console(Req)
	end.

hello_to_html(Req, State) ->
	Body = <<"<html>
<head>
	<meta charset=\"utf-8\">
	<title>REST Hello World!</title>
</head>
<body>
	<p>REST Hello World as HTML!</p>
</body>
</html>">>,
	{Body, Req, State}.

hello_to_json(Req, State) ->
	Body = <<"{\"rest\": \"Hello World!\"}">>,
	{Body, Req, State}.

hello_to_text(Req, State) ->
	{<<"REST Hello World as text!">>, Req, State}.

%%===================================================

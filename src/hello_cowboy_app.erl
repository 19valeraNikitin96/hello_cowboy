-module(hello_cowboy_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile(
		[
			{'_', [
				{"/hello", hello_handler, []},
				{"/api/cache_server", cache_server, []},
				{"/test1", post_test, []}
				]
			}
		]
	),
	{ok, _} = cowboy:start_clear(my_http_listener,
		[{port, 8080}],
		#{env => #{dispatch => Dispatch}}
	),
	hello_cowboy_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(my_http_listener).
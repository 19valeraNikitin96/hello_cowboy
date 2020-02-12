-module(my_cache_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile(
		[
			{'_', [
				{"/api/cache_server", my_cache_server, []}
				]
			}
		]
	),
	{ok, _} = cowboy:start_clear(my_http_listener,
		[{port, 8080}],
		#{env => #{dispatch => Dispatch}}
	),
	my_cache_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(my_http_listener).
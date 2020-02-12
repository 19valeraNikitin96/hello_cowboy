-module(my_cache_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	Procs = [#{id => my_cache,
		start => {my_cache, start_link, []},
		restart => permanent,
		shutdown => brutal_kill,
		type => worker,
		modules => [my_cache]}],
	{ok, {{one_for_one, 1, 5}, Procs}}.

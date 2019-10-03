-module(flamingo).

-export([start/1, new_route/3, request/4, drop_route/2]).

start(_Global) ->
    nope.

request(_Flamingo, _Request, _From, _Ref) ->
    nope.

new_route(_Flamingo, _Prefixes, _Action) ->
    nope.

drop_route(_Flamingo, _Id) ->
    not_implemented.

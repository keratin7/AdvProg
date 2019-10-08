-module(flamingo).

-export([start/1, new_route/3, request/4, drop_route/2]).

start(Global) -> 
	A = spawn(fun() -> loop({Global, maps:new()}) end),
	{ok, A}.
	% Implement error case {error reason}


request(Flamingo, Request, From, Ref) ->
	Flamingo ! {Request, From, Ref}.

new_route(Flamingo, Prefixes, Action) ->
    Flamingo ! {self(), Prefixes, Action},
    receive
    	{ok,Id} -> {ok, Id}
    end.

drop_route(_Flamingo, _Id) ->
    not_implemented.

    % {String, map()}
loop({String, Routes}) ->
	receive
		{{Path, ArgList}, F, Ref} ->
			Res = handle_req(String, Routes, Path, ArgList),
			F ! {Ref, Res},
			loop({String, Routes});

		{From, Li, Act} ->
			NewLi = [ {X,Act} || X <- Li ],
			TempMap = maps:from_list(NewLi),
			NewMap = maps:merge(Routes, TempMap),
		 	From ! {ok, NewMap},
		 	loop({String, NewMap});

		{From, Msg} ->
			From ! {cool, Msg},
			loop({String, Routes});

		stop ->
			true
	end.

handle_req(String, Routes, Path, ArgList) ->
	Fan = maps:get(Path, Routes),
	Fan({Path, ArgList}, String).



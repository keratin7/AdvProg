-module(flamingo).

-export([start/1, new_route/3, request/4, drop_route/2]).

start(Global) ->
	% Checks if new server is spawned.
	try
		A = spawn(fun() -> loop({Global, maps:new()}) end),
		{ok, A}
	catch
		_Exception:_Reason -> "Couldn't spawn new server"
	end.

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
		{{Path, ArgList}, F, Ref} ->	% request()
			Res = handle_req(String, Routes, Path, ArgList),
			F ! {Ref, Res},
			loop({String, Routes});

		{From, Li, Act} ->	% new_route()
			NewLi = [ {X,Act} || X <- Li ], % Create list of {Prefix,Action} tuples
			TempMap = maps:from_list(NewLi),
			NewMap = maps:merge(Routes, TempMap), % Any old prefixes are replaced
		 	From ! {ok, NewMap},
		 	loop({String, NewMap});	% Update state
		 	
		stop ->
			true
	end.

handle_req(String, Routes, Path, ArgList) ->
	try
		Fan = maps:get(Path, Routes),	% Get action
		try
			Fan({Path, ArgList}, String)	% Execute action
		catch
			_Exception:_Reason -> {500, "text/plain", "Action failed. "}
		end
	catch
		_E:_R -> {404, "text/plain", "No matching route."}
	end.

	


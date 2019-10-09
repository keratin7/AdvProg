-module(mood).
-export([server/0]).

moo(_Req, Server) ->
	Server ! {self(),moo},
	{200, "text/plain", "That's funny"}.

mood(_Req, Server) ->
	Server ! {self()},
	receive
		X -> X
	end,
	if X =:= moo -> {200, "text/plain", "Happy!"};
	   X =:=initial -> {200, "text/plain", "Sad"}
	end.

server() -> 
	N = moo_ser(),
	{ok, F} = flamingo:start(N),
	flamingo:new_route(F,["/moo"], fun moo/2),
	flamingo:new_route(F,["/mood"], fun mood/2),
	F.

moo_ser() -> 
	Npid = spawn(fun() -> loop(initial) end),
	Npid.

loop(State) ->
	receive
		{_F,X} ->
			loop(X);
		{F} ->
			F ! State,
			loop(State)
	end.

-module(counter).
-export([server/0]).

inc({_Path, [{K, N} | _ ]}, Server) ->
	IntN = list_to_integer(N),
	NN = if 	% Check if key is "x" or value is negative
		K =/= "x" -> 1;
		IntN<0 -> 1;
		K =:= "x" -> IntN
	end,
	Server ! {self(), in, NN},
	receive
		{C} -> C
	end,
	{200, "text/plain", integer_to_list(C)}.

dec({_Path, [{K, N} | _ ]}, Server) ->
	IntN = list_to_integer(N),
	NN = if 	% Check if key is "x" or value is negative
		K =/= "x" -> 1;
		IntN<0 -> 1;
		K =:= "x" -> IntN
	end,
	Server ! {self(), de, NN},	%Message to spawned counter server
	receive
		{C} -> C
	end,
	{200, "text/plain", integer_to_list(C)}.

server() ->
	Count_id = counter_server(),
	{ok, F} = flamingo:start(Count_id),
	flamingo:new_route(F, ["/inc_with"], fun inc/2 ),
	flamingo:new_route(F, ["/dec_with"], fun dec/2 ),
	F.

counter_server() ->
	C_id = spawn(fun() -> loop(0) end),
	C_id.

loop(Count) ->
	receive
		{F, in, N} -> 
			NewCount = Count + N,
			F ! {NewCount},
			loop(NewCount);

		{F, de, N} ->
			NewCount = Count - N,
			F ! {NewCount},
			loop(NewCount)
	end.




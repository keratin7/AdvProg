-module(counter).
-export([server/0]).

inc({_Path, [{"x", N} | _ ]}, Server) ->
	Server ! {self(), in, list_to_integer(N)},
	receive
		{C} -> C
	end,
	{200, "text/plain", integer_to_list(C)}.

dec({_Path, [{"x", N} | _ ]}, Server) ->
	Server ! {self(), de, list_to_integer(N)},
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




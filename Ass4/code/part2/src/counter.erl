-module(counter).
-export([server/0]).

inc({_Path, Li}, Server) ->
	Val = checkli(Li),
	Server ! {self(), in, Val},
	receive
		{C} -> C
	end,
	{200, "text/plain", integer_to_list(C)}.

dec({_Path, Li}, Server) ->
	Val = checkli(Li),
	Server ! {self(), de, Val},	%Message to spawned counter server
	receive
		{C} -> C
	end,
	{200, "text/plain", integer_to_list(C)}.

% Checks what value should be passed to the counter
checkli(Li) ->
	case Li of
		[] -> 1;
		[{"x",V}|_] ->
			IntV = list_to_integer(V),
			if
				IntV >= 0 -> IntV;
				true -> 1
			end;
		[_|T] -> checkli(T)
	end.  

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




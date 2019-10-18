-module(rps).
-import(broker, [start_link/0]).
-export([tell_state/1, start/0, queue_up/3, move/2, statistics/1, drain/3]).

start() -> 
	broker:start_link().
	
queue_up(Broker_Ref, Name, Rounds) ->
	gen_server:call(Broker_Ref, {Name, Rounds}, infinity).

tell_state(Broker_Ref)->
	gen_server:call(Broker_Ref, tell).

move(Coord, Choice) ->
	gen_statem:call(Coord, {move, Choice}).

statistics(Broker_Ref) ->
	gen_server:call(Broker_Ref, stats).

drain(Broker_Ref, Pid, Msg) ->
	gen_server:cast(Broker_Ref, {Pid, Msg, drain}).




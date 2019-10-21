-module(test_rps).
-export([test_all/0]).

%% Maybe you want to use eunit
-include_lib("eunit/include/eunit.hrl").


test_all() ->
    eunit:test(
      [
       start_broker(), check_queue_up(),check_move(),check_statistics()
      ], [verbose]).


start_broker() ->
    {"Start a broker, and nothing else",
     fun() ->
             ?assertMatch({ok, _}, rps:start())
     end}.

check_queue_up() ->
    {"check queue up",
     fun() ->
     	{ok,A} = rps:start(),
     	spawn(fun()->rps:queue_up(A,a,3) end),
             ?assertMatch({ok, _,_,0}, rps:statistics(A))
     end}.

check_move() ->
    {"check move",
     fun() ->
     	{ok,A} = rps:start(),
     	spawn(fun()->{ok,_,CID}=rps:queue_up(A,a,3) ,
     		rps:move(CID,rock),
     		rps:move(CID,rock),
     		rps:move(CID,scissors)
     	end),
     	{ok,P2,CID} = rps:queue_up(A,b,3),
     		?assertMatch({ok,a,_}, {ok,P2,CID}),
     		?assertMatch(round_lost, rps:move(CID,scissors)),
     		?assertMatch(tie, rps:move(CID,rock)),
     		?assertMatch({game_over,0,2}, rps:move(CID,paper))
     end}.

check_statistics() ->
    {"check move",
     fun() ->
     	{ok,A} = rps:start(),
     	spawn(fun()->{ok,_,CID}=rps:queue_up(A,a,3) ,
     		rps:move(CID,rock),
     		rps:move(CID,rock),
     		rps:move(CID,rock)
     	end),
		{ok,P2,CID} = rps:queue_up(A,b,3),
     	spawn(fun()->{ok,_,CID1}=rps:queue_up(A,c,3) ,
     		rps:move(CID1,rock),
     		rps:move(CID1,rock)
     		
     	end),
     		?assertMatch({ok,a,_}, {ok,P2,CID}),
     		?assertMatch(round_lost, rps:move(CID,scissors)),
     		?assertMatch(tie, rps:move(CID,rock)),
      		?assertMatch({game_over,0,2}, rps:move(CID,scissors)),
        
     	{ok,P4,_CID} = rps:queue_up(A,d,3),
            ?assertMatch({ok,c,_}, {ok,P4,_CID}),
     		?assertMatch(round_won, rps:move(_CID,paper)),
			?assertMatch(ok, rps:drain(A,self(),msg_drain))
     		
     end}.
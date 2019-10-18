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
     	P1 = spawn(fun()->rps:queue_up(A,a,3) end),
             ?assertMatch({ok, _,_,0}, rps:statistics(A))
     end}.

check_move() ->
    {"check move",
     fun() ->
     	{ok,A} = rps:start(),
     	P1 = spawn(fun()->{ok,_,CID}=rps:queue_up(A,a,3) ,
     		rps:move(CID,rock),
     		rps:move(CID,rock),
     		rps:move(CID,paper),
     		rps:move(CID,scissors)
     	end),
     	{ok,P2,CID} = rps:queue_up(A,b,3),
     		?assertMatch({ok,a,_}, {ok,P2,CID}),
     		?assertMatch(round_lost, rps:move(CID,scissors)),
     		?assertMatch(tie, rps:move(CID,rock)),
     		?assertMatch(round_won, rps:move(CID,scissors)),
     		?assertMatch({game_over,1,2}, rps:move(CID,paper))
     end}.

check_statistics() ->
    {"check move",
     fun() ->
     	{ok,A} = rps:start(),
     	P1 = spawn(fun()->rock_bot:queue_up_and_play(A) end),
     	{ok,P2,CID} = rps:queue_up(A,b,3),
     	P3 = spawn(fun()->rock_bot:queue_up_and_play(A) end),
     		?assertMatch({ok,"Rock bot(tom)",_}, {ok,P2,CID}),
     		?assertMatch(round_lost, rps:move(CID,scissors)),
     		?assertMatch(tie, rps:move(CID,rock)),
      		?assertMatch({game_over,0,2}, rps:move(CID,scissors)),
        
     	{ok,P4,_CID} = rps:queue_up(A,c,3),
            ?assertMatch({ok,"Rock bot(tom)",_}, {ok,P4,_CID}),
     		?assertMatch(round_won, rps:move(_CID,paper)),
     		?assertMatch({game_over,2,0}, rps:move(_CID,paper))
     		
     end}.
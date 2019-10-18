-module(async).

-export([new/2, wait/1, poll/1]).

new(Fun, Arg) -> spawn(fun() -> start_supervisor(Fun, Arg) end).


wait(Aid) -> 
	Ref = make_ref(),
	Me  = self(),
	Aid ! {send_info, Me, Ref},
	receive
		{Ref, {exception, Ex}} -> throw(Ex);
		{Ref,{ok, Result}} -> Result
	end.

poll(Aid) -> 
	Ref = make_ref(),
	Me = self(),
	Aid ! {are_you_ready, Me, Ref},
	receive
		{Ref, Result} -> Result
	end.

start_supervisor(Fun, Arg) ->
	process_flag(trap_exit, true),
	Super_Pid = self(),
	Action_Pid = spawn_link(fun() ->
				Result =
				try 
					Fun(Arg)
				catch
					_Exception:Reason -> {exception, Reason}
				end,
				Super_Pid ! {result, self(), Result} end),
	loop_supervisor(Action_Pid,{},[]).

loop_supervisor(Action_Pid, Result_state, Sub_list) -> 
	receive
		{'EXIT', Action_Pid, {Ex, _}} -> 
						send_msg({exception, Ex}, Sub_list),
						loop_supervisor(Action_Pid, {exception, Ex}, []);
		{are_you_ready, From, Ref} -> 
						case Result_state of
							{ok, Result} -> From ! {Ref, {ok, Result}},
											loop_supervisor(Action_Pid, Result_state, Sub_list);
							{exception, Ex} -> From ! {Ref, {exception, Ex}},
											loop_supervisor(Action_Pid, Result_state, Sub_list);
							_ -> From ! {Ref, nothing},
							loop_supervisor(Action_Pid, Result_state, Sub_list)
						end;
		{send_info, From, Ref} ->
						case Result_state of
							{ok, Result} -> From ! {Ref, {ok, Result}},
											loop_supervisor(Action_Pid, Result_state, Sub_list);
							{exception, Ex} -> From ! {Ref, {exception, Ex}},
											loop_supervisor(Action_Pid, Result_state, Sub_list);
							_ -> self()!{send_info, From, Ref},
							loop_supervisor(Action_Pid, Result_state, Sub_list)

						end;
		{result, Action_Pid, {exception, Reason}} -> 
						send_msg({exception, Reason}, Sub_list),
						loop_supervisor(Action_Pid, {exception, Reason}, []);

		{result, Action_Pid, Result} -> 
						send_msg({ok, Result}, Sub_list),
						loop_supervisor(Action_Pid, {ok, Result}, [])

	end. 

send_msg(_, []) -> nothing;
send_msg(Result, [{From, Ref}|Tail]) -> From ! {Ref, Result},
										send_msg(Result, Tail).


%% Optional functions, recommended

% wait_catch(Aid) -> nope.
% wait_any(Aids) -> nope.

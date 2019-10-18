-module(coordinator).
-behaviour(gen_statem).

-export([start/1]).
-export([terminate/3,code_change/4,init/1,callback_mode/0]).
-export([match/3, waiting_for_player1/3, waiting_for_player2/3, game_over/3 ]).

%% API.  This example uses a registered name name()
%% and does not link to the caller.
start(Game_Deatils) ->
    gen_statem:start(?MODULE, Game_Deatils, []).

%% Mandatory callback functions
terminate(_Reason, _State, _Data) ->
    void.
code_change(_Vsn, State, Data, _Extra) ->
    {ok,State,Data}.

init(Game_Deatils) ->
    %% Set the initial state + data.
    State = match, 
    Data = #{player1 => lists:nth(1, Game_Deatils),
            player2 => lists:nth(2, Game_Deatils),
            scores => {0,0},
            rounds => lists:nth(3, Game_Deatils),
            game_length => 0,
            last_move => none,
            round_no => 0,
            bro_ref => lists:nth(4, Game_Deatils)
            } ,
    {ok,State,Data}.
callback_mode() -> state_functions.

%%% state callback(s)

match({call,{From,_R}=F}, {move, Choice}, #{player1 := Player1, player2 := Player2} = Data) ->
    {P1_id,_Re} = Player1,
    {P2_id,_Ref} = Player2,
    if
        From =:= P1_id ->
            {next_state, waiting_for_player2, Data#{last_move := Choice, player1 := F}};
        From =:= P2_id ->
            {next_state, waiting_for_player1, Data#{last_move := Choice, player2 := F}};
        true ->
            {keep_state,Data}
    end;
match({call, From}, {tell_state}, Data) ->
    {keep_state, Data,
     [{reply,From,Data}]}.
    
waiting_for_player2( {call,{From, _Ref}=F}, {move, Choice}, 
    #{player1 := Player1, player2 := Player2, last_move := LastMove, game_length := GameLength,
     round_no := RoundNo, rounds := Rounds, scores := {Player1Score, Player2Score}, bro_ref := Bro_ref} = Data) ->
    P2_id = element(1,Player2),
    if
        From =:= P2_id ->
            % io:write('In loop'),
            NewGameLength = GameLength+1,
            NewRoundNo = RoundNo+1,
            MatchOutcome = match_result(LastMove, Choice),
            % io:write(MatchOutcome),
            if
                MatchOutcome == won ->
                    if
                        NewRoundNo == Rounds ->
                            gen_server:cast(Bro_ref, {self(), game_over, NewGameLength}),
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo},
                            [{reply, Player1, {game_over, Player1Score+1, Player2Score}}, {reply, F, {game_over, Player2Score, Player1Score+1}}]}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}, [{reply, Player1, round_won}, {reply, F, round_lost}]}
                    end;
                MatchOutcome == lost ->
                    if
                        NewRoundNo == Rounds ->
                            gen_server:cast(Bro_ref, {self(), game_over, NewGameLength}),
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}, [{reply, Player1, {game_over, Player1Score, Player2Score+1}}, {reply, F, {game_over, Player2Score+1, Player1Score}}]}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}, [{reply, Player1, round_lost}, {reply, F, round_won}]}
                    end;
                MatchOutcome == tie ->
                    {next_state, match, Data#{last_move := none, game_length := NewGameLength}, [{reply, Player1, tie}, {reply, F, tie}]}
            end
    end;
waiting_for_player2({call, From}, {tell_state}, Data) ->
    {keep_state, Data,
     [{reply,From,Data}]}.

waiting_for_player1({call,{From,_Ref}=F}, {move, Choice}, 
    #{player1 := Player1, player2 := Player2, last_move := LastMove, game_length := GameLength,
     round_no := RoundNo, rounds := Rounds, scores := {Player1Score, Player2Score}, bro_ref := Bro_ref} = Data) ->
    {P1_id,_Re} = Player1,
    % {P2_id,_Ref} = Player2,
    if
        From =:=  P1_id ->
            NewGameLength = GameLength+1,
            NewRoundNo = RoundNo+1,
            MatchOutcome = match_result(LastMove, Choice),
            if
                MatchOutcome == lost ->
                    if
                        NewRoundNo == Rounds ->
                            gen_server:cast(Bro_ref, {self(), game_over, NewGameLength}),
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}, [{reply, Player1, {game_over, Player1Score+1, Player2Score}}, {reply, Player2, {game_over, Player2Score, Player1Score+1}}]}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}, [{reply, Player1, won}, {reply, Player2, lost}]}
                    end;
                MatchOutcome == won ->
                    if
                        NewRoundNo == Rounds ->
                            gen_server:cast(Bro_ref, {self(), game_over, NewGameLength}),
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}, [{reply, Player1, {game_over, Player1Score, Player2Score+1}}, {reply, Player2, {game_over, Player2Score+1, Player1Score}}]}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}, [{reply, Player1, round_lost}, {reply, Player2, round_won}]}
                    end;
                MatchOutcome == tie ->
                    {next_state, match, Data#{last_move := none, game_length := NewGameLength}, [{reply, Player2, tie}, {reply, F, tie}]}
            end
    end.

game_over(_, _ , Data) ->
    {keep_state, Data}.


match_result(FirstPChoice, SecondPChoice) ->
    Result =
    if
        FirstPChoice =:=  SecondPChoice ->
            tie;
        {FirstPChoice, SecondPChoice} =:= {rock, scissors} ->
            won;
        {FirstPChoice, SecondPChoice} =:= {rock, paper } ->
            lost;
        {FirstPChoice, SecondPChoice} =:= {paper, rock} ->
            won;
        {FirstPChoice, SecondPChoice} =:= {paper, scissors} ->
            lost;
        {FirstPChoice, SecondPChoice} =:= {scissors, rock} ->
            lost;
        {FirstPChoice, SecondPChoice} =:= {scissors, paper} ->
            won;
        true ->
            Res1 = lists:member(FirstPChoice, [rock, paper, scissors]),
            Res2 = lists:member(SecondPChoice, [rock, paper, scissors]),
            if
                Res1 =:= true ->
                    won;
                Res2 =:= true ->
                    lost;
                true -> 
                    tie
            end
    end,
    Result.

%% Handle events common to all states
handle_event({call,From}, get_count, Data) ->
    %% Reply with the current count
    {keep_state,Data,[{reply,From,Data}]};
handle_event(_, _, Data) ->
    %% Ignore all other events
    {keep_state,Data}.
-module(coordinator).
-behaviour(gen_statem).

-export([start/1,move/1]).
-export([terminate/3,code_change/4,init/1,callback_mode/0]).
-export([match/3, waiting_for_player1_turn/3, waiting_for_player2_turn/3 ]).

name() -> coordinator_statem. % The registered server name

%% API.  This example uses a registered name name()
%% and does not link to the caller.
start(Game_Deatils) ->
    gen_statem:start({local,name()}, ?MODULE, Game_Deatils, []).

move(Choice) ->
    gen_statem:call(name(), {move, Choice}).


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
            round_no => 0
            } ,
    {ok,State,Data}.
callback_mode() -> state_functions.

%%% state callback(s)

match({call,From}, {move, Choice}, 
    #{player1 := Player1, player2 := Player2} = Data) ->
    if
        From =:= Player1 ->
            {next_state, waiting_for_player2_turn, Data#{last_move := Choice}};
        From =:= Player2 ->
            {next_state, waiting_for_player1_turn, Data#{last_move := Choice}};
        true ->
            {keep_state,Data}
    end.
    

waiting_for_player2_turn({call,From}, {move, Choice}, 
    #{player2 := Player2, last_move := LastMove, game_length := GameLength,
     round_no := RoundNo, rounds := Rounds, scores := {Player1Score, Player2Score}} = Data) ->
    if
        From =:=  Player2 ->
            NewGameLength = GameLength+1,
            NewRoundNo = RoundNo+1,
            MatchOutcome = game_result(LastMove, Choice),
            if
                MatchOutcome =:= won ->
                    if
                        NewRoundNo >= Rounds ->
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}}
                    end;
                MatchOutcome =:= lost ->
                    if
                        NewRoundNo >= Rounds ->
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}}
                    end;
                MatchOutcome =:= tie ->
                    {next_state, match, Data#{last_move := none, game_length := NewGameLength}}
            end
    end.

waiting_for_player1_turn({call,From}, {move, Choice}, 
    #{player1 := Player1, last_move := LastMove, game_length := GameLength,
     round_no := RoundNo, rounds := Rounds, scores := {Player1Score, Player2Score}} = Data) ->
    if
        From =:=  Player1 ->
            NewGameLength = GameLength+1,
            NewRoundNo = RoundNo+1,
            MatchOutcome = game_result(LastMove, Choice),
            if
                MatchOutcome =:= lost ->
                    if
                        NewRoundNo >= Rounds ->
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score+1, Player2Score}, round_no := NewRoundNo}}
                    end;
                MatchOutcome =:= won ->
                    if
                        NewRoundNo >= Rounds ->
                            {next_state, game_over, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}}; 
                        true ->
                            {next_state, match, Data#{last_move := none, game_length := NewGameLength,
                            scores := {Player1Score, Player2Score+1}, round_no := NewRoundNo}}
                    end;
                MatchOutcome =:= tie ->
                    {next_state, match, Data#{last_move := none, game_length := NewGameLength}}
            end
    end.


game_result(Player1Choice, Player2Choice) ->
    Result =
    if
        Player1Choice =:=  Player2Choice ->
            tie;
        {Player1Choice, Player2Choice} =:= {rock, scissor} ->
            won;
        {Player1Choice, Player2Choice} =:= {rock, paper } ->
            lost;
        {Player1Choice, Player2Choice} =:= {paper, rock} ->
            won;
        {Player1Choice, Player2Choice} =:= {paper, scissor} ->
            lost;
        {Player1Choice, Player2Choice} =:= {scissor, rock} ->
            lost;
        {Player1Choice, Player2Choice} =:= {scissor, paper} ->
            won;
        true ->
            none
    end,
    Result.

%% Handle events common to all states
handle_event({call,From}, get_count, Data) ->
    %% Reply with the current count
    {keep_state,Data,[{reply,From,Data}]};
handle_event(_, _, Data) ->
    %% Ignore all other events
    {keep_state,Data}.
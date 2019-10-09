-module(test_flamingo).

-include_lib("eunit/include/eunit.hrl").
-export([mytests/0]).

mytests() ->
    eunit:test({module, ?MODULE}, [verbose]).

start_a_flamingo_server_test() ->
    ?assertMatch({ok, _}, flamingo:start("flamingo")).

generator_start_a_flamingo_server_test_() ->
    ?_assertMatch({ok, _}, flamingo:start("flamingo")).

fancy_generator_start_a_flamingo_server_test_() ->
    {"Start a flamingo server an check that it returns a pair with ok as the first component",
     ?_assertMatch({ok, _}, flamingo:start("flamingo"))}.

%% failing_test_() ->
%%     {"We messed up the test",
%%      ?_assertMatch({{ok}, _}, flamingo:start("flamingo"))}.

greetings_test_() ->
    {"Start a greeting server, and send a request",
     fun () ->
             F = greetings:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/hello", [{"name", "Ken"}]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, _, _}}, X)
             end

     end}.

hello_test_() ->
    {"hello_test_1_",
     fun () ->
             F = hello:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/hello",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "Hello my dear friend"}}, X)
             end

     end}.

goodbye_test_() ->
    {"goodbye test in hello server ",
     fun () ->
             F = hello:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/goodbye",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "Sad to see you go already."}}, X)
             end

     end}.

invalid_path_test_() ->
    {"requesting invalid path in hello server ",
     fun () ->
             F = hello:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/gd",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {404, _, _}}, X)
             end

     end}.

moo_test_() ->
    {"moo test  ",
     fun () ->
             F = mood:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/moo",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "That's funny"}}, X)
             end
             

     end}.

happy_mood_test_() ->
    {"happy mood test  ",
     fun () ->
             F = mood:server(),
             Ref = make_ref(),
             
             flamingo:request(F, {"/moo",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "That's funny"}}, X)
             end,
             flamingo:request(F, {"/mood",[]},
                              self(), Ref),
             receive
                 Y ->
                     ?assertMatch({Ref, {200, "text/plain", "Happy!"}}, Y)
             end,
             flamingo:request(F, {"/mood",[]},
                              self(), Ref),
             receive
                 Z ->
                     ?assertMatch({Ref, {200, "text/plain", "Happy!"}}, Z)
             end
             
     end}.

sad_mood_test_() ->
    {"sad mood test  ",
     fun () ->
             F = mood:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/mood",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "Sad"}}, X)
             end

     end}.

mood_with_mooda_path_test_() ->
    {"mood test with mooda path  ",
     fun () ->
             F = mood:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/mooda",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "Sad"}}, X)
             end
             

     end}.



inc_counter_without_x_in_arguments_test_() ->
    {"inc counter test without x in arguments  ",
     fun () ->
             F = counter:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/inc_with",[{"y","2"}]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "1"}}, X)
             end

     end}.

inc_counter_when_value_of_x_is_negative_integer_test_() ->
    {"inc counter test when value of x is negative  ",
     fun () ->
             F = counter:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/inc_with",[{"x","-2"}]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "1"}}, X)
             end

     end}.

inc_counter_without_arguments_test_() ->
    {"inc counter test without arguments  ",
     fun () ->
             F = counter:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/inc_with",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "1"}}, X)
             end

     end}.

inc_counter_with_invalid_argument_test_() ->
    {"inc counter test  with invalid abc argument",
     fun () ->
             F = counter:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/inc_with",[{"abc"}]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "1"}}, X)
             end

     end}.

dec_counter_test_() ->
    {"dec counter test  ",
     fun () ->
             F = counter:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/inc_with",[{"x","2"}]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "2"}}, X)
             end,
             flamingo:request(F, {"/dec_with",[{"x","2"}]},
                              self(), Ref),
             receive
                 Y ->
                     ?assertMatch({Ref, {200, "text/plain", "0"}}, Y)
             end

     end}.

dec_counter_1_test_() ->
    {"dec counter 1 test  ",
     fun () ->
             F = counter:server(),
             Ref = make_ref(),
             flamingo:request(F, {"/inc_with",[]},
                              self(), Ref),
             receive
                 X ->
                     ?assertMatch({Ref, {200, "text/plain", "1"}}, X)
             end,
             flamingo:request(F, {"/inc_with",[]},
                              self(), Ref),
             receive
                 Y ->
                     ?assertMatch({Ref, {200, "text/plain", "2"}}, Y)
             end,
             flamingo:request(F, {"/dec_with",[{"x","2"}]},
                              self(), Ref),
             receive
                 Z ->
                     ?assertMatch({Ref, {200, "text/plain", "0"}}, Z)
             end

     end}.





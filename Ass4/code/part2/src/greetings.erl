-module(greetings).
-export([server/0, try_it/1]).

greeter({_Path, [{"name", Name} | _ ]}, Server) ->
    {200, "text/plain",
     lists:concat(["Greetings ", Name, "\n",
                   "You have reached ", Server])}.

server() ->
    {ok, F} = flamingo:start("The Flamingo Server"),
    flamingo:new_route(F, ["/hello"], fun greeter/2),
    F.

try_it(Flamingo) ->
    Me = self(),
    Ref = make_ref(),
    flamingo:request(Flamingo, {"/hello", [{"name", "Student"}]},
                     Me, Ref),
    receive
        {Ref, Reply} -> Reply
    end.

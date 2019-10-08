-module(hello).
-export([server/0]).

greet(_Req, _Server) ->
	{200, "text/plain", "Hello my dear friend"}.

bye(_Req, _Server) ->
	{200, "text/plain", "Sad to see you go already."}.

server() -> 
	{ok, F} = flamingo:start(" Flamingo Hello Server"),
    flamingo:new_route(F, ["/hello"], fun greet/2),
    flamingo:new_route(F, ["/goodbye"], fun bye/2),
    F.


%% % AP2019 Assignment 3
% Skeleton for main part. Predicates to implement:

% removes X from list and return Rest
is_selec(X, [Head|Tail], Rest) :-
  is_select3(Tail, Head, X, Rest).
is_select3(Tail, Head, Head, Tail).
is_select3([Head2|Tail], Head, X, [Head|Rest]) :-
is_select3(Tail, Head2, X, Rest).


% checks if X is a member of a list
membe(X, [X|_]).
membe(X,[_|Z]):-
	membe(X,Z).

% checks if X is a person in network
is_person(X,[person(X,_)|_]).
is_person(X,[_|Z]) :-
    is_person(X,Z).

% checks if X and Y are different members of network
different(G,X,Y) :-
    is_selec(person(X,_),G,R),is_person(Y,R).

% checks if X is not a member of list 
not_membe(_,_,[]).
not_membe(G,X, [Z|P]) :-
	different1(G,X,Z) ,not_membe(G,X,P).

%% g1([person(kara, [barry, clark]),
%%     person(bruce,[clark, oliver]),
%%     person(barry, [kara, oliver]),
%%     person(clark, [oliver, kara]),
%%     person(oliver, [kara])]).

%%% level 0 %%%

follows([person(X,D)|_],X,Y):-
	membe(Y,D).
follows([_|AS],X,Y):-
	follows(AS,X,Y).
    
% ignores(G, X, Y)
ignores(G,X,Y):-
	is_ignores(G,G,X,Y).

is_ignores(N,[person(X,F)|_],X,Y):-
	follows(N,Y,X), not_membe(N,Y,F).
is_ignores(G,[_|AS],X,Y):-
	is_ignores(G,AS,X,Y).



%%% level 1 %%%

% popular(G, X)

% outcast(G, X)

% friendly(G, X)

% hostile(G, X)

%%% level 2 %%%

% aware(G, X, Y)

% ignorant(G, X, Y)

%%% level 3 %%%

% same_world(G, H, K)

% optional!
% different_world(G, H)

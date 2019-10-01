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
	different(G,X,Z) ,not_membe(G,X,P).

g1([person(kara, [barry, clark]),
    person(bruce,[clark, oliver]),
    person(barry, [kara, oliver]),
    person(clark, [oliver, kara]),
    person(oliver, [kara])]).

%%% level 0 %%%

follows([person(X,D)|_],X,Y):-
	membe(Y,D).
follows([_|AS],X,Y):-
	follows(AS,X,Y).
    
% ignores(G, X, Y)
ignores(G,X,Y):-
	is_ignores(G,G,X,Y).

is_ignores(N,[person(X,F)|_],X,Y):-
	follows(N,Y,X), 
	not_membe(N,Y,F).
is_ignores(G,[_|AS],X,Y):-  %Shouldn't this be (G,AS,X,Y)?
	is_ignores(G,AS,X,Y).

%%% level 1 %%%

% checks if Y is followed by all the members of the list
followed_list(_,[],_).
followed_list(G,[X|T],Y) :-
    follows(G,X,Y),followed_list(G,T,Y).

% checks if Y follows all members of the list
follow_list(_,_,[]).
follow_list(G,Y,[H|T]):-
	follows(G,Y,H),
	follow_list(G,Y,T).

popular(G,X):-
    is_popular(G,G,X).

is_popular(G,[person(X,Y)|_],X) :-
    followed_list(G,Y,X).  %change variable names. X=Y
is_popular(G,[_|T],X) :-
    is_popular(G,T,X).

ignores_list(_,[],_).
ignores_list(G,[X|T],Y) :-
    ignores(G,X,Y),ignores_list(G,T,Y).

outcast(G,X):-
    is_outcast(G,G,X).

is_outcast(G,[person(X,Y)|_],X) :-
    ignores_list(G,Y,X).
is_outcast(G,[_|T],X) :-
    is_outcast(G,T,X).

friendly(G, X) :- 
	list_follow(G, G, X, FL),
	follow_list(G, X, FL).
	%% is_friendly(G, G, X).

 %Attempt nested recursion
%% is_friendly(G, [person(P,L)|T], X) :-
	

%% found_one(G, [person(P,L)|T], X) :-


%% check_rest(G, [], X) :-
%% 	fail.
%% check_rest(G, [person(P,L)|T],X) :-
%% 	membe(X,L),
%% 	follows(G,X,P),
%% 	is_friendly(G,T,X).
%% check_rest(G, [person(P,L)|T],X) :-
%% 	not_membe(X,L),
%% 	is_friendly(G,T,X).

%% is_friendly(G, [_|T], X) :-
	%% is_friendly(G, T, X).


concat([], L, L).
concat([H|L1],L2,[H|L3]) :-
	concat(L1,L2,L3).

appen([], X, X).
appen([X|L],X,[X|L]).

list_follow(_,[],_,[]). 
list_follow(G,[person(P,L)|T], Per, [P|FL]) :-
	membe(Per,L),
	list_follow(G,T,Per,FL).
list_follow(G,[person(_,L)|T], Per, FL) :-
	not_membe(G,Per,L),
	list_follow(G,T,Per,FL).



% hostile(G, X)

%%% level 2 %%%

% aware(G, X, Y)

% ignorant(G, X, Y)

%%% level 3 %%%

% same_world(G, H, K)

% optional!
% different_world(G, H)

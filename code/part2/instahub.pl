%% % AP2019 Assignment 3
% Skeleton for main part. Predicates to implement:
membe(X, [X|_]).
membe(X,[_|Z]):-
	membe(X,Z).

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

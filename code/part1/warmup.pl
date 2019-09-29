% AP2019 Assignment 3
% Skeleton for warm-up part. Predicates to implement:

add(X,z,X).
add(X,s(Y),s(N)) :- 
	add(X,Y,N).

mult(X,s(Y),Z) :- 
	add(X,K,Z),
	mult(X,Y,K).

comp(X,X,eq).
comp(_,z,gt).
comp(z,_,lt).
comp(s(X),s(Y),Z) :-
	X \= Y,
	comp(X,Y,Z). 


insert(N, leaf, node(N, leaf, leaf)).
insert(N, node(K,L,R), node(K,L,R)):-
	comp(N,K,eq).
insert(N, node(K,L,R), node(K,L,Q)):-
	comp(N,K,gt),
	insert(N,R,Q).
insert(N, node(K,L,R), node(K,Q,R)):-
	comp(N,K,lt),
	insert(N,L,Q).


insertlist([], TI, TI).
insertlist([X|Y], TI, F) :-
	insert(X,TI,Q),
	insertlist(Y,Q,F).
    
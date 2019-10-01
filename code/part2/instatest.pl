% Rudimentary test suite. Feel free to replace anything

% Can run as: swipl -g run_tests -g halt instahub.pl instatest.pl

% The sample graphs from the assignment text:
g1([person(kara, [barry, clark]),
    person(bruce,[clark, oliver]),
    person(barry, [kara, oliver]),
    person(clark, [oliver, kara]),
    person(oliver, [kara])]).

g2([person(batman, [green_arrow, superman]),
    person(green_arrow, [supergirl]),
    person(supergirl, [flash, superman]),
    person(flash, [green_arrow, supergirl]),
    person(superman, [green_arrow, supergirl])]).

:- begin_tests(instahub).

test(follows1, [nondet]) :-
    g1(G), follows(G, bruce, clark).

test(follows2, [fail]) :-
    g1(G), follows(G, clark, bruce).

test(follows3, [set(X == [barry,clark,oliver])]) :-
    g1(G), follows(G, X, kara).

test(follows4, [set(X == [kara])]) :-
    g1(G), follows(G, X, barry).

test(follows5, [set(X == [kara])]) :-
    g1(G), follows(G, oliver, X).

test(friendly1, [set(X == [kara, barry])]) :-
    friendly([person(kara,[barry]),person(barry,[kara])], X).

test(friendly2, [nondet]) :-
    friendly([person(kara,[]),person(barry,[])], kara).

test(friendly3, [set(X == [kara, oliver])]) :-
    friendly([person(kara,[barry]),person(barry,[]),person(oliver,[])], X).

test(friendly3, [set(X == [barry, bruce])]) :-
    g1(G), friendly(G, X).

test(hostile1, [set(X == [kara, barry, oliver])]) :-
    hostile([person(kara,[barry]),person(barry,[]),person(oliver,[])], X).

test(hostile2, [set(X == [bruce, oliver])]) :-
    g1(G), hostile(G, X).

:- end_tests(instahub).

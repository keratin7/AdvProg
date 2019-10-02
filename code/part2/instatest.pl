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

g3([person(ken, [ben, olin]),
    person(ben,[ken]),
    person(olin, [ken, ben, brad, clint]),
    person(clint, [brad]),
    person(brad, [olin]),
    person(jenna, [brad, clint]),
    person(carol, []),
    person(ana, [])]).

g4([person(kia, []),
    person(mia,[])]).

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

test(follows6, [fail]) :-
    g3(G), follows(G, carol, _).

test(follows7, [set(X == [brad, clint])]) :-
    g3(G), follows(G, jenna, X).

test(follows8, [fail]) :-
    g4(G), follows(G, kia, _).


test(ignores1, [fail]) :-
    g1(G), ignores(G, bruce, oliver).

test(ignores2, [nondet]) :-
    g1(G), ignores(G, clark, bruce).

test(ignores3, [set(X == [bruce, barry, clark])]) :-
    g1(G), ignores(G, oliver, X).

test(ignores4, [fail]) :-
    g3(G), ignores(G, jenna, _).

test(ignores5, [set(X == [clint, brad])]) :-
    g3(G), ignores(G, X, jenna).

test(ignores6, [fail]) :-
    g3(G), ignores(G, _,carol).

test(ignores7, [nondet]) :-
    g3(G), ignores(G, ben, olin).

test(ignores8, [fail]) :-
    g4(G), ignores(G, mia, _).



test(popular1, [set(X == [kara])]) :-
    g1(G), popular(G, X).

test(popular2, [nondet]) :-
    g1(G), popular(G, kara).

test(popular3, [fail]) :-
    g1(G), popular(G, barry).

test(popular4, [set(X == [ken, ben, brad, carol, ana])]) :-
    g3(G), popular(G, X).

test(popular5, [nondet]) :-
    g3(G), popular(G, brad).

test(popular6, [fail]) :-
    g3(G), popular(G, clint).

test(popular7, [set(X == [kia, mia])]) :-
    g4(G), popular(G, X).


test(outcast1, [set(X == [bruce, oliver])]) :-
    g1(G), outcast(G, X).

test(outcast2, [nondet]) :-
    g1(G), outcast(G, bruce).

test(outcast3, [fail]) :-
    g1(G), outcast(G, kara).

test(outcast4, [set(X == [clint, jenna, carol, ana])]) :-
    g3(G), outcast(G, X).

test(outcast5, [nondet]) :-
    g3(G), outcast(G, carol).

test(outcast6, [fail]) :-
    g3(G), outcast(G, ben).

test(outcast7, [set(X == [kia, mia])]) :-
    g4(G), outcast(G, X).


test(friendly1, [set(X == [barry, bruce])]) :-
    g1(G), friendly(G, X).

test(friendly2, [nondet]) :-
    g1(G), friendly(G, barry).

test(friendly3, [fail]) :-
    g1(G), friendly(G, kara).

test(friendly4, [set(X == [olin, ken, jenna, carol, ana])]) :-
    g3(G), friendly(G, X).

test(friendly5, [nondet]) :-
    g3(G), friendly(G, jenna).

test(friendly6, [fail]) :-
    g3(G), friendly(G, ben).

test(friendly7, [nondet]) :-
    g4(G), friendly(G, kia).

test(friendly8, [nondet]) :-
    g4(G), friendly(G, mia).

test(friendly9, [set(X == [kia, mia])]) :-
    g4(G), friendly(G, X).

test(friendly10, [nondet]) :-
    friendly([], _).


test(hostile1, [set(X == [oliver, bruce])]) :-
    g1(G), hostile(G, X).

test(hostile2, [nondet]) :-
    g1(G), hostile(G, bruce).

test(hostile3, [fail]) :-
    g1(G), hostile(G, kara).

test(hostile4, [set(X == [clint, jenna, carol, ana])]) :-
    g3(G), hostile(G, X).

test(hostile5, [nondet]) :-
    g3(G), hostile(G, jenna).

test(hostile6, [fail]) :-
    g3(G), hostile(G, ben).

test(hostile7, [nondet]) :-
    g4(G), hostile(G, kia).

test(hostile8, [nondet]) :-
    g4(G), hostile(G, mia).

test(hostile9, [set(X == [kia, mia])]) :-
    g4(G), hostile(G, X).

test(hostile10, [nondet]) :-
    hostile([], _).

/**

test(aware1, [nondet]) :-
    g1(G), aware(G,kara, oliver).

test(aware2, [set(X == [kara, barry, clark, oliver])]) :-
    g1(G), aware(G,bruce, X).

test(aware3, [fail]) :-
    g1(G), aware(G,kara, bruce).

test(aware4, [nondet]) :-
    g3(G), aware(G,kem, olin).

test(aware5, [set(X == [ben, ken, olin, clint, brad])]) :-
    g3(G), aware(G,jenna, X).

test(aware6, [fail]) :-
    g3(G), aware(G,ana, _).

test(aware7, [fail]) :-
    g4(G), aware(G,kia, _).


test(ignorant1, [nondet]) :-
    g1(G), ignorant(G,kara, bruce).

test(ignorant2, [set(X == [bruce])]) :-
    g1(G), ignorant(G,barry, X).

test(ignorant3, [fail]) :-
    g1(G), ignorant(G, bruce, kara).

test(ignorant4, [nondet]) :-
    g3(G), ignorant(G,kem, jenna).

test(ignorant5, [set(X == [carol, ana])]) :-
    g3(G), ignorant(G,jenna, X).

test(ignorant6, [nondet]) :-
    g3(G), ignorant(G,ana, carol).

test(ignorant7, [nondet]) :-
    g4(G), ignorant(G,kia, mia).

test(same_world1, [set(X == [[p(kara,supergirl),
                             p(bruce,batman), 
                             p(barry,flash), 
                             p(clark,superman), 
                             p(oliver,green_arrow)]])]) :-
    g1(G), g2(H), same_world(G,H,X).

test(same_world2, [fail]) :-
    g1(G), g3(H), same_world(G,H,_).

**/
:- end_tests(instahub).

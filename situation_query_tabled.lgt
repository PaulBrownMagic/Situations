:- op(800, xfy, and).
:- op(850, xfy, or).
:- op(870, xfy, implies).
:- op(880, xfy, equivalentTo).
:- op(600, fy, not).

:- category(situation_query).

    :- public(holds/2).
    :- table(holds/2).

    holds(Q, S) :-
        ( var(Q) ; \+ compound_query(Q) ),
        ::holds_(Q, S).
    holds(Q, S) :-
        nonvar(Q),
        compound_query(Q),
        query(Q, S).

    :- private(holds_/2).
    :- mode(holds_(?object, +list), zero_or_more).
    :- mode(holds_(+term, +list), zero_or_more).
    :- info(holds_/2,
         [ comment is 'Helper for ``holds/1``, distinguishes from fluents that hold and Logtalk/Prolog terms.'
         , argnames is ['FluentOrTerm', 'Situation']
         ]).

    % Transform holds query into single fluent subgoals and see if they hold
    query(P and Q, S) :- nonvar(P), nonvar(Q),
        query(P, S), query(Q, S).
    query(P or Q, S) :- nonvar(P), nonvar(Q),
        query(P, S); query(Q, S).
    query(P implies Q, S) :- nonvar(P), nonvar(Q),
        query(not P or Q, S).
    query(P equivalentTo Q, S) :- nonvar(P), nonvar(Q),
        query((P implies Q) and (Q implies P), S).
    query(not (not P), S) :- nonvar(P),
        query(P, S).
    query(not (P and Q), S) :- nonvar(P), nonvar(Q),
        query(not P or not Q, S).
    query(not (P or Q), S) :- nonvar(P), nonvar(Q),
        query(not P and not Q, S).
    query(not (P implies Q), S) :- nonvar(P), nonvar(Q),
        query(not (not P or Q), S).
    query(not (P equivalentTo Q), S) :- nonvar(P), nonvar(Q),
        query(not ((P implies Q) and (Q implies P)), S).
    query(not P, S) :- nonvar(P), \+ compound_query(P),
        \+ ::holds_(P, S).
    query(P, S) :- \+ compound_query(P),
        ::holds_(P, S).

    % test if arg is a query term that requires transformation
    compound_query(not _).
    compound_query(_ and _).
    compound_query(_ or _).
    compound_query(_ implies _).
    compound_query(_ equivalentTo _).

    :- public(is_action/1).
    is_action(A) :-
        conforms_to_protocol(A, action_protocol),
        current_object(A).

    :- public(is_fluent/1).
    is_fluent(F) :-
        conforms_to_protocol(F, fluent_protocol),
        current_object(F).

:- end_category.

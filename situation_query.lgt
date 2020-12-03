:- op(800, xfy, and).
:- op(850, xfy, or).
:- op(870, xfy, implies).
:- op(880, xfy, equivalentTo).
:- op(600, fy, not).

:- category(situation_query).

	:- private(holds_/2).
	:- mode(holds_(+term, +list), zero_or_more).
	:- info(holds_/2,
		 [ comment is 'Helper for ``holds/1``, distinguishes from fluents that hold and Logtalk/Prolog terms.'
		 , argnames is ['FluentOrTerm', 'Situation']
		 ]).

	:- public(holds/2).
	:- mode(holds(+term, +list), zero_or_more).
    :- info(holds/2,
	    [ comment is 'Query what holds in a ``Situation``. Queries can be Fluents, or
		              compound terms with ``and`` conjunction, ``or`` disjunction, ``not``
					  for Prolog style negation, ``implies`` for implication and ``equivalentTo``
					  for equivalence.

				      **Caveats**
					  - For the case ``not P``, Prolog style negation is used (\\+)
					  - For the case where ``P implies Q``, ``P`` is false, and ``Q`` is
					  not ground, we can\'t unify ``Q`` with a false case due to
					  Prolog style negation.
				      - For the case where ``P equivalentTo Q`` if either ``P`` or ``Q`` are
					  non-ground, only the case where both ``P`` and ``Q`` are true will hold.
				      So if ``P`` is ground to a false case and ``Q`` is not ground, then
					  ``P equivalentTo Q`` won\'t hold even if some value of Q would make it so.
				      The same applies if ``Q`` is ground to the false case and ``P`` is not
					  ground. This is due to the Prolog style negation.'
		, argnames is ['Query', 'Situation']
		]).
    :- if(current_logtalk_flag(tabling, supported)).
         :- table(holds/2).
    :- endif.
    holds(Query, Situation) :-
        % holds/2 might be tabled,
        % pass to query/2 to avoid overhead of tabling subqueries
        query(Query, Situation).

    % query/2 is non-tabled holds/2
    % for when tabling is supported,
    % it reduces overhead of tabling
    % each subquery
    query(Query, Situation) :-
        ( compound_nonvar(Query) % check if fluent, compound, or var
        -> compound_query(Query, Situation) % decompose query
        ; ::holds_(Query, Situation) % check fluent
        ).
    compound_query(not Query, Situation) :-
        \+ query(Query, Situation).
    compound_query(P and Q, Situation) :-
        query(P, Situation),
        query(Q, Situation).
    compound_query(P or _Q, Situation) :-
        query(P, Situation).	% Decompose query
    compound_query(_P or Q, Situation) :-
        query(Q, Situation).	% Decompose query
    compound_query(P implies Q, Situation) :-
        (	query(P, Situation)
        ->	query(Q, Situation)
        ;	ignore(query(Q, Situation))
        ).
    compound_query(P equivalentTo Q, Situation) :-
        (	query(P, Situation)
        ->	query(Q, Situation) % P holds, so Q must also hold
        ;	\+ query(Q, Situation) % not P holds, so not Q must hold
        ).

	% unification hack to test for variable
	compound_nonvar('Variable Fluents are not supported, at least some part of the Fluent term must be ground') :-
		context(Context),
		throw(error(instantiation_error, Context)).
	% test if arg is a query term that requires transformation
	compound_nonvar(not _).
	compound_nonvar(_ and _).
	compound_nonvar(_ or _).
	compound_nonvar(_ implies _).
	compound_nonvar(_ equivalentTo _).

	:- public(is_action/1).
	is_action(A) :-
		conforms_to_protocol(A, action_protocol),
		current_object(A).

	:- public(is_fluent/1).
	is_fluent(F) :-
		conforms_to_protocol(F, fluent_protocol),
		current_object(F).

:- end_category.

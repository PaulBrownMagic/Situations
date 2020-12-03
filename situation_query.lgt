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
		( compound_nonvar(Query) ->  % Is it a compound (also throw on Query being a var)
		  holds_compound(Query, Situation)	% Decompose query
		; ::holds_(Query, Situation)  % See if Fluent holds
		).

	% Transform holds query into single fluent subgoals and see if they hold
	% Conjuction
	holds_compound(P and Q, S) :-
		holds(P, S),
		holds(Q, S).
	% Disjunction
	holds_compound(P or _Q, S) :-
		holds(P, S).
	holds_compound(_P or Q, S) :-
		holds(Q, S).
	% Implication
	holds_compound(P implies Q, S) :- % not P or (P and Q)
		(	holds(P, S)
		->	holds(Q, S)
		;	ignore(holds(Q, S))
		).
	% Equivalence
	holds_compound(P equivalentTo Q, S) :- % holds((P implies Q) and (Q implies P), S).
		(	holds(P, S)
		->	holds(Q, S) % P holds, so Q must also hold
		;	\+ holds(Q, S) % not P holds, so not Q must hold
		).
	% Negation (Prolog negation)
	holds_compound(not P, S) :- \+ holds(P, S).

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

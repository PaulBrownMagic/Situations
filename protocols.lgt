:- protocol(situation_protocol).

    :- info([ version is 1:0:0
            , author is 'Paul Brown'
            , date is 2019-11-2
            , comment is 'A situation is a set of relations that hold.'
            ]).


    :- public(empty/1).
    :- mode(empty(?term), zero_or_one).
    :- info(empty/1,
        [ comment is 'The term that represents the "empty" situation.'
        , argnames is ['Situation']
        ]).

    :- public(holds/2).
    :- meta_predicate(holds(*, *)).
    :- mode(holds(?object, +term), zero_or_more).
    :- mode(holds(+term, +term), zero_or_more).
    :- info(holds/2,
        [ comment is 'What fluents hold in the situation. Can also be provided with a logical query term provided all fluents are nonvar: `situation::holds(power(X) and position(Y)).`'
        , argnames is ['Holding', 'Situation']
        ]).

    :- public(do/3).
    :- mode(do(+object, +term, ?term), zero_or_one).
    :- mode(do(+object, -term, +term), zero_or_one).
    :- mode(do(+object, -term, -term), zero_or_more).
    :- info(do/3,
        [ comment is 'True if doing the Action in S1 results in S2.'
        , argnames is ['Action', 'S1', 'S2']
        ]).

:- end_protocol.


:- protocol(action_protocol).

    :- info([ version is 1:0:0
            , author is 'Paul Brown'
            , date is 2019-11-2
            , comment is 'An action is something that when done changes some fluents that hold in the situation.'
            ]).

    :- public(do/2).
    :- mode(do(+term, ?term), zero_or_one).
    :- mode(do(-term, +term), zero_or_one).
    :- mode(do(-term, -term), zero_or_more).
    :- info(do/2,
        [ comment is 'True if doing the action in S1 results in S2.'
        , argnames is ['S1', 'S2']
        ]).

    :- public(poss/1).
    :- mode(poss(-term), zero_or_more).
    :- mode(poss(+term), zero_or_one).
    :- info(poss/1,
        [ comment is 'True if the action is possible in the situation.'
        , argnames is ['Situation']
        ]).

:- end_protocol.


:- protocol(fluent_protocol).

    :- info([ version is 1:0:0
            , author is 'Paul Brown'
            , date is 2019-11-2
            , comment is 'A fluent is a relationship that may or may not hold in some situations.'
            ]).

    :- public(holds/1).
    :- mode(holds(-list), zero_or_more).
    :- mode(holds(+list), zero_or_one).
    :- info(holds/1,
        [ comment is 'True if the fluent holds in the situation.'
        , argnames is ['Situation']
        ]).

:- end_protocol.

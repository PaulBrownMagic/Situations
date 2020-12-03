## Situations

This repository provides the top-level definition for interpretations of
Situations in Logtalk.

Examples include:
    - [SitCalc](https://github.com/PaulBrownMagic/SitCalc)
	- [STRIPState](https://github.com/PaulBrownMagic/STRIPState)

A library implementing these protocols is suitable for use with
[BedSit](https://github.com/PaulBrownMagic/BedSit) for developing
applications quickly and flexibly.

An additional category is provided to use queries with `holds/2`.

## Situation Query DSL

```
sitcalc::holds(Query, Situation).
```

Query what holds in a ``Situation``. Queries can be Fluents, or
compound terms with ``and`` conjunction, ``or`` disjunction, ``not``
for Prolog style negation, ``implies`` for implication and ``equivalentTo``
for equivalence.

**Caveats**
- For the case ``not P``, Prolog style negation is used (\+)
- For the case where ``P implies Q``, ``P`` is false, and ``Q`` is
not ground, we can't unify ``Q`` with a false case due to
Prolog style negation.
- For the case where ``P equivalentTo Q`` if either ``P`` or ``Q`` are
non-ground, only the case where both ``P`` and ``Q`` are true will hold.
So if ``P`` is ground to a false case and ``Q`` is not ground, then
``P equivalentTo Q`` won't hold even if some value of Q would make it so.
The same applies if ``Q`` is ground to the false case and ``P`` is not
ground. This is due to the Prolog style negation.

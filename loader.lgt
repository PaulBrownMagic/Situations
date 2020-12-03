%  early SWI tabling support required an imported module
:- if((
	current_logtalk_flag(prolog_dialect, swi),
	current_prolog_flag(version_data, swi(Major, Minor, Patch)),
	Major =< 7, Minor =< 7, Patch =< 13
)).
	:- use_module(library(tabling)).
:- endif.

%  Notify developer that tabling is being used
:- if(current_logtalk_flag(tabling, supported)).
   :- initialization(logtalk::print_message(information, core, ['Loading situation_query with tabling supported'])).
:- endif.

:- initialization(
	logtalk_load([
				   protocols
				 , situation_query
				 ],
				 [
				   optimize(on)
				 ])
).

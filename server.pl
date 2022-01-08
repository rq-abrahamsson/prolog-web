:- set_prolog_flag(double_quotes, chars).
:- pack_install('sudoku_utils', [
		url('https://github.com/rq-abrahamsson/sudoku_utils/archive/v0.0.11.zip'),
		upgrade(true),
		interactive(false)
	]).

:- use_module(library('sudoku_utils')).

:- use_module(library(clpfd)).
:- use_module(library(lists)).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_server)).
:- use_module(library(http/http_log)).
:- use_module(library(http/json_convert)).

:- http_handler(root(health), health, []).
:- http_handler(root(show_sudoku), show_sudoku, []).
:- http_handler(root('show_sudoku.json'), show_sudoku_json, []).

server(Port) :-
	http_server(http_dispatch, [port(Port)]).

health(_Request) :-
	reply_json(ok).

sudoku_column([]) --> [].
sudoku_column(Row) -->
	{ nth0(0, Row, E, Rest) },
	html([td(E), td(' ') | \sudoku_column(Rest)]).

sudoku_row(Row) -->
	html(tr(\sudoku_column(Row))).

sudoku_rows([]) --> [].
sudoku_rows(Rows) -->
	{ nth0(0, Rows, Row, Rest) },
	html([\sudoku_row(Row), \sudoku_rows(Rest)]).

sudoku_table(Rows) -->
	html(table([\sudoku_rows(Rows)])) .


show_sudoku(Request) :-
	http_parameters(Request,
			[
			problem(ProblemNumber, [between(1, 2), default(1)])
			]),
	!,
	problem(ProblemNumber, Problem),
	sudoku_with_underscore_string(Problem, ProblemWithUnderscoreString), 
	problem(ProblemNumber, Rows),
	sudoku(Rows), 
	maplist(labeling([ff]), Rows),
	http_log('Sudoku Board: ~w hej ~n', [Rows]),
	reply_html_page(title('Sudoku'),
		[ 
			h1('Sudoku problem'),
			\sudoku_table(ProblemWithUnderscoreString),
			h1('Sudoku solution'),
			\sudoku_table(Rows)
		]).

show_sudoku_json(Request) :-
	http_parameters(Request,
			[
			problem(ProblemNumber, [between(1, 2), default(1)])
			]),
	!,
	% sudoku(PrologOut),
	problem(ProblemNumber, Rows),
	sudoku(Rows), 
	maplist(labeling([ff]), Rows),
	%,maplist(portray_clause, Rows),
	prolog_to_json(Rows, JSONOut),
	reply_json(JSONOut).

problem(1, P) :-
	P = [[1,_,_,8,_,4,_,_,_],
		[_,2,_,_,_,_,4,5,6],
		[_,_,3,2,_,5,_,_,_],
		[_,_,_,4,_,_,8,_,5],
		[7,8,9,_,5,_,_,_,_],
		[_,_,_,_,_,6,2,_,3],
		[8,_,1,_,_,_,7,_,_],
		[_,_,_,1,2,3,_,8,_],
		[2,_,5,_,_,_,_,_,9]].
problem(2, P) :-
	P = [[_,1,_,8,_,4,_,_,_],
		[_,2,_,_,_,_,4,5,6],
		[_,_,3,2,_,5,_,_,_],
		[_,_,_,4,_,_,8,_,5],
		[7,8,9,_,5,_,_,_,_],
		[_,_,_,_,_,6,2,_,3],
		[8,_,1,_,_,_,7,_,_],
		[_,_,_,1,2,3,_,8,_],
		[2,_,5,_,_,_,_,_,9]].

get_env_with_default(Variable, _Default, OutValue) :-
	getenv(Variable, OutValue),
	!.

get_env_with_default(_Variable, Default, Default).
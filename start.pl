:- initialization main.

:- ensure_loaded(server).

main :-
    server(80),
    repeat,
    sleep(10),
    fail.

:- main.
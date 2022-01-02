:- initialization main.

:- ensure_loaded(server).

main :-
    server(8080),
    repeat,
    sleep(10),
    fail.

:- main.
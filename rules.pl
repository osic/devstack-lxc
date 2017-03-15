submit_rule(submit(CR, V)) :-
    base(CR, V),
    CR = label(_, ok(Reviewer)),
    gerrit:commit_author(Author),
    Author \= Reviewer,
    !.

submit_rule(submit(CR, V, N)) :-
    base(CR, V),
    N = label('Non-Author-Code-Review', need(_)).

base(CR, V) :-
    gerrit:max_with_block(-2, 2, 'Code-Review', CR).

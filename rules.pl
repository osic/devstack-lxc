% Rules for merging patches
% It needs to have at least one +2
% And the author of the patch can not vote

submit_rule(submit(CR)) :-
    base(CR),
    CR = label(_, ok(Reviewer)),
    gerrit:commit_author(Author),
    \+ (Author = Reviewer),
    Author \= Reviewer,
    !.

submit_rule(submit(CR, N)) :-
    base(CR),
    N = label('Non-Author-Code-Review', need(_)).

base(CR) :-
    gerrit:max_with_block(-2, 2, 'Code-Review', CR).
    

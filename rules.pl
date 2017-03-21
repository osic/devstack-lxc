% Rules for merging patches
% It needs to have at least one +2
% And the author of the patch can not vote
%
%submit_rule(submit(CR)) :-
%    base(CR),
%    CR = label(_, ok(Reviewer)),
%    gerrit:commit_author(Author),
%    Author \= Reviewer,
%    !.
%
%submit_rule(submit(CR, N)) :-
%    base(CR),
%    N = label('Non-Author-Code-Review', need(_)).
%
%base(CR) :-
%    gerrit:max_with_block(-2, 2, 'Code-Review', CR).

% These are some sample Facts like the ones Gerrit will provide for each patch 
% commit_author(user(1000000), 'Castulo J. Martinez', 'castulo.martinez@intel.com').
% commit_committer(user(1000000), 'Castulo J. Martinez', 'castulo.martinez@intel.com').
% commit_message('Add plugin support to Gerrit').

submit_rule(submit(CR)) :-
    base(CR),
    CR = label(_, ok(user(Reviewer))),
    gerrit:commit_author(user(Author)),
    Author \= Reviewer,
    !.

submit_rule(submit(CR, N)) :-
    base(CR),
    N = label('Non-Author-Code-Review', need(_)).

base(CR) :-
    gerrit:max_with_block(-2, 2, 'Code-Review', CR).

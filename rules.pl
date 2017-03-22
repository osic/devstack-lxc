% Rules for merging patches:
% It needs to have at least two +2 votes
% And the author of the patch can not vote

% These are some sample Facts like the ones Gerrit will provide for each patch 
% commit_author(user(1000000), 'Castulo J. Martinez', 'castulo.martinez@intel.com').
% commit_committer(user(1000000), 'Castulo J. Martinez', 'castulo.martinez@intel.com').
% commit_message('Add plugin support to Gerrit').

%submit_rule(submit(CR)) :-
%    sum(2, 'Code-Review', CR),
%    gerrit:max_with_block(-2, 2, 'Code-Review', CR),
%    gerrit:commit_author(Author, _, _),
%    CR = label(_, ok(Reviewer)),
%    Author \= Reviewer,
%    !.

%submit_rule(submit(CR, N)) :-
%    gerrit:max_with_block(-2, 2, 'Code-Review', CR),
%    N = label('Non-Author-Code-Review', need(_)).

%sum(VotesNeeded, Category, label(Category, ok(_))) :-
%    findall(Score, score(Category, Score), All),

submit_rule(submit(CR, V)) :-
    sum(1, 'Code-Review', CR),
    gerrit:max_with_block(-1, 1, 'Verified', V).

% Sum the votes in a category. Uses a helper function score/2
% to select out only the score values the given category.
sum(VotesNeeded, Category, label(Category, ok(_))) :-
    findall(Score, score(Category, Score), All),
    sum_list(All, Sum),
    Sum >= VotesNeeded,
    !.
$sum(VotesNeeded, Category, label(Category, need(VotesNeeded))).

score(Category, Score) :-
    gerrit:commit_label(label(Category, Score), User).

% Simple Prolog routine to sum a list of integers.
sum_list(List, Sum)   :- sum_list(List, 0, Sum).
sum_list([X|T], Y, S) :- Z is X + Y, sum_list(T, Z, S).
sum_list([], S, S).

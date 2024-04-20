% A seperate database file called db.pl which will be consulted before running
% this program for the word database

main:-
    write('Welcome to Prolog-Wordle!'), nl,
    write('----------------------'), nl,
    consult('db.pl'),
    play.

play:-
    categories(Categories),  % Making a list of categories of words possible
    random_member(C, Categories),  % Selecting a category randomly
    nl, write('The selected category is '), write(C), nl, nl,
    L is 5,
    Guesses is L + 1,
    write('Game started. You have '), write(Guesses), write(' guesses.'), nl, nl,
    setof(W, pick_word(W, C), Words),  % Creating a list of all words of the category
    random_member(ActualWord, Words),  % Selecting a word randomly from category
    guess_word(ActualWord, L, Guesses).

pick_word(W, C):-
    word(W, C).

% Function to get an element from a list randomly
random_member(X, List) :-
    length(List, Length),
    random(0, Length, Index),
    nth0(Index, List, X).

guess_word(ActualWord, RequiredLength, Guesses):-
    write('Enter a word composed of '), write(RequiredLength), write(' letters:'), nl,
    read(GuessWord),
    (
        var(GuessWord),  %  Invalid input
        write('You cannot enter variables, try again.'), nl,
        guess_word(ActualWord, RequiredLength, Guesses)
    ;
        GuessWord = ActualWord,  %  Winning Condition
        write('You won!'), nl
    ;
        Guesses = 1,  % Losing Condition
        write('You lost!'), nl,
        write('The correct word was '),write(ActualWord),write('!')
    ;
        (
            atom_length(GuessWord, RequiredLength),  %  Making sure guess word is of length 5
            atom_chars(ActualWord, ActualLetters),  %  atom_chars converts a string into a list of its letters
            atom_chars(GuessWord, GuessLetters),
            correct_letters(ActualLetters, GuessLetters, CorrectLetters),
            correct_positions(ActualLetters, GuessLetters, CorrectPositions),
            write('Correct letters are: '), write(CorrectLetters), nl,
            write('Correct letters in correct positions are: '), write(CorrectPositions), nl,
            NewGuesses is Guesses - 1
        ;
            write('Word is not composed of '), write(RequiredLength), write(' letters. Try again.'), nl,
            NewGuesses is Guesses
        ),
        write('Remaining Guesses are '), write(NewGuesses), nl, nl,
        guess_word(ActualWord, RequiredLength, NewGuesses)
    ).

is_category(C):-
    word(_, C).

categories(L):-
    setof(X, is_category(X), L).

% Function correct_letters returns the list letters common in the guessword and
% the actual word
correct_letters(ActualLetters, GuessLetters, CorrectLetters):-
    intersection(GuessLetters, ActualLetters, CL),
    list_to_set(CL, CorrectLetters).

% Function correct_positions returns the list of letters at the same position in
% guessword and the actual word
correct_positions([], [], []).
correct_positions([H|T1], [H|T2], [H|T3]):-
    correct_positions(T1, T2, T3).
correct_positions([H1|T1], [H2|T2], T3):-
    H1 \= H2,
    correct_positions(T1, T2, T3).

intersection([], _, []).
intersection([H|T1], L2, [H|T3]) :-
    member(H, L2), !,
    intersection(T1, L2, T3).
intersection([_|T1], L2, L3) :-
    intersection(T1, L2, L3).

list_to_set([], []).
list_to_set([H|T], Set) :-
    member(H, T), !,
    list_to_set(T, Set).
list_to_set([H|T], [H|Set]) :-
    list_to_set(T, Set).

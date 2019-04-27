:- module(parser, [parse/2]).
/** <module> Parse the user's input into a prolog term
 *
 */

:- use_module(library(tokenize)).
:- use_module(library(porter_stem)).
:- use_module(library(dcg/basics)).
:- ensure_loaded(adventure).

parse(Codes, Term) :-
    tokenize(Codes, Tokens, [case(false),spaces(false), cntrl(false), to(atoms), pack(false)] ),
    !, % tokenize leaves choice points
    normalize_tokens(Tokens, NormTokens),
    phrase(adventure_input(Term), NormTokens).

normalize_tokens([], []).
normalize_tokens([word(W)|T], NT) :-
    porter_stem(W, Stem),
    member(Stem, [a, an, the, of, for]),
    normalize_tokens(T, NT).
normalize_tokens([word(W)|T], [Stem|NT]) :-
    porter_stem(W, Stem),
    normalize_tokens(T, NT).
normalize_tokens([_|T], NT) :-
    normalize_tokens(T, NT).


adventure_input(X) -->
    ... ,
    command(X),
    ... ,
    !.
adventure_input(error_input) -->
    ...,
    !.

... --> [].
... --> [_], ... .

command(look) --> [look].
command(goto(Place)) -->
        ( [g] |  [go] | [go, to] | [visit] | [return, to]),
        place(Place).
command(move(Place)) -->
     place(Place).
command(take(Thing)) -->
    [take],
    thing(Thing).
command(put(Thing)) -->
    (   [put] | [drop] | [leave] ),
    thing(Thing).
command(inventory) -->
    [i] |
    [inv] |
    [invent] |
    [inventory].

place(X) -->
    [X],
    {adventure:room(X)}.

thing(X) -->
    { adventure:location(X, _) }.
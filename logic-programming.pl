/*

Assignment #3
Author: Jephte Pierre

This assignment investigates the solver of nonograms, a classic puzzle that requires
players to put 'x' or ' ' on a rectangular grid while satisfying the restrictions
provided on each row and column. The nature of this puzzle is to find a solution (as a
pattern on a grid) under certain constriants (numbers of consecutive x's of each row and
column). To date, this puzzle is classified as an NP-complete problem, and the polynomial time-solving algorithm does not exist yet. Therefore, a brute force approach, implemented 
in Prolog, will be presented.

Since there is not much restriction on the constraints, I can most likely expect the
following three cases from a nonogram:

1. No solution. For example, in a 3x3 grid:
	[[[1],[2],[1]], [[1,1],[1],[1,1]]] will not yield any solution, since the [2] will
    block at least one of the [1,1]'s.

2. More than one solution. For example, in a 2x2 grid:
	[[[1],[1]],[[1],[1]]] can either be a left-to-right or right-to-left diagonal and
    a similar constraint can be raised by using the n-queen problem approach.

3. One unique solution.
	The case I am interested in.

Our implementation follows closely with the steps provided by the Prof. 

Variable list:
	Row 			- one possible pattern of a row or column (in terms of [', ''x']).
    Runs 			- constraint applied on a row (in terms of [int]).
	Image			- a collection of rows that satisfy a series of runs (constraint).
    ForestImage		- a collection of Images that satisfy the constraint.

As stated, a nonogram is classified as an NP-complete problem; it would not be wise to invent
a new algorithm to solve it in polynomial time. It would be more achievable to
improve time efficiency by using better sampling techniques.

One of the research papers available in Library Commons:
https://ubishops.on.worldcat.org/search/detail/5648999003?queryString=nonogram&databaseList=283%2C638&clusterResults=true&groupVariantRecords=false&stickyFacetsChecked=true

I have found that Images are treated as a matrix, and the algorithm is applied so that some cells
in the matrix can be determined as x or '  ' once the runs are read, i.e. for a row length 3,
If a [2] is read, the middle cell must be a x, and the number of iterations must be reduced.

The paper above adopted 13 similar rules to improve time performance, and the findings were
encouraging that an hour of computation from a genetic algorithm or DFS becomes a matter of minutes.

However, it would be difficult to implement such an algorithm to Prolog because matrix notations
may not be supported natively: any implementation of the matrix would increase the overhead of the
new algorithm.


Copyright announcement for the library(clpfd)
  @inproceedings{Triska12,
  author    = {Markus Triska},
  title     = {The Finite Domain Constraint Solver of {SWI-Prolog}},
  book title = {FLOPS},
  series    = {LNCS},
  volume    = {7294},
  year      = {2012},
  pages     = {307-316}
}

*/
:- use_module(library(clpfd)).

% Question 1 part 1
/*
This part is to generate a set of lists which its elements are the combination of two characters,
i.e. x and '  '. I first construct a list ['  ', x] to provide building blocks. length(L,H) is a
list holder (list of lists) of H lists. Then I can map the lambda function to write each list as the
combination of ['  ', x], since member function looks through our building blocks.
*/

% https://github.com/dtonhofer/prolog_notes/blob/master/swipl_notes/about_maplist/maplist_2_examples.md#generating_binary_patterns
generateRow(H,L):- length(L,H),maplist([Element]>>(member(Element,['  ',x])) , L).


% Question 1 part 2
/*
In this part, I use part 1 to construct all possible combination of a row, regardless of its runs,
and convert each row into its corresponding runs. Then I compare with runs provided and return
rows that fits the runs.
*/
generateRowCheck(Runs,H,Row):-
	generateRow(H,L),
	convertRowToRuns(L,R),
    R = Runs, Row = L.

/*
Helper function convertRowToRuns: [row] -> [runs]
1. Convert x into 1, space into 0.
2. Condense the list such that consecutive 1's are added.
3. Remove all occurances of 0's in the condensed list, i.e. runs.
*/
convertRowToRuns(Row, Runs):-
	convertX(Row,RowOne),
    mergeOnes(RowOne,RowOnes),
    removeZeros(RowOnes,Runs),!.

/*
Helper Function: [x / '  '] -> [0 / 1]
A maplist approach to convert x's and space's into 1's and 0's 
*/
equalToX(X,I):- X == x, I = 1; I = 0.
convertX(Row, ZeroOne):-
    maplist(equalToX, Row, ZeroOne),!.

/*
Helper Function:
Add 1 to the head of list.
*/
addOne([H|T],[HR|TR]):-
    HR is H + 1,
    TR = T.

/*
Helper Function: [0 / 1] -> [Int]
Condense a list of 0's and 1's such that
	1. add an new element 0 when seeing a 0.
    2. add increment by 1 to current tail value when seeing a 1.
*/
mergeOnes([],[0]).
mergeOnes([H|T], R):-
    mergeOnes(T,S), (H == 0, append([0],S,R); addOne(S,R)),!.

/*
Helper Function: [Int] -> [Int]
Condense a list of Int such that elements with value zero are removed.
*/
equalToZero(X) :- X = 0.
removeZeros(X,Y):-
    exclude(equalToZero, X ,Y).


/*
Rearrange arguments for use in maplist.
*/ 
generateRowCheck2(H,Runs,Row):-
	generateRowCheck(Runs,H,Row).


% Question 2
/*
In Question 2, I map generateRowCheck on the list Runs. All combinations will be 
generated one by one and bind to Image. 
Note that V is a singleton variable, I implictly use the length Runs instead.
*/ 
generateImage(V,H,Runs,Image):-
    maplist(generateRowCheck2(H), Runs, Image).


% Question 3
/*
A direct application of the library(clpfd)), i.e. Constraint Logic Programming over Finite Domains.
I cut the corner and play safe.
*/
transposeImage(Image,Result):-
    transpose(Image,Result).

/*
One of the simpler transpose functions that can be searched over Internet. I amconfident
that I cannot come up with this either.
*/ 
% https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
transposeMat([[]|_], []).
transposeMat(Matrix, [Row|Rows]) :- 
    transpose_1st_col(Matrix, Row, RestMatrix),
    transposeMat(RestMatrix, Rows).
transpose_1st_col([], [], []).
transpose_1st_col([[H|T]|Rows], [H|Hs], [T|Ts]) :- 
    transpose_1st_col(Rows, Hs, Ts).


% Question 4
/*
To solve the puzzle, I
1. Get size of grids from the constriants. (number of runs reflects its orthogonal length)
2. For H constriants, all possible candidates are generated (ForestHImage).
3. Then I generate Image from V constriants, and then transpose it.
4. The solution is the image(s) that is a member of ForestHImage.
*/ 
solve_puzzle(HRuns,VRuns,Solution):-
    length(VRuns, V), length(HRuns, H),
	obtainForest(H,V,HRuns,ForestHImage),
	generateImage(_,H,VRuns,VImage),
    transposeImage(VImage, VtoHImage),
   	Matched = VImage, member(VtoHImage,ForestHImage),
    transposeImage(Matched,Solution),
	writelist(Solution).

/*
Helper function generateRunsList: Image -> [Image]
Collects all images that satisfy the constriant.
*/
obtainForest(V,H,Runs,ForestImage):-
	bagof(I, generateImage(V,H,Runs,I), ForestImage).

% Code provided by the Prof
writelist([]).
writelist([H|T]) :- write(H), nl, writelist(T).

/*
 * Testing of each part
 * Question 1 part 1

?- generateRow(3,L)
L = ['  ', '  ', '  ']
L = ['  ', '  ', x]
L = ['  ', x, '  ']
L = ['  ', x, x]
L = [x, '  ', '  ']
L = [x, '  ', x]
L = [x, x, '  ']
L = [x, x, x]

?- generateRow(2,L)
L = ['  ', '  ']
L = ['  ', x]
L = [x, '  ']
L = [x, x]

 * Question 1 part 2
?- generateRowCheck([1,1],3,L).
L = [x, '  ', x]
false

?- generateRowCheck([2],3,L).
L = ['  ', x, x]
L = [x, x, '  ']
false

?- generateRowCheck([1,1,1],3,L).
false

?- generateRowCheck([3],3,L).
L = [x, x, x]

 * Question 2
?- generateImage(3,3,[[2],[1,1],[1]],I).
I = [['  ', x, x], [x, '  ', x], ['  ', '  ', x]]
I = [['  ', x, x], [x, '  ', x], ['  ', x, '  ']]
I = [['  ', x, x], [x, '  ', x], [x, '  ', '  ']]
I = [[x, x, '  '], [x, '  ', x], ['  ', '  ', x]]
I = [[x, x, '  '], [x, '  ', x], ['  ', x, '  ']]
I = [[x, x, '  '], [x, '  ', x], [x, '  ', '  ']]

?- generateImage(3,4,[[2],[1,1],[3]],I).
I = [['  ', '  ', x, x], ['  ', x, '  ', x], ['  ', x, x, x]]
I = [['  ', '  ', x, x], ['  ', x, '  ', x], [x, x, x, '  ']]
I = [['  ', '  ', x, x], [x, '  ', '  ', x], ['  ', x, x, x]]
I = [['  ', '  ', x, x], [x, '  ', '  ', x], [x, x, x, '  ']]
I = [['  ', '  ', x, x], [x, '  ', x, '  '], ['  ', x, x, x]]
I = [['  ', '  ', x, x], [x, '  ', x, '  '], [x, x, x, '  ']]
I = [['  ', x, x, '  '], ['  ', x, '  ', x], ['  ', x, x, x]]
I = [['  ', x, x, '  '], ['  ', x, '  ', x], [x, x, x, '  ']]
I = [['  ', x, x, '  '], [x, '  ', '  ', x], ['  ', x, x, x]]
I = [['  ', x, x, '  '], [x, '  ', '  ', x], [x, x, x, '  ']]
I = [['  ', x, x, '  '], [x, '  ', x, '  '], ['  ', x, x, x]]
I = [['  ', x, x, '  '], [x, '  ', x, '  '], [x, x, x, '  ']]
I = [[x, x, '  ', '  '], ['  ', x, '  ', x], ['  ', x, x, x]]
I = [[x, x, '  ', '  '], ['  ', x, '  ', x], [x, x, x, '  ']]
I = [[x, x, '  ', '  '], [x, '  ', '  ', x], ['  ', x, x, x]]
I = [[x, x, '  ', '  '], [x, '  ', '  ', x], [x, x, x, '  ']]
I = [[x, x, '  ', '  '], [x, '  ', x, '  '], ['  ', x, x, x]]
I = [[x, x, '  ', '  '], [x, '  ', x, '  '], [x, x, x, '  ']]

 * Question 3
?- transpose([[x, x, '  '], [x, '  ', x], [x, '  ', '  ']],I)
I = [[x, x, x], [x, '  ', '  '], ['  ', x, '  ']]

?- transpose([[x, x, x], [x, '  ', '  '], ['  ', x, '  ']],I)
I = [[x, x, '  '], [x, '  ', x], [x, '  ', '  ']]

 * Question 4 (Due to hardware/setting issues, SWISH does not
 * 	allow the constriant as shown in assignment (not enough
 * 	stack memory). Smaller puzzle, therefore, is used and the result 
 * 	is verified visually. 

?- solve_puzzle([[1,1],[2,1],[4],[2],[2]],[[3],[2],[1],[3],[2,2]],L)
[x, , , , x]
[x, x, , , x]
[x, x, x, x, ]
[ , , , x, x]
[ , , , x, x]
L = [[x, '  ', '  ', '  ', x], [x, x, '  ', '  ', x], [x, x, x, x, '  '], ['  ', '  ', '  ', x, x], ['  ', '  ', '  ', x, x]]
false

*/ 

    
    

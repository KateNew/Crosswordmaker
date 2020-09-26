%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Crosswordmaker 
%%%%% Kateřina Nová
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%mainMaker(+InputFile,+OutputFile,+Width,+Height,+Secret)
mainMaker(InputFile,OutputFile,Width,Height,Secret):-
    readWords(InputFile,WordsList),
    string_chars(Secret,SecretChars),
    makeCrossword(WordsList,SecretChars,Width,Height,SquaresList,KeyList),
    drawTable(SquaresList,Height,Table),
    reverse(Table,Output),
    listToFile(OutputFile,Output,KeyList).

%%%%% Načtení vstupu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%readWords(+File,-WordsList)
readWords(File, WordsList):-
    csv_read_file(File, Rows),
    rowsToWordsList(Rows,WordsList).

%rowsToWordsList(+Rows,-WordsList)
rowsToWordsList([],[]).
rowsToWordsList([row(Key,Answer)|RowT],[(Key,Chars)|WordsListT]):-
    string_chars(Answer, Chars),
    rowsToWordsList(RowT,WordsListT).

%%%%%% Tvorba křížovky %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%makeCrossword(+WordsList,+SecretChars, +Width, +Height, -SquareList, -KeyList)
makeCrossword(WordsList,SecretChars,Width,Height,SquaresList,KeysList):-
    placeWord(SecretChars,Width,Height,WordSquares),
    addKey(WordSquares,tajenka,KeysListR,KeysList),
    makeCrossword1(WordsList,Width,Height,WordSquares,SquaresList,KeysListR),
    complete(SquaresList,Width,Height),!.

%makeCrossword1(+WordsList, +Width, +Height, +Acumulator, -SquaresList, -KeyList)
makeCrossword1([],_,_,A,A,[]).
makeCrossword1([(Key,CharsList)|WordT],Width,Height,A,SquaresList,KeysList):-
    placeWord(CharsList,Width, Height, WordSquares),
    legalWord(WordSquares,A),
    addKey(WordSquares,Key,KeysListR,KeysList),
    append(WordSquares,A,SquaresListR),
    makeCrossword1(WordT,Width,Height,SquaresListR,SquaresList,KeysListR).

%placeWord(+CharsList, +Width, +Height, -WordSquares)
placeWord(ListOfChars,Width,Height,WordSquares):-
    length(ListOfChars, Len),
    listNtoM(1,Width-Len+1,YList),
    listNtoM(1,Height,XList),
    member(X,XList),
    member(Y,YList),
    placeWord1(ListOfChars, (X,Y),horizontal,WordSquares).
placeWord(ListOfChars,Width,Height,WordSquares):-
    length(ListOfChars, Len),
    listNtoM(1,Width,YList),
    listNtoM(1,Height-Len+1,XList),
    member(X,XList),
    member(Y,YList),
    placeWord1(ListOfChars, (X,Y),vertical,WordSquares).
placeWord(_,_,_,[]).

%placeWord1(+CharsList,+(X,Y),+Direction,-WordSquares)    
placeWord1([],_,_,[]).
placeWord1([H|TChars],(X,Y),Direction,[(X,Y,H,Direction)|TSquares]):-
    newCoordinates((X,Y),Direction,(NX,NY)),
    placeWord1(TChars,(NX,NY),Direction,TSquares).

%newCoordinates(+(X,Y),+Direction,-(NX,NY))
newCoordinates((X,Y),horizontal,(X,NY)):-
    NY is Y + 1.
newCoordinates((X,Y),vertical,(NX,Y)):-
    NX is X + 1.

%listNtoM(+N, +M, -List)
listNtoM(N,M,[]):-
    N > M.
listNtoM(N,M,[N|List]):-
    N =< M,
    NR is N + 1,
    listNtoM(NR,M,List).

%legalWord(+WordSquares,+SquaresList)
legalWord([],_).
legalWord([(X1,Y1,L,Direction)|WordSquares],SquareList):-
    oposite(Direction,ODirection),
    member((X1,Y1,L,ODirection),SquareList),
    legalWord(WordSquares,SquareList).

legalWord([(X1,Y1,_,_)|WordSquares],SquareList):-
    \+member((X1,Y1,_,_),SquareList),
    legalWord(WordSquares,SquareList).

%oposite(+Direction,-Direction).
oposite(vertical,horizontal).
oposite(horizontal,vertical).

%addKey(+SquaresList, +Key, +OldKeysList, -NewKeysList)  
addKey([],_,KeyList,KeyList).
addKey([(X,Y,_,Direction)|_],Key,KeyList,[(X,Y,Direction,Key)|KeyList]).

%complete(+KeysList, +Height)
complete(SquareList,Width,Height):-
    Size is Width * Height *2,
    length(SquareList,Len),
    Size == Len.

%%%%% Vypsání výsledku %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%drawTable(+SquaresList,+Height,-Table)
drawTable([],0,[]):-!.
drawTable(SquareList,X,[Row|Output]):-
    bagof((Y,L), member((X,Y,L,vertical),SquareList), RowBag),
    delete(SquareList,(X,_,L,_),SquareListR),
    sort(1,@<,RowBag,Sorted),
    drawRow(Sorted,Row),
    NX is X -1,
    drawTable(SquareListR,NX,Output).


%drawRow(+SquaresList, -RowList)
drawRow([],[]).
drawRow([(_,L)|List],[L|Row]):-drawRow(List,Row).

%writeList(+File, +List)
writeList(_File, []) :- !.
writeList(File, [LetterList|T]) :-
    write(File,LetterList),
    %write(File, '\t'),
    %write(File, Key),
    write(File, '\n'),
    writeList(File, T).

%listToFile(+Filename, +List)
listToFile(Filename,List1,List2) :-
    append(List1,List2,List),
    open(Filename, write, File),
    writeList(File, List),
    close(File).
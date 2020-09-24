%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Crosswordmaker 
%%%%% Kateřina Nová
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%mainMaker(+InputFile,+OutputFile,+MaxWidth,+Secret)
mainMaker(InputFile,OutputFile,Width,Secret):-
    readWords(InputFile,WordsList),
    string_chars(Secret,SecretChars),
    length(SecretChars,Height),
    makeCrossword(WordsList,SecretChars,Width,Height,SquaresList,KeyList),
    drawTable(SquaresList,Height,Table),
    reverse(Table,Output),
    listToFile(OutputFile,Output).

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
    listNtoM(1,Width,List),
    member(Y1,List),
    makeCrossword1([("tajenka",SecretChars)||WordsList],Width,Height,WordSquares,SquaresList,KeysList),
    complete(KeysList,Width,Height),!.

%makeCrossword1(+WordsList, +Width, +Height, +Acumulator, -SquaresList, -KeyList)
makeCrossword1([],_,_,A,A,[]).
makeCrossword1([(Key,CharsList)|WordT],Width,Height,A,SquaresList,KeysList):-
    placeWord(CharsList,Width, Height, WordSquares),
    legalWord(WordSquares,A),!,
    addKey(WordSquares,Key,KeysListR,KeysList),
    append(WordSquares,A,SquaresListR),
    makeCrossword1(WordT,Width,Height,SquaresListR,SquaresList,KeysListR).

%placeWord(+CharsList, +Width, +Height, -WordSquares)
placeWord(CharsList,Width,_,[]):-
    length(CharsList, Len),
    Width - Len < 0,!.
placeWord(ListOfChars,Width,Height,WordSquares):-
    length(ListOfChars, Len),
    listNtoM(1,Width-Len+1,YList),
    listNtoM(1,Height,XList),
    member(X,XList),
    member(Y,YList),
    placeWord1(ListOfChars, (X,Y),horizontal,WordSquares).
placeWord(ListOfChars,Width,Height,WordSquares):-
    length(ListOfChars, Len),
    listNtoM(1,Width-Len+1,YList),
    listNtoM(1,Height,XList),
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
legalWord(WordSquares,SquareList):-
    member((X1,Y1,L,horizontal),WordSquares),
    member((X1,Y1,L,vertical),SquareList),!.
legalWord(WordSquares,SquareList):-
    member((X1,Y1,L,vertical),WordSquares),
    member((X1,Y1,L,horizontal),SquareList),!.
legalWord(WordSquares,SquareList):-
    member((X1,Y1,_,_),WordSquares),
    \+member((X1,Y1,_,_),SquareList),!.

%addKey(+SquaresList, +OldKeysList, -NewKeysList)  
addKey([],_,KeyList,KeyList).
addKey([(X,_,_,_)|_],Key,KeyList,[(X,Key)|KeyList]).

%complete(+KeysList, +Height)
complete(SquareList,Width,Height):-
    Size is Width * Height,
    length(SquareList,Len),
    Size == Len.

%%%%% Vypsání výsledku %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%drawTable(+SquaresList,+Height,-Table)
drawTable([],0,[]):-!.
drawTable(SquareList,X,[Row|Output]):-
    findall((Y,L), member((X,Y,L,vertical),SquareList), RowBag),
    findall((Y,L), \+member((X,_,L,_),SquareList),SquareListR),
    sort(1,@>,RowBag,Sorted),
    drawRow(Sorted,Row),
    NX is X -1,
    drawTable(SquareListR,NX,Output).


%drawRow(+SquaresList, -RowList)
drawRow([],[]).
drawRow([[(_,L)|List],[L|Row]):-drawRow(List,Row).

%writeList(+File, +List)
writeList(_File, []) :- !.
writeList(File, [(Key,LetterList)|T]) :-
    write(File,LetterList),
    write(File, '\t'),
    write(File, Key),
    write(File, '\n'),
    writeList(File, T).

%listToFile(+Filename, +List)
listToFile(Filename,List) :-
    open(Filename, write, File),
    writeList(File, List),
    close(File).

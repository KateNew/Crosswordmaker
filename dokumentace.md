# Crosswordmaker

### Popis programu
Program dostane seznam dvojic klíč-odpověď, tajenku a maximální šířku tabulky. Z odpovědí sestaví tabulku tak, aby v jednom sloupci svisle vycházela zadaná tajenka. V každém řádku výsledné tabulky se nachází právě jedna položka. Ty mohou začínat i končit různě, ale všechny musí zasahovat do tajenkového sloupce.

### Implementace
#### Načtení vstupu
Program dostane jméno souboru, ve kterém se nachází dvojice klíč-odpověd. Každá dvojice se musí nacházet na samostatném řádku a klíč a odpověď jsou odděleny čárkou. Jak klíč, tak odpověď mohou obsahovat víc slov. Procedura *readWords* a *rowsToWordsList* načtou obsah souboru a vytvoří seznam dvojic (Klíč, Seznam znaků odpovědi).
Také tajenka se převede na seznam znaků a z jeho délky se zjistí výška tabulky.

#### Tvorba křížovky
Jednotlivá políčka tabulky jsou reprezentovány čtveřicí (Xová souřadnice, Yová souřadnice, Znak, Směr). 
Procedura *makeCrossword* nederministicky umístí tajenku do nějakého sloupce a pak zavolá *makeCrossword1*, která umístí do tabulky zbylá slova. 
Procedura *makeCrossword1* rekurzivně prochází seznam slov a každé se pomocí procedury *placeWord* pokusí umístit do tabulky. Procedura *legalWord* kontroluje, jestli takto umístěné slovo splňuje požadované vlastnosti (protíná sloupec tajenky a v daném řádku už není jiné slovo). Pokud ano, přidá jeho klíč do seznamu klíčů pomocí procedury *addKey* a jeho políčka do seznamu všech políček.
Procedura *placeWord* funguje nedeterministicky - dané slovo se buď vůbec nepoužije - v tom případě se vrátí prázdný seznam a nebo pomocí *member* deterministicky umístí slovo na všechny možné pozice a vrátí seznam odpovídajícíh políček.
Umisťování do tabulky na konkrétní místo a v konkrétním směru má na starosti rekurzivní procedura *placeWord1*. 
Po vytvoření tajenky se pomocí procedura *complete* zkontroluje, zda je počet klíčů shodný s výškou tabulky. Protože předtím kontrolujeme, zda v jednom řádku není víc klíčů, je tento term splněný pouze pokud každý řádek má právě jeden klíč.

#### Tisk výsledků
Nejprve procedury *drawTable* a *drawRow* převedou list jednotlivých políček na tabulku. Ta se pomocí *listToFile* zapíše do souboru. Výstup tvoří vyplněná tajenka s klíčem na každém řádku.

### Testovací data
Vstupní testovací data jsou uložena v souboru *test.csv*. Následující příkaz vytvoří z testovacích dat křížovku s tajenkou PROLOG a maximální šířkou deset políček a zapíše ji do souboru *krizovka.txt*.

mainMaker("test.csv","krizovka.txt",10,"prolog").

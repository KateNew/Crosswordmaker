# Crosswordmaker

### Popis programu
Program dostane seznam dvojic klíč-odpověď, tajenku a velikost tabulky. Odpovědi a tajenku umístí do tabulky tak, aby každé políčko bylo součástí právě dvou slov (horizontálně a vertikálně). Pak vypíše seznam klíčů s odpovídajícími souřadnicemi a směrem jejích odpovědí.

### Implementace
#### Načtení vstupu
Program dostane jméno souboru, ve kterém se nachází dvojice klíč-odpověd. Každá dvojice se musí nacházet na samostatném řádku a klíč a odpověď jsou odděleny čárkou. Jak klíč, tak odpověď mohou obsahovat víc slov. Procedura *readWords* a *rowsToWordsList* načtou obsah souboru a vytvoří seznam dvojic (Klíč, Seznam znaků odpovědi).
Také tajenka se převede na seznam znaků.

#### Tvorba křížovky
Jednotlivá políčka tabulky jsou reprezentovány čtveřicí (Xová souřadnice, Yová souřadnice, Znak, Směr). 
Procedura *makeCrossword* nederministicky umístí tajenku a pak zavolá *makeCrossword1*, která umístí do tabulky zbylá slova. 
Procedura *makeCrossword1* rekurzivně prochází seznam slov a každé se pomocí procedury *placeWord* pokusí umístit do tabulky. Procedura *legalWord* kontroluje, jestli takto umístěné slovo splňuje požadované vlastnosti (pro každé políčko platí, že je tam stejné písmeno, ale v opačném směru, nebo se tam zatím nic nevyskytuje). Pokud ano, přidá jeho klíč do seznamu klíčů pomocí procedury *addKey* a jeho políčka do seznamu všech políček.
Procedura *placeWord* funguje nedeterministicky, dané slovo se buď vůbec nepoužije - v tom případě se vrátí prázdný seznam, umístí se horizontálně nebo vertikálně - pak pomocí *member* deterministicky umístí slovo na všechny možné pozice a vrátí seznam odpovídajícíh políček.
Umisťování do tabulky na konkrétní místo a v konkrétním směru má na starosti rekurzivní procedura *placeWord1*. 
Po vytvoření tajenky se pomocí procedura *complete* zkontroluje, zda se počet vytvořených políček rovná dvojnásobku velikosti tabulky. Díky *legalWord* se nemůže stát, že by ve vytvořených políčkách bylo nějaké víckrát než dvakrát.

#### Tisk výsledků
Nejprve procedury *drawTable* a *drawRow* převedou list jednotlivých políček na tabulku. Ta se pomocí *listToFile* zapíše do souboru spolu se seznamem klíčů. Výstup tvoří vyplněná tajenka a seznam klíčů s odpovídajícími souřadnicemi.

### Testovací data
Vstupní testovací data jsou uložena v souboru *test.csv* (delší slova s klíči) a *test2.csv* (tří písmená slova bez klíčů). 

Fungující příkaz:
mainMaker("test2.csv","krizovka2.txt",3,3,cat).

Následující příkaz nedoběhne:
mainMaker("test.csv","krizovka.txt",6,6,prolog).

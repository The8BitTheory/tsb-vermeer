#RetroDevStudio.MetaData.BASIC:2049,BASIC V2

1 TL$="WIE EIN VERMEER..."
2 DN$="TV*"

4 IF A=0 THEN DR=PEEK(186)
5 IF A=0 THEN PRINT CHR$(147);:POKE53280,0:POKE53281,0

6 IF A=0 THEN PRINT CHR$(30);TL$CHR$(144);

10 IF A=0 THEN A=1:LOAD"TSB.OBJ",DR,1
20 P=631:C=0:POKE 39291,DR:POKE 56,128

30 KB$=CHR$(76)+CHR$(79)+CHR$(193)+CHR$(34)
32 KB$=KB$+LEFT$(DN$,3)+CHR$(34)+CHR$(58)+CHR$(131)

34 FOR C=1 TO LEN(KB$)
36  V=ASC(MID$(KB$,C,1))
38  POKE P+C-1,V
40 NEXT

42 POKE 198,LEN(KB$):SYS 33139

#RetroDevStudio.MetaData.BASIC:2049,BASIC V2,lowercase,10,10
# DISTANCES BETWEEN CITIES
# ALSO, TYPE OF TRANSPORT (SHIP, TRAIN)

# 

10 DIM TR$(19)

20 TR$(0)=CHR$(7)+CHR$(8)+CHR$(7)+CHR$(8)+CHR$(9)+CHR$(11)+CHR$(15)+CHR$(15)+CHR$(12)+CHR$(10)+CHR$(9)+CHR$(9)+CHR$(8)+CHR$(5)+CHR$(4)+CHR$(3)+CHR$(2)+CHR$(16)+CHR$(13)+CHR$(11)
30 TR$(1)=CHR$(1)+CHR$(2)+CHR$(1)+CHR$(2)+CHR$(4)+CHR$(8)+CHR$(10)+CHR$(9)+CHR$(8)+CHR$(7)+CHR$(11)+CHR$(13)+CHR$(10)+CHR$(9)+CHR$(10)+CHR$(9)+CHR$(13)+CHR$(15)+CHR$(17)
40 TR$(2)=CHR$(3)+CHR$(1)+CHR$(1)+CHR$(4)+CHR$(8)+CHR$(10)+CHR$(9)+CHR$(9)+CHR$(8)+CHR$(12)+CHR$(12)+CHR$(9)+CHR$(10)+CHR$(11)+CHR$(10)+CHR$(13)+CHR$(15)+CHR$(16)
50 TR$(3)=CHR$(2)+CHR$(3)+CHR$(5)+CHR$(9)+CHR$(11)+CHR$(8)+CHR$(6)+CHR$(5)+CHR$(9)+CHR$(11)+CHR$(8)+CHR$(9)+CHR$(10)+CHR$(9)+CHR$(13)+CHR$(16)+CHR$(15)
60 TR$(4)=CHR$(1)+CHR$(3)+CHR$(7)+CHR$(9)+CHR$(8)+CHR$(8)+CHR$(7)+CHR$(11)+CHR$(13)+CHR$(10)+CHR$(10)+CHR$(11)+CHR$(10)+CHR$(12)+CHR$(14)+CHR$(17)
70 TR$(5)=CHR$(3)+CHR$(7)+CHR$(9)+CHR$(8)+CHR$(8)+CHR$(8)+CHR$(12)+CHR$(13)+CHR$(10)+CHR$(11)+CHR$(12)+CHR$(11)+CHR$(12)+CHR$(14)+CHR$(17)
80 TR$(6)=CHR$(4)+CHR$(6)+CHR$(5)+CHR$(5)+CHR$(6)+CHR$(12)+CHR$(16)+CHR$(13)+CHR$(13)+CHR$(12)+CHR$(13)+CHR$(9)+CHR$(11)+CHR$(14)
90 TR$(7)=CHR$(2)+CHR$(3)+CHR$(5)+CHR$(6)+CHR$(12)+CHR$(16)+CHR$(14)+CHR$(14)+CHR$(12)+CHR$(17)+CHR$(7)+CHR$(7)+CHR$(10)
100 TR$(8)=CHR$(3)+CHR$(5)+CHR$(6)+CHR$(10)+CHR$(14)+CHR$(14)+CHR$(14)+CHR$(12)+CHR$(16)+CHR$(3)+CHR$(8)+CHR$(8)
110 TR$(9)=CHR$(2)+CHR$(3)+CHR$(9)+CHR$(13)+CHR$(11)+CHR$(11)+CHR$(9)+CHR$(14)+CHR$(5)+CHR$(8)+CHR$(11)
120 TR$(10)=CHR$(1)+CHR$(7)+CHR$(11)+CHR$(9)+CHR$(9)+CHR$(7)+CHR$(12)+CHR$(7)+CHR$(10)+CHR$(13)
130 TR$(11)=CHR$(6)+CHR$(10)+CHR$(8)+CHR$(8)+CHR$(6)+CHR$(11)+CHR$(8)+CHR$(11)+CHR$(14)
140 TR$(12)=CHR$(4)+CHR$(7)+CHR$(8)+CHR$(7)+CHR$(11)+CHR$(13)+CHR$(15)+CHR$(14)
150 TR$(13)=CHR$(3)+CHR$(4)+CHR$(7)+CHR$(7)+CHR$(15)+CHR$(12)+CHR$(10)
160 TR$(14)=CHR$(1)+CHR$(4)+CHR$(4)+CHR$(12)+CHR$(9)+CHR$(7)
170 TR$(15)=CHR$(3)+CHR$(3)+CHR$(13)+CHR$(10)+CHR$(8)
180 TR$(16)=CHR$(5)+CHR$(14)+CHR$(13)+CHR$(11)
190 TR$(17)=CHR$(14)+CHR$(11)+CHR$(9)
200 TR$(18)=CHR$(3)+CHR$(6)
210 TR$(19)=CHR$(3)



310 REM TRAVELDISTANCES
320 OPEN 1,8,3,"@0:TRAVEL,S,W"

330 FOR X=0 TO 19
340  PRINT X":"LEN(TR$(X))
350  PRINT#1,TR$(X);
360 NEXT

370 CLOSE 1

380 PRINT "DONE"

420 OPEN 1,8,3,"@0:TRAVEL,S,R"

430 FOR X=0 TO 19
440  L=20-X
445  PRINT "X="X",L="L":";
450  FOR P=1 TO L
460   GET#1,A:PRINT ASC(A);
470  NEXT
475  PRINT
480 NEXT

490 CLOSE 1

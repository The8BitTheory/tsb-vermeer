#RetroDevStudio.MetaData.BASIC:2049,Tuned Simons' BASIC,lowercase,10,10
# ALLO OODWELL! :-)

# CH HAB EIGENTLICH NUR ZWEI NMERKUNGEN ZU DEINEM IDEO. AS EINE IST, DASS
# DU DEN EFEHL  NICHT ZU KENNEN SCHEINST, ER DIENT DAZU, TELLEN AUF DEM
# ILDSCHIRM ZU INVERTIEREN. A ERUEBRIGT SICH EINE ZWEIFACHE EXTAUSGABE (EIN-
# MAL REVERS).

# AS ANDERE IST DIE GROSSE NTERSTUETZUNG, DIE  EINEM GEBEN KANN, WENN MAN
# STRUKTURIERTE ROGRAMME ENTWICKELN MOECHTE.

# EIN ROGRAMM WAR NATUERLICH TOTALER PAGHETTI-ODE, SOLLTE ES JA AUCH SEIN
# ("MAN KANN MIT  MAL EBEN WAS ZAUBERN"). BER  ERLEICHTERT *UNGEMEIN* DAS
# STRUKTURIERTE ODEN UND LANEN! ELCHE EATURES SOLL MEIN ROGRAMM HABEN?
# ANN ICH DIE AUF EINE UNKTION HERUNTERBRECHEN, DIE IN EINE ROZEDUR PASST?

# N DEN ALLERMEISTEN AELLEN FINDEST DU MIT  DAZU GUTE NTWORTEN, LEICHT
# NACHVOLLZIEHBAR, KURZ UND SCHNELL IM BLAUF.

# N MEINER ERSION VON DEINEM ROGRAMM HIER HABE ICH DAS ALLES ZU VERDEUTLICHEN
# VERSUCHT. ENN ICH DABEI ETWAS UEBER DAS IEL HINAUSGESCHOSSEN BIN, BITTE
# NICHT BOESE SEIN. AS PASSIERT HALT SO IM LOW! ;-)

# -----------------------------------------------------------------------------

# S GEHT LOS:  *OHNE* ARAMETER MACHT SOWOHL ILDSCHIRM ALS AUCH AHMEN
# SCHWARZ, DER URSOR BLEIBT WIE ER WAR. IER MACHT DAS INN, DENN DIE URSOR-
# FARBE KOMMT ERST SPAETER INS PIEL (IN  SCREEN).

# TRUKTURIERUNG: IES HIER IST DAS AUPTPROGRAMM: > INIT:SCREEN:MENUE <.
# N SO EINE UFTEILUNG HAB ICH MICH SCHNELL GEWOEHNT. IE IST IMMER DER ERSTE
# CHRITT ZU (WEITERER) TRUKTUR. AST ALLE MEINE -ROGRAMME FANGEN SO AN.

100 COLOUR0,0,1:CA=$E800
105 IFA=0THENA=1:MEM:PRINT"ADE EICHENSATZ":LOAD"TSB2.SET",0,0,CA
110 INIT:SCREEN:MENUE
120 NRM:CLS:COLOUR11,12,0
130 END

# INIT: RRAYS, IHRE EFUELLUNG, WICHTIGE ARIABLEN, DIE ZUERST IM UCHPROZESS
# DES NTERPRETERS STEHEN MUESSEN. EICHENSATZ. : AMIT HAST DU GROSSE
# LEXIBILITAET BEIM EFUELLEN VON RRAYS GEWONNEN! IN WAHRER EGEN! CH HABE
# DESHALB ABSICHTLICH DIE -EILEN ETWAS VERTEILT. EI  WIRD 
# BERUECKSICHTIGT (AUCH WICHTIG!) -  BESCHLEUNIGT ALLE S. AS
# CHLUESSELWORT  HABE ICH GRUNDSAETZLICH WEGGELASSEN, DAS ABEL ALLEIN
# REICHT JA ALS ROZEDURAUFRUF. EBRIGENS IST  *MIT* CHLUESSELWORT GERING-
# FUEGIG SCHNELLER ALS OHNE (DIE RKENNUNG ALS -UFRUF FAELLT BEI VORHAN-
# DENEM  WEG).

1000 PROC INIT

1002  CHECK
1010  INITMOUSE

1015  DIM M$(14),F%(1,6),BD$,I,I1:F=11:FS=12:FB=6:IL=10:ID=0:MI=0


#PD(PLAYER-ID,#): LAYER ATA
#              0: CURRENT CITY
#              1: CASH
1016  DIM PD(1,1)
#     PLAYER STARTS IN BERLIN
1017  PD(0,0)=6:PD(0,1)=50000

#GS(#): GAME STATE
#   0: CURRENT PLAYER
#   1: CURRENT ROOM
1018  DIM GS(1)
1019  GS(0)=0:GS(1)=2

# LANTATION
#PL$(PLANTATION-ID,$): PLANTATION-DATA
# TRING, CONTAINING 1 BYTE EACH FOR
#  X-COORDINATE
#  Y-COORDINATE
#  WIDTH
#  HEIGHT
#  SEED: ABAK,AFFEE,AKAO,EE,EIDE
#  PRODUCTIVITY: 0, 100, 110
#  SOIL: OK
#  SIZE: WIDTH*HEIGHT MINUS OCCUPIED SPOTS (WATER, BUSHES, ROCKS, ...)

#PP$(PLAYER-ID) - PLAYER-PLANTATION ASSIGNMENT
#
#1030 DIM PL$(36),PP$(4)

# ROOMS:
#  ROOM DEFINES THE NAVIGATION OPTIONS AND WHAT'S DISPLAYED
# HAT MEANS THAT SUB-SECTIONS OF "ROOMS" ARE ALSO ROOMS BY THEMSELVES
# EVEN THOUGH IT MIGHT NOT LOOK LIKE THAT FOR THE PLAYER.
# G BUYING A PLANTATION IS A SEPARATE ROOM JUST AS WELL AS THE PLANTATION
# OVERVIEW, SELLING A PLANTATION AND THE PLANTATION MANAGEMENT SCREEN.

# THE S ARE NOT ORDERED VERY WELL, THE ORDER REFLECTS THE ORDER OF
# DEVELOPMENT.

# 0: CITY HUB EMPORIUM
# 1: CITY HUB GALLERIE
# 2: CITY HUB PLANTATION
# 3: TRAVEL
# 4: HOTEL
# 5: GALLERIE
# 6: BANK
# 7: AUKTIONSHAUS
# 8: PLANTATION
# 9: LAGER
#10: MARKTPLATZ
#11: EXPEDITION

#12: BUY PLANTATION
#13: SELL PLANTATION
#14: MANAGE PLANTATION

# ROOM-OPTIONS(ROOM-ID,OPTION-TARGET)
1020  DIM RO(14,5)
1021  RO(0,0)=3:RO(0,1)=10:RO(0,2)=4:RO(0,3)=6:RO(0,4)=7:RO(0,5)=-1
1022  RO(1,0)=3:RO(1,1)=5 :RO(1,2)=4:RO(1,3)=6:RO(1,4)=7:RO(1,5)=-1
1023  RO(2,0)=3:RO(2,1)=8 :RO(2,2)=4:RO(2,3)=6:RO(2,4)=11:RO(2,5)=9
1024  RO(3,0)=128:RO(3,1)=-1
1025  RO(4,0)=128:RO(4,1)=-1
1026  RO(5,0)=1:RO(5,1)=-1
1027  RO(6,0)=128:RO(6,1)=-1
1028  RO(7,0)=128:RO(7,1)=-1

1029  RO(8,0)=12:RO(8,1)=13:RO(8,2)=14:RO(8,3)=2

1030  RO(9,0)=2:RO(9,1)=-1
1031  RO(10,0)=0:RO(10,1)=-1
1032  RO(11,0)=2:RO(11,1)=-1
1033  RO(12,0)=15:RO(12,1)=15:RO(12,2)=8
1034  RO(13,0)=0:RO(13,1)=-1
1035  RO(14,0)=0:RO(14,1)=-1

#     XM(0)=MINIMUM X-COORDINATE FOR SPRITE ON PLANTATION
#     YM(0)=MINIMUM Y-COORDINATE FOR SPRITE ON PLANTATION
#     XM(1) AND YM(1) ARE ACCORDING IMUM COORDINATES
1040  DIM XM(2),YM(2),T(3):XM(2)=24:YM(2)=50
1042  XM(0)=XM(2)+16:YM(0)=YM(2)+6*8
1044  XM(1)=XM(0)+21*8:YM(1)=YM(0)+15*8


1100  M$(0)="USGANG":M$(1)="USGANG":M$(2)="USGANG":M$(3)="EISEN"
1110  M$(4)="OTEL":M$(5)="ALERIE":M$(6)="ANK":M$(7)="UKTION"
1120  M$(8)="LANTAGE":M$(9)="AGERHAUS":M$(10)="ARKT":M$(11)="XPEDITION"

# LANTAGE
1130  M$(12)="AUFEN":M$(13)="ERKAUFEN":M$(14)="ERWALTEN"




1200  RESET 58250

1210  FOR I=1 TO 9
1220   READ A:BD$=BD$+CHR$(A)
1230  NEXT

1240  RESET 2000

1250  FOR I=1 TO 6
1260   READ F%(0,I)
1270  NEXT
1280  FOR I=1 TO 6
1290   READ F%(1,I)
1300  NEXT

1310  ZEICHEN
1320  INITCITIES

1330 END PROC


# ARBEN
2000 DATA 15, 9,11, 2, 5, 6
2010 DATA  1, 2,15,10,13,14


# TRUKTUR: ILDSCHIRMAUFBAU MIT BLEIBENDEN NHALTEN IN EINEM EIGENEN . IER
# HAST DU IN DEINEM IDEO JA AUCH VARIABLE ERTE EINGEBAUT (DIE ARBEN), GERE-
# GELT DURCH DIE ARIABLE . EI UFRUFEN VON NTERPROGRAMMEN (FRAME) SETZE ICH
# ALLE NOETIGEN ARAMETER MOEGLICHST DAVOR IN DIE GLEICHE EILE, DAS SCHAFFT
# LARHEIT. - EINE RLAEUTERUNG ZU  IM IDEO FAND ICH SEHR ANSCHAULICH!

# UNKTIONEN: AS BRAUCHT MAN ZUR ARSTELLUNG AUF DEM ILDSCHIRM: AESTEN,
# CHATTEN, NHALTE, REALISIERT MIT FRAME, DANACH  (ODER  (..) ).
# ENN EIN ENUE DABEI IST WIE HIER: MENUE, ITEM UND TAG (ENUEPUNKT UND AR-
# KIERUNG DESSELBEN). N MENUE FINDET DIE ROGRAMMSTEUERUNG STATT (CHLEIFE MIT
# ). CH LESE ZUR ERMEIDUNG VON TRINGMUELL UND ZUR BLAUFBESCHLEUNIGUNG
# DEN ASTENDRUCK BEI  DIREKT AUS DEM INGABEPUFFER AUS (512). UR E-
# FUELLUNG DES ENUES DIENT ' ITEMS'.


# ILDSCHIRMMASKE
# IL: ITEM LENGTH (MAX CHARACTERS OF MENU-ITEM)
# OC: OPTION COUNT (NR OF MENU ITEMS)
6800 PROC SCREEN
6810  IF GS(1)<12 THEN FILL 0,0,40,25,0,15
6811  COLOUR,1

6815  PRINT AT(0,0) GS(1)

6820  IF GS(1)=0 THEN OHUBEMP:END PROC
6821  IF GS(1)=1 THEN OHUBGAL:END PROC
6822  IF GS(1)=2 THEN OHUBPLA:END PROC
6823  IF GS(1)=3 THEN OTRA:END PROC
6825  IF GS(1)=4 THEN OHOT:END PROC
6827  IF GS(1)=5 THEN OGAL:END PROC
6828  IF GS(1)=6 THEN OBAN:END PROC
6829  IF GS(1)=7 THEN OAUC:END PROC
6830  IF GS(1)=8 THEN OPLA:END PROC
6831  IF GS(1)=9 THEN OWAR:END PROC
6832  IF GS(1)=10 THEN OMAR:END PROC
6833  IF GS(1)=11 THEN OEXP:END PROC

# UY PLANTATION
6834  IF GS(1)=12 THEN OPLABUY:END PROC
# ELL PLANTATION
6835  IF GS(1)=13 THEN OPLASEL:END PROC
# MANAGE PLANTATION
6836  IF GS(1)=14 THEN OPLAMAN:END PROC
# PLANT PLANTATION
#6837  IF GS(1)=15 THEN OPLAPLANT

6870 END PROC


########################
# KTUELLER RT UND ATUM
# ANK, LANTAGE, ITYHUB, ALLERIE
6900 PROC LOCDATECASHHEADER

6901  BX=1:BY=1:BW=26:BH=3:FRAME
6902  PRINT AT(BY+1,BX+1) TX$(PD(0,0),0)

# NZEIGE ARVERMOEGEN
6903  BX=27:BY=1:BW=12:BH=3:FRAME
6904  PRINT AT(BY+1,BX+1) PD(0,1)" "

6905 END PROC





################
# USWAHLMENUE
# UEBERALL AUSSER EISEN
# TV:TEMP VALUE
# OC:OPTION COUNT
6910 PROC CHOICEMENU

6912  BX=27:BY=20-OC:BW=12:BH=3+OC:FRAME

#     IN ENUE BEFUELLEN
6914  FOR I1=0 TO OC

#      INEN EINZELNEN ENUEPUNKT AUSGEBEN
6916   TV=RO(GS(1),I1)
6918   IF TV=128 THEN TV=0
6920   IF TV>=0 THEN PRINT AT(BY+I1+1,BX+1) M$(TV);

6922  NEXT
6923  TAG

6924 END PROC





######
# GENERIC BOX WITH TEXT
#######
6930 PROC BOXWITHTEXT

6932  BX=1:BY=6:BW=20:BH=5:FRAME
6934  CENTER AT(BY+2,BX)TX$,BW

6939 END PROC


# EACH OF THE FOLLOWING 1000-LINES SECTIONS HANDLES ONE ROOM
# EACH OF THE HANDLERS CONSISTS OF 3 MAIN PROCEDURES
# INPUT, LOGIC, OUTPUT
# INPUT IS CALLED BY THE HANDLEENTER DISPATCH METHOD
# LOGIC IS USUALLY CALLED BY THE INPUT PART AND CONTAINS THE ACTUAL GAME-CODE
# OUTPUT DEALS WITH RENDERING THE SCREEN, BASED ON THE ROOM'S DATA


###################
# TADTBILDSCHIRM MPORIUM 0 #
###################
7000 PROC OHUBEMP
7001  IL=10:OC=4

7002  LOCDATECASHHEADER
7003  CHOICEMENU

7199 END PROC

###################
# TADTBILDSCHIRM ALLERIE 1 #
###################
8000 PROC OHUBGAL
8001  IL=10:OC=4
8002  LOCDATECASHHEADER
8003  CHOICEMENU

8199 END PROC


###################
# TADTBILDSCHIRM LANTAGE 2 #
###################
9000 PROC OHUBPLA
9001  IL=10:OC=5
9002  LOCDATECASHHEADER


9010  BX=1:BY=12:BW=24:BH=11:FRAME
9020  PRINT AT(BY+1,BX+1) "RSTER ESUCH";
9030  PRINT AT(BY+3,BX+1) "RODUKTION:";
9040  PRINT AT(BY+4,BX+1) TT$(VAL(TX$(PD(0,0),1)));
9050  PRINT AT(BY+5,BX+1) TT$(VAL(TX$(PD(0,0),2)));

9102  CHOICEMENU

9199 END PROC



###################
# EISEBILDSCHIRM 3 #
###################

#INPUT
#PD(X,Y):PLAYERDATA
# X:CURRENT CITY
# Y:CURRENT CASH
10000 PROC ITRA

10010  IF ID<21 THEN PD(0,0)=ID

10020  FCC

10030  ID=0:SCREEN

10040 END PROC


#OUTPUT
10800 PROC OTRA
10801  GS(1)=3:IL=11:OC=21
#     RAHMEN FUER WELTKARTE
10810  BX=1:BY=1:BW=24:BH=17:FRAME

#     ANZEIGE SPIELERNAME UND AKTUELLE STADT
10820  BX=1:BY=20:BW=24:BH=3:FRAME

#     AUSWAHL DER STADT
10830  BX=26:BY=0:BW=13:BH=24:FRAME

10840  FOR I1=0 TO 20
10850   PRINT AT(BY+I1+1,BX+1) TX$(I1,0);
10860  NEXT

10870  PRINT AT(BY+21+1,BX+1) M$(0)+" ";

10875  TAG

10880 END PROC




#########
# OTEL 4 #
#########
12000 PROC OHOT
12001  GS(1)=4:IL=10:OC=0
12010  LOCDATECASHHEADER

12020  TX$="OTEL":BOXWITHTEXT

12030  CHOICEMENU

12040 END PROC


########
# ANK 6 #
########
13000 PROC OBAN
13001  GS(1)=6:IL=10:OC=0
13010  LOCDATECASHHEADER

#     TRESORE
13020  BX=1:BY=3:BW=38:BH=10:FRAME

#     LISTE DER AKTIENKURSE
13030  BX=1:BY=15:BW=22:BH=6:FRAME

13040  CHOICEMENU

13050 END PROC


###########
# ALERIE 5 #
###########
14000 PROC OGAL
14001  GS(1)=5:IL=10:OC=0

14010  LOCDATECASHHEADER
14020  TX$="ALERIE":BOXWITHTEXT
14030  CHOICEMENU

14040 END PROC



###########
# UKTION 7 #
###########
15000 PROC OAUC
15001  GS(1)=7:IL=10:OC=0

15010  LOCDATECASHHEADER
15020  TX$="UKTION":BOXWITHTEXT
15030  CHOICEMENU

15040 END PROC


############
# LANTAGE 8 #
############
16000 PROC OPLA
16001  GS(1)=8:IL=10:OC=3

16010  LOCDATECASHHEADER
16020  BX=1:BY=5:BW=25:BH=19:FRAME
16025  FILL BY+1,BX+1,BW-2,BH-2,96,5
16030  CHOICEMENU

16040 END PROC



##################
# BUY PLANTATION 12 #
##################
17000 PROC OPLABUY
17010  GS(1)=12:IL=10:OC=2

17015  BX=27:BY=5:BW=12:BH=4:FRAME
17016  PRINT AT(BY+1,BX+1) "ANDPREIS"
17017  PRINT AT(BY+2,BX+1) "291 "

17020  BX=27:BY=17:BW=12:BH=5:FRAME
17021  PRINT AT(BY+1,BX+1) TT$(VAL(TX$(PD(0,0),1)));
17022  PRINT AT(BY+2,BX+1) TT$(VAL(TX$(PD(0,0),2)));
17023  PRINT AT(BY+3,BX+1) M$(0)

17024  TAG

17030 END PROC

########################

17100 PROC IPLABUY

17102  IF ID<2 THEN OPLAPLANT:END PROC

17110  IF ID=2 THEN GS(1)=8:ID=0:SCREEN:END PROC
17120 END PROC

#########################



####################
# PLANT PLANTATION 15 #
####################
17500 PROC OPLAPLANT
17502  GS(1)=15:OC=1

# DW=DRAW SPRITE (FLAG)
# XM(0) = MINIMUM X-COORDINATE
# XM(1) = MAXIMUM Y-COORDINATE
# SAME FOR YM(0) AND YM(1)
17505  SX=XM(0)+16:SY=YM(0)+16

# SPRITE-NR,BLOCK,COLOR,PRIO,TYPE,SIZE
# 1,1,BLACK,DONT SHOW,HIRES
17510  MMOB1,SX-17,SY-17:MMOB3,SX-17,SY+12:MMOB5,SX,SY
#:MMOB2,SX+9,SY-17:MMOB4,SX+9,SY+12:
17511  MOBON1:MOBON3:MOBON5
17512  DW=0:PQ=0

17515  REPEAT
17520   KEYGET I$:I=PEEK(512)

17525   IF I=145 THEN DO
17526    SY=SY-8:IF SY>=YM(0) THEN DW=-1:ELSE SY=YM(0)
17527   DONE
17528   IF DW THEN 17575

17535   IF I=17 THEN DO
17536    SY=SY+8:IF SY<=YM(1) THEN DW=-1:ELSE SY=YM(1)
17537   DONE
17538   IF DW THEN 17575

17545   IF I=157 THEN DO
17546    SX=SX-8:IF SX>=XM(0) THEN DW=-1:ELSE SX=XM(0)
17547   DONE
17548   IF DW THEN 17575

17555   IF I=29 THEN DO
17556    SX=SX+8:IF SX<=XM(1) THEN DW=-1:ELSE SX=XM(1)
17557   DONE
17558   IF DW THEN 17575

17560   IF I=13 THEN PQ=-1

17570   GOTO 17580

17575   MMOB1,SX-17,SY-17:MMOB3,SX-17,SY+12:MMOB5,SX,SY
#:MMOB2,SX+9,SY-17:MMOB4,SX+9,SY+12
17576   DW=0

17580  UNTIL PQ=-1

17582  LPLAOK

17585  MOBOFF1:MOBOFF3:MOBOFF5
#:MOBOFF2:MOBOFF4

17587  BX=27:BY=17:BW=12:BH=4:FRAME
17588  PRINT AT(BY+1,BX+1) "AUFEN";
17589  PRINT AT(BY+2,BX+1) "BBRECHEN";
17590  ID=0:TAG

17599 END PROC

###############

17700 PROC IPLAPLANT

17710  IF ID=0 THEN LPLAOK

17725  GS(1)=8:ID=0:SCREEN

17729 END PROC


# LOGIC: PLANTATION CONFIRMED OK
# THIS IS THE BOOKKEEPING TO CREATE THE NEW PLANTATION AND
#  ASSIGN IT TO THE PLAYER
# 


17730 PROC LPLAOK

17735  T(0)=SY/8-8:T(1)=SX/8-5:T(2)=6:T(3)=6

17740  IF T(0)<6 THEN T(3)=6-(6-T(0)):T(0)=6
17745  IF T(1)<2 THEN T(2)=6-(2-T(1)):T(1)=2

17750  IF T(0)>18 THEN T(3)=6-(T(0)-18)
17755  IF T(1)>19 THEN T(2)=6-(T(1)-19)

17760  FILL T(0),T(1),T(2),T(3),42,ID

17799 END PROC


###################
# SELL PLANTATION 13 #
###################
18000 PROC OPLASEL
18001  GS(1)=13:IL=10:OC=0
18010  TX$="LANTAGE VERKAUFEN":BOXWITHTEXT
18020  CHOICEMENU
18099 END PROC

######################

18100 PROC IPLASEL
18110  GS(1)=8:ID=0:SCREEN
18120 END PROC



#####################
# MANAGE PLANTATION 14 #
#####################
19000 PROC OPLAMAN
19001  GS(1)=14:IL=10:OC=0
19010  TX$="LANTAGE VERWALTEN":BOXWITHTEXT
19020  CHOICEMENU
19099 END PROC

19100 PROC IPLAMAN
19110  GS(1)=8:ID=0:SCREEN
19120 END PROC


#############
# AREHOUSE 9 #
#############
20000 PROC OWAR
20001  GS(1)=9:IL=10:OC=0

20010  LOCDATECASHHEADER
20020  TX$="AGERHAUS":BOXWITHTEXT
20030  CHOICEMENU

20040 END PROC

20100 PROC IWAR
20110  HANDLECHOICE
20120 END PROC

###############
# ARKETPLACE 10 #
###############
21000 PROC OMAR
21001  GS(1)=10:IL=10:OC=0

21010  LOCDATECASHHEADER
21020  TX$="ARKTPLATZ":BOXWITHTEXT
21030  CHOICEMENU

21040 END PROC

21100 PROC IMAR
21110  HANDLECHOICE
21120 END PROC

##############
# XPEDITION 11 #
##############
22000 PROC OEXP
22001  GS(1)=11:IL=10:OC=0

22010  LOCDATECASHHEADER
22020  TX$="XPEDITION":BOXWITHTEXT
22030  CHOICEMENU

22040 END PROC

22100 PROC IEXP
22110  HANDLECHOICE
22120 END PROC


# INEN ASTEN MIT CHATTEN MALEN, DIE ARBEN SIND IN EINEM RRAY, DAMIT MAN
# DIE ARBKOMBINATIONEN UNTER ONTROLLE HAT.

58200 PROC FRAME
58210  INSERT BD$,BY,BX,BW,BH,FB
58215  FILL BY+1,BX+1,BW-2,BH-2,32,1
58220  FCOL BY+BH,BX+1,BW,1,11:REM F%(0,ID)
58225  FCOL BY+1,BX+BW,1,BH,11:REM F%(0,ID)
58230 END PROC

# AHMENZEICHEN
58250 DATA 111,183,112,180,32,170,108,187,188



# TATT OPPELAUSGABE (EINMAL DAVON REVERS) EINFACH  VERWENDEN!

# INEN ENUEPUNKT MARKIEREN
58400 PROC TAG
58410  INV BY+ID+1,BX+1,IL,1
58420 END PROC

# AS ENUE, IN EINER CHLEIFE. CH VERSUCHE IMMER JEGLICHE ORM VON  ZU
# VERMEIDEN, DAMIT EIN ROGRAMM JEDERZEIT MOEGLICHST EINFACH ZU VERAENDERN IST.

58440 PROC MENUE
#8442  TAG

58443  LOOP
58444   IF MI THEN QRYMOUSE
58446   IF NOT MI THEN DO

58448    Q=0

58452    REPEAT

58454     R=0:KEYGET I$:I=PEEK(512)

58456     IF I=145 THEN TAG:ID=ID-1:R=-1:IF ID<0 THEN ID=OC
58458     IF I=17 THEN TAG:ID=ID+1:R=-1:IF ID>OC THEN ID=0

58460     IF I=13 THEN HANDLEENTER

58462     IF I=ASC("I") THEN MI=-1:Q=-1
58464     IF R THEN TAG

58466    UNTIL Q=-1

58470   DONE
58472  END LOOP

58474 END PROC





# HANDLES THE ENTER KEY IN THE MAIN NAVIGATION FRAME
# THIS IS JUST A DISPATCH METHOD THAT FORWARDS TO THE INPUT HANDLER
# OF THE ACCORDING ROOM


58479 PROC HANDLEENTER

58483  IF GS(1)=3 THEN ITRA:END PROC
58485  IF GS(1)<12 THEN HANDLECHOICE:END PROC
#58480  IF GS(1)=0 THEN IHUBEMP:END PROC
#58481  IF GS(1)=1 THEN IHUBGAL:END PROC
#58482  IF GS(1)=2 THEN IHUBPLA:END PROC
#58484  IF GS(1)=4 THEN IHOT:END PROC
#58485  IF GS(1)=5 THEN IGAL:END PROC
#58486  IF GS(1)=6 THEN IBAN:END PROC
#58487  IF GS(1)=7 THEN IAUC:END PROC
#58488  IF GS(1)=8 THEN IPLA:END PROC
#58489  IF GS(1)=9 THEN IWAR:END PROC
#58490  IF GS(1)=10 THEN IMAR:END PROC
#58491  IF GS(1)=11 THEN IEXP:END PROC

58492  IF GS(1)=12 THEN IPLABUY:END PROC
58493  IF GS(1)=13 THEN IPLASEL:END PROC
58494  IF GS(1)=14 THEN IPLAMAN:END PROC
58495  IF GS(1)=15 THEN IPLAPLANT:END PROC

58499 END PROC



# THIS SHOULD ONLY BE USED TO HANDLE THE MAIN SCREENS.
#  ALL SUB-SCREENS (LIKE EG PLANTATION SCREENS) SHOULD BE HANDLED INDIVIDUALLY
#  AS THESE MIGHT NOT NEED TO SETUP THE FULL-SCREEN ALWAYS

#GS(1): CURRENT ROOM
#TV: TEMP-VALUE
58500 PROC HANDLECHOICE

58505  TV=RO(GS(1),ID)
58510  IF TV<128 THEN GS(1)=TV: ELSE FCC
58515  ID=0
58520  SCREEN

58525 END PROC


#FCC=FILLCURCITY
58550 PROC FCC
58560   GS(1)=2
58570   IF TX$(PD(0,0),1)="" THEN GS(1)=0
58580   IF TX$(PD(0,0),1)="" THEN GS(1)=1
58599 END PROC




# AUSABFRAGE
58600 PROC QRYMOUSE

58602  Q=0:MOB ON 0
58605  REPEAT

58610   GET X$

58615   IF X$=CHR$(160) THEN CLICKP
#1517   IF JOY(1)=1 THEN CLICKS

58620   X0=INT(PEEK($D000)):X1=PEEK($D010 )AND 1:Y0=PEEK($D001):X=X0+256*X1
58630   X=INT(X0+X1*256):Y=INT(Y0)

58640   USE AT(17,18)"X =-###",X:USE AT(18,18)"Y =-###",Y:X$=""

58645   GET I$:IF LEN(I$)>0 THEN IF I$="I" THEN MI=0:Q=-1

58650  UNTIL Q=-1
58658  MOB OFF 0

58660 END PROC



# CLICK PRIMAERE MAUSTASTE (LINKS)
58700 PROC CLICKP
58705  PRINT AT(19,18)"LINKS "
58710 END PROC

# CLICK SEKUNDAERE MAUSTASTE (RECHTS)
58715 PROC CLICKS
58720  PRINT AT(19,18)"RECHTS"
58725 END PROC


58800 PROC INITMOUSE
58801  IF PEEK(828)<>$AD THEN PRINT"ADE AUSTREIBER":LOAD"MAUS.DRV",0,0,$0334
58802  DESIGN 0,$C000
58803  @BBB.....................
58804  @BBBBB...................
58805  @BBBBBBB.................
58806  @BBBBBBBBB...............
58807  @BBBBB...................
58808  @BB..BBB.................
58809  @B....BBB................
58810  @......BBB...............
58811  @.......BB...............
58812  @........................
58813  @........................
58814  @........................
58815  @........................
58816  @........................
58817  @........................
58818  @........................
58819  @........................
58820  @........................
58821  @........................
58822  @........................
58823  @........................
58824  MOB SET 0,0,15,128,0
58825  SYS$033C:RLOCMOB0,160,100,0,1
58826  MOB OFF 0

#58935  DESIGN 0,$C000+64*1
#58936  @.BBBBBBBBBBB............
#58937  @BB.........BB...........
#58938  @B.B.......B.B...........
#58939  @B..BBBBBBB..B...........
#58940  @B..B.....B..B...........
#58941  @B..B.....B..B...........
#58942  @B..B.....B..B...........
#58943  @B..B.....B..B...........
#58944  @B..B.....B..B...........
#58945  @B..BBBBBBB..B...........
#58946  @B.B.......B.B...........
#58947  @BB.........BB...........
#58948  @.BBBBBBBBBBB............
#58949  @........................
#58950  @........................
#58951  @........................
#58952  @........................
#58953  @........................
#58954  @........................
#58955  @........................
#58956  @........................


#58960  DESIGN 0,$C000+64*2
#58961  @........................
#58962  @..BBBBBBBBB.............
#58963  @.B.BBBBBBB.B............
#58964  @.BB.......BB............
#58965  @.BB.......BB............
#58966  @.BB.......BB............
#58967  @.BB.......BB............
#58968  @.BB.......BB............
#58969  @.BB.......BB............
#58970  @.BB.......BB............
#58971  @.B.BBBBBBB.B............
#58972  @..BBBBBBBBB.............
#58973  @........................
#58974  @........................
#58975  @........................
#58976  @........................
#58977  @........................
#58978  @........................
#58979  @........................
#58980  @........................
#58981  @........................

### SPRITE BLOCKS 0-15 AVAILABLE
58827  DESIGN 0,$C000+64*1
58828  @BBBBBBBBBBBBBBBBBBBBBBBB
58829  @B.......................
58830  @.......................B
58831  @.......................B
58832  @B.......................
58833  @B.......................
58834  @.......................B
58835  @.......................B
58836  @B.......................
58837  @B.......................
58838  @.......................B
58839  @.......................B
58840  @B.......................
58841  @B.......................
58842  @.......................B
58843  @.......................B
58844  @B.......................
58845  @B.......................
58846  @.......................B
58847  @.......................B
58848  @B.......................

58850  DESIGN 0,$C000+64*2
58851  @BBBBBBBBBBBBBBBBBBBBBBBB
58852  @.......................B
58853  @.......................B
58854  @.......................B
58855  @.......................B
58856  @.......................B
58857  @.......................B
58858  @.......................B
58859  @.......................B
58860  @.......................B
58861  @.......................B
58862  @.......................B
58863  @.......................B
58864  @.......................B
58865  @.......................B
58866  @.......................B
58867  @.......................B
58868  @.......................B
58869  @.......................B
58870  @.......................B
58871  @.......................B

58875  DESIGN 0,$C000+64*3
58876  @B......................B
58877  @B......................B
58878  @B......................B
58879  @B......................B
58880  @B......................B
58881  @B......................B
58882  @B......................B
58883  @B......................B
58884  @B......................B
58885  @B......................B
58886  @B......................B
58887  @B......................B
58888  @B......................B
58889  @B......................B
58890  @B......................B
58891  @B......................B
58892  @B......................B
58893  @B......................B
58894  @B......................B
58895  @B......................B
58896  @BBBBBBBBBBBBBBBBBBBBBBBB

58900  DESIGN 0,$C000+64*4
58901  @.......................B
58902  @.......................B
58903  @.......................B
58904  @.......................B
58905  @.......................B
58906  @.......................B
58907  @.......................B
58908  @.......................B
58909  @.......................B
58910  @.......................B
58911  @.......................B
58912  @.......................B
58913  @.......................B
58914  @.......................B
58915  @.......................B
58916  @.......................B
58917  @.......................B
58918  @.......................B
58919  @.......................B
58920  @.......................B
58921  @BBBBBBBBBBBBBBBBBBBBBBBB

58930  DESIGN 0,$C000+64*5
58931  @BBBBBBBBBBBBBBBB........
58932  @B..............B........
58933  @B..............B........
58934  @B..............B........
58935  @B..............B........
58936  @B......BB......B........
58937  @B...B.B..B.....B........
58938  @B...BB....B....B........
58939  @B...B......B...B........
58940  @B.BBBBBBBBBBBB.B........
58941  @B..B........B..B........
58942  @B..B.B....B.B..B........
58943  @B..B...BB...B..B........
58944  @B..B..B..B..B..B........
58945  @B..B..B..B..B..B........
58946  @BBBBBBBBBBBBBBBB........
58947  @........................
58948  @........................
58949  @........................
58950  @........................
58951  @........................

# SPRITE-IDX, SLOT-IDX, COLOR, PRIO, TYPE, SIZE
58955  MOB SET 1,1,1,128,0,1
58956  MOB SET 2,2,1,128,0,0
58957  MOB SET 3,3,1,128,0,1
58958  MOB SET 4,4,1,128,0,0
58959  MOB SET 5,5,1,128,0,0
58999 END PROC


# REI RTEN VON TAEDTEN:
# * ONDON UND EW ORK:
#   - EISEN
#   - ARKTPLATZ
#   - OTEL
#   - ANK
#   - UKTIONSHAUS

# * MSTERDAM, OM, ISSABON, ARIS, ERLIN UND AN RANCISCO
#   - EISEN
#   - ALLERIE
#   - OTEL
#   - ANK
#   - UKTIONSHAUS

# * LLE ANDEREN 15 TADTE: LANTAGEN
#   - EISEN
#   - LANTAGE
#   - RBEITER
#   - OTEL
#   - AGER
# NKARA,OMBAY,OLOMBO,OMBASA,UALA,BIDJAN,IO,OGOTA
# UATEMALA,EXICO ITY,AVANA,T.OUIS,ATAVIA,ONGKONG,OKYO

59000 PROC INITCITIES
59005  PRINT "EREISE DIE ELT..."
# 0:AME DER TADT
# 1: ODER  (MPORIUM, ALLERY) ODER IFFER FUER ERSTES RODUKT
# 2:IFFER FUER ZWEITES RODUKT
# 3:IFFER FUER HIPPING OMPANY
59010  DIM TX$(22,3)
59011  OPEN 1,8,3,"CITIES,S,R"
59020  FOR L=0 TO 22

59030   INPUT#1,TX$(L,0),TX$(L,1),TX$(L,2),TX$(L,3)

59070  NEXT
59080  CLOSE 1

59090  PRINT "ORT UND CHRIFT..."
59091  DIM TT$(4)
59092  OPEN 1,8,3,"TEXTS,S,R"
59093  FOR L=0 TO 4
59094   INPUT#1,TT$(L)
59095  NEXT
59096  CLOSE 1

59099 END PROC



# EICHENDEFINITIONEN SETZE ICH ANS ROGRAMMENDE (ODER LADE SIE EINFACH AUS
# EINER ATEI, UND ZWAR VIA , DA MUSS ICH KEINE UECKSICHT AUF DEN RT DES
# ODES IM ROGRAMM NEHMEN). ENN ICH EICHEN LADE, HABE ICH SIE ENTWEDER MIT
# EINEM EIGENS DAFUER GEMACHTEN -ROGRAMM ERZEUGT ODER MIT EINEM HAR-DITOR,
# Z.. DEM VON OLOAK ODER MEGA.

60000 PROC ZEICHEN
60001  DESIGN2,CA+8*0
60002  @.B.BBBB.
60003  @B.BBBB.B
60004  @.B.BB.BB
60005  @BBB..BBB
60006  @BBB..BBB
60007  @BB.BB.B.
60008  @B.BBBB.B
60009  @.BBBB.B.
60010  DESIGN2,CA+8*111
60011  @........
60012  @.BBBBBBB
60013  @.B......
60014  @.B.BBBBB
60015  @.B.B....
60016  @.B.B....
60017  @.B.B....
60018  @.B.B....
60019  DESIGN2,CA+8*119
60020  @........
60021  @BBBBBBBB
60022  @........
60023  @BBBBBBBB
60024  @........
60025  @........
60026  @........
60027  @........
60028  DESIGN2,CA+8*112
60029  @........
60030  @BBBBBBB.
60031  @......B.
60032  @BBBBB.B.
60033  @....B.B.
60034  @....B.B.
60035  @....B.B.
60036  @....B.B.
60037  DESIGN2,CA+8*123
60038  @........
60039  @........
60040  @........
60041  @........
60042  @BBBBBBBB
60043  @........
60044  @BBBBBBBB
60045  @........
60046  DESIGN2,CA+8*116
60047  @.B.B....
60048  @.B.B....
60049  @.B.B....
60050  @.B.B....
60051  @.B.B....
60052  @.B.B....
60053  @.B.B....
60054  @.B.B....
60055  DESIGN2,CA+8*106
60056  @....B.B.
60057  @....B.B.
60058  @....B.B.
60059  @....B.B.
60060  @....B.B.
60061  @....B.B.
60062  @....B.B.
60063  @....B.B.
60064  DESIGN2,CA+8*108
60065  @.B.B....
60066  @.B.B....
60067  @.B.B....
60068  @.B.B....
60069  @.B.BBBBB
60070  @.B......
60071  @.BBBBBBB
60072  @........
60073  DESIGN2,CA+8*124
60074  @....B.B.
60075  @....B.B.
60076  @....B.B.
60077  @....B.B.
60078  @BBBBB.B.
60079  @......B.
60080  @BBBBBBB.
60081  @........
60082  DESIGN2,CA+8*96
60083  @B..BB..B
60084  @.BB..BB.
60085  @.BB..BB.
60086  @B..BB..B
60087  @B..BB..B
60088  @.BB..BB.
60089  @.BB..BB.
60090  @B..BB..B
60999 END PROC
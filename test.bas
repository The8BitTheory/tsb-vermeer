#RetroDevStudio.MetaData.BASIC:2049,Tuned Simons' BASIC,lowercase,10,10
280 MEMDEF AN,B2,0,BK:MEMSAVE
290 MEMDEF AN,CP,OF,BK,CL:MEMSAVE
310 REPEAT:REPEAT:PRINT AT(22,0)"PRESS KEY";:KEYGET I$:UNTIL I$>""
340 CLS:S=TI:RFETCH:PRINT AT(1,0)TI-S
350 UNTIL I$="X":CSET 1
360 END

440 PROC RFETCH
450 MEMOR CP,OF,BK,CL:MEMLOAD
490 MEMOR B2,0,BK:MEMLOAD
540 END PROC

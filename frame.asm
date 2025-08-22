;6502 assembly

*= $c000

;!to "frame.bin.prg"

!ct pet

fr          =   1   ;frame index. needs to be parsed from SYS parameter

helpvec     =   $b0
; y=1,x=1,w=26,h=3
zeileanf    =   $C5DF
spalteanf   =   $C5E0
spaltenanz  =   $C5E1
zeilenanz   =   $C5E2

basromaus   =   $8e5f
basromein   =   $8e3a
;l20pl40     =   $8dd6

mve9a       =   $9ecb

mkbox       =   $a158
movez       =   $a0b1
;mkline      =   $a052
;fillmt      =   $a084

; calculate absolute address of frame index offsets
    clc
    lda fa
    adc #fr
    adc #fr
    sta f2
    lda fa+1
    adc #0
    sta f2+1

; calculate layout data address by reading the offset and then adding it to fa
    ldy #0
    lda (f2),y
    tax
    iny
    lda (f2),y
    pha
    iny
    clc
    txa
    adc fa
    sta f2
    pla
    adc fa+1
    sta f2+1

; get frame coordinates
    ldy #0
    jsr loadCoordinates ;increases y by 2
    lda (f2),y
    sta spaltenanz
    sta tempW
    iny
    lda (f2),y
    sta zeilenanz
    sta tempH

    ; zeile mit rahmendaten vorbereiten
    ; $0137 für rahmenzeile (BD$). folgende Zeichen umgekehrt 111,183,112,180,32,170,108,187,188
    ; $0b für länge (8 zeichen)
    ; write color 6 ($a6 evtl nur positiv, wert für color-ram evtl in $20?)
;    ldx #fb
;    stx $a6

    ldx #8
    stx helpvec

-   lda border,x
    sta $0137,x
    dex
    bpl -

    jsr basromaus
    
    ; call INSERT BD$,BY,BX,BW,BH,#FB
    ; compute address (parameters are set)
    lda #0
    sta $a6
    jsr movez
    
    ; screen-ram work for box
    jsr mkbox
    
    ; color-ram work for box (replicates mve9 from TSB's INSERT routine)
    inc $a6
    jsr movez
    
    lda #fb
    jsr mve9a

    ; call FILL BY+1,BX+1,BW-2,BH-2,32,1
    inc zeileanf
    inc spalteanf
    dec spaltenanz
    dec spaltenanz
    dec zeilenanz
    dec zeilenanz

    ; calculate fill dimensions for screen-ram
    lda #0
    sta $a6
    jsr movez
    
    ; set fill character (space)
    lda #32
    ; write to screen-ram
    jsr mve9a
    
    ; calculate fill dimensions for color-ram
    inc $a6
    jsr movez

    ; set foreground-color to fill
    lda #1
    ; write to color-ram
    jsr mve9a
    
    
    ; horizontal shadow below frame
    ; call FCOL BY+BH,BX+1,BW,1,#sb
    clc
    lda tempY         ;load y
    adc tempH         ;add height
    sta zeileanf      ;store y
    
    clc
    lda tempX         ;load x
    adc #1            ;add 1
    sta spalteanf     ;store x
    
    clc
    lda tempW         ;load width
    sta spaltenanz    ;store width
    
    clc
    lda #1            ;load height
    sta zeilenanz     ;store height
    
    ; calc addresses for color-ram
    inc $a6
    jsr movez
    
    ; write color value to calculated addresses
    lda #sb
    jsr mve9a
    
    ; vertical shadow right of frame
    ; call FCOL BY+1,BX+BW,1,BH,#sb
    clc
    lda tempY         ;load y
    adc #1            ;add 1
    sta zeileanf      ;store y
    
    clc
    lda tempX         ;load x
    adc tempW         ;add width
    sta spalteanf     ;store x
    
    clc
    lda #1            ;load 1
    sta spaltenanz    ;store width
    
    clc
    lda tempH         ;load height
    sta zeilenanz     ;store height
    
    ; calc addresses for color-ram
    inc $a6
    jsr movez
    
    ; write color value to calculated addresses
    lda #sb
    jsr mve9a


    jsr basromein
    
    rts

    

    ; increase layout data offset by 4 (that's how long data for a frame is)
incBy4
    clc
    lda f2
    adc #4
    sta f2
    bcc checkNext
    inc f2+1

; check next type byte
; 0 = done
; 1 = cpr
; 2 = vpr
; 3 = vus
checkNext
    ldy #0
    lda (f2),y

    beq .done   ; zero means no more layout data for this frame
    iny

    cmp #1
    beq cpr

    cmp #2
    beq vpr

    cmp #3
    beq vus

    ; invalid value. set carry flag and leave (that shows something went wrong)
    sec
    rts

; PRINT AT(). prints from the textconsts file with a constant index to constant coordinates
cpr
    jsr loadCoordinates
    
    lda (f2),y  ;load index of text constant
    sta tx

    ; jump to constant print handling (same as for vpr)

    jmp incBy4

; PRINT AT().  prints from the textconsts file with a variable index (via param) to constant coordinates
vpr
    jsr loadCoordinates

    lda (f2),y  ;load index of variable-array
    sta vx

    ; iterate variable array to given index and extract the value into tx
    ; sta tx

    ; create temporary string descriptor that points into text constants

    ; calculate absolute y and x positions (framepos + itempos)
    ; poke length into MP$ descriptor
    ; PT=TC+TX*3:TL=PEEK(PT):POKEMA,TL
    ; write value from textconsts at tx into MP$
    ;D!POKE$5A,TC+D!PEEK(PT+1):D!POKE$58,MP:POKE781,1:POKE782,TL:SYS $A3EC

    ;PRINT AT(BY+CY,BX+CX) MP$;
    

    jmp incBy4

; USE AT(). prints a numeric value from VX() with a given CF$ index
vus
    jsr loadCoordinates

    lda (f2),y
    sta cf
    iny
    lda (f2),y
    sta vx

    ; iterate variable array to given index and extract the  value 

    ; calculate absolute y and x positions (framepos + itempos)

    ; get correct CF$ entry

    ;USE AT(BY+CY,BX+CX) CF$(CF),VX(VX)
    
    clc
    lda f2
    adc #5
    sta f2
    bcc +
    inc f2+1
+   jmp checkNext


; we're done. clear carry (to indicate that everything worked out fine) and return
.done
    clc
    rts

loadCoordinates
    lda (f2),y
    sta zeileanf
    sta tempY
    iny
    lda (f2),y
    sta spalteanf
    sta tempX
    iny
    rts

fa !word $7c00 ;address where the binary frame data is stored. either parse from SYS or POKE
;f2  !word 0 ;absolute address pointing to the offset of the layout data
f2 = $fb
fb = 6 ; foreground border
sb = 11; shadow border

; stores x,y,w,h because we need them several times
tempY  !byte 0
tempX  !byte 0
tempW  !byte 0
tempH  !byte 0

tx !byte 0
cf !byte 0
vx !byte 0

border !byte 188,187,108,170,32,180,112,183,111
;border !byte 111,183,112,180,32,170,108,187,188

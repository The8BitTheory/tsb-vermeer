;6502 assembly

*= $7700

!to "frame.bin.prg",cbm

helpvec     =   $b0
  
zeileanf    =   $C5DF
spalteanf   =   $C5E0
spaltenanz  =   $C5E1
zeilenanz   =   $C5E2

basromaus   =   $8e5f
basromein   =   $8e3a

mve9a       =   $9ecb

movez       =   $a0b1
mkbox       =   $a158
use2        =   $a35a
use3        =   $a3bd

chkcommaint =   $e200
;chkcommaint =   $8b89
bsout       =   $ffd2


    jmp frame
    jmp printConstant
    jmp setup
    jmp readkeys        ;auction
    jmp dmaCopy         ;mega65

frame
; calculate absolute address of frame index offsets

    jsr chkcommaint
    stx fr

    clc
    lda fa
    adc fr
    adc fr
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
    sty baseY
    sty baseX
    jsr loadCoordinates ;increases y by 2
    lda tempY
    sta baseY
    lda tempX
    sta baseX
    
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
    
;    clc
    lda tempX         ;load x
    adc #1            ;add 1
    sta spalteanf     ;store x
    
;    clc
    lda tempW         ;load width
    sta spaltenanz    ;store width
    
;    clc
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
    
;    clc
    lda tempX         ;load x
    adc tempW         ;add width
    sta spalteanf     ;store x
    
;    clc
    lda #1            ;load 1
    sta spaltenanz    ;store width
    
;    clc
    lda tempH         ;load height
    sta zeilenanz     ;store height
    
    ; calc addresses for color-ram
    inc $a6
    jsr movez
    
    ; write color value to calculated addresses
    lda #sb
    jsr mve9a
    
    jsr basromein
    
    ; increase layout data offset by 4 (that's how long data for a frame is)
incBy4
    clc
    lda f2
    adc #4
incByZ
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

    bne +
    rts   ; zero means no more layout data for this frame
+   iny

    cmp #1
    beq cpr

    cmp #2
    beq vpr

    cmp #3
    beq vus

    ; invalid value. leave. todo: throw syntax error or something like that
    rts

; PRINT AT(). prints from the textconsts file with a constant index to constant coordinates
cpr
    jsr loadCoordinates
    
    ;load index of text constant
    lda (f2),y  

    jsr printIndexAt

    jmp incBy4
    

; PRINT AT().  prints from the textconsts file with a variable index (via param) to constant coordinates
vpr
    jsr loadCoordinates

    jsr chkcommaint
    txa
    
    jsr printIndexAt
    
;incBy3
    clc
    lda f2
    adc #3
    jmp incByZ
    

; USE AT(). prints a numeric value from parameter with a given CF$ index
vus
    jsr loadCoordinates
    
    lda (f2),y
    tax
    lda cfIndex,x

    jsr prepareForPrint
    
    stx $69 ;store length to x
    
    jsr basromaus
    ldx f4
    ldy f4+1
    ; call TSB's use3
    ; $69 contains length of ctrl string
    ; .X contains LB
    ; .Y contains HB

    jsr use3
    jsr basromein

    ;USE AT(BY+CY,BX+CX) CF$(CF),VX(VX)
    
    jmp incBy4
    
setup
    rts
    
printConstant
    ;pt=tc+tx*3:tl=peek(pt):pokema,tl
    ;d!poke$5a,tc+d!peek(pt+1):d!poke$58,mp:poke781,1:poke782,tl:sys $a3ec
    ; read constant index from parameter
    jsr chkcommaint
    stx zeileanf
    jsr chkcommaint
    stx spalteanf
    jsr chkcommaint
    txa

printIndexAt
    jsr prepareForPrint

    ; read char into A and call BSOUT
    ; for REU, f4 would be replaced with dedicated address $C64D, for example
    ldy #0
-   lda (f4),y
    jsr bsout
    iny
    dex
    bne -
    
    rts
    
prepareForPrint
; takes the value from .A (the text index) and multiplies by 3. store to f4
;  that's where length and string pointer are stored

    ldx #0
    stx tempIndex+1
    
    ;load pointer to text constant into f4
    ;pointer address = tempIndex*3
    ldx #2
    sta tempIndex
-   clc
    adc tempIndex
    bcc +
    inc tempIndex+1
+   dex
    bne -
    sta tempIndex
    
    clc
    adc tc        ; add offset to text-constants
    sta f4
    
    lda tc+1
    adc tempIndex+1
    sta f4+1
    
    ; jump to constant print handling (same as for vpr)
    clc         ;clear carry flag to indicate setting cursor position
    ldy spalteanf   ;y-reg contains col
    ldx zeileanf   ;x-reg contains row
    jsr $fff0   ;set cursor position
    
; stores the pointer to the text constant into f4
;  length of the constant is stored to .X
    ; get text data from constants
    ldy #0    
    lda (f4),y    ; load length of text
    pha           ; store to stack
    
    iny
    lda (f4),y    ; pointer low-byte offset
    tax           ; store to X temporary
    iny
    lda (f4),y    ; pointer high-byte offset
    tay           ; store to y temporary
    
    clc
    txa           ; get offset low-byte
    adc tc        ; add base-address low-byte
    sta f4        ; store as new offset low-byte 
    
    tya           ; get offset high-byte
    adc tc+1      ; add base-address high-byte
    sta f4+1      ; store as new offset high-byte

    pla           ; pull length from stack
    tax           ; write to X
    
; f4 could be a reference to REU memory.
; then we could copy the string to a dedicated RAM location at this point
; f4 would receive the dedicated RAM location afterwards
; the routine printIndexAt would then always just use a fixed read location
; $C64D is an area with 256 bytes available, that would be a good candidate for that
    rts

loadCoordinates
    clc
    lda (f2),y
    adc baseY
    sta zeileanf
    sta tempY
    iny
    clc
    lda (f2),y
    adc baseX
    sta spalteanf
    sta tempX
    iny
    rts

fa !word $0400 ;address where the binary frame data is stored. either parse from SYS or POKE
tc !word $7a00 ;address where the binary text constants are stored. either parse from SYS or POKE

f2 = $fb
f4 = $fd
fb = 6 ; foreground border
sb = 11; shadow border

fr        !byte 0
; stores x,y,w,h because we need them several times
baseY     !byte 0
baseX     !byte 0


tempY     !byte 0
tempX     !byte 0

;used for frame fill and shadows to keep original values of frame's width and height
tempW     !byte 0
tempH     !byte 0

tempIndex !word 0

;border !byte 111,183,112,180,32,170,108,187,188

; these are the indices in textconstants
cfIndex   !byte 88,89,90,91,92,93,94

border !byte 124,123,108,106,32,116,112,119,111

!source "auction.asm"

;!source "loadfromreu.asm"

!source "megadma.asm"
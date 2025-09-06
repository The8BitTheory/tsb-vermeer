;6502 assembly

*= $7c00

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
    jmp swapWithReu     ;REU
    jmp stashToReu      ;REU


baseY     !byte 0
baseX     !byte 0
baseW     !byte 0
baseH     !byte 0


frame
; calculate absolute address of frame index offsets
    jsr .memExpPreWarm

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
    
    ; copy index data (2 bytes) from reu to ram
    ldx #2
    jsr .fromExpF2ToMemloc

; calculate layout data address by reading the offset and then adding it to fa
    ldy #0
    lda (memloc),y
    tax
    iny
    lda (memloc),y
    pha
    iny
    clc
    txa
    adc fa
    sta f2
    pla
    adc fa+1
    sta f2+1
    
    ldx #$ff
    jsr .fromExpF2ToMemloc

; get frame coordinates
    ldy #0
    sty baseY
    sty baseX
    jsr loadCoordinates ;increases y by 2
    lda tempY
    sta baseY
    lda tempX
    sta baseX
    
    lda (memloc),y
    sta spaltenanz
    sta tempW
    sta baseW
    iny
    lda (memloc),y
    sta zeilenanz
    sta tempH
    sta baseH
    iny
    sty fy

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
    jmp +
    
    ; increase layout data offset by 4 (that's how long data for a frame is)
checkNext
    ldx #$ff
    jsr .fromExpF2ToMemloc

; check next type byte
; 0 = done
; 1 = cpr
; 2 = vpr
; 3 = vus
+   ldy fy
    lda (memloc),y

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
    lda (memloc),y
    iny
    sty fy    ;store y-offset of framedata

    jsr printIndexAt

    jmp checkNext
    

; PRINT AT().  prints from the textconsts file with a variable index (via param) to constant coordinates
vpr
    jsr loadCoordinates
    sty fy
    jsr chkcommaint
    txa
    
    jsr printIndexAt
    
;incBy3
    jmp checkNext
    

; USE AT(). prints a numeric value from parameter with a given CF$ index
vus
    jsr loadCoordinates
    
    lda (memloc),y
    iny
    sty fy    ;store y-offset of framedata
    tax
    lda cfIndex,x

    jsr prepareForPrint
    
    stx $69 ;store length to x
    
    jsr basromaus

    ldx $69
    jsr .fromExpF4ToMemloc
    
;    ldx f4
;    ldy f4+1
    ; call TSB's use3
    ; $69 contains length of ctrl string
    ; .X contains LB
    ; .Y contains HB
    ldx memloc
    ldy memloc+1

    jsr use3
    jsr basromein

    ;USE AT(BY+CY,BX+CX) CF$(CF),VX(VX)
    
    jmp checkNext
    
; this reads 3 addresses (tc,fa,memloc) from parameters and stores them here for future use
setup
    ; read memory type
    jsr chkcommaint
    cpx #1
    bne +
    lda #<.reuPreWarm
    sta memexp_prewarm
    lda #>.reuPreWarm
    sta memexp_prewarm+1
    
    lda #<.fromReuToMemloc
    sta memexp_toMemloc
    lda #>.fromReuToMemloc
    sta memexp_toMemloc+1
    jmp .setupAddresses

+   cpx #2
    bne +
    lda #<mega65DmaFetchPreWarm
    sta memexp_prewarm
    lda #>mega65DmaFetchPreWarm
    sta memexp_prewarm+1
    
    lda #<fromMega65ToMemloc
    sta memexp_toMemloc
    lda #>fromMega65ToMemloc
    sta memexp_toMemloc+1

.setupAddresses    
    ; read memloc. $c64d pretty much
    jsr parseAddressParameter
    lda $14
    sta memloc
    lda $15
    sta memloc+1
    
    ; read text-constants offset. used to be $7a00 in main ram, but now needs to be REU/M65 bank offset
    jsr parseAddressParameter
    lda $14
    sta tc
    lda $15
    sta tc+1
    
    ; read frame-definitions offset. used to be $0400 in main ram, but now needs to be REU/M65 bank offset
    jsr parseAddressParameter
    lda $14
    sta fa
    lda $15
    sta fa+1
    
+   rts
        
printConstant
    ; read constant index from parameter
    jsr .memExpPreWarm
    
    jsr chkcommaint
    stx zeileanf
    jsr chkcommaint
    stx spalteanf
    jsr chkcommaint
    txa

printIndexAt
    jsr prepareForPrint

    ; read char into A and call BSOUT
    ldy #0
-   lda (memloc),y
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
    
    ldx #3
    jsr .fromExpF4ToMemloc
    
    ; jump to constant print handling (same as for vpr)
    clc         ;clear carry flag to indicate setting cursor position
    ldy spalteanf   ;y-reg contains col
    ldx zeileanf   ;x-reg contains row
    jsr $fff0   ;set cursor position
    
    
; stores the pointer to the text constant into f4
;  length of the constant is stored to .X
    ; get text data from constants
    ldy #0    
    lda (memloc),y    ; load length of text
    pha           ; store to stack
    
    iny
    lda (memloc),y    ; pointer low-byte offset
    tax           ; store to X temporary
    iny
    lda (memloc),y    ; pointer high-byte offset
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
    
    jmp .fromExpF4ToMemloc

loadCoordinates
    clc
    lda (memloc),y
    adc baseY
    sta zeileanf
    sta tempY
    iny
    clc
    lda (memloc),y
    adc baseX
    sta spalteanf
    sta tempX
    iny
    rts
    
; .A=c64 address LB, .Y=c64 address HB, .X=length LB
.fromExpF4ToMemloc
    lda f4
    ldy f4+1
    jmp (memexp_toMemloc)

; .A=c64 address LB, .Y=c64 address HB, .X=length LB
.fromExpF2ToMemloc
    lda f2
    ldy f2+1
    jmp (memexp_toMemloc)
    
.memExpPreWarm
    jmp (memexp_prewarm)

parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
        
; .A=LB, .X=HB for Length
.fromReuToMemloc
    stx REUBYTES

; set reu address
    sta REURAM
    sty REURAM+1
    
; set c64 address
    ;done in preWarm
    lda #REU_FETCH_A__
    sta REUCOMMAND

    rts
    
.reuPreWarm
    lda #0
    sta REUBYTES+1
    sta REUBANK
    
    lda memloc
    sta REUC64RAM
    lda memloc+1
    sta REUC64RAM+1
    
    rts


fa        !word $0400 ; address where the binary frame data is stored.
f2        !word 0     ; current value of fa+offset
fy        !byte 0     ; offset in frame-data (y offset in 256 byte window)

tc        !word $7a00 ; address where the binary text constants are stored. todo: parse from SYS or POKE
f4        !word 0     ; 

memloc    = $fb;  !word $c64d ;temporary 256 byte working area for dma.

; type of expanded memory
; 1=reu
; 2=mega65
;memtype   !byte 0

; the address
memexp_prewarm        !word 0
memexp_toMemloc       !word 0



fb = 6 ; foreground border
sb = 11; shadow border

fr        !byte 0
; stores x,y,w,h because we need them several times

tempY     !byte 0
tempX     !byte 0

;used for frame fill and shadows to keep original values of frame's width and height
tempW     !byte 0
tempH     !byte 0

tempIndex !word 0

; these are the indices in textconstants
cfIndex   !byte 88,89,90,91,92,93,94

border    !byte 124,123,108,106,32,116,112,119,111

!source "loadfromreu.asm"

!source "megadma.asm"

!source "auction.asm"



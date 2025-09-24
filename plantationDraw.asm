*= $ca00
!to "plantationdr.bin.prg",cbm

!source "mem.inc"

bsout               = $ffd2
mve9a               = $9ecb
movez               = $a0b1
basromaus           = $8e5f
basromein           = $8e3a

zeileanf            = $c5df
spalteanf           = $c5e0
spaltenanz          = $C5E1
zeilenanz           = $C5E2


; draws all plantations of a town

;    jmp drawPlantations
    
drawPlantations
    lda #1
    sta spaltenanz
    sta zeilenanz
    
    jsr fetchTownPlantationData
    
    ; iterate over plantations of this town
    ldx #0  ; contains the memory offset of the plantation (ie index x 13)
    stx .plantLine
    stx .plantCol

checkPlantationOwner
    ;find available plantation slot
    lda plantExpMem,x
    cmp #$ff
    bne availablePlantationFound       ; if unoccupied (owner is $ff), use this
    
; jump to next plantation data
gotoNextPlantationData
    txa                   ; add 13 bytes to index (= location of next plantation data)
    clc
    adc #13
    tax
    bcc checkPlantationOwner ; if carry-bit is clear, we're inside the available plantation indices of this town. draw it.
    
    ; we're beyond the plantation area. we're done
    rts
    

;owner is not $ff, plantation slot is used. draw it.
availablePlantationFound
    stx .plantOffsetX
    
    jsr calcCurPlantData
    
    ldy #1
    lda (.curPlantData),y
    sta .plantSeed

    ldy #3
    clc
    lda (.curPlantData),y
    ;adc #2         ; not adding 2, because we want to start 2 left of the building coordinates anyways
    sta spalteanf
    
    iny
    clc
    lda (.curPlantData),y      ;load the y-coordinate (byte 4)
    adc #4              ;line 6 (0-based) - minus 2 (from building start to plantation start)
    sta zeileanf
        
    ;draw plantation (.plantStart contains building location in screen-ram at this point)
handlePlantationLine
    iny                     ; move on to plantation data coverage (1 byte per line, 6 bits for 6 cells)
    cpy #11                 ; is last line reached?+
    bne handlePlantationCol

    ldx .plantOffsetX
    jmp gotoNextPlantationData

handlePlantationCol    
    lda (.curPlantData),y          ; load single plantation line

    ldx .plantCol
    and .bits6,x            ; beq means zero matches, bne means matches (can only be 1 match because of how .bits6 looks)
    beq gotoNextCol
    
    sty .plantLine
    
    ; output plantation col to screen
    clc         ;clear carry flag to indicate setting cursor position
    ldy spalteanf   ;y-reg contains col
    ldx zeileanf   ;x-reg contains row
    jsr $fff0   ;set cursor position
    
    ldx .plantSeed
    clc
    lda .plantChar,x
    adc #128
    jsr bsout
    
    jsr basromaus
    
    ; calc addresses for color-ram
    lda #1
    sta $a6
    jsr movez
    
    ; write color value to calculated addresses
    lda .plantColor,x
    jsr mve9a
    
    jsr basromein
    
    ldy .plantLine
    
gotoNextCol
    inc spalteanf
    inc .plantCol
    lda .plantCol
    cmp #6
    bne handlePlantationCol     ;go to next col
    
    sec
    lda spalteanf
    sbc #6
    sta spalteanf
    
    inc zeileanf
    lda #0
    sta .plantCol
    
    jmp handlePlantationLine    ;last col reached, go to next line
    
!source "commonPlantation.inc"


.plantOffsetX       !byte 0 ;temp storage for x offset in plantation data (mulitple of 13)
.plantLine          !byte 0
.plantCol           !byte 0
.plantColor         !byte 7,15,15,15
.plantChar          !byte 97,98,99,100
.plantSeed          !byte 0


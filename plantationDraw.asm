*= $ca00
!to "plantationdr.bin.prg",cbm

!source "mem.inc"

bsout             = $ffd2
zeileanf          = $c5df
spalteanf         = $c5e0

plantExpMem         = $c64d
.curPlantData       = $fd ;this points to one specific plantation (ie $c64d + offset)
.expPlantVector   = $c3f0 ;this points to the location in memexp that contains 2304 bytes of plantation data
                          ;plantations of first town are at this address, each following town is at plus 256

;memloc         = $fb   ;screen-ram location of the plantation's building (ie +2/+2 from top-most left point)
                          ;contains the plantation's top-left tile later (can be building, can be less)
;.plantdataaddr    = $fd   ;contains the reu-location of the current town

; draws all plantations of a town

;    jmp drawPlantations
    
drawPlantations
    ; fetch plantation data of this town into $c64d
    jsr chkcommaint
    clc
    txa
    adc .expPlantVector+1
    tay ;high-byte of reu address
    
    lda .expPlantVector
    ldx #$ff
    jsr memFetchResource
    
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
    
    clc
    txa
    adc #<plantExpMem
    sta .curPlantData
    
    lda #>plantExpMem
    adc #0
    sta .curPlantData+1

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
    
    lda #97+128
    jsr bsout
    
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
    
    
.plantOffsetX       !byte 0 ;temp storage for x offset in plantation data (mulitple of 13)
.plantLine          !byte 0
.plantCol           !byte 0
.bits6              !byte %00100000, %00010000, %00001000, %00000100, %00000010, %00000001
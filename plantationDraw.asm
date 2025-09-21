*= $ca00
!cpu 6510

!source "mem.inc"

bsout             = $ffd2
zeileanf          = $c5df
spalteanf         = $c5e0


plantvector       = $c3f0 ;this points to the location in memexp that contains 2304 bytes of plantation data
                          ;plantations of first town are at this address, each following town is at plus 256

memloc         = $fb   ;screen-ram location of the plantation's building (ie +2/+2 from top-most left point)
                          ;contains the plantation's top-left tile later (can be building, can be less)
;.plantdataaddr    = $fd   ;contains the reu-location of the current town

    jmp drawPlantations
    
drawPlantations
    jsr expmem_prewarm  ;set constant values in memory expansion (len-HB=0, dest-address=$c64d)
        
    ; parse town-id
    jsr chkcommaint
    txa    
    adc #>plantvector  ; add 256 bytes to the address per town
    tay
    
    lda #<plantvector   
    ldx #255
    ; fetch plantations of current town into memloc $c64d
    jsr expmem_to_memloc
        
    ; iterate over plantations of this town
    ldy #0
    
checkPlantationOwner
    lda (memloc),y
    cmp #$ff
    beq gotoNextPlantationData ;owner is $ff, that means that plantation slot is empty
    
    ;owner is not $ff, plantation slot is used. draw it.
        
    ;add coordinates of plantation's building to that (bytes 3 and 4 in plantation data)
    sty .plantOffset
    iny
    iny
    iny
    
;    clc
;    lda #2              ;column 2 (0-based) - minus 2 (from building start to plantation start)
    lda (memloc),y      ;add x-coordinate of building
    sta spalteanf

    iny
    clc
    lda #4              ;line 6 (0-based) - minus 2 (from building start to plantation start)
    adc (memloc),y      ;load the y-coordinate (byte 4)
    sta zeileanf
        
    ;draw plantation (.plantStart contains building location in screen-ram at this point)
handlePlantationLine
    iny                     ; move on to plantation data coverage (1 byte per line, 6 bits for 6 cells)
    cpy #11                 ; is last line reached?+
    bne +

    tya                   ; reset index to start of current plantation data
    sec
    sbc #11
    tay
    jmp gotoNextPlantationData
    
+   lda (memloc),y          ; load single plantation line
    
handlePlantationCol
    ldx .plantCol
    and .bits6,x            ; beq means zero matches, bne means matches (can only be 1 match because of how .bits6 looks)
    beq gotoNextCol
    
    sty .plantLine
    
    ; output plantation col to screen
    clc         ;clear carry flag to indicate setting cursor position
    ldy spalteanf   ;y-reg contains col
    ldx zeileanf   ;x-reg contains row
    jsr $fff0   ;set cursor position
    
    lda #97
    jsr bsout
    
    ldy .plantLine
    
gotoNextCol
    inc spalteanf
    inc .plantCol
    cmp #6
    bne handlePlantationCol     ;go to next col
    
    sec
    lda spalteanf
    sbc #6
    sta spalteanf
    
    inc zeileanf
    
    jmp handlePlantationLine    ;last col reached, go to next line
    
    
gotoNextPlantationData
    tya                   ; add 13 bytes to index (= location of next plantation data)
    clc
    adc #13
    tay
    bcc checkPlantationOwner ; if carry-bit is clear, we're inside the available plantation indices of this town. draw it.
    
    rts
    
.plantLine          !byte 0
.plantCol           !byte 0
.plantOffset        !byte 0     ; temp-storage for y register
.bits6              !byte %00100000, %00010000, %00001000, %00000100, %00000010, %00000001
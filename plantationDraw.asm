*= $ca80

HIBASE            = $0288  ; location of screen-ram high-byte
chkcommaint       = $e200
memloc_park       = $064c  ; defined in frame.asm

expmem_prewarm    = $7e00
expmem_to_memloc  = $7e03  ; .X=count, .A=mem LB, .Y=mem HB

plantvector       = $c3f0 ;this points to the location in memexp that contains 2304 bytes of plantation data
                          ;plantations of first town are at this address, each following town is at plus 256

!zone plantation
.plantLoc         = $fb   ;screen-ram location of the plantation's building (ie +2/+2 from top-most left point)
                          ;contains the plantation's top-left tile later (can be building, can be less)
;.plantdataaddr    = $fd   ;contains the reu-location of the current town

    jmp drawPlantations
    
drawPlantations
    jsr expmem_prewarm  ;set constant values in memory expansion. this needs access to memloc_park. todo: rethink this
        
    ; parse town-id
    jsr chkcommaint
    txa    
    adc #>plantvector  ; add 256 bytes to the address per town
    tay
    
    lda #<plantvector   
    ldx #255
    ; fetch plantations of current town into memloc $c64d
    jsr expmem_to_memloc
        
    ; iterate over plantations of town
    ldy #0
-   lda (memloc),y
    cmp #$ff
    beq .next   ;owner is $ff, that means that plantation slot is empty. go to next one
    
    ; draw plantation
    lda #242            ;40*6 + 2 (row 6, column 2)
    sta .plantStart
    lda HIBASE
    sta .plantStart+1
    
    
    
    rts
    
    
.plantStart       !word 0     ; top-left corner of plantation area in screen-ram
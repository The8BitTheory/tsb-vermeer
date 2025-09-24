plantExpMem         = $c64d
.curPlantData       = $fd   ;this points to one specific plantation (ie $c64d + offset)
.expPlantVector     = $c3f0 ;this points to the location in memexp that contains 2304 bytes of plantation data
                            ;plantations of first town are at this address, each following town is at plus 256

fetchTownPlantationData
    ; fetch plantation data of this town into $c64d
    jsr chkcommaint
    clc
    txa
    adc  .expPlantVector+1
    tay ;high-byte of reu address
    
    lda .expPlantVector
    ldx #$ff
    jmp memFetchResource

calcCurPlantData
    clc
    txa
    adc #<plantExpMem
    sta .curPlantData
    
    lda #>plantExpMem
    adc #0
    sta .curPlantData+1
    rts
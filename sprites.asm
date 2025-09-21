*=$ca00
!to "sprites.bin.prg",cbm

!source "mem.inc"

chrgot          = $79

    jmp .fetchSprites
    jmp .setupSpriteLocation

    ; 2 count, 2 c64-address (lb,hb), 2 ext-address (lb,hb)
    ; bank-information is contained in memexp-specific code

.exp_sprites      !word 0

.setupSpriteLocation
    jsr parseAddressParameter
    lda $14
    sta .exp_sprites
    lda $15
    sta .exp_sprites+1
    rts

; takes multiple indices as parameters, copies them to $c000 as specified by index
.fetchSprites

    ; length will always be 64 bytes
    lda #64
    sta dma_params_len
    ldy #0
    sty dma_params_len+1

    ; c64 address will start at $c000 and increment by 64 for each subsequent index
    sty dma_params_c64
    lda #$c0
    sta dma_params_c64+1
    
.parseSpriteIndex
    jsr chkcommaint
    ; multiply index by 2 to get source offset from .exp_sprites
    txa
    asl

    ; reu address is always .exp_sprites plus offset (index * 2)
    ; offset is in accumulator
    clc
    adc .exp_sprites
    sta dma_params_exp
    lda .exp_sprites+1      ; always write HB to get rid of previous value
    adc #0
    sta dma_params_exp+1
    
    ;copy
    jsr expmem_dma_fetch

    jsr chrgot  ; no more parameters?
    beq +       ; no. we're done

    ; increase c64-ram address by 64
    clc
    lda dma_params_c64
    adc #64
    sta dma_params_c64
    bcc .parseSpriteIndex
    inc dma_params_c64+1
    bcs .parseSpriteIndex

; we're done
+   rts


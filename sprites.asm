*=$ca80

!zone spriteFetch

chkcom          = $aefd
frmnum          = $ad8a
getadr          = $b7f7
chrgot          = $79
spriteLoc       = $c000
chkcommaint     = $e200

.dma_params_len = $ca06
.dma_params_c64 = $ca08
.dma_params_exp = $ca0a

.mlDmaFetch     = $7e0c  ; address where the memexp-specific dma-job is executed (reudma.asm, megadma.asm, etc)

    jmp .fetchSprites
    jmp .setupSpriteLocation

    ; 2 count, 2 c64-address (lb,hb), 2 ext-address (lb,hb)
    ; bank-information is contained in memexp-specific code
;.dma_params_len   !byte 0,0
;.dma_params_c64   !byte <spriteLoc,>spriteLoc
;.dma_params_exp   !byte 0,0

.exp_sprites      !word 0

.setupSpriteLocation
    jsr .parseAddressParameter
    lda $14
    sta .exp_sprites
    lda $15
    sta .exp_sprites+1
    rts

; takes multiple indices as parameters, copies them to $c000 as specified by index
.fetchSprites

    ; length will always be 64 bytes
    lda #64
    sta .dma_params_len
    ldy #0
    sty .dma_params_len+1

    ; c64 address will start at $c000 and increment by 64 for each subsequent index
    sty .dma_params_c64
    lda #$c0
    sta .dma_params_c64+1
    
.parseSpriteIndex
    jsr chkcommaint
    ; multiply index by 2 to get source offset from .exp_sprites
    txa
    asl

    ; reu address is always .exp_sprites plus offset (index * 2)
    ; offset is in accumulator
    clc
    adc .exp_sprites
    sta .dma_params_exp
    lda .exp_sprites+1      ; always write HB to get rid of previous value
    adc #0
    sta .dma_params_exp+1
    
    ;copy
    jsr .mlDmaFetch

    jsr chrgot  ; no more parameters?
    beq +       ; no. we're done

    ; increase c64-ram address by 64
    clc
    lda .dma_params_c64
    adc #64
    sta .dma_params_c64
    bcc .parseSpriteIndex
    inc .dma_params_c64+1
    bcs .parseSpriteIndex

; we're done
+   rts

.parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
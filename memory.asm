; memory manager
; is responsible for pulling in the ML routines from expanded memory into RAM
; does so by wrapping all the specific ML routines
; basically this is a directory of 4-byte long entries.
; each entry has 2 bytes length and 2 bytes location in the memory expansion
; location in RAM is supposed to be the same for all of them
; execution of the routines has to be done in basic via SYS
*=$ca00


!zone memory

chkcom        = $aefd
frmnum        = $ad8a
getadr        = $b7f7
chkcommaint   = $e200

.mlDmaFetch   = $7e0c  ; address where the memexp-specific dma-job is executed (reudma.asm, megadma.asm, etc)

execLocation  = $ca80    ; this is where ML routines go to in RAM

    jmp .fetch
    jmp .setup
    
; 2 count, 3 c64-address (lb,hb), 3 ext-address (lb,hb)
.dma_params_len   !byte 0,0
.dma_params_c64   !byte <execLocation,>execLocation
.dma_params_exp   !byte 0,0

; length and locations of routines in expanded memory
; 2 entries so far
; - 0=plantation
; - 1=auction
.exp_dictionary   !fill 12


; this routine creates a dictionary entry
;  it requires an index, 2 bytes length and 2 bytes location in memory expansion
.setup
    jsr chkcommaint
    ; multiply index by 4 to get offset
    txa
    asl
    asl
    sta .tempIndex
    
    ; length
    jsr .parseAddressParameter
    lda $14
    ldx .tempIndex
    sta .exp_dictionary,x
    inx
    lda $15
    sta .exp_dictionary,x
    inx
    stx .tempIndex
    
    ; location
    jsr .parseAddressParameter
    lda $14
    ldx .tempIndex
    sta .exp_dictionary,x
    inx
    lda $15
    sta .exp_dictionary,x
    
    rts
    
.fetch
    lda .exp_dictionary
    sta .dma_params_len
    lda .exp_dictionary+1
    sta .dma_params_len+1
    
    ; expansion location
    lda .exp_dictionary+2
    sta .dma_params_exp
    lda .exp_dictionary+3
    sta .dma_params_exp+1

    ; copy from reu to memory
    jmp .mlDmaFetch
    
    
.parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
    
.tempIndex    !byte 0
    
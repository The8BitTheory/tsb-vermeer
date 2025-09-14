; memory manager
; is responsible for pulling in the ML routines from expanded memory into RAM
; does so by wrapping all the specific ML routines
; basically this is a directory of 4-byte long entries.
; each entry has 2 bytes length and 2 bytes location in the memory expansion
; location in RAM is supposed to be the same for all of them
; execution of the routines has to be done in basic via SYS
*=$ca00
!to "memory.bin.prg",cbm

!zone memory

chkcom          = $aefd
frmnum          = $ad8a
getadr          = $b7f7
chkcommaint     = $e200

.mlDmaFetch     = $7e0c  ; address where the memexp-specific dma-job is executed (reudma.asm, megadma.asm, etc)

execLocation    = $ca80    ; this is where ML routines go to in RAM
parseAddressParameter = $063a ;lives in frame.asm

    jmp .fetch
    jmp .setup
    
; 2 count, 3 c64-address (lb,hb), 3 ext-address (lb,hb)
.dma_params_len   !byte 0,0
.dma_params_c64   !byte <execLocation,>execLocation
.dma_params_exp   !byte 0,0

; length and locations of routines in expanded memory
; setup is writing to this
; 3 entries so far
; - 0=sprites
; - 1=auction
; - 2=plantation
.exp_dictionary   !fill 8


; this routine creates a dictionary entry
;  it requires an index, 2 bytes length and 2 bytes location in memory expansion
.setup
    jsr .parseIndex
    
    ; length
    jsr parseAddressParameter
    lda $14
    ldx .tempIndex
    sta .exp_dictionary,x
    inx
    lda $15
    sta .exp_dictionary,x
    inx
    stx .tempIndex
    
    ; location
    jsr parseAddressParameter
    lda $14
    ldx .tempIndex
    sta .exp_dictionary,x
    inx
    lda $15
    sta .exp_dictionary,x
    
    rts
    
.fetch
    jsr .parseIndex
    tax
    
    lda .exp_dictionary,x
    sta .dma_params_len
    inx
    lda .exp_dictionary,x
    sta .dma_params_len+1
    inx
    
    ; expansion location
    lda .exp_dictionary,x
    sta .dma_params_exp
    inx
    lda .exp_dictionary,x
    sta .dma_params_exp+1

    lda #<execLocation
    sta .dma_params_c64
    lda #>execLocation
    sta .dma_params_c64+1

    ; copy from reu to memory
    jsr .mlDmaFetch

    jmp execLocation

.parseIndex
    jsr chkcommaint
    ; multiply index by 4 to get offset
    txa
    asl
    asl
    sta .tempIndex
    rts
    
;.parseAddressParameter
;    jsr chkcom
;    jsr frmnum
;    jmp getadr
    
.tempIndex    !byte 0
    
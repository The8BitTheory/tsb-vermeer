; memory manager
; is responsible for pulling in the ML routines from expanded memory into RAM
; does so by wrapping all the specific ML routines
; basically this is a directory of 4-byte long entries.
; each entry has 2 bytes length and 2 bytes location in the memory expansion
; location in RAM is supposed to be the same for all of them
; execution of the routines has to be done in basic via SYS
*=$7e00
!to "memory.bin.prg",cbm

!source "mem.inc"

chkcom          = $aefd
frmnum          = $ad8a
getadr          = $b7f7


.expmem_prewarm  = expmem_loc
execLocation    = $ca00    ; this is where ML routines go to in RAM


    jmp fetch       ;fetches ml-routine into $ca00 and executes it
    jmp addRoutineToDict
    jmp .parseAddressParameter
    jmp locMemExpPreWarm
    jmp setup
    
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
.exp_dictionary   !fill 20

setup
    ; read memloc. $c64d pretty much
    jsr parseAddressParameter
    lda $14
    ;lda #$4d
    sta .memloc_park
    lda $15
    ;lda #$c6
    sta .memloc_park+1
    rts

; this routine creates a dictionary entry
;  it requires an index, 2 bytes length and 2 bytes location in memory expansion
addRoutineToDict
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
    
fetch
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
    jsr expmem_dma_fetch        ; goes to $7ecc (.mlDmaFetch routine)

    jmp execLocation

.parseIndex
    jsr chkcommaint
    ; multiply index by 4 to get offset
    txa
    asl
    asl
    sta .tempIndex
    rts
    
.parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
    
locMemExpPreWarm
    lda .memloc_park
    sta memloc
    lda .memloc_park+1
    sta memloc+1
    jmp .expmem_prewarm

    
.tempIndex    !byte 0
.memloc_park  !word 0;$c64d
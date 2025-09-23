; memory manager
; is responsible for pulling in the ML routines from expanded memory into RAM
; does so by wrapping all the specific ML routines
; basically this is a directory of 4-byte long entries.
; each entry has 2 bytes length and 2 bytes location in the memory expansion
; location in RAM is supposed to be the same for all of them
; execution of the routines has to be done in basic via SYS
*=$7e00
!to "memory2.bin.prg",cbm

!source "mem.inc"

chkcom          = $aefd
frmnum          = $ad8a
getadr          = $b7f7

execLocation    = $ca00    ; this is where ML routines go to in RAM
;expmem_loc      = $7f50
expmem_loc      = $0700
expmem_stash    = expmem_loc
expmem_fetch    = expmem_loc+3
expmem_swap     = expmem_loc+6

basic_exp       = $8000


    jmp setup                       ; persist value for dma-working location (memloc)
    jmp addRoutineToDict            ; add ML-routine binary to dictionary
    jmp .parseAddressParameter      ; parses the next basic parameter as address (0-65535)
    jmp stashBasic                  ; a stash command that can be called from basic
    jmp fetchBasic                  ; a fetch command that can be called from basic
    jmp swapBasic                   ; a swap command that can be called from basic
    jmp stash                       ; a stash command that acts on values in dma_params_*
    jmp fetch                       ; a fetch command that acts on values in dma_params_*
    jmp swap                        ; a swap command that acts on values in dma_params_*
    jmp fetchResource               ; a fetch command that reads from expanded memory at .A/.Y .X and writes to C64's dma-working location (memloc). sets dma_params_* and calls fetch
    jmp fetchRoutine                ; a fetch command that reads from expanded memory data taken from the dictionary via index and writes to C64's execute-location ($ca00).
    jmp swapBasicProgram            ; swaps $0800 in DRAM with $8000 in expanded mem and continues running basic at the first line

    
.dma_params_len   !byte 0,0
.dma_params_c64   !byte 0,0
.dma_params_exp   !byte 0,0

; length and locations of routines in expanded memory
; setup is writing to this
; 3 entries so far
; - 0=sprites
; - 1=auction
; - 2=plantation
.exp_dictionary   !fill 20

setup
    jsr .parseAddressParameter
    lda $14
    sta .memloc_park
    lda $15
    sta .memloc_park+1
    rts
    
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
    
.parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
    
.parse3Params
    jsr .parseAddressParameter
    lda $14
    sta .dma_params_len
    lda $15
    sta .dma_params_len+1
    
    jsr .parseAddressParameter
    lda $14
    sta .dma_params_c64
    lda $15
    sta .dma_params_c64+1

    jsr .parseAddressParameter
    lda $14
    sta .dma_params_exp
    lda $15
    sta .dma_params_exp+1
    
    rts
    
stashBasic
    jsr .parse3Params
    jmp expmem_stash
    
fetchBasic
    jsr .parse3Params
    jmp expmem_fetch
    
; copying to $8001 instead of $8000, that allows us to keep the low-byte identical between source and target
;  so we only have to change the HB between read and write when the memory expansion doesn't have native swap
swapBasicProgram
    sec
    lda $2d
    sbc $2b
    sta .dma_params_len
  
    lda $2e
    sbc $2c
    sta .dma_params_len+1
    
; set reu address
    lda #<basic_exp
    sta .dma_params_exp
    lda #>basic_exp
    sta .dma_params_exp+1
    
; set c64 address
    lda $2b
    sta .dma_params_c64
    lda $2c
    sta .dma_params_c64+1

    jsr expmem_swap
    
    ; CURLIN <- Zeilennummer aus $0803/$0804 (erste Zeile bei $0801)
    lda $0803
    sta $39        ; CURLIN low
    lda $0804
    sta $3A        ; CURLIN high

    ; TXTPTR <- Adresse erstes Token (bei $0801 ist das $0801+4 = $0805)
    jsr $a68e
    
    ; 4) In BASIC-Interpreter einsteigen
    jmp $A7AE
    
swapBasic
    jsr .parse3Params
    
swap
    jmp expmem_swap
    
stash
    jmp expmem_stash
    
    
; a fetch command that reads from expanded memory at .A/.Y .X and writes to C64's dma-working location (memloc). sets dma_params_* and calls fetch
fetchResource
    stx .dma_params_len

    sta .dma_params_exp
    sty .dma_params_exp+1
    
    lda .memloc_park
    sta .dma_params_c64
    lda .memloc_park+1
    sta .dma_params_c64+1
    
    lda #0
    sta .dma_params_len+1
    
    jmp expmem_fetch
    
    
; a fetch command that reads from expanded memory data taken from the dictionary via index and writes to C64's execute-location ($ca00).
fetchRoutine
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
    
    jsr expmem_fetch
    jmp execLocation
    

fetch
    jmp expmem_fetch
    
    
.parseIndex
    jsr chkcommaint
    ; multiply index by 4 to get offset
    txa
    asl
    asl
    sta .tempIndex
    rts
    
.tempIndex    !byte 0
.memloc_park  !word 0;$c64d
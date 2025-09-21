*=$7ec0

!to "reudma.bin.prg",cbm

; tt:txttab. start of basic program text
; vt:vartab. start of variables = end of basic program text
; bl:basic length
; bb:basic bank. where in the reu to store the basic program

; tt=d!peek($2b):vt=d!peek($2d):bl=vt-tt:bb=1
; memdef bl,tt,0,bb:memsave
; length: $df07,$df08
; c64 address: $df02, $df03
; reu address:  $df04,$df05
; reu bank: $df06
; reu execute: $df01

; source: https://www.retro-programming.de/programming/nachschlagewerk/nice-to-know/reu-programmierung/
;*******************************************************************************
;*** REU-Register
;*******************************************************************************
REUSTATUS           = $df00         ;Statusregister (nur lesen, wird dann gelöscht!)
REUCOMMAND          = $df01         ;Befehlsregister
REUC64RAM           = $df02         ;RAM-Adresse im C64 (LSB/MSB)
REURAM              = $df04         ;Speicher Adresse in der REU (LSB/MSB)
REUBANK             = $df06         ;Bank in der REU
REUBYTES            = $df07         ;Anzahl der betroffenen BYTES (LSB/MSB)
REUIRQMASK          = $df09         ;Interruptmaske
REUADRCONTROL       = $df0a         ;Adress-Kontroll-Register

;*******************************************************************************
;*** REU-Befehle
;*******************************************************************************
 
;*** Standardbefehle mit AUTOLOAD, ohne $ff00
REU_STASH_A__       = $fc           ;kopiere C64 -> REU
REU_FETCH_A__       = $fd           ;kopiere REU -> C64
REU_SWAP_A__        = $fe           ;Speicherbereich tauschen
REU_VERIFY_A__      = $ff           ;Speicherbereich vergleichen
 
;*** mit AUTOLOAD und mit $ff00
REU_STASH_A_F       = $ec           ;kopiere C64 -> REU
REU_FETCH_A_F       = $ed           ;kopiere REU -> C64
REU_SWAP_A_F        = $ee           ;Speicherbereich tauschen
REU_VERIFY_A_F      = $ef           ;Speicherbereich vergleichen
 
;*** ohne AUTOLOAD, ohne $ff00
REU_STASH____       = $dc           ;kopiere C64 -> REU
REU_FETCH____       = $dd           ;kopiere REU -> C64
REU_SWAP____        = $de           ;Speicherbereich tauschen
REU_VERIFY____      = $df           ;Speicherbereich vergleichen
 
;*** ohne AUTOLOAD, mit $ff00
REU_STASH___F       = $cc           ;kopiere C64 -> REU
REU_FETCH___F       = $cd           ;kopiere REU -> C64
REU_SWAP___F        = $ce           ;Speicherbereich tauschen
REU_VERIFY___F      = $cf           ;Speicherbereich vergleichen


!source "mem.inc"


; used by frame.asm
    jmp reuPreWarm
    jmp fromReuToMemloc
    
; used to load different basic program
    jmp swapWithReu    

; used as basic stash command
    jmp .dmaStash
; used by memory.asm to fetch ML routines to $ca00
    jmp .mlDmaFetch
; used as basic fetch command
    jmp .dmaFetch
    
; 2 count, 2 c64-address (lb,hb), 2 ext-address (lb,hb)
;dma_ml_loc = $ca06 in memory.asm
;$ca06 .dma_params_len   !byte 0,0
;$ca06 .dma_params_c64   !byte <execLocation,>execLocation
;$ca06 .dma_params_exp   !byte 0,0
; on the mega65, this always copies from some bank 5 location to the bank 0 location taken from $ca2c
; this is used by memory.asm to pull in ML-routines before execution
.mlDmaFetch
  
    lda dma_params_len
    sta REUBYTES
    lda dma_params_len+1
    sta REUBYTES+1
  
    lda dma_params_c64
    sta REUC64RAM
    lda dma_params_c64+1
    sta REUC64RAM+1
  
    lda dma_params_exp
    sta REURAM
    lda dma_params_exp+1
    sta REURAM+1
  
    lda #0
    sta REUBANK
  
    lda #REU_FETCH____
    sta REUCOMMAND
    
    rts
  
 
.parseLengthParameter
    jsr parseAddressParameter
    lda $14
    sta REUBYTES
    lda $15
    sta REUBYTES+1
    rts

.parseC64RAMParameter
    jsr parseAddressParameter
    lda $14
    sta REUC64RAM
    lda $15
    sta REUC64RAM+1
    rts

.parseREURAMParameter
    jsr parseAddressParameter
    lda $14
    sta REURAM
    lda $15
    sta REURAM+1    
    rts
    
; read parameters from basic and do DMA stash to REU (length, source, dest)
.dmaStash
    jsr .parseLengthParameter
    jsr .parseC64RAMParameter
    jsr .parseREURAMParameter
    
    lda #0
    sta REUBANK
    
    lda #REU_STASH____
    sta REUCOMMAND
    
    rts

; read parameters from basic and do DMA feetch from REU (length, source, dest)
.dmaFetch
    jsr .parseLengthParameter
    jsr .parseREURAMParameter
    jsr .parseC64RAMParameter
    
    lda #0
    sta REUBANK
    
    lda #REU_FETCH____
    sta REUCOMMAND
    
    rts

; routine that swaps basic program between main memory and higher bank
swapWithReu
; calculate and store length
    sec
    lda $2d
    sbc $2b
    sta REUBYTES
    
    lda $2e
    sbc $2c
    sta REUBYTES+1
    
; set reu address
    lda #0
    sta REURAM
    lda #$80
    sta REURAM+1
    
    lda #0
    sta REUBANK ; bank
    
; set c64 address
    lda $2b
    sta REUC64RAM
    lda $2c
    sta REUC64RAM+1
    
    lda #REU_SWAP____
    sta REUCOMMAND
    
    ; CURLIN <- Zeilennummer aus $0803/$0804 (erste Zeile bei $0801)
    lda $0803
    sta $39        ; CURLIN low
    lda $0804
    sta $3A        ; CURLIN high

    ; TXTPTR <- Adresse erstes Token (bei $0801 ist das $0801+4 = $0805)
    jsr $a68e
    
    ; 4) In BASIC-Interpreter einsteigen
    jmp $A7AE       


 ; .A=LB, .X=HB for Length
fromReuToMemloc
    stx REUBYTES

; set reu address
    sta REURAM
    sty REURAM+1
    
; set c64 address
    ;done in preWarm
    lda #REU_FETCH_A__
    sta REUCOMMAND

    rts
    
reuPreWarm
    lda #0
    sta REUBYTES+1
    sta REUBANK
    
    lda memloc
    sta REUC64RAM
    lda memloc+1
    sta REUC64RAM+1
    
    rts
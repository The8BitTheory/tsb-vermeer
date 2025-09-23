*=$0700

!to "reudma2.bin.prg",cbm

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

    jmp reuStash
    jmp reuFetch
    jmp reuSwap

.paramsToRegs
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
    
    rts    

reuStash
    jsr .paramsToRegs
    lda #REU_STASH____
    jmp .executeCommand

    
reuFetch
    jsr .paramsToRegs
    lda #REU_FETCH____
    jmp .executeCommand

reuSwap
    jsr .paramsToRegs
    lda #REU_SWAP____
    
.executeCommand
    pha
    lda #0
    sta REUBANK

    pla
    sta REUCOMMAND
    rts

 

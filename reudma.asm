*=$7e00

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


memloc    = $fb;  !word $c64d ;temporary 256 byte working area for dma.

!zone load_from_reu

    jmp reuPreWarm
    jmp fromReuToMemloc
    ;jmp swapWithReu    ;enable this when more jmp statements are added

; routine that swaps basic program between main memory and higher bank
swapWithReu
    jsr .setReuBasicAddress
    lda #REU_SWAP____
    sta REUCOMMAND
    
    ; CURLIN <- Zeilennummer aus $0803/$0804 (erste Zeile bei $0801)
    LDA $0803
    STA $39        ; CURLIN low
    LDA $0804
    STA $3A        ; CURLIN high

    ; TXTPTR <- Adresse erstes Token (bei $0801 ist das $0801+4 = $0805)
    jsr $a68e
    
    ; 4) In BASIC-Interpreter einsteigen
    JMP $A7AE       

.setReuBasicAddress
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
    sta REURAM+1
    lda #1
    sta REUBANK ; bank
    
; set c64 address
    lda $2b
    sta REUC64RAM
    lda $2c
    sta REUC64RAM+1
    
    rts

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
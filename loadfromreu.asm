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

!zone load_from_reu
loadFromReu
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
    sta REUBANK ; bank
    
; set c64 address
    lda $2b
    sta REUC64RAM
    lda $2c
    sta REUC64RAM+1

;   xxxxxx00 = STASH
;   xxxxxx01 = FETCH
;   xxxxxx10 = SWAP
;   00000011 = VERIFY
    lda #%10010000
    sta REUCOMMAND

    rts



!zone checkForREU

;*******************************************************************************
;*** Prüfen, ob eine REU angeschlossen ist. 
;*** Um auch die 1700 zu erkennen wird NICHT so, wie auf der 1764 Demo-Disk mit
;*** #$00 geprüft. Bei der 1700 kann $df00 den Wert #$00 annehmen!!
;*******************************************************************************
;*** Übergabe: -
;*******************************************************************************
;*** Rückgabe: Y = 0 REU vorhanden, sonst nicht!
;*******************************************************************************
;*** ändert  : A, X, Y, SR
;*******************************************************************************
checkForREU
 ldy #$ff                           ;Erstmal von keiner REU ausgehen
 lda REUSTATUS                      ;Status-Register lesen, um Bit 7-5 zu löschen
 sty REUSTATUS                      ;schreiben wir zum Test mal #$ff hinein
 cpy REUSTATUS                      ;und schauen, ob der Wert erhalten bleibt
 beq .exit                          ;wenn JA, KEINE REU!!!
 ldx #$04                           ;Wir testen nur Register 2-5 
.loop
 txa
 sta REUCOMMAND,X                   ;Testwert speichern
 cmp REUCOMMAND,X                   ;gleicher Wert?
 bne .exit                          ;wenn nicht, KEINE REU!!!
 dex                                ;Schleifenzähler verringern
 bne .loop                          ;wenn > 0, nochmal
 ldy #$00                           ;sonst wurde eine REU gefunden
.exit
 rts                                ;zurück
 
 
 
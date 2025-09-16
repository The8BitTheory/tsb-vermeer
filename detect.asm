*= $c000

REUSTATUS           = $df00         ;Statusregister (nur lesen, wird dann gelöscht!)
REUCOMMAND          = $df01         ;Befehlsregister

KAWARIREG           = $d03f

jmp checkForREU
jmp checkForMega65
jmp checkForKawari


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
 

; Y=0 VIC-IV erkannt, Mega65
checkForMega65
  ldy #$ff
  
  lda #1
  sta $d000
  
  lda #$47      ;(dec 71) "G"
  sta $d02f
  
  lda #$53      ;(dec 83) "S"
  sta $d02f
  
  lda #0
  sta $d100
  
  lda $d000
  cmp #1
  bne .exit
  
  ldy #0
  sty $d02f
  rts
  
checkForKawari
  lda #86 ; 'V'
  sta KAWARIREG
  lda #73 ; 'I'
  sta KAWARIREG
  lda #67 ; 'C'
  sta KAWARIREG
  lda #50 ; '2'
  sta KAWARIREG
  
  ldy #$ff
  lda $d03b
  bne .exit
  
;  lda #%10000000
;  sta KAWARIREG
  
  ldy #0
  rts


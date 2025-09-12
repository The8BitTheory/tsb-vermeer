*=$ca80

!zone auction
  
  jmp readkeys
  
aucKey    !byte 0

readkeys
  ; pfeil-links (pa7, pb1)
  ; pfeil-hoch (pa6, pb6)
  ; return (pa0, pb1)
  
  ; feuer 1 (pb4)
  ; feuer 2 (pa4)

  sei             ; Interrupts sperren (IRQ-Routine abschalten, um Überschneidungen mit alter Tastaturabfrage zu vermeiden)
  
  lda #%00000100
  sta val2
  
  lda #0
  sta aucKey
  
  ldx #2
  
selectColumn
  lda cols,x      ; Spalte der Matrix testen (PA)
  sta $dc00       ; Spaltenregister schreiben
  bit $dc00       ; Dummy-Befehl: Warten, bis PA-Leitungen neuen Spannungspegel haben
  bit $dc00       ; Nochmal etwas warten

.loop
  lda $dc01       ; Zeilenregister auslesen (PB)
  cmp $dc01       ; Entprellen:
  bne .loop       ; Warten bis PB stabil
  and rows,x      ; Zeile ausmaskieren
  
  bne .checkNext   ; nicht gedrückt. nächstes zeichen prüfen
  
  lda val2
  ora aucKey
  sta aucKey

.checkNext
  lsr val2
  dex
  bpl selectColumn

  lda #%11111111
  sta $dc00

  cli             ; Interrupts wieder zulassen
  rts             ; Rücksprung BASIC
  
val2 !byte 0

;          return 01  pfhoch 66  pflinks71
cols !byte %11111110, %10111111, %01111111
rows !byte %00000010, %01000000, %00000010



!zone mega65dma
dma_format= $d703
dma_bank  = $d702 ;bank and flags
dma_hb    = $d701 ;high byte of address
dma_lbx   = $d700 ;low byte of address and execute

chkcom      = $aefd
chkcommaint = $e200
frmnum      = $ad8a
getadr      = $b7f7

dmaCopy
  ; parse parameters (count, source, dest)
  jsr chkcom
  jsr frmnum
  jsr getadr
  lda $14
  sta .dmalistCount
  lda $15
  sta .dmalistCount+1
  
  jsr chkcom
  jsr frmnum
  jsr getadr
  lda $14
  sta .dmalistSourceAddr
  lda $15
  sta .dmalistSourceAddr+1
  
  jsr chkcommaint
  stx .dmalistSourceBank
  
  jsr chkcom
  jsr frmnum
  jsr getadr
  lda $14
  sta .dmalistDestAddr
  lda $15
  sta .dmalistDestAddr+1
  
  jsr chkcommaint
  stx .dmalistDestBank
  
  lda #1
  sta dma_format
  
  lda #0
  sta dma_bank
  
  lda #>.dmalist
  sta dma_hb
  
  lda #<.dmalist
  sta dma_lbx

  rts
  
  
.dmalist
  !byte 0     ; command lsb (0=copy, 3=fill)
.dmalistCount
  !word 0     ; count
.dmalistSourceAddr
  !word 0     ; source address
.dmalistSourceBank
  !byte 0     ; source bank and flags
.dmalistDestAddr
  !word 0     ; dest address
.dmalistDestBank
  !byte 0     ; dest bank and flags
  
  !byte 0     ; command msb (always zero)
  !word 0     ; modulo. unused. always zero
  

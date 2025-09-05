

!zone mega65dma
dma_format= $d703
dma_bank  = $d702 ;bank and flags
dma_hb    = $d701 ;high byte of address
dma_lbx   = $d700 ;low byte of address and execute

chkcom      = $aefd
chkcommaint = $e200
frmnum      = $ad8a
getadr      = $b7f7

knockVic4
  lda #$47      ;(dec 71) "G"
  sta $d02f  
  lda #$53      ;(dec 83) "S"
  sta $d02f
  rts
  
dmaCopy
  jsr knockVic4

  ; parse parameters (count, source, dest)
  jsr parseAddressParameter
  lda $14
  sta .dmalistCount
  lda $15
  sta .dmalistCount+1
  
  jsr parseAddressParameter
  lda $14
  sta .dmalistSourceAddr
  lda $15
  sta .dmalistSourceAddr+1
  
  jsr chkcommaint
  stx .dmalistSourceBank
  
  jsr parseAddressParameter
  lda $14
  sta .dmalistDestAddr
  lda $15
  sta .dmalistDestAddr+1
  
  jsr chkcommaint
  stx .dmalistDestBank
  
;  lda #1
;  sta dma_format
  
  lda #0
  sta dma_bank
  
  lda #>.dmalist
  sta dma_hb
  
  lda #<.dmalist
  sta dma_lbx

knockVic2  
  lda #0
  sta $d02f

  rts
  
fromMega65ToMemloc
    stx .fetchlistCount

    sta .fetchlistSourceAddr
    sty .fetchlistSourceAddr+1
    
    jsr knockVic4
    
    lda #<.fetchlist
    sta dma_lbx
    
    jmp knockVic2

mega65DmaFetchPreWarm
    ;count high-byte and source/dest banks are directly defined in the .fetchlist part below
    
    lda memloc
    sta .fetchlistDestAddr
    lda memloc+1
    sta .fetchlistDestAddr+1

    lda #>.fetchlist
    sta dma_hb
    
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
  

.fetchlist
  !byte 0     ; command lsb (0=copy, 3=fill)
.fetchlistCount
  !word 0     ; count
.fetchlistSourceAddr
  !word 0     ; source address
;.fetchlistSourceBank
  !byte 5     ; source bank and flags
.fetchlistDestAddr
  !word 0     ; dest address
;.fetchlistDestBank
  !byte 0     ; dest bank and flags
  
  !byte 0     ; command msb (always zero)
  !word 0     ; modulo. unused. always zero
  

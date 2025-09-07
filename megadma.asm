*=$7f00

!zone mega65dma
dma_format= $d703
dma_bank  = $d702 ;bank and flags
dma_hb    = $d701 ;high byte of address
dma_lbx   = $d700 ;low byte of address and execute

chkcom    = $aefd
frmnum    = $ad8a
getadr    = $b7f7

memloc    = $fb;  !word $c64d ;temporary 256 byte working area for dma.
chkcommaint = $e200


  jmp mega65DmaFetchPreWarm
  jmp fromMega65ToMemloc
  jmp .swapBasic
  jmp dmaCopy
  

knockVic4
  lda #$47      ;(dec 71) "G"
  sta $d02f  
  lda #$53      ;(dec 83) "S"
  sta $d02f
  rts
  
; generic stash/fetch command. used for copying ressource files to higher banks upon loading
dmaCopy
  jsr knockVic4

  ; parse parameters (count, source, dest)
  jsr parseAddressParameter
  ldx #1  ;dmalistcount
  jsr h1415toDmalist

  jsr parseAddressParameter
  ldx #3  ;dmalistSourceAddr
  jsr h1415toDmalist
  
  jsr chkcommaint
  stx .dmalistSourceBank
  
  jsr parseAddressParameter
  ldx #6  ;dmalistDestAddr
  jsr h1415toDmalist
  
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
  
h1415toDmalist
    lda $14
    sta .dmalist,x
    inx
    lda $15
    sta .dmalist,x
    rts

; used to copy ressources from higher banks into dma-working memory
fromMega65ToMemloc
    stx .dmalistCount

    sta .dmalistSourceAddr
    sty .dmalistSourceAddr+1
    
    jsr knockVic4
    
    lda #<.dmalist
    sta dma_lbx
    
    jmp knockVic2

mega65DmaFetchPreWarm
    ;count high-byte and source/dest banks are directly defined in the .fetchlist part below
    lda #5
    sta .dmalistSourceBank
    
    lda memloc
    sta .dmalistDestAddr
    lda memloc+1
    sta .dmalistDestAddr+1

    lda #0
    sta dma_bank
    sta .dmalistDestBank
  
    lda #>.dmalist
    sta dma_hb
    
    rts
    
.swapBasic
    rts

parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
    
;todo:
; * routine that swaps basic program between main memory and higher bank
  
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


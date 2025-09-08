*=$7e00

!to "megadma.bin.prg",cbm

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
  

.execDmaList
;knockVic4
  lda #$47      ;(dec 71) "G"
  sta $d02f  
  lda #$53      ;(dec 83) "S"
  sta $d02f
  
;  lda #1
;  sta dma_format
  
  lda #0
  sta dma_bank
  
  lda #>.dmalist
  sta dma_hb
  
  lda #>.dmalist
  sta dma_hb
  
  lda #<.dmalist
  sta dma_lbx

;knockVic2  
  lda #0
  sta $d02f
  rts
  
; generic stash/fetch command. used for copying ressource files to higher banks upon loading
dmaCopy
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

  jmp .execDmaList
  
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
        
    jmp .execDmaList

mega65DmaFetchPreWarm
    ;count high-byte and source/dest banks are directly defined in the .fetchlist part below
    lda #5
    sta .dmalistSourceBank
    
    lda memloc
    sta .dmalistDestAddr
    lda memloc+1
    sta .dmalistDestAddr+1

    lda #0
    sta .dmalistDestBank
    sta .dmalistCount+1
    
    rts
    
.swapBasic
    ; copy from ram ($0800 at bank 0) to temp high bank ($0800 at bank 1)
    sec
    lda $2d
    sbc $2b
    sta .dmalistCount
    
    lda $2e
    sbc $2c
    sta .dmalistCount+1
    
    lda $2b
    sta .dmalistSourceAddr
    lda $2c
    sta .dmalistSourceAddr+1
    
    lda #0
    sta .dmalistSourceBank
    sta .dmalistDestAddr
    
    lda #08
    sta .dmalistDestAddr+1
    
    lda #1
    sta .dmalistDestBank

    jsr .execDmaList
        
    ; copy from ext ($8000 at bank 5) to ram ($0801 at bank 0)
    lda #0
    sta .dmalistSourceAddr
    sta .dmalistDestBank
    
    lda #$80
    sta .dmalistSourceAddr+1
    
    lda #5
    sta .dmalistSourceBank
    
    lda $2c
    sta .dmalistDestAddr
    lda $2d
    sta .dmalistDestAddr+1
        
    jsr .execDmaList

    ; copy from temp high ($0800 at bank 1) bank to ext ($8000 at bank 5)
    lda #0
    sta .dmalistSourceAddr
    lda #08
    sta .dmalistSourceAddr+1
    
    lda #1
    sta .dmalistSourceBank
    
    lda #0
    sta .dmalistDestAddr
    lda #$80
    sta .dmalistDestAddr+1
    
    lda #5
    sta .dmalistDestBank

    jsr .execDmaList
    
    LDA $0803
    STA $39        ; CURLIN low
    LDA $0804
    STA $3A        ; CURLIN high

    ; TXTPTR <- Adresse erstes Token (bei $0801 ist das $0801+4 = $0805)
    jsr $a68e
    
    ; 4) In BASIC-Interpreter einsteigen
    JMP $A7AE     

parseAddressParameter
    jsr chkcom
    jsr frmnum
    jmp getadr
  
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


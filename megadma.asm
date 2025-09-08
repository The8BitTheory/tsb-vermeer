*=$7e00

!cpu m65
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

;NOPs are added to keep compatibility with JMP instructions of other CPUs
  bra mega65DmaFetchPreWarm
!byte $ea ;nop
  bra fromMega65ToMemloc
!byte $ea ;nop
  bra .swapBasic
!byte $ea ;nop
  bra dmaCopy
  

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
  
  lda #<.dmalist
  sta dma_lbx

;knockVic2  
  lda #0
  sta $d02f
  rts
  
; generic stash/fetch command. used for copying ressource files to higher banks upon loading
dmaCopy
  ; parse parameters (count, source, dest)
  
  ldx #1  ;dmalistcount
  bsr h1415toDmalist

  ldx #3  ;dmalistSourceAddr
  bsr h1415toDmalist
  
  bsr chkcommaint
  stx .dmalistSourceBank
  
  ldx #6  ;dmalistDestAddr
  bsr h1415toDmalist
  
  bsr chkcommaint
  stx .dmalistDestBank

  bra .execDmaList
  
h1415toDmalist
    phx
    bsr parseAddressParameter
    plx
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
        
    bra .execDmaList

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


; mega65 dma doesn't have swap capability (yet?)
;  so we'll copy from ram to temporary space
;  then the "other" basic program from high-ram (was put there when it was first loaded) to ram
;  then the "previous" basic program from temporary space to high-ram
; this assumes we're only swapping between two basic programs. we'll see if that holds

.basic_ram_addr = $0801
.basic_ram_bank = $0
.basic_temp_addr = $8000
.basic_temp_bank = $1
.basic_high_addr = $8000
.basic_high_bank = $5

.swapBasic
    ; write chain-byte to dmalist-command
    lda #%00000100
    sta .dmalist
    
    ; copy from ram ($0800 at bank 0) to temp ($8000 at bank 1)
    sec
    lda $2d
    sbc $2b
    sta .dmalistCount
    sta .dmalistCount+12
    sta .dmalistCount+24
    
    lda $2e
    sbc $2c
    sta .dmalistCount+1
    sta .dmalistCount+13
    sta .dmalistCount+25
    ; write count to 2nd and 3rd command as well
    
    lda #<.basic_ram_addr
    sta .dmalistSourceAddr
    lda #>.basic_ram_addr
    sta .dmalistSourceAddr+1

    lda #.basic_ram_bank
    sta .dmalistSourceBank
    
    lda #<.basic_temp_addr
    sta .dmalistDestAddr
    
    lda #>.basic_temp_addr
    sta .dmalistDestAddr+1
    
    lda #.basic_temp_bank
    sta .dmalistDestBank

    bsr .execDmaList
    
    ; remove chain-byte from dmalist-command
    lda #0
    sta .dmalist
    
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

; copy from high to ram
  !byte 4     ;copy + chain
  !word 0     ;count - set in code
  !word $8000 ;source address
  !byte 5     ;source bank
  !word $0801 ;dest address
  !byte 0     ;dest bank
  !byte 0
  !word 0
  
; copy from temp to high
  !byte 0     ;copy + chain
  !word 0     ;count - set in code
  !word $8000 ;dest address
  !byte 1     ;dest bank
  !word $8000 ;source address
  !byte 5     ;source bank
  !byte 0
  !word 0
  

*=$7f50

!cpu m65
!to "megadma2.bin.prg",cbm

!source "mem.inc"

key_register  = $d02f

dma_format    = $d703
dma_bank      = $d702 ;bank and flags
dma_hb        = $d701 ;high byte of address
dma_lbx       = $d700 ;low byte of address and execute

    jmp megaStash
    jmp megaFetch
    jmp megaSwap



; generic stash command. used for copying ressource files to higher banks upon loading

;write to expanded memory
megaStash
  lda #0
  sta .dmalistSourceBank  
  
  lda dma_params_c64
  sta .dmalistSourceAddr
  lda dma_params_c64+1
  sta .dmalistSourceAddr+1

  lda #5
  sta .dmalistDestBank
  
  lda dma_params_exp
  sta .dmalistDestAddr
  lda dma_params_exp+1
  sta .dmalistDestAddr+1

.prepLengthAndExec
  lda #0
  sta .dmalist
  
  lda dma_params_len
  sta .dmalistCount
  lda dma_params_len+1
  sta .dmalistCount+1

;knockVic4
  lda #$47      ;(dec 71) "G"
  sta key_register  
  lda #$53      ;(dec 83) "S"
  sta key_register
  
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
  sta key_register
  rts
  

; 2 count, 3 c64-address (lb,hb), 3 ext-address (lb,hb)
;dma_ml_loc = $7e0f
;$7e0f .dma_params_len   !byte 0,0
;$7e11 .dma_params_c64   !byte <execLocation,>execLocation
;$7e13 .dma_params_exp   !byte 0,0
; on the mega65, this always copies from some bank 5 location to the bank 0 location taken from $ca06 (memory.asm .dma_params_*)
megaFetch
    lda #5
    sta .dmalistSourceBank  
  
    lda dma_params_exp
    sta .dmalistSourceAddr
    lda dma_params_exp+1
    sta .dmalistSourceAddr+1

    lda #0
    sta .dmalistDestBank
  
    lda dma_params_c64
    sta .dmalistDestAddr
    lda dma_params_c64+1
    sta .dmalistDestAddr+1
    
    bra .prepLengthAndExec


; mega65 dma doesn't have swap capability (yet?)
;  so we'll do the copy via CPU and the z-register for 32-bit addresses [],z

.basic_ram_addr = $0801
.basic_ram_bank = $0
.basic_temp_addr = $8000
.basic_temp_bank = $1
.basic_high_addr = $8000
.basic_high_bank = $5


; basic program
; $0800-$7fff -> $8800
; using $fb,$fc,$fd,$fe as 32-bit register for upper mem (mega65-ram bank 5). $fd is the bank, $fe is zero (b/c within first mb)
; and $fb,$fc as 16-bit register for lower-mem (c64-ram)
megaSwap
    lda #0
    sta memloc+3
    sta memloc
    tay
    taz

    lda #5
    sta memloc+2
    
    ; read from bank 0
    lda dma_params_c64+1
    tax
    
-   txa ; source-hb to memloc
    sta memloc+1
    lda (memloc),y
    
    ; push to stack
    pha
    
    ; destination-hb to memloc
    lda dma_params_exp+1
    sta memloc+1
    ; read from bank 5
    lda [memloc],z
    
    ; source-hb to memloc
    txa
    sta memloc+1
    ; write to bank 0
    sta (memloc),y
    
    
    ; destination-HB to memloc
    lda dma_params_exp+1
    sta memloc+1
    
    ; pull from stack
    pla
    ; write to bank 5
    sta [memloc],z
    
    ; decrease the overall count, so we know whether we're done
    dec dma_params_len
    bne +
    dec dma_params_len+1
    bmi .swapDone
    
+   iny
    inz
    bne -
    inc dma_params_exp+1
    inc dma_params_c64+1
    inx
    jmp -
    
.swapDone
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

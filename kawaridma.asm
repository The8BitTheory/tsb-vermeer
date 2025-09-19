*=$7ec0

!to "kawaridma.bin.prg",cbm

; the VIC-II Kawari has a single 64kB memory bank
; data-transfer can be done in various ways, here we'll use DMA
; unlocking the additional registers is done through a knock sequence, like on the Mega65
; DMA transfer is documented here: https://github.com/randyrossi/vicii-kawari/blob/main/doc/REGISTERS.md#dma-functions
; 

VIDEO_MEM_1_IDX   = $d035
VIDEO_MEM_2_IDX   = $d036
VIDEO_MODE_1      = $d037
VIDEO_MODE_2      = $d038

VIDEO_MEM_1_LO    = $d039
VIDEO_MEM_1_HI    = $d03a
VIDEO_MEM_1_VAL   = $d03b

VIDEO_MEM_2_LO    = $d03c
VIDEO_MEM_2_HI    = $d03d
VIDEO_MEM_2_VAL   = $d03e

VIDEO_MEM_FLAGS   = $d03f


;chkcom      = $aefd
;frmnum      = $ad8a
;getadr      = $b7f7

memloc        = $fb;  !word $c64d ;temporary 256 byte working area for dma.    
memory_loc              = $7e00
parseAddressParameter   = memory_loc+$6
dma_params_len          = memory_loc+$f
dma_params_c64          = memory_loc+$11
dma_params_exp          = memory_loc+$13

!zone kawaridma

    jmp .kawariDmaFetchPreWarm
    jmp .fromKawariToMemloc
    jmp .swapBasic
    jmp .dmaStash
    jmp .mlDmaCopy
    jmp .dmaFetch

;sets the registers that are used by memloc operations constantly multiple times

; count high-byte is always zero
; destination is always memloc
.kawariDmaFetchPreWarm
    ; closing registers and then opening them again brings back the previously stored values.
;    jsr .knockKawariOpen

    lda #0
    sta VIDEO_MEM_2_IDX
    
    lda memloc
    sta VIDEO_MEM_1_LO
    lda memloc+1
    sta VIDEO_MEM_1_HI
    
;    jmp .closeKawari
    rts
  
;copies a ressource (text constants, frames, navlabels) to the memloc area in RAM
; .A=c64 address LB, .Y=c64 address HB, .X=length LB
    ; video_mem_1 is destination address
    ; video_mem_2 is source address
.fromKawariToMemloc
;    pha
;    jsr .knockKawariOpen
;    pla
    sta VIDEO_MEM_2_LO
    sty VIDEO_MEM_2_HI
    stx VIDEO_MEM_1_IDX

    ldx #16                ; Perform DMA op (8=dram to vram, 16=vram to dram)
    jmp .execDmaAndCloseKawari

;swaps the currently running basic program with the one stored in expanded memory
; as the kawari doesn't have SWAP capability and insufficient space to use a swap-area we'll have to
; try byte-by-byte copy.
; dma-copy in 256 byte chunks (as that's the size of our working area anyways) wouldn't work, as the code is
;  outside of the vic's ram-bank ($c000 - $ffff)
.swapBasic
    sec
    lda $2d
    sbc $2b
    sta dma_params_len
    lda $2e
    sbc $2c
    sta dma_params_len+1
    
    ; store dram-read-address in $fb/$fc
    lda $2b
    sta $fb
    lda $2c
    sta $fc
    
;    jsr .knockKawariOpen
    
    ; VIDEO_MEM_1 = read-port
    ; VIDEO_MEM_2 = write-port
    lda #0
    sta VIDEO_MEM_1_LO
    sta VIDEO_MEM_2_LO
    lda #80
    sta VIDEO_MEM_1_HI
    sta VIDEO_MEM_2_HI
    
    lda #%00000101               ; Auto increment port 1 and port 2
    sta VIDEO_MEM_FLAGS
    
    ldy #0
    
-   lda ($fb),y                   ; read from dram
    pha                           ; put aside
    lda VIDEO_MEM_1_VAL           ; read from vram
    sta ($fb),y                   ; write to dram
    pla                           ; get from aside
    sta VIDEO_MEM_2_VAL           ; write to vram
    
    ; decrease the overall count, so we know whether we're done
    dec dma_params_len
    bne +
    dec dma_params_len+1
    bmi .backToBasic              ; once the count HB becomes negative, we're done (needs validation)
    
+   iny
    bne -
    inc $fc
    jmp -
    
.backToBasic
;    jsr .closeKawari

    lda $0803
    sta $39        ; CURLIN low
    lda $0804
    sta $3A        ; CURLIN high

    ; TXTPTR <- Adresse erstes Token (bei $0801 ist das $0801+4 = $0805)
    jsr $a68e
    
    ; 4) In BASIC-Interpreter einsteigen
    jmp $A7AE     
    
    
.parseLenSourceDest
    jsr parseAddressParameter
    lda $14
    sta VIDEO_MEM_1_IDX
    lda $15
    sta VIDEO_MEM_2_IDX
    
    ; source address
    jsr parseAddressParameter
    lda $14
    sta VIDEO_MEM_2_LO
    lda $15
    sta VIDEO_MEM_2_HI
    
    ; destination address
    jsr parseAddressParameter
    lda $14
    sta VIDEO_MEM_1_LO
    lda $15
    sta VIDEO_MEM_1_HI

    rts
; generic stash command. used for copying ressource files to higher banks upon loading
; length, dram, vram
    ; video_mem_1 is destination address
    ; video_mem_2 is source address
.dmaStash
;    jsr .knockKawariOpen
    
    jsr .parseLenSourceDest

    ldx #8                ; Perform DMA op (8=dram to vram, 16=vram to dram)
    
.execDmaAndCloseKawari
    lda #15               ; Port 1 op DMA, Port 2 op DMA
    sta VIDEO_MEM_FLAGS
    
    stx VIDEO_MEM_1_VAL   ; write executes dma operation

.polldone
    lda VIDEO_MEM_2_IDX   ; wait for done
    bne .polldone

;.closeKawari
    rts
    ; close Kawari registers (good practice?)
;    lda #%10000000
;    sta VIDEO_MEM_FLAGS
;    rts
    
.dmaFetch
;    jsr .knockKawariOpen
    
    jsr .parseLenSourceDest
    
    ldx #16                ; Perform DMA op (8=dram to vram, 16=vram to dram)

    jmp .execDmaAndCloseKawari

; this always copies from a location in kawari-vram to the dram location taken from $ca06 (memory.asm .dma_params_*)
;  currently used to copy ML-routines (by memory.asm/fetch) to $ca00 and sprites (by sprites.asm/fetchSprites) to $c000
;  which are both inside the VIC-II's memory area, fortunately.
    ; video_mem_1 is destination address
    ; video_mem_2 is source address
.mlDmaCopy
;    jsr .knockKawariOpen
    
    lda dma_params_len
    sta VIDEO_MEM_1_IDX
    lda dma_params_len+1
    sta VIDEO_MEM_2_IDX

; source
    lda dma_params_exp
    sta VIDEO_MEM_2_LO
    lda dma_params_exp+1
    sta VIDEO_MEM_2_HI

; destination
    lda dma_params_c64
    sta VIDEO_MEM_1_LO
    lda dma_params_c64+1
    sta VIDEO_MEM_1_HI

    ldx #16                ; Perform DMA op (8=dram to vram, 16=vram to dram)

    jmp .execDmaAndCloseKawari
    
    
;.knockKawariOpen
;    lda #86 ; 'V'
;    sta VIDEO_MEM_FLAGS
;    lda #73 ; 'I'
;    sta VIDEO_MEM_FLAGS
;    lda #67 ; 'C'
;    sta VIDEO_MEM_FLAGS
;    lda #50 ; '2'
;    sta VIDEO_MEM_FLAGS
;    rts
    
    
    
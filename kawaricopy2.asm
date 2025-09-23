*=$0700

!to "kawaricopy2.bin.prg",cbm

; the VIC-II Kawari has a single 64kB memory bank
; data-transfer can be done in various ways, here we'll use regular copying via CPU
; unlocking the additional registers is done through a knock sequence, like on the Mega65
; VRAM/DRAM transfer is documented here: https://github.com/randyrossi/vicii-kawari/blob/main/doc/REGISTERS.md#accessing-video-memory
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

!source "mem.inc"

    jmp stash
    jmp fetch
    jmp swap

.dmaParamsValues
    lda dma_params_exp
    sta VIDEO_MEM_1_LO
    sta VIDEO_MEM_2_LO
    
    lda dma_params_exp+1
    sta VIDEO_MEM_1_HI
    sta VIDEO_MEM_2_HI

    lda dma_params_c64
    sta memloc
    lda dma_params_c64+1
    sta memloc+1

    lda #%00000101               ; Auto increment port 1 and port 2
    sta VIDEO_MEM_FLAGS

    rts

stash
    jsr .dmaParamsValues

    ldy #0
    
-   lda (memloc),y                  ; read from dram
    sta VIDEO_MEM_1_VAL             ; write to vram
    
    ; decrease the overall count, so we know whether we're done
    dec dma_params_len
    bne +
    dec dma_params_len+1
    bmi .stashDone
    
+   iny
    bne -
    inc memloc+1
    jmp -

.stashDone
    rts
    

fetch
    jsr .dmaParamsValues
    
    ldy #0
    
-   lda VIDEO_MEM_1_VAL     ; read from vram
    sta (memloc),y          ; write to dram
    
    ; decrease the overall count, so we know whether we're done
    dec dma_params_len
    bne +
    dec dma_params_len+1
    bmi .fetchDone
    
+   iny
    bne -
    inc memloc+1
    jmp -

.fetchDone
    rts


;swaps the currently running basic program with the one stored in expanded memory
; as the kawari doesn't have SWAP capability and insufficient space to use a swap-area we'll have to
; try byte-by-byte copy.
; dma-copy in 256 byte chunks (as that's the size of our working area anyways) wouldn't work, as the code is
;  outside of the vic's ram-bank ($c000 - $ffff)
swap
    jsr .dmaParamsValues
    
    ldy #0
    
-   lda (memloc),y                ; read from dram
    pha                           ; put aside
    lda VIDEO_MEM_1_VAL           ; read from vram
    sta (memloc),y                ; write to dram
    pla                           ; get from aside
    sta VIDEO_MEM_2_VAL           ; write to vram
    
    ; decrease the overall count, so we know whether we're done
    dec dma_params_len
    bne +
    dec dma_params_len+1
    bmi .swapDone              ; once the count HB becomes negative, we're done (needs validation)
    
+   iny
    bne -
    inc memloc+1
    jmp -

.swapDone    
    rts
    
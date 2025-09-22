memory_loc = $7e00
expmem_loc = $7f50

expmem_stash    = expmem_loc
expmem_fetch    = expmem_loc+3
expmem_swap     = expmem_loc+6

memloc        = $fb;  !word $c64d ;temporary 256 byte working area for dma.
parseAddressParameter = memory_loc+$6

;dma_params              = memory_loc+$f     ; location of ML routine parameters that are DMA-copied on demand (plantations, auctions, ...)
dma_params              = memory_loc+$24     ; location of ML routine parameters that are DMA-copied on demand (plantations, auctions, ...)
dma_params_len          = dma_params
dma_params_c64          = dma_params+2
dma_params_exp          = dma_params+4


chkcommaint   = $e200


; basicStash
; basicFetch

; mlStash           ; stash. acts on parameters in memory.asm's dma_params_*

; mlFetchBin        ; fetches binary from memory.asm's exp_dictionary to $ca00 (length and source from indexed dictionary entry, target fixed)
; mlFetchRes        ; fetches a resource from expmem (.A/.Y = LB/HB, .X = length) to dma-working-memory at memloc ($c64d)

; mlFetch           ; fetch. acts on parameters in memory.asm's dma_params_*

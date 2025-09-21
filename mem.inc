memory_loc = $7e00
expmem_loc = $7e00+$c0

memory_prewarm      = memory_loc+$9
expmem_to_memloc    = expmem_loc+$3  ; .X=count, .A=mem LB, .Y=mem HB
expmem_dma_fetch    = expmem_loc+$c




memloc        = $fb;  !word $c64d ;temporary 256 byte working area for dma.
parseAddressParameter = memory_loc+$6

dma_params              = memory_loc+$f     ; location of ML routine parameters that are DMA-copied on demand (plantations, auctions, ...)
dma_params_len          = dma_params
dma_params_c64          = dma_params+2
dma_params_exp          = dma_params+4


chkcommaint   = $e200
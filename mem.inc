memory_loc = $7e00


memloc        = $fb;  !word $c64d ;temporary 256 byte working area for dma.
parseAddressParameter = memory_loc+$6


;dma_params              = memory_loc+$f     ; location of ML routine parameters that are DMA-copied on demand (plantations, auctions, ...)
dma_params              = memory_loc+$24     ; location of ML routine parameters that are DMA-copied on demand (plantations, auctions, ...)
dma_params_len          = dma_params
dma_params_c64          = dma_params+2
dma_params_exp          = dma_params+4


chkcommaint   = $e200


memStashBasic       = memory_loc+$09
memFetchBasic       = memory_loc+$0c
memSwapBasic        = memory_loc+$0f

memStash            = memory_loc+$12         ; stash. acts on parameters in memory.asm's dma_params_*
memFetch            = memory_loc+$15         ; fetch. acts on parameters in memory.asm's dma_params_*
memSwap             = memory_loc+$18
         
memFetchResource    = memory_loc+$1b        ; fetches a resource from expmem (.A/.Y = LB/HB, .X = length) to dma-working-memory at memloc ($c64d)
memFetchRoutine     = memory_loc+$1e            ; fetches binary from memory.asm's exp_dictionary to $ca00 (length and source from indexed dictionary entry, target fixed)
memSwapBasicProgram = memory_loc+$21


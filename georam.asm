*=$7ec0

!to "georam.bin.prg",cbm

; ml routines are copied to location in memory they are compiled for.
; data should be worked with inside the georam window directly

memory_loc = $7e00
memloc        = $fb;  !word $c64d ;temporary 256 byte working area for dma.
dma_ml_loc    = memory_loc+$f ; location of ML routine parameters that are DMA-copied on demand (plantations, auctions, ...)
parseAddressParameter = memory_loc+$6

geoBank       = $dfff   ; 16 kb bank
geoPage       = $dffe   ; page inside the bank (64 pages available per bank)
geoData       = $de00   ; $de00 - $deff


; used by frame.asm. makes max 256 bytes of data available in $de00 (others copy via dma to $c64d)
    jmp geoPreWarm
    jmp fromGeoToMemloc
    
; used to load different basic program. swaps data between dram and georam
    jmp swapWithGeo    

; used as basic stash command
    jmp geoStash
; used by memory.asm to fetch ML routines to $ca00-$cbff. does up to 512 bytes.
    jmp mlGeoFetch
; used as basic fetch command
    jmp geoFetch
    
geoPreWarm
;    lda #0
;    sta geoBank
    
    rts

; selects 256 byte window - instead of $c64d
 ; .X=HB for Length, .A=LB, .Y=HB
fromGeoToMemloc
    pha
    tya
    ror
    ror
    ror
    ror
    ror
    ror
    sta geoBank
    
    tya
    and #%00111111
    sta geoPage
    
    pla
    tax
    lda geoData,x

    rts
    
    
    
swapWithGeo
    rts
    
geoStash
    rts

geoFetch
    rts

mlGeoFetch
    rts
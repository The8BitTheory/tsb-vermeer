*=$ca00

!to "plantation.bin.prg",cbm
!source "mem.inc"

HIBASE            = $0288  ; location of screen-ram high-byte



.plantLoc         = $fb   ;screen-ram location of the plantation's building (ie +2/+2 from top-most left point)
                          ;contains the plantation's top-left tile later (can be building, can be less)
plantvector       = $c3f0 ;this points to the location in memexp that contains 2304 bytes of plantation data
                          ;plantations of first town are at this address, each following town is at plus 256
                          
; START OF CODE

    jmp checkPlantation

productivity  !byte 0
size          !byte 0
plantData     !byte 0,0,0,0,0,0


; compares plantation area with greenfield. params: location in screen-ram
;  params: x-coordinate (column), y-coordinate (row). both zero-based
;  calculates size(y) and productivity(x) (requiring 1 byte each)
;  size <4 means, invalid ground (building is not on 4 grass tiles)
;  also calculates the 4 bytes with area assignment
checkPlantation


    jsr chkcommaint
    stx .buildingCol
    jsr chkcommaint
    stx .buildingRow
    
    ; load plantations of this town into memory
    jsr memory_prewarm  ;set constant values in memory expansion (len-HB=0, dest-address=$c64d)
            
    ; parse town-id
    jsr chkcommaint
    txa    
    adc #>plantvector  ; add 256 bytes to the address per town
    tay
    
    lda #<plantvector   
    ldx #255
    ; fetch plantations of current town into memloc $c64d
    jsr expmem_to_memloc
        
    ; iterate over plantations of this town
    ldy #0
    
checkPlantationOwner
    ;find available plantation slot
    lda (.plantLoc),y
    cmp #$ff
    beq availablePlantationFound       ; if unoccupied (owner is $ff), use this
    
    ; jump to next plantation data
    tya                   ; add 13 bytes to index (= location of next plantation data)
    clc
    adc #13
    tay
    bcc checkPlantationOwner ; if carry-bit is clear, we're inside the available plantation indices of this town. draw it.
    
    lda #0
    sta size
    jmp .plantCheckDone
    

availablePlantationFound
    lda #242            ;40*6 + 2 (row 6, column 2)
    sta .plantStart
    sta .plantLoc
    lda HIBASE
    sta .plantStart+1
    sta .plantLoc+1

    ldx .buildingRow  ;need this to set zero flag (or not)

  ; add building row to .plantStart to get .plantLoc
    beq ++       ;if .X=row zero, add nothing
  
    lda .plantLoc
-   clc
    adc #40
    sta .plantLoc
    bcc +
    inc .plantLoc+1
+   dex
    bne -

  ; add building column to .plantLoc
++  clc
    lda .plantLoc
    adc .buildingCol
    sta .plantLoc
    bcc +
    inc .plantLoc+1

  ; check if building is on solid ground (no water, no rocks)
+   ldx #0        ; x contains number of valid ground tiles (4 means, position is ok)
    ldy #0
    sty size
  
  ; tile top-left
    jsr .checkIsGrassTile
  
  ; tile top-right
    iny
    jsr .checkIsGrassTile
  
  ;tile bottom-left
    tya
    clc
    adc #39
    tay
    jsr .checkIsGrassTile
  
    iny
    jsr .checkIsGrassTile
  
    cpx #4
    beq +  
    
    ; if building isn't on solid ground, skip the rest
    stx size
    jmp .plantCheckDone

; calculate size. available area is 23x17
; - boundary on 4 sides (not going beyond borders of available area)
;   - minimum ram location (top-left of available area)
;   - maximum ram location (bottom-right of available area)
    ; clear plantation data
+   lda #0
    sta plantData
    sta plantData+1
    sta plantData+2
    sta plantData+3
    sta plantData+4
    sta plantData+5
    sta .plantRow
    sta .plantCol

    ; using row and col make it easier to compare for exceeding the boundaries
    sec
    lda .buildingRow
    sbc #2
    sta .curRow

    clc
    lda .buildingRow
    adc #4
    sta .lastRow

    ; plantLoc is needed for comparing actual tiles. decrementing by 2 rows and 2 cols
    sec
    lda .plantLoc
    sbc #82
    sta .plantLoc
    bcs +
    dec .plantLoc+1

+   ldx #0
    ldy #0

    sec
    lda .buildingCol
    sbc #2
    sta .curCol

    clc
    lda .buildingCol
    adc #4
    sta .lastCol

  ; check first line of plantation. can be outside of available area, in theory
  ;  first line starts 2 screen rows above and 2 cols left of building

.checkRow
    lda .curRow
    bmi .toNextRowSkip         ; if negative, skip row check and go to next row
    cmp #17                    ; if beyond bottom-border, we're done
    bpl .plantCheckDone

    ;check cols
    lda .curCol
    bmi .toNextCol          ; if negative, go to next col
    cmp #23
    beq .toNextCol          ; if beyond border, go to next col

.checkTile
    lda (.plantLoc),y
    cmp #96
    bne .toNextCol
    inc size
    ldx .plantRow
    lda plantData,x
    ldx .plantCol
    ora .bits6,x
    ldx .plantRow
    sta plantData,x

.toNextCol
    inc .plantCol
    inc .curCol
    lda .curCol
    cmp .lastCol
    beq .toNextRow
    iny
    jmp .checkTile

.toNextRowSkip
    clc
    tya
    adc #5
    tay
.toNextRow
    sec
    lda .buildingCol
    sbc #2
    sta .curCol
    lda #0
    sta .plantCol

    clc
    tya
    adc #35
    tay
    inc .plantRow
    inc .curRow
    lda .curRow
    cmp .lastRow
    bne .checkRow

.plantCheckDone
; now, check for adjacent water. yes, productivity 110. no, productivity 100
    ldx #100
    stx productivity

; write size to .Y
    ldy size
    rts


; - water and rocks (value not 96)
; - other plantations (value not 96)
.checkIsGrassTile
    lda (.plantLoc),y
    cmp #96
    bne +
    inx
+   rts


.buildingCol      !byte 0
.buildingRow      !byte 0
.curCol           !byte 0
.curRow           !byte 0
.lastCol          !byte 0
.lastRow          !byte 0
.plantCol         !byte 0
.plantRow         !byte 0
.plantStart       !word 0

.bits6 !byte %00100000, %00010000, %00001000, %00000100, %00000010, %00000001


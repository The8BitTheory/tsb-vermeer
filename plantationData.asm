; Plantation:

; one page in memory (256 bytes) contains all plantations of a town
; last byte of page (ff) contains the town-id

; bytes per plantation:
; 0    owner (ff means: empty plantation slot)
; 1    seed
; 2    warehouse slot (0 or 1)
; 3    x-coordinate of building top-left in grass area (0-22)
; 4    y-coordiante of building top-left in grass area (0-16)
; 5-10 plantation area coverage (1 byte per line) (starts two squares left and two rows above of building)
; 11   size
; 12   productivity

; 19 plantations (13 bytes each) per town max -> 247 bytes
; 9 towns --> 171 plantations max in the game (9x19)

; mapping tables:
; - player>plantation. what needed for?


*= $c64d

! byte 0    ; nr of 


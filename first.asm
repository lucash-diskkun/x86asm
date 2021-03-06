INCLUDE "hardware.inc"
SECTION "header", ROM0[$100]

EntryPoint:
	jp Start
	ds $150 - @, 0

SECTION "city tiles", ROM0

city_tile_data:
INCBIN "city.chr"
city_tile_data_end:

SECTION "city map", ROM0

city_map_data:
INCBIN "city.map"
city_map_data_end:

SECTION "sprite", ROM0
opt g.123
sprite_data:
dw `.333333.
dw `31111113
dw `31311313
dw `31111113
dw `31311313
dw `31133113
dw `31111113
dw `.333333.
sprite_data_end:

SECTION "game code", ROM0[$150]

Start:
	call disableLCD

	ld a, %11100100
	ld [rBGP], a
	ld a, %11100000
	ld [rOBP0], a

	ld bc, city_tile_data_end - city_tile_data
	ld de, $8000
	ld hl, city_tile_data
	call memCopy
	ld bc, city_map_data_end - city_map_data
	ld de, $9800
	ld hl, city_map_data
	call memCopy

	ld bc, sprite_data_end - sprite_data
	ld de, $8000 + city_tile_data_end - city_tile_data
	ld hl, sprite_data
	call memCopy
	
	ld hl, $fe00
	xor a
	ld c, $a0
	call memset_small

	ld a, 60
	ld [$fe00], a
	ld a, 50
	ld [$fe01], a
	ld a, $eb
	ld [$fe02], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [$fe03], a

	call enableLCD
.deadloop:
	jr .deadloop

enableLCD:
	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
	ldh [rLCDC], a
	ret

memCopy:
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, memCopy
	ret

disableLCD:
	ld   a, [rLY]
	cp   144
	jr   c, disableLCD
	
	ld a, [rLCDC]
	res 7, a
	ld [rLCDC], a
	ret

; HL - destination
; A - byte to store
; C - number of bytes to set
memset_small:
  ld [hli], a
  dec c
  jr nz, memset_small
  ret

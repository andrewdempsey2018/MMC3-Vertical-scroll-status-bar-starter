; --------------------------------------------------
; Draws a row of 16 metatiles.
;
; If row_number is even, writes 8 bytes of attribute
; data.
;
; Inputs:
; row_number: the row number that will be drawn
;
; row_tile_ptr: pointer to metatile data
;
; row_attrib_ptr: pointer to attribute data
;
; Clobbers: A, X, Y
;
; Outputs: None
;
; Notes:
; --------------------------------------------------

.segment "RODATA"

; --------------------------------------------------
; Nametable address of first tile in each
; 16x16 metatile row (row numbers 0-14).
;
; Nametable address of first attribte in each 32x32
; attribute row (8 rows total)
; --------------------------------------------------
row_address_hi_table:
  .byte $20,$20,$20,$20,$21,$21,$21,$21,$22,$22,$22,$22,$23,$23,$23
row_address_lo_table:
  .byte $00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80
attrib_address_lo_table:
  .byte $C0,$FF,$C8,$FF,$D0,$FF,$D8,$FF,$E0,$FF,$E8,$FF,$F0,$FF,$F8

.segment "CODE"
draw_row:
  ldy row_number
  lda PPUSTATUS
  lda row_address_hi_table, y
  sta PPUADDR
  lda row_address_lo_table, y
  sta PPUADDR

  ldy #$00
draw_top_of_tiles:
  lda (row_tile_ptr), y
  asl a
  tax
  lda metatiles_top_table, x
  sta PPUDATA
  inx
  lda metatiles_top_table, x
  sta PPUDATA
  iny
  cpy #$10
  bne draw_top_of_tiles

  ldy #$00
draw_bottom_of_tiles:
  lda (row_tile_ptr), y
  asl a
  tax
  lda metatiles_bottom_table, x
  sta PPUDATA
  inx
  lda metatiles_bottom_table, x
  sta PPUDATA
  iny
  cpy #$10
  bne draw_bottom_of_tiles

; attribs
  lda row_number
  and #$01 ; isolate bit 0
  bne dont_load_attribs

  ldy row_number
  lda PPUSTATUS
  lda #$23 ;;; attrib address high
  sta PPUADDR
  lda attrib_address_lo_table, y
  sta PPUADDR

  ldy #$00
load_attribs:
  lda (row_attrib_ptr), y
  sta PPUDATA
  iny
  cpy #8
  bne load_attribs

dont_load_attribs:
  
  rts
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
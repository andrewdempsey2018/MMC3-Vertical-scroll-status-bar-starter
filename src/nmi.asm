.segment "CODE"
nmi:
  SAVE_REGISTERS

  ldx #$00
  stx PPUCTRL
  stx PPUMASK
  lda PPUSTATUS
  lda #$3F
  sta PPUADDR
  lda #$01
  sta PPUADDR
  lda #$00
  sta PPUDATA
  lda #$10
  sta PPUDATA

  ; --------------------------------------------------
; Enable sprites and background
; draw sprites and bg on leftmost side of screen
; --------------------------------------------------
  lda #%00011110 
  sta PPUMASK

; --------------------------------------------------
; NMI on, background at $1000 sprites at $0000
; --------------------------------------------------
  lda #%10001000
  sta PPUCTRL

; --------------------------------------------------
; Trigger sprite DMA transfer
; --------------------------------------------------
  lda #$02
  sta OAMDMA

; --------------------------------------------------
; Reset OAM address
; --------------------------------------------------
  lda #$00
  sta OAMADDR

; --------------------------------------------------
; Read player input
; --------------------------------------------------
  jsr read_controller

; --------------------------------------------------
; sfsdf
; --------------------------------------------------
  lda scroll_y
  and #%00001111 ; multiple of 16
  bne :+
  jsr draw_meta_row
  lda #$01
  sta prep_next_row
:

; --------------------------------------------------
; Set scroll
; --------------------------------------------------
  dec scroll_y
  lda scroll_y
  cmp #255
  bne :+
  lda #239
  sta scroll_y
:

; perform scroll on PPU
  lda scroll_x
  sta PPUSCROLL
  lda scroll_y
  sta PPUSCROLL

; --------------------------------------------------
; Toggle sleeping flag
; --------------------------------------------------
  lda #$00
  sta sleeping

  RESTORE_REGISTERS

  sta $E001
  sta $C001

  rti

; --------------------------------------------------
; draw a row of metatiles
; --------------------------------------------------
draw_meta_row:
  ldy row_number
  lda PPUSTATUS
  lda row_hi, y
  sta PPUADDR
  lda row_lo, y
  sta PPUADDR

  ldy #$00
draw_top_of_tiles:
  lda (row_ptr), y
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
  lda (row_ptr), y
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

  rts
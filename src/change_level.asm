; --------------------------------------------------
;
;
; Inputs:
; 
; Clobbers: 
;
; Outputs:
;
; Notes:
;
; --------------------------------------------------
.segment "CODE"

change_level:
; --------------------------------------------------
; Disable nmi/rendering
; --------------------------------------------------
  ldx #$00
  stx PPUCTRL
  stx PPUMASK

  lda scene_number
  cmp #TITLE_SCREEN_SCENE
  beq @title_screen_scene
  cmp #LEVEL_1_SCENE
  beq @level_1_scene

@title_screen_scene:
  jmp level_loaded

@level_1_scene:
; load all of first screen
  lda #14
  sta row_number

  ldx #0
  lda tiles_lo_table, x
  sta row_tile_ptr_lo
  lda tiles_hi_table, x
  sta row_tile_ptr_hi

  lda attribs_lo_table, x
  sta row_attrib_ptr_lo
  lda attribs_hi_table, x
  sta row_attrib_ptr_hi

  jsr load_screen
  inc screen_number

; load first row of second screen
; and then turn on scrolling
  lda #14
  sta row_number

  ldx #1
  lda tiles_lo_table, x
  sta row_tile_ptr_lo
  lda tiles_hi_table, x
  sta row_tile_ptr_hi

  lda attribs_lo_table, x
  sta row_attrib_ptr_lo
  lda attribs_hi_table, x
  sta row_attrib_ptr_hi

  jsr draw_row
  jsr prepare_row
  dec row_number

; turn on scrolling & MMC scanline IRQ
  lda #$01
  sta do_scroll
  sta do_irq

  jmp level_loaded

level_loaded:

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

  rts
; --------------------------------------------------
; Draws 15 rows of metatiles (a full screen)
;
; Inputs:
; row_number: must be initially set to 14
;
; row_tile_ptr: must point to the first row of the
; map table data.
;
; row_attrib_ptr: must point to the first row of the
; attribute table data.
;
; Clobbers: A
;
; Outputs: None
;
; Notes:
; --------------------------------------------------

.segment "CODE"

load_screen:

load_row:
  jsr draw_row
  jsr prepare_row
  dec row_number
  lda row_number
  cmp #255
  bne load_row

  rts
; --------------------------------------------------
; Sets metatile pointer to the next row of tiles in
; sequence.
;
; If row_number is even, pointer to attributes is
; also updated.
;
; Inputs:
; row_number: the row number that will be prepared
; row_tile_ptr: pointer to metatile data
; row_attrib_ptr: pointer to attribute data
;
; Clobbers: A
;
; Outputs:
; row_tile_ptr will be updated to point at next
; row of data that is to rendered
; row_attrib_ptr will be updated if applicable
;
; Notes:
; --------------------------------------------------
.segment "CODE"

prepare_row:

  lda row_tile_ptr_lo
  clc
  adc #16
  sta row_tile_ptr_lo
  lda row_tile_ptr_hi
  adc #0
  sta row_tile_ptr_hi

; attribs
  lda row_number
  and #$01 ; isolate bit 0
  bne dont_load_attribs_yet

  lda row_attrib_ptr_lo
  clc
  adc #8
  sta row_attrib_ptr_lo
  lda row_attrib_ptr_hi
  adc #0
  sta row_attrib_ptr_hi

dont_load_attribs_yet:

  rts
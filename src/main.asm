.segment "ZEROPAGE"
sleeping: .res 1
scroll_x: .res 1
scroll_y: .res 1
ptr: .res 2
ptr_lo = ptr
ptr_hi = ptr+1
row_number: .res 1
row_ptr: .res 2
row_tile_ptr_lo = row_ptr
row_tile_ptr_hi = row_ptr+1
row_attrib_ptr: .res 2
row_attrib_ptr_lo = row_attrib_ptr
row_attrib_ptr_hi = row_attrib_ptr+1
prep_next_row: .res 1
screen_number: .res 1

.segment "RODATA"
palette_table:
; background
  .byte $0F,$00,$10,$30
  .byte $0F,$01,$21,$31
  .byte $0F,$06,$16,$26
  .byte $0F,$09,$19,$29
; sprites
  .byte $0F,$00,$10,$30
  .byte $0F,$01,$21,$31
  .byte $0F,$06,$16,$26
  .byte $0F,$09,$19,$29

.include "levels.asm"

row_hi:
  .byte $23,$23,$23,$22,$22,$22,$22,$21,$21,$21,$21,$20,$20,$20,$20
  ;.byte $23,$23,$23,$22,$22,$22,$22,$21,$21,$21,$21,$20,$20,$20,$20
  ;.byte $20,$20,$20,$20,$21,$21,$21,$21,$22,$22,$22,$22,$23,$23,$23
row_lo:
  .byte $80,$40,$00,$C0,$80,$40,$00,$C0,$80,$40,$00,$C0,$80,$40,$00
  ;.byte $80,$40,$00,$C0,$80,$40,$00,$C0,$80,$40,$00,$C0,$80,$40,$00
  ;.byte $00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80,$C0,$00,$40,$80

.segment "CODE"
; --------------------------------------------------
; Includes for fixed bank
; --------------------------------------------------
.include "header.asm"
.include "macros.asm"
.include "constants.asm"
.include "reset.asm"
.include "nmi.asm"
.include "irq.asm"
.include "controllers.asm"

main:
; --------------------------------------------------
; Disable nmi/rendering
; --------------------------------------------------
  ldx #$00
  stx PPUCTRL
  stx PPUMASK

; --------------------------------------------------
; Load initial palette
; --------------------------------------------------
  ldx PPUSTATUS
  ldx #$3F
  stx PPUADDR
  ldx #$00
  stx PPUADDR

  ldx #$00
:
  lda palette_table, x
  sta PPUDATA
  inx
  cpx #$20
  bne :-

; --------------------------------------------------
; Init zeropage/bss memory to initial state
; --------------------------------------------------

  lda #$00
  sta sleeping
  sta buttons_held
  sta buttons_pressed
  sta scroll_x
  sta scroll_y
  sta ptr_lo
  sta ptr_hi
  sta prep_next_row
  sta screen_number

  ldx #0
  lda tiles_lo_table, x
  sta row_tile_ptr_lo
  lda tiles_hi_table, x
  sta row_tile_ptr_hi

  sta row_attrib_ptr_lo
  sta row_attrib_ptr_hi

  lda #$00
  sta row_number

; --------------------------------------------------
; nametable 01
; --------------------------------------------------
  lda #<bar_table
  sta ptr_lo
  lda #>bar_table
  sta ptr_hi

  lda PPUSTATUS
  lda #$24
  sta PPUADDR
  lda #$00
  sta PPUADDR

  ldx #$00
  ldy #$00

:
  lda (ptr), y
  sta PPUDATA
  iny
  cpy #0
  bne :-

  inc ptr_hi
  inx
  cpx #4
  bne :-

; --------------------------------------------------
; Enable maskable interrupts
; --------------------------------------------------
  cli

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

main_loop:
  
; --------------------------------------------------
; If NMI has set the prep_next_row flag then update
; tile pointer and attributes pointer in preparation
; for next row drawing opration in NMI.
; If the row_number returns to 0, this means the
; next screen should be loaded.
; Reset prep_next_row flag when done.
; --------------------------------------------------
  lda prep_next_row
  beq dont_prepare_row

  lda row_tile_ptr_lo
  clc
  adc #16
  sta row_tile_ptr_lo
  lda row_tile_ptr_hi
  adc #0
  sta row_tile_ptr_hi

  inc row_number

  lda row_number
  cmp #15
  bne dont_reset_row_number
  lda #0
  sta row_number
  
  inc screen_number
  ldx screen_number
  lda tiles_lo_table, x
  sta row_tile_ptr_lo
  lda tiles_hi_table, x
  sta row_tile_ptr_hi

dont_reset_row_number:

  lda #$00
  sta prep_next_row

dont_prepare_row:

; --------------------------------------------------
; Wait until NMI resets 'sleeping' to 0
; --------------------------------------------------
  lda #$01
  sta sleeping

sleep:
  lda sleeping
  bne sleep

  jmp main_loop

.segment "VECTORS"
  .word nmi
  .word reset
  .word irq

.segment "CHRROM"
  .incbin "../chr/gfx0.chr"
  .incbin "../chr/gfx1.chr"
  .incbin "../chr/gfx2.chr"
  .incbin "../chr/gfx3.chr"

.segment "CODE0"
.segment "CODE1"
.segment "CODE2"
.segment "CODE3"
.segment "CODE4"
.segment "CODE5"
.segment "FIXED_CODE0"
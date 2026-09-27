.segment "CODE"
nmi:
  SAVE_REGISTERS

  ldx #$00
  stx PPUCTRL
  stx PPUMASK

; --------------------------------------------------
; IRQ only tasks
; Code that executes when MMC3 scanline IRQ is on.
; --------------------------------------------------
  ;lda do_irq
  ;beq no_irq

; IRQ changes some palette values to colors needed
; for status bar, restore these to orignal values.
  lda PPUSTATUS
  lda #$3F
  sta PPUADDR
  lda #$01
  sta PPUADDR
  lda #$00
  sta PPUDATA
  lda #$10
  sta PPUDATA

; draw some demo text to status bar
; inefficient code, for demo purposes
; value to be displayed should be calculated outside of NMI
  lda PPUSTATUS
  lda #$24
  sta PPUADDR
  lda #$4F
  sta PPUADDR
  lda scroll_y
  and #%11110000
  lsr a
  lsr a
  lsr a
  lsr a
  clc
  adc #$40
  sta PPUDATA
  lda scroll_y
  and #%00001111
  clc
  adc #$40
  sta PPUDATA

no_irq:

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
; Draw a row of meta tiles If scrolling is on and 
; if the scroll threshold has been reached -
; (every 16 frames)
; --------------------------------------------------
  lda do_scroll
  beq dont_scroll

  lda scroll_y
  and #%00001111 ; multiple of 16
  bne dont_draw_row
  jsr draw_row

  lda #$01
  sta prep_next_row
  
dont_draw_row:

; --------------------------------------------------
; Handle scrolling
; --------------------------------------------------
  dec scroll_y
  lda scroll_y
  cmp #255
  bne dont_reset_scroll_value
  lda #239
  sta scroll_y
dont_reset_scroll_value:

dont_scroll:
  lda scroll_x
  sta PPUSCROLL
  lda scroll_y
  sta PPUSCROLL

; --------------------------------------------------
; Toggle sleeping flag
; --------------------------------------------------
  lda #$00
  sta sleeping

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
; If IRQ is on,
; --------------------------------------------------
  lda do_irq
  beq no_irq_reload
  sta IRQ_ENABLE
  sta IRQ_RELOAD
no_irq_reload:

  RESTORE_REGISTERS

  rti
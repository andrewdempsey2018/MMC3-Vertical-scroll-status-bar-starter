.segment "CODE"
reset:
; --------------------------------------------------
; Standard NES setup steps
; --------------------------------------------------
  sei
  cld
  lda #%01000000
  sta APU_FRAME_COUNTER
  ldx #$FF
  txs
  lda #$00
  sta PPUCTRL
  sta PPUMASK
  lda #%00000000
  sta APU_DMC
  bit PPUSTATUS

; --------------------------------------------------
; Mapper init code can go here
; --------------------------------------------------
  lda #0
  sta MMC3_IRQ_DISABLE

  lDA #0
  sta NAMETABLE_MIRRORING

; Toggle PPU A12 (prevent undesirable IRQ behaviour)
; This code is verbatim in most MMC3 games
  bit PPUSTATUS
  lda #$10
  tax
toggle:
  sta PPUADDR
  sta PPUADDR
  eor #$10
  dex
  bne toggle

; Set scanline IRQ will trigger
  lda #208 ; status bar is 32 pixels high
  sta MMC3_IRQ_LATCH

; Initialise 8 CHR bank windows
  lda #%00000000
  sta MMC3_BANK_SELECT
  lda #0
  sta MMC3_BANK_DATA
  
  lda #%00000001
  sta MMC3_BANK_SELECT
  lda #2
  sta MMC3_BANK_DATA

  lda #%00000010
  sta MMC3_BANK_SELECT
  lda #4
  sta MMC3_BANK_DATA

  lda #%00000011
  sta MMC3_BANK_SELECT
  lda #5
  sta MMC3_BANK_DATA

  lda #%00000100
  sta MMC3_BANK_SELECT
  lda #6
  sta MMC3_BANK_DATA

  lda #%00000101
  sta MMC3_BANK_SELECT
  lda #7
  sta MMC3_BANK_DATA

; --------------------------------------------------
; VBlank wait 1 of 2
; --------------------------------------------------
  WAIT_VBLANK

; --------------------------------------------------
; clear vram
; --------------------------------------------------
  lda #$20
  sta PPUADDR
  lda #$00
  sta PPUADDR
  ldx #$00
  lda #$00
clear_loop:
  sta PPUDATA
  inx
  bne clear_loop

; --------------------------------------------------
; Init ram
; --------------------------------------------------
  lda #$00
@clrmem:
  sta $00,x
  sta $100,x
  sta $200,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x
  inx
  bne @clrmem

; --------------------------------------------------
; Setup audio and other mapper code here
; --------------------------------------------------
  ; init audio/mapper

; --------------------------------------------------
; VBlank wait 2 of 2
; --------------------------------------------------
  WAIT_VBLANK

; --------------------------------------------------
; Finished, go to main loop
; --------------------------------------------------
  jmp main
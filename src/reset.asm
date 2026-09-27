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
  sta $E000

  lDA #0
  sta $A000

  bit $2002
  lda #$10
  tax
xloop:
  sta $2006
  sta $2006
  eor #$10
  dex
  bne xloop

  lda #$D0
  sta $C000
  ;sta $C001
  ;sta $E001

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
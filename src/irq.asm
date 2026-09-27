.segment "CODE"

irq:
  SAVE_REGISTERS
  
  sta $E000

; --------------------------------------------------
; NOP loop to clean MMC3 related status bar
; artifacts. Adjust / comment out as necessary
; --------------------------------------------------
;  ldx #8
;:
;  NOP
;  dex
;  bne :-

; --------------------------------------------------
; 
; --------------------------------------------------
  ldx #$00
  stx PPUCTRL
  stx PPUMASK
  lda PPUSTATUS

; palette
  lda #$3F
  sta PPUADDR
  lda #$01
  sta PPUADDR
  lda #$0F
  sta PPUDATA
  lda #$21
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
  lda #%10001001
  sta PPUCTRL

  lda #$24
  sta PPUADDR

  lda #$00
  sta PPUSCROLL

  lda #$00
  sta PPUSCROLL

  lda #$00
  sta PPUADDR

  RESTORE_REGISTERS
  rti
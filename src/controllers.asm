; --------------------------------------------------
; Constants
; --------------------------------------------------
CONTROLLER1 = $4016
CONTROLLER2 = $4017
BTN_RIGHT = %00000001
BTN_LEFT = %00000010
BTN_DOWN = %00000100
BTN_UP = %00001000
BTN_START = %00010000
BTN_SELECT = %00100000
BTN_B = %01000000
BTN_A = %10000000

.segment "ZEROPAGE"
buttons_held: .res 1
buttons_pressed: .res 1

.segment "CODE"

.proc read_controller
  SAVE_REGISTERS

  lda buttons_held
  tay
  lda #$01
  sta CONTROLLER1
  sta buttons_held
  lsr
  sta CONTROLLER1
get_buttons:
  lda CONTROLLER1
  lsr
  rol buttons_held
  bcc get_buttons
  tya
  eor buttons_held
  and buttons_held
  sta buttons_pressed

  RESTORE_REGISTERS
  rts
.endproc
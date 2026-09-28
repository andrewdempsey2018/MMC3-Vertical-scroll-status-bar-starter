; --------------------------------------------------
; PPU registers
; --------------------------------------------------
PPUCTRL	= $2000
PPUMASK	= $2001
PPUSTATUS = $2002
OAMADDR	= $2003
OAMDATA	= $2004
PPUSCROLL = $2005
PPUADDR	= $2006
PPUDATA	= $2007

; --------------------------------------------------
; APU registers
; --------------------------------------------------
OAMDMA = $4014
APU_FRAME_COUNTER = $4017
APU_DMC = $4010

; --------------------------------------------------
; MMC3 registers
; --------------------------------------------------
MMC3_IRQ_LATCH = $C000
MMC3_IRQ_RELOAD = $C001
MMC3_IRQ_DISABLE = $E000
MMC3_IRQ_ENABLE = $E001
NAMETABLE_MIRRORING = $A000
MMC3_BANK_SELECT = $8000
MMC3_BANK_DATA = $8001
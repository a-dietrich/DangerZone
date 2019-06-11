; ********************************************************************
;  Danger Zone 
;
;       created           : 05-Aug-1997
;       last modification : 12-Aug-1997
;
;  Copyright (c) 1997 Andreas Dietrich
; ********************************************************************
                
                PROCESSOR 6502

; --------------------------------------------------------------------        
;       Global Definitions
; --------------------------------------------------------------------        
                
                INCLUDE VCS.H

MemBase         = $00

ROMStart        = $F000
ROMSize         = $1000

RAMBase         = $80
RAMTop          = $FF

;---------------------------------------------------------------------
LineCtr         = $80
Temp            = $81
ColorCtr        = $82
BitMapHeight    = $83
CharSizeIdx     = $84
Charakter       = $85
ColorTabPtr     = $86
FrameCtr        = $88
KernelSwitch    = $89
GRPPtr          = $D0

NP_VarBase      = $E0
NP_SpeedCtr     = $EE
NP_Speed        = 2

;---------------------------------------------------------------------
;       Macros
;---------------------------------------------------------------------
        MAC storeword
                lda     #<{1}
                sta     {2}
                lda     #>{1}
                sta     {2}+1
        ENDM
        
        MAC colorbar
                ldy     #{1}
.loop           lda     {2},y
                sta     WSYNC
                sta     {3}
                dey
                bpl     .loop
        ENDM

; ********************************************************************
; --------------------------------------------------------------------        
;       System Setup         
; --------------------------------------------------------------------        
                
                ORG ROMStart 

Start:          sei
                cld

                ldx     #RAMTop
                txs
        
                lda     #0        
ClearMem:       sta     MemBase,x
                dex
                bne     ClearMem

; --------------------------------------------------------------------        
;       Main Program         
; --------------------------------------------------------------------        
                jsr     Init

MainLoop:       jsr     VerticalSync
                jsr     VerticalBlank

                lda     KernelSwitch
                lsr
                bcs     S1
                jsr     Kernel
                jmp     FrameEnd
S1:             jsr     S1_Kernel

FrameEnd:       jsr     OverScan                
                jmp     MainLoop

; --------------------------------------------------------------------        
;       Vertical Sync Procedure         
; --------------------------------------------------------------------        
VerticalSync:   lda     #%00000010
                sta     WSYNC
                sta     VSYNC

                sta     WSYNC
                sta     WSYNC
                lda     #44                
                sta     TIM64T
                lda     #0                
                sta     CXCLR

                inc     FrameCtr
                
                sta     WSYNC
                sta     VSYNC
                rts

; --------------------------------------------------------------------        
;       Vertical Blank Routines         
; --------------------------------------------------------------------        
VerticalBlank:  dec     NP_SpeedCtr
                bpl     Scroll
                lda     #NP_Speed    
                sta     NP_SpeedCtr
                jsr     NP_Play0
                jsr     NP_Play1
Scroll:         inc     ColorCtr
                ldy     ColorCtr
                cpy     #160
                bne     SEnd
                ldy     #0 ;8
                sty     ColorCtr
SEnd
                lda     FrameCtr
                and     #%00000111
                bne     VBEnd

NewChar:        ldy     Charakter
                ldx     MessageText,y
                iny
                cpy     #18
                bne     NextChar
                inc     KernelSwitch
                ldy     #0
NextChar:       sty     Charakter

                ldy     #7
tloop:          lda     LetterFont,x
                sta     $B8,y
                dex
                dey
                bpl     tloop

VBEnd:          rts

;--------------------------------------------------------------------        
;       Stage 1 Display Kernel        
; --------------------------------------------------------------------        
S1_Kernel:      lda     INTIM
                bne     S1_Kernel
                
S1_FirstLine:   sta     WSYNC
                sta     VBLANK
                lda     #%00000001
                sta     CTRLPF
                lda     #$00
                sta     COLUBK
                sta     COLUPF
                lda     #$F0
                sta     PF0
                sta     PF1
                lda     #%00000011
                sta     NUSIZ0
                sta     NUSIZ1
                lda     #%00000001
                sta     VDELP0
                sta     VDELP1

S1_PosScore:    SUBROUTINE
                ldy     #7
                sta     WSYNC
.loop           dey
                bpl     .loop
                sta     RESP0
                sta     RESP1
                lda     #$30
                sta     HMP0
                lda     #$40
                sta     HMP1
                sta     WSYNC
                sta     HMOVE

S1_DrawScore:   SUBROUTINE
                ldy     #7
                sty     LineCtr
.loop           ldy     LineCtr
                lda     ScoreColors,y
                sta     COLUP0
                sta     WSYNC
                sta     COLUP1
                lda     #0
                nop
                sta     Temp
                lda     S,y
                ldx     C,y
                sta     GRP0
                stx     GRP1
                lda     O,y
                ldx     R,y
                sta     GRP0
                lda     E,y        
                ldy     Temp
                stx     GRP1
                sta     GRP0
                sty     GRP1
                sta     GRP0
                dec     LineCtr
                bpl     .loop
                
                lda     #$40
                sta     HMP0
                sta     HMP1
                sta     WSYNC
                sta     HMOVE
                lda     #0
                sta     COLUP0

S1_DrawPoints:  SUBROUTINE                
                ldy     #7
                sty     LineCtr
.loop           sta     WSYNC
                lda     #0
                sta     GRP0
                sta     GRP1
                sta     GRP0
                ldy     LineCtr
                lda     PointsBGColors,y
                sta     COLUBK
                lda     PointsFGColors,y
                sta     COLUP0
                sta     COLUP1
                lda     (GRPPtr+$0),y
                sta     GRP0          
                sta     WSYNC
                lda     (GRPPtr+$2),y
                sta     GRP1
                lda     (GRPPtr+$4),y
                sta     GRP0
                lda     (GRPPtr+$6),y
                sta     Temp
                lda     (GRPPtr+$8),y
                tax
                lda     (GRPPtr+$A),y
                tay
                lda     Temp
                sta     GRP1
                stx     GRP0
                sty     GRP1
                sta     GRP0
                dec     LineCtr
                bpl     .loop

                sta     WSYNC
                lda     #0
                sta     COLUBK
                sta     VDELP0
                sta     VDELP1
                sta     GRP0
                sta     GRP1
                sta     PF0
                sta     PF1
                
                ldx     #0
                lda     ColorCtr 
                jsr     PosObj
                lda     #$40
                sta     COLUBK

                ldy     #24
                jsr     WaitNLines

S1_DrawPlanes:  SUBROUTINE
                ldy     #7
.loop           sta     WSYNC
                lda     GRP0Graphics,y
                sta     GRP0
                lda     GRP0Colors,y
                sta     COLUP0
                dey
                bpl     .loop

S1_Playfield:   SUBROUTINE                
                ldy     #31
.loop           sta     WSYNC
                tya
                lsr
                and     #%00001110
                eor     #%00001110
                ora     #$50
                sta     COLUBK
                dey
                bpl     .loop
                ldy     #63
.loop2          sta     WSYNC
                tya
                lsr
                lsr
                and     #%00001110
                eor     #%00001110
                ora     #$F0
                sta     COLUBK
                dey
                bpl     .loop2

                ldy     #33
                jmp     WaitNLines

;--------------------------------------------------------------------        
;       Message Screen Display Kernel        
; --------------------------------------------------------------------        
Kernel:         lda     INTIM
                bne     Kernel
                
FirstLine:      sta     WSYNC
                sta     VBLANK
                lda     #$00
                sta     COLUBK
                lda     #%00000000
                sta     CTRLPF
                storeword ColorBar2, ColorTabPtr

                ldy     #10
                jsr     WaitNLines

                ldx     CharSizeIdx
                lda     SineTab,x
                sta     BitMapHeight
                dex
                bpl     StoreCharSize
                ldx     #44
StoreCharSize:  stx     CharSizeIdx
                
BlueBar:        colorbar 21, ColorBar1, COLUBK

                lda     #15
                sec
                sbc     BitMapHeight
                asl
                asl
                tay
                sty     LineCtr
                beq     DrawBitMap
                jsr     WaitNLines

DrawBitMap:     ldx     #7
DisplayPart2:   ldy     BitMapHeight
NextLine:       lda     (ColorTabPtr),y
                sta     WSYNC
                sta     COLUPF
                lda     $90,x
                asl     
                asl     
                asl     
                asl     
                sta     PF0
                lda     $98,x
                sta     PF1
                lda     $A0,x
                sta     PF2
                lda     $90,x
                sta     PF0
                lda     $A8,x
                sta     PF1
                lda     $B0,x
                sta     PF2
                dey     
                bpl     NextLine
                dex     
                bpl     DisplayPart2
                                      
                sta     WSYNC
                lda     #0
                sta     PF0
                sta     PF1
                sta     PF2
                                 
                ldy     LineCtr
                beq     GoldBar
                jsr     WaitNLines
                                    
GoldBar:        colorbar     21, ColorBar3, COLUBK
  
                ldx     #7
Rotate:         sta     WSYNC
                clc     
                rol     $B8,x
                ror     $B0,x
                rol     $A8,x
                ror     $90,x
                lda     $90,x
                clc     
                and     #%00001000
                beq     RotateLeft
                sec     
RotateLeft:     ror     $A0,x
                rol     $98,x
                lda     $90,x
                and     #%11110111
                bcc     ShiftNext
                ora     #%00001000
ShiftNext:      sta     $90,x
                dex     
                bpl     Rotate
  
                sta     WSYNC
                rts     
  
; --------------------------------------------------------------------        
;       Overscan Program         
; --------------------------------------------------------------------        
OverScan:       lda     #%00000010
                sta     WSYNC
                sta     VBLANK
                lda     #0
                sta     ENAM0
                sta     ENAM1
                sta     ENABL
                sta     GRP0
                sta     GRP1
                sta     GRP0
                sta     PF0
                sta     PF1
                sta     PF2

                ldy     #29
                jmp     WaitNLines

; --------------------------------------------------------------------        
;       Initialisation Subroutines
; --------------------------------------------------------------------        
Init:           storeword Zero , GRPPtr+$0
                storeword One  , GRPPtr+$2
                storeword Two  , GRPPtr+$4
                storeword Three, GRPPtr+$6
                storeword Four , GRPPtr+$8
                storeword Five , GRPPtr+$A

                ldy     #0
                ldx     #2
                jsr     NP_Init0
                ldy     #0
                ldx     #2
                jmp     NP_Init1
  
; --------------------------------------------------------------------        
;       Display Subroutines
; --------------------------------------------------------------------        
WaitNLines:     sta     WSYNC
                dey     
                bne     WaitNLines
                rts     

; --------------------------------------------------------------------        
PosObj:         SUBROUTINE
                sta     WSYNC
                ldy     #-1
                cmp     #75        
                bcc     .div
                sbc     #75
                ldy     #4
.div            sec
.loop           iny
                sbc     #15
                bcs     .loop
                adc     #15
                sta     WSYNC
                asl
                asl
                asl
                asl
                eor     #%01110000
                sta     HMP0,x
.loop2          dey
                bpl     .loop2
                sta     RESP0,X
                sta     WSYNC
                sta     HMOVE
                rts

; --------------------------------------------------------------------        
;       Sound Subroutines
; --------------------------------------------------------------------        
                
                INCLUDE NPlayer.asm
                
; ********************************************************************
; --------------------------------------------------------------------        
;       Data Section
; --------------------------------------------------------------------        
                
                ALIGN $0100
                                     
PF2Graphics:    BYTE    $82,$82,$82,$86,$86,$86,$86,$86,$86,$8E
                BYTE    $8E,$8E,$8E,$8E,$8E,$8E,$8E,$8C,$8C,$9C
                BYTE    $9C,$9C,$9C,$98,$98,$98,$98,$98,$98,$98
                BYTE    $98,$98,$98,$90,$B0,$B0,$B0,$B0,$B0,$B0
                BYTE    $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                BYTE    $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                BYTE    $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                BYTE    $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                BYTE    $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                BYTE    $A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0
                                      
ColorBar1:      BYTE    $00,$80,$82,$84,$86,$88,$8A,$8C,$8E,$8C,$8A,$88,$86,$84,$82,$80,$6A,$68,$66,$64,$62,$60
ColorBar2:      BYTE    $F8,$F6,$F4,$F2,$90,$92,$94,$96,$98,$9A,$9C,$9E,$9C,$9A,$98,$96
ColorBar3:      BYTE    $00,$10,$12,$14,$16,$18,$1A,$30,$32,$34,$36,$38,$3A,$3C,$3E,$3C,$3A,$38,$36,$34,$32,$30
                                     
SineTab:        BYTE    $8,$9,$A,$B,$B,$C,$D,$E,$E,$F,$F,$F,$F,$F,$E,$E,$D,$D,$C,$B,$A,$9,$8,$7,$6,$5,$4,$3,$2,$2,$1,$1,$0,$0,$0,$0,$0,$1,$1,$2,$3,$4,$4,$5,$6

ScoreColors:    BYTE    $08,$06,$02,$06,$0A,$0E,$0A,$06
PointsBGColors: BYTE    $7C,$7A,$78,$76,$74,$72,$70,$00
PointsFGColors: BYTE    $20,$22,$24,$26,$28,$2A,$2C,$2E
                
GRP0Graphics:   BYTE    $00,$60,$70,$78,$FF,$78,$70,$60
GRP0Colors:     BYTE    $00,$04,$06,$08,$0A,$08,$06,$04

MessageText:    BYTE    D-LetterFont+7
                BYTE    A-LetterFont+7
                BYTE    N-LetterFont+7
                BYTE    G-LetterFont+7
                BYTE    E-LetterFont+7
                BYTE    R-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Z-LetterFont+7
                BYTE    O-LetterFont+7
                BYTE    N-LetterFont+7
                BYTE    E-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Space-LetterFont+7
                BYTE    Space-LetterFont+7

                ALIGN $0100
                
                INCLUDE FONT.ASM

; --------------------------------------------------------------------        
;       CPU Vectors
; --------------------------------------------------------------------        
                
                ORG $FFFA
                                     
NMI:            WORD    Start
Reset:          WORD    Start
IRQ:            WORD    Start

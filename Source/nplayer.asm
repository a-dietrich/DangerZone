; ********************************************************************
;  Noise Player 
;
;       created           : 03-Aug-1997
;       last modification : 04-Aug-1997
;
;  Copyright (c) 1997 Andreas Dietrich
; ********************************************************************

; NP_VarBase     = $80

NP_PatternPtr0 = NP_VarBase+$0
NP_PatternCtr0 = NP_VarBase+$2
NP_PCtrStart0  = NP_VarBase+$3
NP_PCtrEnd0    = NP_VarBase+$4
NP_NoiseCtr0   = NP_VarBase+$5
NP_Hold0       = NP_VarBase+$6

NP_PatternPtr1 = NP_VarBase+$7
NP_PatternCtr1 = NP_VarBase+$9
NP_PCtrStart1  = NP_VarBase+$A
NP_PCtrEnd1    = NP_VarBase+$B
NP_NoiseCtr1   = NP_VarBase+$C
NP_Hold1       = NP_VarBase+$D

; --------------------------------------------------------------------
;       Init
; --------------------------------------------------------------------
NP_Init0:       sty     NP_PCtrStart0
                stx     NP_PCtrEnd0
                ldx     #1
                stx     NP_Hold0
                jmp     NP_SetPattern0

; --------------------------------------------------------------------
NP_Init1:       sty     NP_PCtrStart1
                stx     NP_PCtrEnd1
                ldx     #1
                stx     NP_Hold1
                jmp     NP_SetPattern1

; --------------------------------------------------------------------
;       Play
; --------------------------------------------------------------------
NP_Play0:       dec     NP_Hold0
                bne     NP_End0
                
                ldy     NP_NoiseCtr0
                lda     (NP_PatternPtr0),y
                sta     AUDC0
                iny
                lda     (NP_PatternPtr0),y
                sta     AUDF0
                iny
                lda     (NP_PatternPtr0),y
                sta     AUDV0
                iny
                lda     (NP_PatternPtr0),y
                sta     NP_Hold0
                iny
                lda     (NP_PatternPtr0),y
                bpl     NP_NextNoise0
                
                ldy     NP_PatternCtr0
                cpy     NP_PCtrEnd0
                bne     NP_SetPattern0
                ldy     NP_PCtrStart0
NP_SetPattern0: lda     NP_PatternTab0,y
                sta     NP_PatternPtr0
                iny
                lda     NP_PatternTab0,y 
                sta     NP_PatternPtr0+1
                iny
                sty     NP_PatternCtr0
                ldy     #0
NP_NextNoise0:  sty     NP_NoiseCtr0
NP_End0:        rts

; --------------------------------------------------------------------
NP_Play1:       dec     NP_Hold1
                bne     NP_End1
                
                ldy     NP_NoiseCtr1
                lda     (NP_PatternPtr1),y
                sta     AUDC1
                iny
                lda     (NP_PatternPtr1),y
                sta     AUDF1
                iny
                lda     (NP_PatternPtr1),y
                sta     AUDV1
                iny
                lda     (NP_PatternPtr1),y
                sta     NP_Hold1
                iny
                lda     (NP_PatternPtr1),y
                bpl     NP_NextNoise1
                
                ldy     NP_PatternCtr1
                cpy     NP_PCtrEnd1
                bne     NP_SetPattern1
                ldy     NP_PCtrStart1
NP_SetPattern1: lda     NP_PatternTab1,y
                sta     NP_PatternPtr1
                iny
                lda     NP_PatternTab1,y 
                sta     NP_PatternPtr1+1
                iny
                sty     NP_PatternCtr1
                ldy     #0
NP_NextNoise1:  sty     NP_NoiseCtr1
NP_End1:        rts

; --------------------------------------------------------------------
;       Data
; --------------------------------------------------------------------
NP_PatternTab0: WORD    NP_Pattern1
                
NP_PatternTab1: WORD    NP_Pattern2

;                       AUDC AUDF AUDV Lenght
; --------------------------------------------------------------------
NP_Pattern1:    BYTE    $A,  $5,  $2,  3
                BYTE    $A,  $4,  $2,  3
                BYTE    $A,  $3,  $2,  3
                BYTE    $A,  $2,  $2,  3
                BYTE    $A,  $1,  $2,  3
                BYTE    $A,  $2,  $2,  3
                BYTE    $A,  $3,  $2,  3
                BYTE    $A,  $4,  $2,  3
                BYTE    -1

NP_Pattern2:    BYTE    $E,  $3,  $3,  3*8*3
                BYTE    $E,  $2,  $3,  3*8*3
                BYTE    $E,  $3,  $3,  3*8*3
                BYTE    $E,  $4,  $3,  3*8*3
                BYTE    $E,  $5,  $3,  3*8*3
                BYTE    $E,  $4,  $3,  3*8*3
                BYTE    -1

; --------------------------------------------------------------------

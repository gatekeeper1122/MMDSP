*************************************************************************
*									*
*									*
*	    Ｘ６８０００　ＭＸＤＲＶ／ＭＡＤＲＶディスプレイ		*
*									*
*				ＭＭＤＳＰ				*
*									*
*									*
*	Copyright (C) 1991,1992 Kyo Mikami.  All Rights Reserved.	*
*									*
*	Modified 1992-1994 Masao Takahashi				*
*									*
*************************************************************************


		.include	iocscall.mac
		.include	doscall.mac
		.include	MMDSP.H


SPDATA_SIZE	equ	SPDATA_END-SPRITE_DATA		*ＰＣＧデータの長さ
SPPAL_SIZE	equ	SPPAL_END-SPRITE_PALET		*パレットデーターの長さ

			.text
			.even

*
*	＊ＳＰＲＩＴＥ＿ＩＮＩＴ
*機能：スプライトを初期化する
*入力：なし
*出力：なし
*参考：初期化内容はＰＣＧ，パレット，ＢＧスクリーン，ＳＰレジスタ
*

SPRITE_INIT:
		movem.l	d0-d3/a0-a1,-(sp)

*		IOCS	_SP_INIT

		move.l	#$8000,d0		*BG CLEAR
		movea.l	#PCGADR,a0
		bsr	HSCLR

		move.l	#SPDATA_SIZE,d0		*PCG SET
		lea.l	SPRITE_DATA(pc),a0
		movea.l	#PCGADR+$400,a1
		bsr	HSCOPY

		bsr	hexchr_make

		move.l	#SPPAL_SIZE,d0		*PALET SET
		lea.l	SPRITE_PALET(pc),a0
		movea.l	#SPPALADR,a1
		bsr	HSCOPY

		lea.l	$00eb0800,a0
		moveq	#0,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.w	d0,(a0)

		move.l	#SPRITEREG,a0		*スプライトレジスタ初期化
		moveq.l	#7,d0
		move.w	#32,d1
sp_init_loop3:
		addq.w	#1,d1
		move.w	d1,d2
		addi.w	#16,d2
		moveq	#7-1,d3
sp_init_loop4:
		clr.w	(a0)
		move.w	d1,$2(a0)		*y+1
		clr.w	$04(a0)
		move.w	#$0003,$6(a0)
		clr.w	$8(a0)
		move.w	d2,$A(a0)		*y+17
		move.w	#$0317,$C(a0)
		move.w	#$0003,$E(a0)
		lea	16(a0),a0
		dbra	d3,sp_init_loop4

		subq.w	#1,d1
		move.w	d1,d2
		addi.w	#9,d2
		clr.w	(a0)
		move.w	d1,$2(a0)		*y+0
		move.w	#$0310,$4(a0)
		move.w	#$0003,$6(a0)
		clr.w	$8(a0)
		move.w	d2,$A(a0)		*y+9
		move.w	#$8310,$C(a0)
		move.w	#$0003,$E(a0)
		lea	16(a0),a0

		addi.w	#40,d1
		dbra	d0,sp_init_loop3

.if 0		*実験
		movea.l	#$e80000,a0
		move.w	#$5b,(a0)+
		move.w	#$09,(a0)+
		move.w	#$0f,(a0)+
		move.w	#$53,(a0)+
		move.w	#$237,(a0)+
		move.w	#$05,(a0)+
		move.w	#$1c,(a0)+
		move.w	#$237,(a0)+
.endif

.if 0
		movea.l	#$e80000,a0			*24kHzモード
		move.w	#$52,(a0)+
		move.w	#$06,(a0)+
		move.w	#$0c,(a0)+
		move.w	#$4c,(a0)+
		move.w	#$1e5,(a0)+
		move.w	#$0,(a0)+
		move.w	#$1,(a0)+
		move.b	#$15,$e80029
		ori.b	#$02,$e8e007
		movea.l	#$eb080a,a0
		move.w	#$ff,(a0)+
		move.w	#$10,(a0)+
		move.w	#$2,(a0)+
		move.w	#$0,(a0)+
.endif

		move.l	#VIDEO_PRIO,a0			*プライオリティ変更
		move.w	(a0),d0
		and.w	#$C0FF,d0
		or.w	#%010010*$100,d0
		move.w	d0,(a0)

		move.l	#SPRITEREG,a0			*特殊ＢＧ画面
		move.w	#$219,$808(a0)
		move.w	#$029,$80E(a0)
		move.w	#$000,$810(a0)

		move.w	#$0060,VIDEO_EFFECT		*SPRITE表示ＯＮ

		movem.l	(sp)+,d0-d3/a0-a1
		rts


*----------------------------------------
*１６進キャラ作成
*----------------------------------------

hexchr_getadr	macro	r
		add.w	d0,d0
		move.w	(a0,d0.w),d0
		lea	(a1,d0.w),r
		endm


hexchr_make::	movem.l	d0/d5-d7/a0-a3,-(sp)

		lea.l	HEXDATA(pc),a0
		lea.l	CHR_00(pc),a1
		move.l	#PCGADR+$20*128,a2
		moveq.l	#0,d5

		moveq.l	#$F,d7
hexchr_m_loop1:
		move.l	d7,d0
		hexchr_getadr	a3

		moveq.l	#$F,d6
hexchr_m_loop2:
		move.l	d6,d0
		hexchr_getadr	a4
		bsr	hexchr_pcgset

		dbra	d6,hexchr_m_loop2
		dbra	d7,hexchr_m_loop1

		move.l	a1,a4
		moveq.l	#$F,d7
hexchr_m_loop3:
		move.l	d7,d0
		hexchr_getadr	a3
		bsr	hexchr_pcgset

		dbra	d7,hexchr_m_loop3

		move.l	a1,a3
		moveq.l	#$F,d7
hexchr_m_loop4:
		move.l	d7,d0
		hexchr_getadr	a4
		bsr	hexchr_pcgset

		dbra	d7,hexchr_m_loop4

		movem.l	(sp)+,d0/d5-d7/a0-a3
		rts

*HEX文字をPCGに作成する
*	a2.l <- PCGアドレス
*	a3.l <- 上位文字フォントアドレス
*	a4.l <- 下位文字フォントアドレス
*	d5.w <- シフト数(0-3)
*	a2.l -> 次のPCGアドレス
*	d5.w -> 次のシフト数(0-3)

hexchr_pcgset:
		movem.l	d0/d7/a0/a3-a4,-(sp)
		lea	PCGCNVTBL(pc),a0
		moveq.l	#7-1,d7			*字詰めデータの分は処理しないから7回
hexchr_pcglop1:
		moveq	#$0f,d0
		and.b	(a3)+,d0
		add.w	d0,d0
		move.w	(a0,d0.w),d0
		lsl.w	d5,d0
		or.w	d0,(a2)+

		moveq	#$0f,d0
		and.b	(a4)+,d0
		add.w	d0,d0
		move.w	(a0,d0.w),d0
		lsl.w	d5,d0
		or.w	d0,(a2)+
		dbra	d7,hexchr_pcglop1
		addq.l	#4,a2			*字詰めデーター潰し

		addq.w	#1,d5
		cmp.w	#4,d5
		beq	hexchr_pcg_jp0
		lea.l	-32(a2),a2
hexchr_pcg_jp0:
		and.w	#3,d5
		movem.l	(sp)+,d0/d7/a0/a3-a4
		rts

		.data

HEXDATA:
		.dc.w	'F'*8		*１６進キャラ作成用
		.dc.w	'E'*8
		.dc.w	'D'*8
		.dc.w	'C'*8
		.dc.w	'B'*8
		.dc.w	'A'*8
		.dc.w	'9'*8
		.dc.w	'8'*8
		.dc.w	'7'*8
		.dc.w	'6'*8
		.dc.w	'5'*8
		.dc.w	'4'*8
		.dc.w	'3'*8
		.dc.w	'2'*8
		.dc.w	'1'*8
		.dc.w	'0'*8

PCGCNVTBL:
		.dc.w	%0000_0000_0000_0000
		.dc.w	%0000_0000_0000_0001
		.dc.w	%0000_0000_0001_0000
		.dc.w	%0000_0000_0001_0001
		.dc.w	%0000_0001_0000_0000
		.dc.w	%0000_0001_0000_0001
		.dc.w	%0000_0001_0001_0000
		.dc.w	%0000_0001_0001_0001
		.dc.w	%0001_0000_0000_0000
		.dc.w	%0001_0000_0000_0001
		.dc.w	%0001_0000_0001_0000
		.dc.w	%0001_0000_0001_0001
		.dc.w	%0001_0001_0000_0000
		.dc.w	%0001_0001_0000_0001
		.dc.w	%0001_0001_0001_0000
		.dc.w	%0001_0001_0001_0001

RGB_COL:	.macro	R1,G1,B1,dm1,R2,G2,B2,dm2,R3,G3,B3,dm3,R4,G4,B4
		.dc.w	B1*2+R1*64+G1*2048
		.dc.w	B2*2+R2*64+G2*2048
		.dc.w	B3*2+R3*64+G3*2048
		.dc.w	B4*2+R4*64+G4*2048
		.endm

SPRITE_PALET:
*		RGB_COL	00,00,00,__,10,10,21,__,16,16,31,__,21,21,21	* 0
*		.dc.w	$0000,$52AA,$843E+1,$AD6C
		.dc.w	$0000,$52AA,$843E+1,$D6B4

		RGB_COL	31,31,31,__,31,31,31,__,31,31,31,__,31,31,31	*(Text Color)
		RGB_COL	01,01,01,__,08,08,13,__,13,13,21,__,12,12,12
		RGB_COL	01,01,01,__,08,08,13,__,13,13,21,__,12,12,12

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* 1
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	*(Selector)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,01,__,05,05,12,__,12,12,24,__,03,03,07

		RGB_COL	00,00,00,__,03,03,07,__,04,04,07,__,16,16,31	* 2
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	*(Digital Num)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,07,07,14

		RGB_COL	00,00,00,__,18,18,31,__,00,00,00,__,00,00,00	* 3
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	*(KeyLamp)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	01,17,00,__,02,21,00,__,09,27,00,__,12,31,00
*		RGB_COL	00,08,00,__,00,10,00,__,00,14,00,__,01,17,00

		RGB_COL	00,00,00,__,00,00,01,__,00,00,00,__,00,00,00	* 4
		RGB_COL	06,06,07,__,10,10,11,__,12,12,13,__,14,14,15	*(KeyBord)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	14,14,15,__,18,18,19,__,24,24,25,__,28,28,29

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* 5
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,21,21,22	*(Level&Pan1)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,02,02,06,__,16,16,31

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* 6
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,14,14,14	*(Speana1&Pan2)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,02,02,06,__,16,16,31

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* 7
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	*(Speana2)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,09,05,22,__,01,01,05

		RGB_COL	00,00,00,__,00,00,01,__,00,00,00,__,00,00,00	* 8
		RGB_COL	03,03,04,__,05,05,06,__,06,06,07,__,07,07,08	*(KeyBord dark)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	07,07,08,__,09,09,10,__,12,12,13,__,14,14,15

		RGB_COL	00,00,00,__,00,00,01,__,00,00,00,__,00,00,00	* 9
		RGB_COL	03,03,04,__,05,05,06,__,06,06,07,__,07,07,08	*(KeyBord dark)
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	07,07,08,__,09,09,10,__,12,12,13,__,14,14,15

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* A
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* B
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
MR	equ	22
MG	equ	22
MB	equ	23
		RGB_COL	00,00,00,__,MR,MG,MB,__,00,00,00,__,MR,MG,MB	* C
		RGB_COL	00,00,00,__,MR,MG,MB,__,00,00,00,__,MR,MG,MB
		RGB_COL	00,00,00,__,MR,MG,MB,__,00,00,00,__,MR,MG,MB
		RGB_COL	00,00,00,__,MR,MG,MB,__,00,00,00,__,MR,MG,MB

		RGB_COL	00,00,00,__,00,00,00,__,MR,MG,MB,__,MR,MG,MB	* D
		RGB_COL	00,00,00,__,00,00,00,__,MR,MG,MB,__,MR,MG,MB
		RGB_COL	00,00,00,__,00,00,00,__,MR,MG,MB,__,MR,MG,MB
		RGB_COL	00,00,00,__,00,00,00,__,MR,MG,MB,__,MR,MG,MB

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* E
		RGB_COL	MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB

		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00	* F
		RGB_COL	00,00,00,__,00,00,00,__,00,00,00,__,00,00,00
		RGB_COL	MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB
		RGB_COL	MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB,__,MR,MG,MB
SPPAL_END:

CHRD1:	.macro	A,B,C,D
	.dc.l	A
chB1	=	B
chC1	=	C
chD1	=	D
	.endm

CHRD2:	.macro	A,B,C,D
	.dc.l	A
chB2	=	B
chC2	=	C
chD2	=	D
	.endm

CHRD3:	.macro	A,B,C,D
	.dc.l	A
chB3	=	B
chC3	=	C
chD3	=	D
	.endm

CHRD4:	.macro	A,B,C,D
	.dc.l	A
chB4	=	B
chC4	=	C
chD4	=	D
	.endm

CHRD5:	.macro	A,B,C,D
	.dc.l	A
chB5	=	B
chC5	=	C
chD5	=	D
	.endm

CHRD6:	.macro	A,B,C,D
	.dc.l	A
chB6	=	B
chC6	=	C
chD6	=	D
	.endm

CHRD7:	.macro	A,B,C,D
	.dc.l	A
chB7	=	B
chC7	=	C
chD7	=	D
	.endm

CHRD8:	.macro	A,B,C,D
	.dc.l	A
chB8	=	B
chC8	=	C
chD8	=	D
	.dc.l	chB1,chB2,chB3,chB4,chB5,chB6,chB7,chB8
	.dc.l	chC1,chC2,chC3,chC4,chC5,chC6,chC7,chC8
	.dc.l	chD1,chD2,chD3,chD4,chD5,chD6,chD7,chD8
	.endm

SPRITE_DATA:

*		  20	    21	      22	23
	CHRD1	$00000000,$00000000,$00000000,$00022000
	CHRD2	$00000000,$00000000,$00000000,$03000200
	CHRD3	$00000000,$00000000,$00000000,$03000200
	CHRD4	$00000000,$00000000,$00000000,$03000200
	CHRD5	$00000000,$00000000,$00000000,$03000200
	CHRD6	$00000000,$00000000,$00000000,$03000200
	CHRD7	$00000000,$00000000,$00000000,$00333000
	CHRD8	$00000000,$00000000,$00000000,$00000000
*		  24	    25	      26	27
	CHRD1	$00010000,$01010000,$01000100,$10101010
	CHRD2	$00000000,$10001000,$00100010,$01010101
	CHRD3	$00010000,$00000101,$00010001,$10101010
	CHRD4	$00000000,$00000010,$10001000,$01010101
	CHRD5	$00010000,$00000101,$01000100,$10101010
	CHRD6	$00000000,$10001000,$00100010,$01010101
	CHRD7	$01010101,$01010000,$00010001,$10101010
	CHRD8	$00000000,$00100000,$10001000,$01010101
*		  28	    29	      2A	2B
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000000,$00000000,$00000000,$00000000
	CHRD3	$00000000,$00000000,$00000000,$00000000
	CHRD4	$00000000,$00033000,$00000000,$00022000
	CHRD5	$00000000,$00033000,$00000000,$00022000
	CHRD6	$00000000,$00000000,$00000000,$00000000
	CHRD7	$00003300,$00000000,$00002200,$00000000
	CHRD8	$00003300,$00000000,$00002200,$00000000
*		  2C	    2D	      2E	2F
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000fff,$ffffffff,$00000000,$00000000
	CHRD3	$00000fff,$ffffffff,$00000000,$00000000
	CHRD4	$00000fff,$ffffffff,$ffffffff,$ffffffff
	CHRD5	$00000000,$00000000,$00000000,$00000000
	CHRD6	$00000fff,$ffffffff,$00000000,$00000000
	CHRD7	$00000fff,$ffffffff,$0ddddddd,$dddddddd
	CHRD8	$00000fff,$ffffffff,$ddffffff,$fffffffc
*		  30	    31	      32	33
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000000,$00000000,$00000000,$00000000
	CHRD3	$00033300,$00022200,$00033300,$00022200
	CHRD4	$00300000,$00200000,$00200000,$00300000
	CHRD5	$00300030,$00200030,$00200030,$00300030
	CHRD6	$00300030,$00200030,$00200030,$00300030
	CHRD7	$00300030,$00200030,$00200030,$00300030
	CHRD8	$00300030,$00200030,$00200030,$00300030
*		  34	    35	      36	37
	CHRD1	$00000000,$00000000,$00000000,$00022000
	CHRD2	$00000000,$00000000,$00000000,$03000300
	CHRD3	$00033300,$00022200,$00022200,$03000300
	CHRD4	$00300000,$00300000,$00200000,$03000300
	CHRD5	$00300020,$00300020,$00200020,$03000300
	CHRD6	$00300020,$00300020,$00200020,$03000300
	CHRD7	$00300020,$00300020,$00200020,$00333000
	CHRD8	$00300020,$00300020,$00200020,$00000000
*		  38	    39	      3A	3B
	CHRD1	$00022000,$00033000,$00033000,$00033000
	CHRD2	$02000300,$03000200,$02000300,$02000300
	CHRD3	$02000300,$03000200,$02000300,$02000300
	CHRD4	$02000300,$03000200,$02000300,$02000300
	CHRD5	$02000300,$03000200,$02000300,$02000300
	CHRD6	$02000300,$03000200,$02000300,$02000300
	CHRD7	$00222000,$00333000,$00333000,$00222000
	CHRD8	$00000000,$00000000,$00000000,$00000000
*		  3C	    3D	      3E	3F
	CHRD1	$00033000,$00033000,$00033000,$00022000
	CHRD2	$03000300,$03000300,$03000200,$02000200
	CHRD3	$03000300,$03000300,$03000200,$02000200
	CHRD4	$03000300,$03000300,$03000200,$02000200
	CHRD5	$03000300,$03000300,$03000200,$02000200
	CHRD6	$03000300,$03000300,$03000200,$02000200
	CHRD7	$00333000,$00222000,$00222000,$00222000
	CHRD8	$00000000,$00000000,$00000000,$00000000
*		  40	    41	      42	43
	CHRD1	$01000000,$01000000,$00000000,$00000000
	CHRD2	$01000000,$01000000,$00000000,$00000000
	CHRD3	$01000000,$01000000,$00000000,$00000000
	CHRD4	$01000000,$01000000,$00000000,$00000000
	CHRD5	$01000000,$01000000,$00000000,$00000000
	CHRD6	$01000000,$00000000,$00000000,$00000000
	CHRD7	$01000000,$00000000,$00000000,$00000000
	CHRD8	$01000000,$00000000,$00000000,$00000000
*		  44	    45	      46	47
	CHRD1	$1ed0ee41,$1ed0ee41,$1e411e41,$1e411e41
	CHRD2	$1ed0ee41,$1ed0ee51,$1e411e41,$1e511e51
	CHRD3	$1ed0ee41,$1ed0ee61,$1e411e41,$1e611e61
	CHRD4	$1ed0ee41,$1ed0ee74,$1e411e41,$1e741e74
	CHRD5	$1ed0ee41,$1ed0ee11,$1e411e41,$1e111e11
	CHRD6	$1ed0ee41,$ded0eed0,$1e411e41,$ded0ded0
	CHRD7	$1ed0ee41,$eed0eed0,$1e411e41,$eed0eed0
	CHRD8	$1ed0ee41,$eed0eed0,$1e411e41,$eed0eed0
*		  48	    49	      4A	4B
	CHRD1	$1e411ed0,$1e411ed0,$ee411e41,$ee411e41
	CHRD2	$1e411ed0,$1e511ed0,$ee411e41,$ee511e51
	CHRD3	$1e411ed0,$1e611ed0,$ee411e41,$ee611e61
	CHRD4	$1e411ed0,$1e741ed0,$ee411e41,$ee741e74
	CHRD5	$1e411ed0,$1e111ed0,$ee411e41,$ee111e11
	CHRD6	$1e411ed0,$ded0ded0,$ee411e41,$eed0ded0
	CHRD7	$1e411ed0,$eed0eed0,$ee411e41,$eed0eed0
	CHRD8	$1e411ed0,$eed0eed0,$ee411e41,$eed0eed0
*		  4C	    4D	      4E	4F
	CHRD1	$eee00000,$fff00000,$00000000,$00000000
	CHRD2	$fff00000,$fff00000,$00000000,$00000000
	CHRD3	$fff00000,$fff00000,$00000000,$00000000
	CHRD4	$fff00000,$efe00000,$00000000,$00000000
	CHRD5	$fff00000,$cdc00000,$00000000,$00000000
	CHRD6	$fff00000,$00000000,$00000000,$00000000
	CHRD7	$fff00000,$00000000,$00000000,$00000000
	CHRD8	$fff00000,$00000000,$00000000,$00000000
*		  50	    51	      52	53
	CHRD1	$0e000000,$0f000000,$00000000,$00000000
	CHRD2	$0f000000,$0f000000,$00000000,$00000000
	CHRD3	$0f000000,$0f000000,$00000000,$00000000
	CHRD4	$0f000000,$0f000000,$00000000,$00000000
	CHRD5	$0f000000,$0f000000,$00000000,$00000000
	CHRD6	$0f000000,$efe00000,$00000000,$00000000
	CHRD7	$0f000000,$fff00000,$00000000,$00000000
	CHRD8	$0f000000,$fff00000,$00000000,$00000000
*		  54	    55	      56	57
	CHRD1	$ee000000,$ff000000,$00000000,$00000000
	CHRD2	$ff000000,$ff000000,$00000000,$00000000
	CHRD3	$ff000000,$ff000000,$00000000,$00000000
	CHRD4	$ff000000,$ff000000,$00000000,$00000000
	CHRD5	$ff000000,$ff000000,$00000000,$00000000
	CHRD6	$ff000000,$ffe00000,$00000000,$00000000
	CHRD7	$ff000000,$fff00000,$00000000,$00000000
	CHRD8	$ff000000,$fff00000,$00000000,$00000000
*		  58	    59	      5A	5B
	CHRD1	$0ee00000,$0ff00000,$00000000,$00000000
	CHRD2	$0ff00000,$0ff00000,$00000000,$00000000
	CHRD3	$0ff00000,$0fe00000,$00000000,$00000000
	CHRD4	$0ff00000,$0ff00000,$00000000,$00000000
	CHRD5	$0ff00000,$0ff00000,$00000000,$00000000
	CHRD6	$0ff00000,$eff00000,$00000000,$00000000
	CHRD7	$0ff00000,$fff00000,$00000000,$00000000
	CHRD8	$0ff00000,$fff00000,$00000000,$00000000
*		  5C	    5D	      5E	5F
	CHRD1	$fff00000,$00000000,$00000000,$00000000
	CHRD2	$fff00000,$00000000,$00000000,$00000000
	CHRD3	$fff00000,$00000000,$00000000,$00000000
	CHRD4	$fff00000,$00000000,$00000000,$00000000
	CHRD5	$fff00000,$00000000,$00000000,$00000000
	CHRD6	$efe00000,$00000000,$00000000,$00000000
	CHRD7	$cdc00000,$00000000,$00000000,$00000000
	CHRD8	$00000000,$00000000,$00000000,$00000000
*		  60	    61	      62	63
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000077,$00000077,$00000077,$00000077
	CHRD3	$00007700,$00007700,$00007700,$00007700
	CHRD4	$00070000,$00070007,$00070000,$00070000
	CHRD5	$00070000,$00070007,$00070770,$00070000
	CHRD6	$00700000,$00700007,$00700770,$00700000
	CHRD7	$00700000,$00700007,$00700077,$00707770
	CHRD8	$00700000,$00700000,$00700007,$00700777
*		  64	    65	      66	67
	CHRD1	$eed0eed0,$00000000,$00000000,$00000000
	CHRD2	$eed0eed0,$08002020,$00000000,$0eeeeeee
	CHRD3	$eed0eed0,$80820200,$00000200,$00000000
	CHRD4	$eed0eed0,$a7e31e80,$00000300,$0eeeeeee
	CHRD5	$eed0eed0,$f8f3a3a0,$00006660,$00000000
	CHRD6	$eed0eed0,$b6530f80,$00000300,$0eeeeeee
	CHRD7	$cdc0cdc0,$09e12180,$00000200,$00000000
	CHRD8	$00000000,$00000000,$00000000,$0eeeeeee
*		  68	    69	      6A	6B
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$0eeeeeee,$0eeeeeee,$0eeeeeee,$0fffffff
	CHRD3	$00000000,$00000000,$00000000,$00000000
	CHRD4	$0eeeeeee,$0eeeeeee,$0fffffff,$0fffffff
	CHRD5	$00000000,$00000000,$00000000,$00000000
	CHRD6	$0eeeeeee,$0fffffff,$0fffffff,$0fffffff
	CHRD7	$00000000,$00000000,$00000000,$00000000
	CHRD8	$0fffffff,$0fffffff,$0fffffff,$0fffffff
*		  6C	    6D	      6E	6F
	CHRD1	$00000000,$ffffffff,$00000000,$00000000
	CHRD2	$dddddddd,$ffffffff,$00000000,$00000000
	CHRD3	$ffffffff,$ffffffff,$00000000,$00000000
	CHRD4	$ffffffff,$ffffffff,$00000000,$00000000
	CHRD5	$ffffffff,$ffffffff,$00000000,$00000000
	CHRD6	$ffffffff,$ffffffff,$00000000,$00000000
	CHRD7	$ffffffff,$ffffffff,$00000000,$00000000
	CHRD8	$ffffffff,$ffffffff,$ffffffff,$f0f0f0f0
*		  70	    71	      72	73
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000000,$00000000,$00000000,$00000000
	CHRD3	$00000000,$00000000,$00000000,$00000000
	CHRD4	$ffffffff,$f0f0f0f0,$00000000,$00000000
	CHRD5	$00000000,$00000000,$00000000,$00000000
	CHRD6	$00000000,$00000000,$00000000,$00000000
	CHRD7	$dddddddd,$dddddddd,$00000000,$00000000
	CHRD8	$ffffffff,$ffffffff,$eeeeeeee,$00000000
*		  74	    75	      76	77
	CHRD1	$00000000,$dfffffff,$00000000,$fffffffc
	CHRD2	$0ddddddd,$dfffffff,$dddddddd,$fffffffc
	CHRD3	$ddffffff,$dfffffff,$fffffffc,$fffffffc
	CHRD4	$dfffffff,$dfffffff,$fffffffc,$fffffffc
	CHRD5	$dfffffff,$dfffffff,$fffffffc,$fffffffc
	CHRD6	$dfffffff,$dfffffff,$fffffffc,$fffffffc
	CHRD7	$dfffffff,$dfffffff,$fffffffc,$fffffffc
	CHRD8	$dfffffff,$dfffffff,$fffffffc,$fffffffc
.if 0
*		  78	    79	      7A	7B
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000000,$00000000,$00000000,$00000000
	CHRD3	$00000000,$00000000,$00000000,$00000000
	CHRD4	$00000000,$00000000,$00000000,$00000000
	CHRD5	$00000000,$00000000,$00000000,$00000000
	CHRD6	$00000000,$00000000,$00000000,$00000000
	CHRD7	$67777788,$88899999,$aaaaabbb,$bbcccccd
	CHRD8	$00000000,$00000000,$00000000,$00000000
*		  7C	    7D	      7E	7F
	CHRD1	$00000000,$00000000,$00000000,$00000000
	CHRD2	$00000000,$00000000,$00000000,$00000000
	CHRD3	$00000000,$00000000,$00000000,$00000000
	CHRD4	$00000000,$00000000,$00000000,$00000000
	CHRD5	$00000000,$00000000,$00000000,$00000000
	CHRD6	$00000000,$00000000,$00000000,$00000000
	CHRD7	$ddddeeee,$efffff00,$00000000,$00000000
	CHRD8	$00000000,$00000000,$00000000,$00000000
.endif

SPDATA_END:

		.end

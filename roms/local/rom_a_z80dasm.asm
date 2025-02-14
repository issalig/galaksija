; z80dasm 1.1.6
; command line: z80dasm -l -g 0x0000 -a ./local/rom_a.bin

	org	00000h

l0000h:
	di			;0000
	sub a			;0001
	jp l03dah		;0002
sub_0005h:
	rst 18h			;0005
	inc l			;0006
	inc l			;0007
	call sub_0ab2h		;0008
	jp l0a6dh		;000b
	di			;000e
	ret			;000f
l0010h:
	ld a,h			;0010
	cp d			;0011
	ret nz			;0012
	ld a,l			;0013
	cp e			;0014
	ret			;0015
	ei			;0016
	ret			;0017
l0018h:
	ex (sp),hl			;0018
	call sub_0105h		;0019
	cp (hl)			;001c
	jp l0194h		;001d
l0020h:
	exx			;0020
	cp 020h		;0021
	call sub_09b5h		;0023
	exx			;0026
	ret			;0027
	ld hl,l0000h		;0028
	ret			;002b
l002ch:
	call z,0cccch		;002c
	ld a,(hl)			;002f
	pop af			;0030
	call sub_0414h		;0031
	jp 0078fh		;0034
	inc e			;0037
	push af			;0038
	push bc			;0039
	push de			;003a
	push hl			;003b
	ld hl,02bb0h		;003c
	ld a,0c0h		;003f
	sub (hl)			;0041
	sub (hl)			;0042
	sub (hl)			;0043
	ld e,a			;0044
	ld a,(hl)			;0045
	rrca			;0046
	rrca			;0047
	rrca			;0048
	ld b,a			;0049
	or a			;004a
	jr z,l004dh		;004b
l004dh:
	jr z,l0054h		;004d
	dec (hl)			;004f
	xor a			;0050
l0051h:
	ret c			;0051
	djnz l0051h		;0052
l0054h:
	inc hl			;0054
	ld (hl),a			;0055
	ld b,e			;0056
	ld hl,0207fh		;0057
	ld c,l			;005a
	ld a,(02ba8h)		;005b
	rra			;005e
	jr c,l0061h		;005f
l0061h:
	dec a			;0061
	jr nz,l0061h		;0062
	jr l006dh		;0064
	di			;0066
l0067h:
	ld sp,02ba8h		;0067
	jp l0317h		;006a
l006dh:
	inc c			;006d
	ld a,c			;006e
	and 008h		;006f
	rrca			;0071
	rrca			;0072
	rrca			;0073
	or 028h		;0074
	ld i,a		;0076
	inc de			;0078
	ld de,l080ch		;0079
	ld a,c			;007c
	rrca			;007d
	rrca			;007e
	rrca			;007f
	ccf			;0080
	rr d		;0081
	or 01fh		;0083
	rlca			;0085
	sub 040h		;0086
	rrca			;0088
	ld r,a		;0089
l008bh:
	ld (hl),d			;008b
	inc d			;008c
	inc d			;008d
	inc d			;008e
	inc d			;008f
	xor a			;0090
	scf			;0091
	rra			;0092
	rra			;0093
	xor d			;0094
	ld d,a			;0095
	ld h,c			;0096
	ld a,b			;0097
l0098h:
	ld b,d			;0098
	ld d,d			;0099
	ld b,l			;009a
	ld b,c			;009b
	ld c,e			;009c
	nop			;009d
	ld b,a			;009e
	ld c,h			;009f
l00a0h:
	nop			;00a0
	nop			;00a1
	add a,b			;00a2
	nop			;00a3
	xor a			;00a4
	scf			;00a5
	rra			;00a6
	rra			;00a7
	rra			;00a8
	ld h,a			;00a9
	rla			;00aa
	ld (hl),a			;00ab
	dec b			;00ac
	jr z,l00beh		;00ad
	ld a,r		;00af
	sub 027h		;00b1
	and l			;00b3
	ld r,a		;00b4
	dec e			;00b6
	jp nz,l008bh		;00b7
	ld a,003h		;00ba
	jr l0061h		;00bc
l00beh:
	ld (hl),0bch		;00be
	ld a,(02a82h)		;00c0
	cp 03ah		;00c3
	jr nz,l00fbh		;00c5
	ld a,(02bafh)		;00c7
	rlca			;00ca
	jr nc,l00fbh		;00cb
	ld hl,02a8ah		;00cd
	ld de,03930h		;00d0
	ld b,008h		;00d3
	ld a,d			;00d5
	inc (hl)			;00d6
	inc (hl)			;00d7
	cp (hl)			;00d8
	jr l00dfh		;00d9
l00dbh:
	inc (hl)			;00db
	cp (hl)			;00dc
	ld a,035h		;00dd
l00dfh:
	jr nc,l00ebh		;00df
	ld (hl),e			;00e1
	dec hl			;00e2
	bit 0,b		;00e3
	jr z,l00e9h		;00e5
	dec hl			;00e7
	ld a,d			;00e8
l00e9h:
	djnz l00dbh		;00e9
l00ebh:
	dec b			;00eb
	djnz l00fbh		;00ec
	ld a,(hl)			;00ee
	cp 034h		;00ef
	jr c,l00fbh		;00f1
	dec hl			;00f3
	bit 1,(hl)		;00f4
	jr z,l00fbh		;00f6
	ld (hl),e			;00f8
	inc hl			;00f9
	ld (hl),e			;00fa
l00fbh:
	jp (iy)		;00fb
l00fdh:
	pop hl			;00fd
	pop de			;00fe
	pop bc			;00ff
	pop af			;0100
	ei			;0101
	reti		;0102
l0104h:
	inc de			;0104
sub_0105h:
	ld a,(de)			;0105
	cp 020h		;0106
	jr z,l0104h		;0108
	ret			;010a
	inc hl			;010b
	xor a			;010c
	call sub_0df3h		;010d
	ld (02a99h),hl		;0110
	rst 30h			;0113
sub_0114h:
	rst 8			;0114
	inc hl			;0115
	xor a			;0116
	call sub_0df3h		;0117
	push de			;011a
	ld de,(02a99h)		;011b
	inc de			;011f
	rst 10h			;0120
	jr nc,l0154h		;0121
	jr l0146h		;0123
sub_0125h:
	call sub_0105h		;0125
	sub 041h		;0128
	ret c			;012a
	cp 01ah		;012b
	ccf			;012d
	ret c			;012e
	inc de			;012f
	and a			;0130
	jr nz,l015eh		;0131
	rst 18h			;0133
	jr z,l015dh		;0134
	rst 8			;0136
	inc hl			;0137
	add hl,hl			;0138
	add hl,hl			;0139
	push de			;013a
	jr c,l0154h		;013b
	ld de,(02a99h)		;013d
	add hl,de			;0141
	pop de			;0142
	push de			;0143
	jr c,$+15		;0144
l0146h:
	pop de			;0146
	rst 18h			;0147
	add hl,hl			;0148
	add hl,bc			;0149
	push de			;014a
	ex de,hl			;014b
	call sub_0183h		;014c
	rst 10h			;014f
	jr nc,l0188h		;0150
	ld a,0d5h		;0152
l0154h:
	call sub_0799h		;0154
	ld d,e			;0157
	ld c,a			;0158
	ld d,d			;0159
	ld d,d			;015a
	ld e,c			;015b
	dec c			;015c
l015dh:
	xor a			;015d
l015eh:
	ld h,02ah		;015e
	rla			;0160
	rla			;0161
	ld l,a			;0162
	xor a			;0163
	ret			;0164
sub_0165h:
	call sub_0172h		;0165
	ret nc			;0168
	cp 041h		;0169
	ret c			;016b
	add a,009h		;016c
	cp 050h		;016e
	jr l0178h		;0170
sub_0172h:
	ld a,(de)			;0172
	cp 030h		;0173
	ret c			;0175
	cp 03ah		;0176
l0178h:
	ccf			;0178
	ret c			;0179
	inc de			;017a
l017bh:
	and 00fh		;017b
	ret			;017d
sub_017eh:
	ld (hl),a			;017e
sub_017fh:
	inc hl			;017f
	ld a,l			;0180
	jr l017bh		;0181
sub_0183h:
	push de			;0183
	ld de,(02c38h)		;0184
l0188h:
	ld hl,(02a6ah)		;0188
	ld a,l			;018b
	and 0f0h		;018c
	ld l,a			;018e
	sbc hl,de		;018f
	pop de			;0191
	xor a			;0192
	ret			;0193
l0194h:
	inc hl			;0194
	jr z,l019eh		;0195
	push bc			;0197
	ld c,(hl)			;0198
	ld b,000h		;0199
	add hl,bc			;019b
	pop bc			;019c
	dec de			;019d
l019eh:
	inc de			;019e
	inc hl			;019f
	ex (sp),hl			;01a0
	ret			;01a1
sub_01a2h:
	call sub_0248h		;01a2
	ld b,000h		;01a5
	ld c,b			;01a7
	call sub_0105h		;01a8
l01abh:
	call sub_01b0h		;01ab
	jr l01abh		;01ae
sub_01b0h:
	call sub_0172h		;01b0
	jr c,l01d5h		;01b3
	set 6,b		;01b5
	bit 7,b		;01b7
	jr nz,l01d0h		;01b9
	call sub_01c3h		;01bb
	bit 0,b		;01be
	ret z			;01c0
	dec c			;01c1
	ret			;01c2
sub_01c3h:
	call sub_024fh		;01c3
	ret z			;01c6
	exx			;01c7
	ld h,d			;01c8
	ld l,e			;01c9
	ex af,af'			;01ca
	ld c,a			;01cb
	exx			;01cc
	set 7,b		;01cd
	pop af			;01cf
l01d0h:
	bit 0,b		;01d0
	ret nz			;01d2
	inc c			;01d3
	ret			;01d4
l01d5h:
	rst 18h			;01d5
	ld l,005h		;01d6
	bit 0,b		;01d8
	set 0,b		;01da
	ret z			;01dc
	pop af			;01dd
	bit 6,b		;01de
l01e0h:
	ret z			;01e0
	ld hl,l0018h		;01e1
	push bc			;01e4
	push de			;01e5
	exx			;01e6
	call sub_0914h		;01e7
	pop de			;01ea
	ld bc,l01f3h		;01eb
	push bc			;01ee
	push de			;01ef
	jp l0b6dh		;01f0
l01f3h:
	pop bc			;01f3
	push de			;01f4
	rst 18h			;01f5
	ld b,l			;01f6
	dec de			;01f7
	rst 18h			;01f8
	dec hl			;01f9
	ld (bc),a			;01fa
	jr l0202h		;01fb
	rst 18h			;01fd
	dec l			;01fe
	ld (bc),a			;01ff
	set 1,b		;0200
l0202h:
	call sub_024ah		;0202
l0205h:
	call sub_0172h		;0205
	jr c,l0217h		;0208
	set 5,b		;020a
	call sub_024fh		;020c
	jr nz,l0225h		;020f
	jr l0205h		;0211
l0213h:
	pop de			;0213
	xor a			;0214
	jr l022eh		;0215
l0217h:
	bit 5,b		;0217
	jr z,l0213h		;0219
	pop af			;021b
	exx			;021c
	ld a,c			;021d
	or h			;021e
	ld a,l			;021f
	exx			;0220
	jr nz,l0225h		;0221
	bit 7,a		;0223
l0225h:
	jp nz,0065ah		;0225
	bit 1,b		;0228
	jr z,l022eh		;022a
	neg		;022c
l022eh:
	add a,c			;022e
l022fh:
	and a			;022f
	jr z,l0245h		;0230
	bit 7,a		;0232
	jr z,l023dh		;0234
	inc a			;0236
	push af			;0237
	call sub_0af4h		;0238
	jr l0242h		;023b
l023dh:
	dec a			;023d
	push af			;023e
	call sub_0ae3h		;023f
l0242h:
	pop af			;0242
	jr l022fh		;0243
l0245h:
	bit 6,b		;0245
	ret			;0247
sub_0248h:
	res 6,b		;0248
sub_024ah:
	exx			;024a
	rst 28h			;024b
	ld c,l			;024c
	exx			;024d
	ret			;024e
sub_024fh:
	ex af,af'			;024f
	exx			;0250
	ld d,h			;0251
	ld e,l			;0252
	ld a,c			;0253
	ld b,000h		;0254
	push af			;0256
	add hl,hl			;0257
	rl c		;0258
	rl b		;025a
	add hl,hl			;025c
	rl c		;025d
	rl b		;025f
	add hl,de			;0261
	adc a,c			;0262
	ld c,a			;0263
	ld a,000h		;0264
	adc a,b			;0266
	ld b,a			;0267
	pop af			;0268
	push de			;0269
	ld d,000h		;026a
	add hl,hl			;026c
	rl c		;026d
	rl b		;026f
	ex af,af'			;0271
	ld e,a			;0272
	add hl,de			;0273
	ld a,d			;0274
	adc a,c			;0275
	ld c,a			;0276
	ld a,d			;0277
	adc a,b			;0278
	ld b,a			;0279
	pop de			;027a
	exx			;027b
	ret			;027c
l027dh:
	ld e,l			;027d
	ld d,h			;027e
l027fh:
	inc de			;027f
	ld a,(de)			;0280
	dec de			;0281
	ld (de),a			;0282
	inc de			;0283
	cp 00dh		;0284
	jr nz,l027fh		;0286
	jr l02afh		;0288
l028ah:
	ld a,l			;028a
	cp 0b6h		;028b
	jr z,l02afh		;028d
	dec hl			;028f
	jr l02afh		;0290
l0292h:
	ld a,(hl)			;0292
	cp 00dh		;0293
	jr z,l02afh		;0295
	jr l02eah		;0297
	call sub_0cd3h		;0299
	call sub_07f2h		;029c
	jp c,0065ah		;029f
	ld a,00ch		;02a2
	rst 20h			;02a4
	ld hl,02bb6h		;02a5
	ld (02a68h),hl		;02a8
	call sub_0931h		;02ab
	exx			;02ae
l02afh:
	ld de,02800h		;02af
	ld (02a68h),de		;02b2
	ld de,02bb6h		;02b6
	ld c,(hl)			;02b9
	ld (hl),000h		;02ba
	call sub_0937h		;02bc
	ld a,05fh		;02bf
	call sub_07b6h		;02c1
	call sub_0cf5h		;02c4
	cp 00dh		;02c7
	jr z,l033ch		;02c9
	or a			;02cb
	jr z,l027dh		;02cc
	cp 01dh		;02ce
	jr z,l028ah		;02d0
	cp 01eh		;02d2
	jr z,l0292h		;02d4
	jr c,l02afh		;02d6
	ld b,a			;02d8
	push hl			;02d9
	ld hl,02c34h		;02da
	rst 10h			;02dd
	pop hl			;02de
	jr c,l02afh		;02df
l02e1h:
	dec de			;02e1
	ld a,(de)			;02e2
	inc de			;02e3
	ld (de),a			;02e4
	dec de			;02e5
	rst 10h			;02e6
	jr nz,l02e1h		;02e7
	ld (hl),b			;02e9
l02eah:
	inc hl			;02ea
	jr l02afh		;02eb
sub_02edh:
	ld a,(02a68h)		;02ed
	and 01fh		;02f0
	ld a,00dh		;02f2
	ld (02bb5h),a		;02f4
	ret z			;02f7
	rst 20h			;02f8
	ret			;02f9
l02fah:
	ld a,(02033h)		;02fa
	rrca			;02fd
	ret c			;02fe
sub_02ffh:
	ld a,(02031h)		;02ff
	rrca			;0302
	jr c,l02fah		;0303
l0305h:
	call sub_02edh		;0305
	ld de,l0098h		;0308
	call sub_0937h		;030b
	ld de,(02a9fh)		;030e
	ld a,d			;0312
	or e			;0313
	call nz,sub_08edh		;0314
l0317h:
	ei			;0317
	call sub_02edh		;0318
	ld de,l0f07h		;031b
	call sub_0937h		;031e
l0321h:
	rst 28h			;0321
	ld de,03031h		;0322
	ld sp,02aa7h		;0325
	push de			;0328
	push hl			;0329
	push hl			;032a
	push hl			;032b
	ld hl,(02c36h)		;032c
	inc hl			;032f
	inc hl			;0330
	push hl			;0331
	ld sp,02ba8h		;0332
	ld ix,02aach		;0335
	call sub_07bbh		;0339
l033ch:
	push de			;033c
	ld de,02bb6h		;033d
	call sub_0cd3h		;0340
	pop bc			;0343
	jp z,l038ch		;0344
	dec de			;0347
	ld a,h			;0348
	ld (de),a			;0349
	dec de			;034a
	ld a,l			;034b
	ld (de),a			;034c
	push bc			;034d
	push de			;034e
	ld a,c			;034f
	sub e			;0350
	push af			;0351
	call sub_07f2h		;0352
	push de			;0355
	jr nz,l0368h		;0356
	push de			;0358
	call sub_0811h		;0359
	pop bc			;035c
	ld hl,(02c38h)		;035d
	call sub_0944h		;0360
	ld h,b			;0363
	ld l,c			;0364
	ld (02c38h),hl		;0365
l0368h:
	pop bc			;0368
	ld hl,(02c38h)		;0369
	pop af			;036c
	push hl			;036d
	cp 003h		;036e
	jr z,l0321h		;0370
	ld e,a			;0372
	ld d,000h		;0373
	add hl,de			;0375
	ld de,(02a6ah)		;0376
	rst 10h			;037a
	jp nc,00153h		;037b
	ld (02c38h),hl		;037e
	pop de			;0381
	call sub_094ch		;0382
	pop de			;0385
	pop hl			;0386
	call sub_0944h		;0387
	jr l0321h		;038a
l038ch:
	ld hl,l0317h		;038c
	push hl			;038f
	ld l,00eh		;0390
	ld bc,09b2eh		;0392
	ld bc,0ee2eh		;0395
l0398h:
	ld h,00fh		;0398
l039ah:
	call sub_0105h		;039a
	push de			;039d
	inc de			;039e
	inc hl			;039f
	cp (hl)			;03a0
	jr z,l03a9h		;03a1
	bit 7,(hl)		;03a3
	jr nz,l03b3h		;03a5
	jr l03bah		;03a7
l03a9h:
	ld a,(de)			;03a9
	inc de			;03aa
	inc hl			;03ab
	cp (hl)			;03ac
	jr z,l03a9h		;03ad
	bit 7,(hl)		;03af
	jr z,l03b6h		;03b1
l03b3h:
	dec de			;03b3
	jr l03c8h		;03b4
l03b6h:
	cp 02eh		;03b6
	jr z,l03c3h		;03b8
l03bah:
	inc hl			;03ba
	bit 7,(hl)		;03bb
	jr z,l03bah		;03bd
	inc hl			;03bf
	pop de			;03c0
	jr l039ah		;03c1
l03c3h:
	inc hl			;03c3
	bit 7,(hl)		;03c4
	jr z,l03c3h		;03c6
l03c8h:
	ld a,(hl)			;03c8
	inc hl			;03c9
	ld l,(hl)			;03ca
	and 07fh		;03cb
	ld h,a			;03cd
	pop af			;03ce
	bit 6,h		;03cf
	res 6,h		;03d1
	push hl			;03d3
	call nz,sub_0a6ah		;03d4
	jp 02ba9h		;03d7
l03dah:
	im 1		;03da
	ld iy,l00fdh		;03dc
	ld hl,027ffh		;03e0
	ld (hl),l			;03e3
	ld b,l			;03e4
l03e5h:
	inc hl			;03e5
	ld (hl),b			;03e6
	inc (hl)			;03e7
	jr nz,l03edh		;03e8
	or (hl)			;03ea
	jr z,l03e5h		;03eb
l03edh:
	ld (02a6ah),hl		;03ed
	ld sp,02badh		;03f0
	ld hl,0c90bh		;03f3
	push hl			;03f6
	dec sp			;03f7
	push hl			;03f8
	ld a,00ch		;03f9
	rst 20h			;03fb
	call sub_0cd3h		;03fc
	ld de,02c3ah		;03ff
	add hl,de			;0402
	ld sp,02c3ah		;0403
	push hl			;0406
	push hl			;0407
l0408h:
	jp l0067h		;0408
	call sub_0cd3h		;040b
	ld de,(02c36h)		;040e
l0412h:
	jr l0422h		;0412
sub_0414h:
	ld (02bb5h),a		;0414
	rst 18h			;0417
	ld a,(0f103h)		;0418
	jr l042dh		;041b
	rst 18h			;041d
	dec c			;041e
	jr nz,l0412h		;041f
l0421h:
	rst 28h			;0421
l0422h:
	call sub_07f6h		;0422
	jr c,l0408h		;0425
l0427h:
	ld (02a9fh),de		;0427
	inc de			;042b
	inc de			;042c
l042dh:
	call sub_02ffh		;042d
	ld ix,02aach		;0430
	ld l,02fh		;0434
	jp l0398h		;0436
sub_0439h:
	call sub_068eh		;0439
	call sub_0b10h		;043c
	rst 28h			;043f
	ret			;0440
	rst 8			;0441
	ld a,h			;0442
	or l			;0443
	jr nz,l042dh		;0444
	call sub_081ch		;0446
l0449h:
	jr nc,l0427h		;0449
	jr l0408h		;044b
	rst 28h			;044d
	call sub_0813h		;044e
	jr l0449h		;0451
	rst 8			;0453
	push de			;0454
	call sub_07f2h		;0455
	jp nz,l065bh		;0458
l045bh:
	pop af			;045b
	jr l0427h		;045c
	call sub_0cd3h		;045e
l0461h:
	call sub_02edh		;0461
	call sub_07f2h		;0464
l0467h:
	jr c,l0408h		;0467
l0469h:
	call sub_0931h		;0469
	call sub_07f6h		;046c
	jr c,l0467h		;046f
l0471h:
	call sub_02ffh		;0471
	ld a,(02030h)		;0474
	ld hl,02034h		;0477
	and (hl)			;047a
	rrca			;047b
	jr nc,l0469h		;047c
	jr l0471h		;047e
	rst 18h			;0480
	ld a,(03e05h)		;0481
	dec c			;0484
	rst 20h			;0485
	jr l042dh		;0486
	rst 18h			;0488
	dec c			;0489
	ld b,(hl)			;048a
	rst 20h			;048b
l048ch:
	jr l0421h		;048c
	rst 18h			;048e
	ld (0cd54h),hl		;048f
	jr c,l049dh		;0492
	jr nz,l048ch		;0494
	jr l04adh		;0496
	ld l,05ch		;0498
	ld bc,0602eh		;049a
l049dh:
	ld h,02ah		;049d
	call sub_060eh		;049f
l04a2h:
	ld a,(hl)			;04a2
	inc hl			;04a3
	or a			;04a4
	jr z,l04adh		;04a5
	rst 20h			;04a7
	ld a,l			;04a8
	and 00fh		;04a9
	jr nz,l04a2h		;04ab
l04adh:
	rst 18h			;04ad
	inc l			;04ae
	dec de			;04af
l04b0h:
	ld a,(02a68h)		;04b0
	and 007h		;04b3
	jr z,l04ceh		;04b5
	ld a,020h		;04b7
	rst 20h			;04b9
	jr l04b0h		;04ba
	rst 8			;04bc
	ld a,h			;04bd
	or 028h		;04be
	and 029h		;04c0
	ld h,a			;04c2
	ld (02a68h),hl		;04c3
	rst 18h			;04c6
	inc l			;04c7
	ld (bc),a			;04c8
	jr l04ceh		;04c9
	rst 18h			;04cb
	dec sp			;04cc
	inc de			;04cd
l04ceh:
	call sub_0414h		;04ce
	ld l,0e0h		;04d1
	jp l0398h		;04d3
	call sub_0cd3h		;04d6
	ld (02a6ch),hl		;04d9
	jr nz,l04e4h		;04dc
	ld a,00ch		;04de
	ld bc,l0d3eh		;04e0
	rst 20h			;04e3
l04e4h:
	rst 30h			;04e4
	call 00396h		;04e5
	jr nz,$+9		;04e8
	call sub_0ab2h		;04ea
	call sub_08f6h		;04ed
	ld a,0e7h		;04f0
	jr l04adh		;04f2
	call sub_0974h		;04f4
	rst 8			;04f7
	push de			;04f8
	call sub_07f2h		;04f9
	jp nz,l065bh		;04fc
	ld hl,(02a9fh)		;04ff
	push hl			;0502
	ld hl,(02aa3h)		;0503
	push hl			;0506
	rst 28h			;0507
	ld (02aa1h),hl		;0508
	add hl,sp			;050b
	ld (02aa3h),hl		;050c
	jp l0427h		;050f
	ld hl,(02aa3h)		;0512
	ld a,h			;0515
	or l			;0516
	jp z,0065ah		;0517
	ld sp,hl			;051a
	pop hl			;051b
	ld (02aa3h),hl		;051c
	pop hl			;051f
	ld (02a9fh),hl		;0520
	pop de			;0523
l0524h:
	call sub_0959h		;0524
	rst 30h			;0527
	rst 8			;0528
	ld bc,023efh		;0529
	ld (02a91h),hl		;052c
	ld hl,(02a9fh)		;052f
	ld (02a93h),hl		;0532
	ex de,hl			;0535
	ld (02a95h),hl		;0536
	ld bc,0000ah		;0539
	ld hl,(02aa1h)		;053c
	ex de,hl			;053f
	rst 28h			;0540
	add hl,sp			;0541
	ld a,009h		;0542
	ld a,(hl)			;0544
	inc hl			;0545
	or (hl)			;0546
	jr z,l055fh		;0547
	ld a,(hl)			;0549
	dec hl			;054a
	cp d			;054b
	jr nz,$-9		;054c
	ld a,(hl)			;054e
	cp e			;054f
	jr nz,$-13		;0550
	ex de,hl			;0552
	rst 28h			;0553
	add hl,sp			;0554
	ld b,h			;0555
	ld c,l			;0556
	ld hl,0000ah		;0557
	add hl,de			;055a
	call sub_094ch		;055b
	ld sp,hl			;055e
l055fh:
	ld hl,(02a95h)		;055f
	ex de,hl			;0562
	rst 30h			;0563
	call 0078bh		;0564
	ld (02a9bh),hl		;0567
l056ah:
	push de			;056a
	ex de,hl			;056b
	ld hl,(02aa1h)		;056c
	ld a,h			;056f
	or l			;0570
	jp z,l065bh		;0571
	rst 10h			;0574
	jr z,l0580h		;0575
	pop de			;0577
	call sub_0959h		;0578
	ld hl,(02a9bh)		;057b
	jr l056ah		;057e
l0580h:
	call sub_0a45h		;0580
	call l0a6dh		;0583
	ex de,hl			;0586
	ld hl,(02a91h)		;0587
	push hl			;058a
	add hl,de			;058b
	push hl			;058c
	call sub_0abch		;058d
	ld hl,(02aa1h)		;0590
	call sub_073bh		;0593
	pop de			;0596
	ld hl,(02a6eh)		;0597
	pop af			;059a
	rlca			;059b
	jr nc,l059fh		;059c
	ex de,hl			;059e
l059fh:
	ld a,h			;059f
	xor d			;05a0
	jp p,l05a5h		;05a1
	ex de,hl			;05a4
l05a5h:
	rst 10h			;05a5
	pop de			;05a6
	jp c,l0524h		;05a7
	ld hl,(02a93h)		;05aa
	ld (02a9fh),hl		;05ad
	jr l055fh		;05b0
sub_05b2h:
	jp z,l0736h		;05b2
l05b5h:
	push hl			;05b5
	call sub_05fch		;05b6
	jr c,l05cah		;05b9
	jr z,l05e2h		;05bb
	ex (sp),hl			;05bd
	pop bc			;05be
l05bfh:
	ld a,(bc)			;05bf
	or a			;05c0
	jr z,l05edh		;05c1
	inc bc			;05c3
	call sub_017eh		;05c4
	jr nz,l05bfh		;05c7
	ret			;05c9
l05cah:
	pop hl			;05ca
	rst 18h			;05cb
	ld (0cd00h),hl		;05cc
	exx			;05cf
	dec b			;05d0
	jr z,l05edh		;05d1
	inc de			;05d3
	call sub_017eh		;05d4
	jr nz,$-9		;05d7
	ld a,(de)			;05d9
	cp 00dh		;05da
	ret z			;05dc
	cp 022h		;05dd
	ret nz			;05df
	inc de			;05e0
	ret			;05e1
l05e2h:
	dec de			;05e2
	call 00396h		;05e3
	jr z,l05cah		;05e6
	pop hl			;05e8
	call sub_017eh		;05e9
	ret z			;05ec
l05edh:
	rst 18h			;05ed
	dec hl			;05ee
	ld (bc),a			;05ef
	jr l05b5h		;05f0
	ld (hl),000h		;05f2
l05f4h:
	call sub_017fh		;05f4
	ret z			;05f7
	ld (hl),030h		;05f8
	jr l05f4h		;05fa
sub_05fch:
	call sub_0125h		;05fc
	ret c			;05ff
l0600h:
	dec de			;0600
	ld a,(de)			;0601
	inc de			;0602
	cp 029h		;0603
	ret z			;0605
	ld a,(de)			;0606
	cp 024h		;0607
	jr z,l060dh		;0609
	xor a			;060b
	ret			;060c
l060dh:
	inc de			;060d
sub_060eh:
	ld a,l			;060e
	sub 05ch		;060f
	jr nz,l061dh		;0611
	ld l,070h		;0613
	rst 18h			;0615
	jr z,l061bh		;0616
	call sub_0114h		;0618
l061bh:
	or h			;061b
	ret			;061c
l061dh:
	cp 007h		;061d
	jp nc,0078fh		;061f
	ld l,080h		;0622
	or h			;0624
	ret			;0625
l0626h:
	call sub_05fch		;0626
	jr c,l0663h		;0629
	push de			;062b
	push af			;062c
	push hl			;062d
	ld de,(02a9dh)		;062e
	ld hl,(02c38h)		;0632
l0635h:
	rst 18h			;0635
	inc hl			;0636
	ld (bc),a			;0637
	jr l063dh		;0638
	rst 18h			;063a
	inc l			;063b
	rrca			;063c
l063dh:
	pop hl			;063d
	pop af			;063e
	call sub_05b2h		;063f
l0642h:
	ld (02a9dh),de		;0642
	pop de			;0646
	rst 18h			;0647
	inc l			;0648
	ld b,e			;0649
	jr l0626h		;064a
l064ch:
	ld a,(de)			;064c
	inc de			;064d
	cp 00dh		;064e
	jr nz,l064ch		;0650
	inc de			;0652
	inc de			;0653
	rst 10h			;0654
	jr nc,l0635h		;0655
	pop hl			;0657
l0658h:
	pop af			;0658
	ld c,0d5h		;0659
l065bh:
	call sub_0799h		;065b
	ld c,b			;065e
	ld c,a			;065f
	ld d,a			;0660
	ccf			;0661
	dec c			;0662
l0663h:
	rst 8			;0663
	push de			;0664
	call sub_07f2h		;0665
	inc de			;0668
	inc de			;0669
	jr l0642h		;066a
	push de			;066c
	ld a,03fh		;066d
	call sub_07bdh		;066f
	ld de,02bb6h		;0672
	rst 18h			;0675
	dec c			;0676
	dec b			;0677
	pop de			;0678
	call sub_05fch		;0679
	rst 30h			;067c
	pop de			;067d
	push de			;067e
	call sub_05fch		;067f
	jr c,l065bh		;0682
	push de			;0684
	ld de,02bb6h		;0685
	call sub_05b2h		;0688
	pop de			;068b
	pop af			;068c
	rst 30h			;068d
sub_068eh:
	rst 18h			;068e
	dec l			;068f
	ld b,0efh		;0690
	call sub_0abch		;0692
	jr l06abh		;0695
	rst 18h			;0697
	dec hl			;0698
	nop			;0699
	call sub_06b3h		;069a
l069dh:
	rst 18h			;069d
	dec hl			;069e
	ex af,af'			;069f
	call sub_06b3h		;06a0
	call sub_0b32h		;06a3
	jr l069dh		;06a6
	rst 18h			;06a8
	dec l			;06a9
	rst 18h			;06aa
l06abh:
	call sub_06b3h		;06ab
	call sub_0b1eh		;06ae
	jr l069dh		;06b1
sub_06b3h:
	call 00393h		;06b3
l06b6h:
	rst 18h			;06b6
	ld hl,(0cd08h)		;06b7
	sub e			;06ba
	inc bc			;06bb
	call sub_0ae6h		;06bc
	jr l06b6h		;06bf
	rst 18h			;06c1
	cpl			;06c2
	add a,0cdh		;06c3
	sub e			;06c5
	inc bc			;06c6
	call sub_0af7h		;06c7
	jr l06b6h		;06ca
	ld a,001h		;06cc
	ld bc,0803eh		;06ce
	push af			;06d1
	rst 18h			;06d2
	ld hl,(0f105h)		;06d3
	ld (02bafh),a		;06d6
	rst 30h			;06d9
	pop af			;06da
	ld b,0afh		;06db
	and a			;06dd
	push af			;06de
	rst 8			;06df
	push hl			;06e0
	call sub_0005h		;06e1
	push de			;06e4
	ex de,hl			;06e5
	ld bc,l0020h		;06e6
	inc e			;06e9
	ld hl,02800h		;06ea
l06edh:
	ld d,003h		;06ed
	ld a,001h		;06ef
l06f1h:
	dec e			;06f1
	jr z,l06feh		;06f2
	rlca			;06f4
	rlca			;06f5
	dec d			;06f6
	jr nz,l06f1h		;06f7
	add hl,bc			;06f9
	res 1,h		;06fa
	jr l06edh		;06fc
l06feh:
	ld b,a			;06fe
	pop de			;06ff
	ex (sp),hl			;0700
	res 7,l		;0701
	res 6,l		;0703
	srl l		;0705
	jr nc,l070ah		;0707
	rlca			;0709
l070ah:
	ld h,000h		;070a
	pop bc			;070c
	add hl,bc			;070d
	ld b,a			;070e
	pop af			;070f
	ld a,b			;0710
	jr nz,l071fh		;0711
	bit 7,(hl)		;0713
	jr z,l0718h		;0715
	and (hl)			;0717
l0718h:
	rst 28h			;0718
	jr z,l071ch		;0719
	inc hl			;071b
l071ch:
	jp sub_0abch		;071c
l071fh:
	push af			;071f
	bit 7,(hl)		;0720
	jr nz,l0726h		;0722
	ld (hl),080h		;0724
l0726h:
	pop af			;0726
	jp m,0072dh		;0727
	cpl			;072a
	and (hl)			;072b
	ld b,0b6h		;072c
	ld (hl),a			;072e
	rst 30h			;072f
sub_0730h:
	call 0078bh		;0730
	rst 18h			;0733
	dec a			;0734
	ld e,c			;0735
l0736h:
	push hl			;0736
	call sub_0ab2h		;0737
	pop hl			;073a
sub_073bh:
	call sub_090eh		;073b
	ld bc,00004h		;073e
	push de			;0741
	push hl			;0742
	ex de,hl			;0743
	push ix		;0744
	pop hl			;0746
	ldir		;0747
	ex de,hl			;0749
	dec hl			;074a
	dec hl			;074b
	rl (hl)		;074c
	inc hl			;074e
	ld a,(ix+004h)		;074f
	rla			;0752
	rr (hl)		;0753
	dec hl			;0755
	rr (hl)		;0756
	pop hl			;0758
	pop de			;0759
	ret			;075a
	call sub_05fch		;075b
	jr c,l0768h		;075e
	push af			;0760
	rst 18h			;0761
	dec a			;0762
	dec hl			;0763
	pop af			;0764
	call sub_05b2h		;0765
l0768h:
	rst 30h			;0768
	ld h,d			;0769
	ld l,e			;076a
	call sub_05fch		;076b
	jr l071ch		;076e
	push de			;0770
	ex de,hl			;0771
	call sub_0ab2h		;0772
	pop de			;0775
	ret			;0776
	call sub_0125h		;0777
	jp nc,sub_0a45h		;077a
	call sub_01a2h		;077d
	ret nz			;0780
sub_0781h:
	rst 18h			;0781
	jr z,$+13		;0782
	call sub_0ab2h		;0784
	rst 18h			;0787
	add hl,hl			;0788
	ld bc,0cdc9h		;0789
	dec h			;078c
	ld bc,0d5d0h		;078d
	call sub_0799h		;0790
	ld d,a			;0793
	ld c,b			;0794
	ld b,c			;0795
	ld d,h			;0796
	ccf			;0797
	dec c			;0798
sub_0799h:
	pop de			;0799
	call sub_0937h		;079a
	ld de,(02a9fh)		;079d
	ld a,e			;07a1
	or d			;07a2
	ld hl,l0317h		;07a3
	ex (sp),hl			;07a6
	ret z			;07a7
	rst 10h			;07a8
	ret c			;07a9
	ld c,(hl)			;07aa
	push bc			;07ab
	ld (hl),000h		;07ac
	push hl			;07ae
	call sub_0931h		;07af
	pop hl			;07b2
	pop bc			;07b3
	ld a,03fh		;07b4
sub_07b6h:
	dec de			;07b6
	ld (hl),c			;07b7
	jp l0936h		;07b8
sub_07bbh:
	ld a,03eh		;07bb
sub_07bdh:
	ld de,02bb6h		;07bd
	rst 20h			;07c0
l07c1h:
	exx			;07c1
	ld (hl),05fh		;07c2
	exx			;07c4
l07c5h:
	call sub_0cf5h		;07c5
	rst 20h			;07c8
	exx			;07c9
	ld (hl),05fh		;07ca
	exx			;07cc
	cp 00dh		;07cd
	jr z,l07ddh		;07cf
	cp 01dh		;07d1
	jr z,l07eah		;07d3
	cp 00ch		;07d5
	jr z,sub_07bbh		;07d7
	cp 020h		;07d9
	jr c,l07c5h		;07db
l07ddh:
	ld (de),a			;07dd
	inc de			;07de
	cp 00dh		;07df
	ret z			;07e1
	ld a,e			;07e2
	cp 034h		;07e3
	jr nz,l07c5h		;07e5
	ld a,01dh		;07e7
	rst 20h			;07e9
l07eah:
	ld a,e			;07ea
	cp 0b6h		;07eb
	jr z,sub_07bbh		;07ed
	dec de			;07ef
	jr l07c1h		;07f0
sub_07f2h:
	ld de,(02c36h)		;07f2
sub_07f6h:
	push hl			;07f6
	ld hl,(02c36h)		;07f7
	dec hl			;07fa
	rst 10h			;07fb
	jp nc,l0317h		;07fc
	ld hl,(02c38h)		;07ff
	dec hl			;0802
	rst 10h			;0803
	pop hl			;0804
	ret c			;0805
	ld a,(de)			;0806
	sub l			;0807
	ld b,a			;0808
	inc de			;0809
	ld a,(de)			;080a
	sbc a,h			;080b
l080ch:
	jr c,l0812h		;080c
	dec de			;080e
	or b			;080f
	ret			;0810
sub_0811h:
	inc de			;0811
l0812h:
	inc de			;0812
sub_0813h:
	ld a,(de)			;0813
	cp 00dh		;0814
	jr nz,l0812h		;0816
l0818h:
	inc de			;0818
	jr sub_07f6h		;0819
l081bh:
	inc de			;081b
sub_081ch:
	ld a,(de)			;081c
	rst 28h			;081d
	cp 00dh		;081e
	jr z,l0818h		;0820
	cp 021h		;0822
	jr z,l0812h		;0824
	cp 022h		;0826
	jr nz,l0834h		;0828
l082ah:
	inc de			;082a
	ld a,(de)			;082b
	cp 00dh		;082c
	jr z,l0818h		;082e
	cp 022h		;0830
	jr nz,l082ah		;0832
l0834h:
	cp 045h		;0834
	jr nz,l081bh		;0836
	ld l,0f6h		;0838
	jp l0398h		;083a
l083dh:
	ld a,(ix-001h)		;083d
	and a			;0840
	ld a,020h		;0841
	jr z,l0847h		;0843
	ld a,02dh		;0845
l0847h:
	rst 20h			;0847
	xor a			;0848
	ld (ix-001h),a		;0849
	dec a			;084c
l084dh:
	push af			;084d
	ld hl,l002ch		;084e
	call sub_0b05h		;0851
	jr nc,l0863h		;0854
	call sub_0ae3h		;0856
	pop af			;0859
	dec a			;085a
	jr l084dh		;085b
l085dh:
	call sub_0af4h		;085d
	pop af			;0860
	inc a			;0861
	push af			;0862
l0863h:
	ld hl,l00a0h		;0863
	call sub_0b05h		;0866
	jr nc,l085dh		;0869
	ld a,(ix-002h)		;086b
	neg		;086e
l0870h:
	jr z,l087dh		;0870
	exx			;0872
	srl c		;0873
	rr h		;0875
	rr l		;0877
	exx			;0879
	dec a			;087a
	jr l0870h		;087b
l087dh:
	ld b,007h		;087d
	push ix		;087f
	pop hl			;0881
	ld (hl),000h		;0882
	inc hl			;0884
l0885h:
	xor a			;0885
	call sub_024fh		;0886
	exx			;0889
	ld a,b			;088a
	exx			;088b
	ld (hl),a			;088c
	inc hl			;088d
	djnz l0885h		;088e
	ld bc,l0600h		;0890
	dec hl			;0893
	ld a,(hl)			;0894
	cp 005h		;0895
l0897h:
	ccf			;0897
	ld a,000h		;0898
	dec hl			;089a
	adc a,(hl)			;089b
	sla c		;089c
	cp 00ah		;089e
	jr c,l08a4h		;08a0
	ld a,000h		;08a2
l08a4h:
	ld (hl),a			;08a4
	push af			;08a5
	and a			;08a6
	jr z,l08abh		;08a7
	set 0,c		;08a9
l08abh:
	pop af			;08ab
	djnz l0897h		;08ac
	ld a,c			;08ae
	pop bc			;08af
	jr c,l08b8h		;08b0
	inc b			;08b2
	push bc			;08b3
	ld b,001h		;08b4
	jr l0897h		;08b6
l08b8h:
	ld c,a			;08b8
	ld a,b			;08b9
	inc a			;08ba
	jp m,l08c8h		;08bb
	cp 007h		;08be
	jr nc,l08c8h		;08c0
	ld b,a			;08c2
	call sub_091ch		;08c3
	jr l090bh		;08c6
l08c8h:
	push bc			;08c8
	ld b,001h		;08c9
	call sub_091ch		;08cb
	ld a,045h		;08ce
	rst 20h			;08d0
	pop bc			;08d1
	bit 7,b		;08d2
	ld a,02bh		;08d4
	jr z,l08e0h		;08d6
	ld a,02dh		;08d8
	rst 20h			;08da
	ld a,b			;08db
	neg		;08dc
	jr l08e2h		;08de
l08e0h:
	rst 20h			;08e0
	ld a,b			;08e1
l08e2h:
	ld b,030h		;08e2
l08e4h:
	cp 00ah		;08e4
	jr c,l0904h		;08e6
	add a,0f6h		;08e8
	inc b			;08ea
	jr l08e4h		;08eb
sub_08edh:
	ld a,(de)			;08ed
	ld l,a			;08ee
	inc de			;08ef
	ld a,(de)			;08f0
	ld h,a			;08f1
	inc de			;08f2
	call sub_0abch		;08f3
sub_08f6h:
	push de			;08f6
	push bc			;08f7
	push hl			;08f8
	ld a,(ix-002h)		;08f9
	cp 080h		;08fc
	jp nz,l083dh		;08fe
	xor a			;0901
	ld b,020h		;0902
l0904h:
	or 030h		;0904
	ld c,a			;0906
	ld a,b			;0907
	rst 20h			;0908
	ld a,c			;0909
	rst 20h			;090a
l090bh:
	pop hl			;090b
	pop bc			;090c
l090dh:
	pop de			;090d
sub_090eh:
	ld bc,0fffbh		;090e
l0911h:
	add ix,bc		;0911
	ret			;0913
sub_0914h:
	call sub_0c4ch		;0914
sub_0917h:
	ld bc,0000ah		;0917
	jr l0911h		;091a
sub_091ch:
	inc b			;091c
l091dh:
	djnz l0922h		;091d
	ld a,02eh		;091f
	rst 20h			;0921
l0922h:
	ld a,(hl)			;0922
	or 030h		;0923
	rst 20h			;0925
	inc hl			;0926
	srl c		;0927
	jr nz,l091dh		;0929
	dec b			;092b
	dec b			;092c
	ret m			;092d
	inc b			;092e
	jr sub_091ch		;092f
sub_0931h:
	call sub_08edh		;0931
	ld a,020h		;0934
l0936h:
	rst 20h			;0936
sub_0937h:
	xor a			;0937
	ld b,a			;0938
l0939h:
	ld a,(de)			;0939
	inc de			;093a
	cp b			;093b
	ret z			;093c
	rst 20h			;093d
	cp 00dh		;093e
	jr nz,l0939h		;0940
	inc a			;0942
	ret			;0943
sub_0944h:
	rst 10h			;0944
	ret z			;0945
	ld a,(de)			;0946
	ld (bc),a			;0947
	inc de			;0948
	inc bc			;0949
	jr sub_0944h		;094a
sub_094ch:
	ld a,b			;094c
	sub d			;094d
	jr nz,l0953h		;094e
	ld a,c			;0950
	sub e			;0951
	ret z			;0952
l0953h:
	dec de			;0953
	dec hl			;0954
	ld a,(de)			;0955
	ld (hl),a			;0956
	jr sub_094ch		;0957
sub_0959h:
	pop bc			;0959
	pop hl			;095a
	ld (02aa1h),hl		;095b
	ld a,h			;095e
	or l			;095f
	jr z,l0972h		;0960
	pop hl			;0962
	ld (02a91h),hl		;0963
	pop hl			;0966
	ld (02a6eh),hl		;0967
	pop hl			;096a
	ld (02a93h),hl		;096b
	pop hl			;096e
	ld (02a95h),hl		;096f
l0972h:
	push bc			;0972
	ret			;0973
sub_0974h:
	ld hl,0d4c8h		;0974
	pop bc			;0977
	add hl,sp			;0978
	jp nc,00153h		;0979
	ld hl,(02aa1h)		;097c
	ld a,h			;097f
	or l			;0980
	jr z,l0996h		;0981
	ld hl,(02a95h)		;0983
	push hl			;0986
	ld hl,(02a93h)		;0987
	push hl			;098a
	ld hl,(02a6eh)		;098b
	push hl			;098e
	ld hl,(02a91h)		;098f
	push hl			;0992
	ld hl,(02aa1h)		;0993
l0996h:
	push hl			;0996
	push bc			;0997
	ret			;0998
sub_0999h:
	rst 18h			;0999
	ld a,007h		;099a
	call sub_0439h		;099c
	ret z			;099f
	ret c			;09a0
	inc hl			;09a1
	ret			;09a2
	rst 18h			;09a3
	dec a			;09a4
	ld b,0cdh		;09a5
	add hl,sp			;09a7
	inc b			;09a8
	ret nz			;09a9
	inc hl			;09aa
	ret			;09ab
	rst 18h			;09ac
	inc a			;09ad
	ld d,e			;09ae
	call sub_0439h		;09af
	ret nc			;09b2
	inc hl			;09b3
	ret			;09b4
sub_09b5h:
	push af			;09b5
	call 02bach		;09b6
	ld hl,(02a68h)		;09b9
	jr c,l0a04h		;09bc
	ld (hl),a			;09be
	inc hl			;09bf
l09c0h:
	ld a,02ah		;09c0
	cp h			;09c2
	jr nz,l09ffh		;09c3
	ld hl,02bb0h		;09c5
	call sub_0a3dh		;09c8
	push hl			;09cb
	inc hl			;09cc
	inc (hl)			;09cd
	call sub_0a3dh		;09ce
	or a			;09d1
	ld de,(02a6ch)		;09d2
	res 1,d		;09d6
	ld hl,l01e0h		;09d8
	sbc hl,de		;09db
	jr z,l09edh		;09dd
	jr c,l09edh		;09df
	ld b,h			;09e1
	ld c,l			;09e2
	set 3,d		;09e3
	set 5,d		;09e5
	ld hl,l0020h		;09e7
	add hl,de			;09ea
	ldir		;09eb
l09edh:
	ld hl,(02a6ch)		;09ed
	ld a,h			;09f0
	or l			;09f1
	pop hl			;09f2
	jr nz,l09f7h		;09f3
	ld (hl),003h		;09f5
l09f7h:
	ld hl,029e0h		;09f7
	push hl			;09fa
	call sub_0a34h		;09fb
	pop hl			;09fe
l09ffh:
	ld (02a68h),hl		;09ff
	pop af			;0a02
	ret			;0a03
l0a04h:
	cp 00dh		;0a04
	jr nz,l0a16h		;0a06
	ld a,h			;0a08
	cp 02bh		;0a09
	jr c,l0a11h		;0a0b
	ld (hl),00dh		;0a0d
	jr l09ffh		;0a0f
l0a11h:
	call sub_0a34h		;0a11
	jr l09c0h		;0a14
l0a16h:
	cp 00ch		;0a16
	jr nz,l0a27h		;0a18
	ld hl,029ffh		;0a1a
l0a1dh:
	ld (hl),020h		;0a1d
	dec hl			;0a1f
	bit 1,h		;0a20
	jr z,l0a1dh		;0a22
l0a24h:
	inc hl			;0a24
	jr l09ffh		;0a25
l0a27h:
	cp 01dh		;0a27
	jr nz,l09ffh		;0a29
	ld (hl),020h		;0a2b
	dec hl			;0a2d
	bit 1,h		;0a2e
	jr nz,l0a24h		;0a30
	jr l09ffh		;0a32
sub_0a34h:
	ld (hl),020h		;0a34
	inc hl			;0a36
	ld a,l			;0a37
	and 01fh		;0a38
	jr nz,sub_0a34h		;0a3a
	ret			;0a3c
sub_0a3dh:
	ld a,i		;0a3d
	ret po			;0a3f
l0a40h:
	ld a,(hl)			;0a40
	or a			;0a41
	jr nz,l0a40h		;0a42
	ret			;0a44
sub_0a45h:
	push de			;0a45
	push hl			;0a46
	push af			;0a47
	ld bc,00004h		;0a48
	push ix		;0a4b
	pop de			;0a4d
	ldir		;0a4e
	rl (ix+002h)		;0a50
	rl (ix+003h)		;0a54
	ld a,b			;0a58
	rra			;0a59
	ld (ix+004h),a		;0a5a
	scf			;0a5d
	rr (ix+002h)		;0a5e
	ld c,005h		;0a62
	add ix,bc		;0a64
	pop af			;0a66
	pop hl			;0a67
	pop de			;0a68
	ret			;0a69
sub_0a6ah:
	call sub_0781h		;0a6a
l0a6dh:
	exx			;0a6d
	call sub_090eh		;0a6e
	ld de,l0000h		;0a71
	ld a,(ix+003h)		;0a74
	ld c,(ix+004h)		;0a77
	cp 080h		;0a7a
	jr z,l0aaah		;0a7c
	cp 001h		;0a7e
	jp m,l0aaeh		;0a80
	cp 010h		;0a83
	exx			;0a85
	jp p,0065ah		;0a86
	exx			;0a89
	ld b,a			;0a8a
	ld a,(ix+000h)		;0a8b
	ld l,(ix+001h)		;0a8e
	ld h,(ix+002h)		;0a91
l0a94h:
	sla a		;0a94
	adc hl,hl		;0a96
	rl e		;0a98
	rl d		;0a9a
	djnz l0a94h		;0a9c
l0a9eh:
	sla c		;0a9e
	jr nc,l0aaah		;0aa0
	or h			;0aa2
	or l			;0aa3
	jr z,l0aa7h		;0aa4
	inc de			;0aa6
l0aa7h:
	call sub_0ad7h		;0aa7
l0aaah:
	push de			;0aaa
	exx			;0aab
	pop hl			;0aac
	ret			;0aad
l0aaeh:
	ld a,0ffh		;0aae
	jr l0a9eh		;0ab0
sub_0ab2h:
	call sub_068eh		;0ab2
	call sub_0999h		;0ab5
	ld bc,00a21h		;0ab8
	nop			;0abb
sub_0abch:
	push de			;0abc
l0abdh:
	ex de,hl			;0abd
	call sub_0917h		;0abe
	call sub_0ad4h		;0ac1
	push de			;0ac4
	ld hl,l0010h		;0ac5
	rr h		;0ac8
	exx			;0aca
	pop de			;0acb
	rst 28h			;0acc
	ld h,e			;0acd
	ld c,d			;0ace
	call sub_0c4ch		;0acf
	jr l0b03h		;0ad2
sub_0ad4h:
	xor a			;0ad4
	add a,d			;0ad5
	ret p			;0ad6
sub_0ad7h:
	ld a,e			;0ad7
	neg		;0ad8
	ld e,a			;0ada
	ld a,d			;0adb
	cpl			;0adc
	ccf			;0add
	adc a,000h		;0ade
	ld d,a			;0ae0
	scf			;0ae1
	ret			;0ae2
sub_0ae3h:
	call 00ab9h		;0ae3
sub_0ae6h:
	call sub_0c68h		;0ae6
	jr z,l0b29h		;0ae9
	cp e			;0aeb
	jp z,00b6bh		;0aec
	call sub_0b81h		;0aef
	jr l0b03h		;0af2
sub_0af4h:
	call 00ab9h		;0af4
sub_0af7h:
	call sub_0c68h		;0af7
	jr z,l0b29h		;0afa
	cp e			;0afc
	jp z,l065bh		;0afd
	call sub_0baeh		;0b00
l0b03h:
	jr l0b6dh		;0b03
sub_0b05h:
	call sub_0a45h		;0b05
	call sub_0c68h		;0b08
	ld bc,0fffbh		;0b0b
	jr l0b16h		;0b0e
sub_0b10h:
	call sub_0c68h		;0b10
	ld bc,0fff6h		;0b13
l0b16h:
	add ix,bc		;0b16
	cp l			;0b18
	call sub_0be6h		;0b19
	pop de			;0b1c
	ret			;0b1d
sub_0b1eh:
	call sub_0c68h		;0b1e
	jr nz,l0b28h		;0b21
	call sub_0b62h		;0b23
	jr l0b58h		;0b26
l0b28h:
	cp e			;0b28
l0b29h:
	jr z,l0b7eh		;0b29
	xor d			;0b2b
	ld d,a			;0b2c
	jr l0b3ah		;0b2d
	call sub_0a45h		;0b2f
sub_0b32h:
	call sub_0c68h		;0b32
	jr z,l0b63h		;0b35
	cp e			;0b37
	jr z,l0b7eh		;0b38
l0b3ah:
	call sub_0c04h		;0b3a
	jr z,l0b4dh		;0b3d
	jr nc,l0b48h		;0b3f
	ex de,hl			;0b41
	exx			;0b42
	ex de,hl			;0b43
	ld a,c			;0b44
	ld c,b			;0b45
	ld b,a			;0b46
	exx			;0b47
l0b48h:
	call sub_0c17h		;0b48
	jr l0b6dh		;0b4b
l0b4dh:
	ld a,h			;0b4d
	xor d			;0b4e
	jr nz,$+28		;0b4f
	ld e,001h		;0b51
	call sub_0c3fh		;0b53
	jr l0b6dh		;0b56
l0b58h:
	ld a,(ix-001h)		;0b58
	xor 080h		;0b5b
	ld (ix-001h),a		;0b5d
	pop de			;0b60
	ret			;0b61
sub_0b62h:
	push de			;0b62
l0b63h:
	ld h,d			;0b63
	ld l,e			;0b64
	exx			;0b65
	ld l,e			;0b66
	ld h,d			;0b67
	ld c,b			;0b68
	exx			;0b69
	ld bc,0802eh		;0b6a
l0b6dh:
	ld (ix-006h),h		;0b6d
	ld (ix-007h),l		;0b70
	exx			;0b73
	ld (ix-00ah),l		;0b74
	ld (ix-009h),h		;0b77
	ld (ix-008h),c		;0b7a
	exx			;0b7d
l0b7eh:
	jp l090dh		;0b7e
sub_0b81h:
	ld a,h			;0b81
	xor d			;0b82
	ld h,a			;0b83
	dec e			;0b84
	push hl			;0b85
	push bc			;0b86
	ld b,018h		;0b87
	call sub_0c81h		;0b89
	xor a			;0b8c
	rst 28h			;0b8d
	ld c,a			;0b8e
l0b8fh:
	exx			;0b8f
	srl c		;0b90
	rr h		;0b92
	rr l		;0b94
	exx			;0b96
	jr nc,l0b9dh		;0b97
	add hl,de			;0b99
	ld a,c			;0b9a
	adc a,b			;0b9b
	ld c,a			;0b9c
l0b9dh:
	exx			;0b9d
	djnz l0ba5h		;0b9e
	pop bc			;0ba0
	pop hl			;0ba1
	exx			;0ba2
	jr l0bd5h		;0ba3
l0ba5h:
	exx			;0ba5
	rr c		;0ba6
	rr h		;0ba8
	rr l		;0baa
	jr l0b8fh		;0bac
sub_0baeh:
	ld a,e			;0bae
	neg		;0baf
	ld e,a			;0bb1
	ld a,h			;0bb2
	xor d			;0bb3
	ld h,a			;0bb4
	push hl			;0bb5
	push bc			;0bb6
	ld b,019h		;0bb7
	exx			;0bb9
l0bbah:
	sbc hl,de		;0bba
	ld a,c			;0bbc
	sbc a,b			;0bbd
	ld c,a			;0bbe
	jr nc,l0bc4h		;0bbf
	add hl,de			;0bc1
	adc a,b			;0bc2
	ld c,a			;0bc3
l0bc4h:
	exx			;0bc4
	ccf			;0bc5
	adc hl,hl		;0bc6
	rl c		;0bc8
	djnz l0bd7h		;0bca
	push hl			;0bcc
	push bc			;0bcd
	exx			;0bce
	pop bc			;0bcf
	pop hl			;0bd0
	exx			;0bd1
	pop bc			;0bd2
	pop hl			;0bd3
	exx			;0bd4
l0bd5h:
	jr l0c35h		;0bd5
l0bd7h:
	exx			;0bd7
	add hl,hl			;0bd8
	rl c		;0bd9
	jr nc,l0bbah		;0bdb
	ccf			;0bdd
	sbc hl,de		;0bde
	ld a,c			;0be0
	sbc a,b			;0be1
	ld c,a			;0be2
	or a			;0be3
	jr l0bc4h		;0be4
sub_0be6h:
	jr z,l0bf2h		;0be6
	cp e			;0be8
	jr z,l0bfah		;0be9
	ld a,h			;0beb
	xor d			;0bec
	call z,sub_0c04h		;0bed
	jr l0bf9h		;0bf0
l0bf2h:
	cp e			;0bf2
	ret z			;0bf3
	scf			;0bf4
	bit 7,d		;0bf5
	jr l0bfch		;0bf7
l0bf9h:
	ret z			;0bf9
l0bfah:
	bit 7,h		;0bfa
l0bfch:
	ccf			;0bfc
	ret nz			;0bfd
	ccf			;0bfe
	rra			;0bff
	scf			;0c00
	rl a		;0c01
	ret			;0c03
sub_0c04h:
	ld a,l			;0c04
	sub e			;0c05
	jr z,l0c0fh		;0c06
	jp po,l0c0dh		;0c08
	neg		;0c0b
l0c0dh:
	rlca			;0c0d
	ret			;0c0e
l0c0fh:
	exx			;0c0f
	ld a,c			;0c10
	cp b			;0c11
	jr nz,l0c15h		;0c12
	rst 10h			;0c14
l0c15h:
	exx			;0c15
	ret			;0c16
sub_0c17h:
	ld a,l			;0c17
	sub e			;0c18
	jr z,l0c29h		;0c19
	cp 018h		;0c1b
	ret nc			;0c1d
	exx			;0c1e
l0c1fh:
	srl b		;0c1f
	rr d		;0c21
	rr e		;0c23
	dec a			;0c25
	jr nz,l0c1fh		;0c26
	exx			;0c28
l0c29h:
	ld e,000h		;0c29
	ld a,h			;0c2b
	xor d			;0c2c
	jp m,l0c46h		;0c2d
	exx			;0c30
	add hl,de			;0c31
	ld a,c			;0c32
	adc a,b			;0c33
	ld c,a			;0c34
l0c35h:
	jr nc,l0c3eh		;0c35
	rr c		;0c37
	rr h		;0c39
	rr l		;0c3b
	scf			;0c3d
l0c3eh:
	exx			;0c3e
sub_0c3fh:
	ld a,l			;0c3f
	adc a,e			;0c40
l0c41h:
	jp pe,l0c61h		;0c41
	ld l,a			;0c44
	ret			;0c45
l0c46h:
	exx			;0c46
	sbc hl,de		;0c47
	ld a,c			;0c49
	sbc a,b			;0c4a
	ld c,a			;0c4b
sub_0c4ch:
	ld b,018h		;0c4c
	xor a			;0c4e
	inc c			;0c4f
	dec c			;0c50
l0c51h:
	jp m,l0c5dh		;0c51
	dec a			;0c54
	add hl,hl			;0c55
	rl c		;0c56
	djnz l0c51h		;0c58
l0c5ah:
	ld l,080h		;0c5a
	ret			;0c5c
l0c5dh:
	exx			;0c5d
	add a,l			;0c5e
	jr l0c41h		;0c5f
l0c61h:
	ld a,h			;0c61
	or a			;0c62
	jp p,l0658h		;0c63
	jr l0c5ah		;0c66
sub_0c68h:
	pop hl			;0c68
	push de			;0c69
	push hl			;0c6a
	ld d,(ix-001h)		;0c6b
	ld e,(ix-002h)		;0c6e
	ld h,(ix-006h)		;0c71
	ld l,(ix-007h)		;0c74
	exx			;0c77
	ld e,(ix-005h)		;0c78
	ld d,(ix-004h)		;0c7b
	ld b,(ix-003h)		;0c7e
sub_0c81h:
	ld l,(ix-00ah)		;0c81
	ld h,(ix-009h)		;0c84
	ld c,(ix-008h)		;0c87
	exx			;0c8a
	ld a,080h		;0c8b
	cp l			;0c8d
	ret			;0c8e
	push de			;0c8f
	exx			;0c90
	ld hl,02aa7h		;0c91
	push hl			;0c94
	ld e,(hl)			;0c95
	inc hl			;0c96
	ld d,(hl)			;0c97
	inc hl			;0c98
	ld b,(hl)			;0c99
	exx			;0c9a
	call sub_0248h		;0c9b
	rst 28h			;0c9e
	ld c,003h		;0c9f
l0ca1h:
	ld b,008h		;0ca1
	ld d,(hl)			;0ca3
l0ca4h:
	exx			;0ca4
	add hl,hl			;0ca5
	rl c		;0ca6
	exx			;0ca8
	rl d		;0ca9
	jr nc,l0cb3h		;0cab
	exx			;0cad
	add hl,de			;0cae
	ld a,c			;0caf
	adc a,b			;0cb0
	ld c,a			;0cb1
	exx			;0cb2
l0cb3h:
	djnz l0ca4h		;0cb3
	inc hl			;0cb5
	dec c			;0cb6
	jr nz,l0ca1h		;0cb7
	rst 28h			;0cb9
	exx			;0cba
	pop de			;0cbb
	ld a,l			;0cbc
	add a,065h		;0cbd
	ld (de),a			;0cbf
	inc de			;0cc0
	ld l,a			;0cc1
	ld a,h			;0cc2
	adc a,0b0h		;0cc3
	ld (de),a			;0cc5
	inc de			;0cc6
	ld h,a			;0cc7
	ld a,c			;0cc8
	adc a,005h		;0cc9
	ld (de),a			;0ccb
	ld c,a			;0ccc
	call sub_0914h		;0ccd
	jp l0b6dh		;0cd0
sub_0cd3h:
	rst 28h			;0cd3
	call sub_0105h		;0cd4
	call sub_0172h		;0cd7
	jr c,l0ce3h		;0cda
	dec de			;0cdc
	call sub_01a2h		;0cdd
	call l0a6dh		;0ce0
l0ce3h:
	ld a,h			;0ce3
	or l			;0ce4
	ret			;0ce5
l0ce6h:
	cp h			;0ce6
	jr nz,l0cebh		;0ce7
	ld h,000h		;0ce9
l0cebh:
	cp l			;0ceb
	jr nz,l0cf0h		;0cec
	ld l,000h		;0cee
l0cf0h:
	dec e			;0cf0
	jr nz,l0cfeh		;0cf1
	jr l0cfbh		;0cf3
sub_0cf5h:
	exx			;0cf5
	ld hl,(02aa5h)		;0cf6
	ld c,00eh		;0cf9
l0cfbh:
	ld de,02034h		;0cfb
l0cfeh:
	ld a,(de)			;0cfe
	rrca			;0cff
	ld a,e			;0d00
	jr c,l0ce6h		;0d01
	cp 032h		;0d03
	jr nz,l0d0fh		;0d05
	dec c			;0d07
	jr nz,l0ce6h		;0d08
	ld a,(02bb4h)		;0d0a
	jr l0d54h		;0d0d
l0d0fh:
	cp h			;0d0f
	jr z,l0cf0h		;0d10
	cp l			;0d12
	jr z,l0cf0h		;0d13
	ld b,000h		;0d15
l0d17h:
	rst 10h			;0d17
	ld a,(de)			;0d18
	rrca			;0d19
	jr c,l0ce6h		;0d1a
	djnz l0d17h		;0d1c
	ld a,h			;0d1e
	or a			;0d1f
	jr nz,l0d25h		;0d20
	ld h,e			;0d22
	jr l0d2ah		;0d23
l0d25h:
	ld a,l			;0d25
	or a			;0d26
	jr nz,l0cfeh		;0d27
	ld l,e			;0d29
l0d2ah:
	ld (02aa5h),hl		;0d2a
	rst 28h			;0d2d
	ld a,e			;0d2e
	cp 034h		;0d2f
	jp z,l0461h		;0d31
	cp 031h		;0d34
	jp z,l0305h		;0d36
	cp 01bh		;0d39
	ld hl,02035h		;0d3b
l0d3eh:
	jr c,l0d59h		;0d3e
	cp 01fh		;0d40
	jr c,l0d54h		;0d42
	sub 01fh		;0d44
	rr (hl)		;0d46
	rla			;0d48
	ld c,a			;0d49
	ld hl,l0d70h		;0d4a
	add hl,bc			;0d4d
	ld a,r		;0d4e
	ld (02aa8h),a		;0d50
	ld a,(hl)			;0d53
l0d54h:
	ld (02bb4h),a		;0d54
	exx			;0d57
	ret			;0d58
l0d59h:
	add a,040h		;0d59
	rr (hl)		;0d5b
	jr c,l0d54h		;0d5d
	ld hl,l0d94h		;0d5f
	ld bc,l045bh		;0d62
l0d65h:
	cp (hl)			;0d65
	jr z,$+7		;0d66
	inc hl			;0d68
	inc c			;0d69
	djnz l0d65h		;0d6a
	ld c,079h		;0d6c
	jr l0d54h		;0d6e
l0d70h:
	jr nz,l0d92h		;0d70
	ld e,a			;0d72
	jr nc,l0d96h		;0d73
	ld sp,03222h		;0d75
	inc hl			;0d78
	inc sp			;0d79
	inc h			;0d7a
	inc (hl)			;0d7b
	dec h			;0d7c
	dec (hl)			;0d7d
	ld h,036h		;0d7e
	cp a			;0d80
	scf			;0d81
	jr z,$+58		;0d82
	add hl,hl			;0d84
	add hl,sp			;0d85
	dec hl			;0d86
	dec sp			;0d87
	ld hl,(03c3ah)		;0d88
	inc l			;0d8b
	dec l			;0d8c
	dec a			;0d8d
	ld a,02eh		;0d8e
	ccf			;0d90
	cpl			;0d91
l0d92h:
	dec c			;0d92
	dec c			;0d93
l0d94h:
	ld e,b			;0d94
	ld b,e			;0d95
l0d96h:
	ld e,d			;0d96
	ld d,e			;0d97
	inc c			;0d98
	nop			;0d99
	call sub_0183h		;0d9a
	ld bc,(02a99h)		;0d9d
	sbc hl,bc		;0da1
	jr l0dbfh		;0da3
	ld c,(hl)			;0da5
	inc hl			;0da6
	ld h,(hl)			;0da7
	ld l,c			;0da8
	jr l0dbfh		;0da9
	ld a,h			;0dab
	or l			;0dac
	jr nz,l0db4h		;0dad
	call sub_0cf5h		;0daf
	jr l0dbah		;0db2
l0db4h:
	set 5,h		;0db4
	ld a,(hl)			;0db6
	cpl			;0db7
l0db8h:
	and 001h		;0db8
l0dbah:
	ld l,a			;0dba
	ld a,06eh		;0dbb
	ld h,000h		;0dbd
l0dbfh:
	jp sub_0abch		;0dbf
	call sub_05fch		;0dc2
	push hl			;0dc5
	rst 18h			;0dc6
	inc l			;0dc7
	nop			;0dc8
	call sub_05fch		;0dc9
	pop bc			;0dcc
l0dcdh:
	ld a,(bc)			;0dcd
	cp (hl)			;0dce
	jr nz,$+13		;0dcf
	or a			;0dd1
	jr z,l0ddbh		;0dd2
	inc hl			;0dd4
	inc bc			;0dd5
	ld a,l			;0dd6
	and 00fh		;0dd7
	jr nz,l0dcdh		;0dd9
l0ddbh:
	ld a,0afh		;0ddb
	jr l0db8h		;0ddd
	call sub_0165h		;0ddf
	jr c,l0df8h		;0de2
	dec de			;0de4
	rst 28h			;0de5
l0de6h:
	call sub_0165h		;0de6
	jr c,l0dbfh		;0de9
	rlca			;0deb
	rlca			;0dec
	rlca			;0ded
	rlca			;0dee
	ld bc,l0de6h		;0def
	push bc			;0df2
sub_0df3h:
	ld b,004h		;0df3
l0df5h:
	rlca			;0df5
	adc hl,hl		;0df6
l0df8h:
	jp c,0065ah		;0df8
	djnz l0df5h		;0dfb
	ret			;0dfd
	or 0afh		;0dfe
	push af			;0e00
	rst 8			;0e01
	push hl			;0e02
	call sub_0005h		;0e03
	ex (sp),hl			;0e06
	pop bc			;0e07
	ld (hl),c			;0e08
	pop af			;0e09
	jr z,l0e0eh		;0e0a
	inc hl			;0e0c
	ld (hl),b			;0e0d
l0e0eh:
	rst 30h			;0e0e
	push de			;0e0f
	ld de,l0abdh		;0e10
	push de			;0e13
	jp (hl)			;0e14
	or d			;0e15
	ld a,l			;0e16
	ret			;0e17
	call sub_0974h		;0e18
	call sub_0730h		;0e1b
	ld (02aa1h),hl		;0e1e
	rst 18h			;0e21
	ld d,h			;0e22
	or d			;0e23
	rst 18h			;0e24
	ld c,a			;0e25
	xor a			;0e26
	rst 8			;0e27
	ld (02a6eh),hl		;0e28
	ld l,0d8h		;0e2b
	jp l0398h		;0e2d
	ld hl,02c36h		;0e30
	push hl			;0e33
	ld hl,(02c38h)		;0e34
	rst 18h			;0e37
	dec c			;0e38
	ld (bc),a			;0e39
	jr l0e42h		;0e3a
	rst 8			;0e3c
	ex (sp),hl			;0e3d
	call sub_0005h		;0e3e
	inc hl			;0e41
l0e42h:
	pop de			;0e42
	ld b,060h		;0e43
	di			;0e45
l0e46h:
	xor a			;0e46
	call sub_0e68h		;0e47
	djnz l0e46h		;0e4a
	ld a,0a5h		;0e4c
	call sub_0e68h		;0e4e
	call sub_0e62h		;0e51
	call sub_0e62h		;0e54
	dec hl			;0e57
l0e58h:
	ld a,(de)			;0e58
	inc de			;0e59
	call sub_0e68h		;0e5a
	jr nc,l0e58h		;0e5d
	ld a,b			;0e5f
	cpl			;0e60
	ld e,a			;0e61
sub_0e62h:
	ex de,hl			;0e62
	ld a,l			;0e63
	call sub_0e68h		;0e64
	ld a,h			;0e67
sub_0e68h:
	exx			;0e68
	ld c,010h		;0e69
	ld hl,02038h		;0e6b
l0e6eh:
	bit 0,c		;0e6e
	jr z,l0e77h		;0e70
	rrca			;0e72
	ld b,064h		;0e73
	jr nc,l0e86h		;0e75
l0e77h:
	ld (hl),0fch		;0e77
	ld b,032h		;0e79
l0e7bh:
	djnz l0e7bh		;0e7b
	ld (hl),0b8h		;0e7d
	ld b,032h		;0e7f
l0e81h:
	djnz l0e81h		;0e81
	ld (hl),0bch		;0e83
	inc b			;0e85
l0e86h:
	djnz l0e86h		;0e86
l0e88h:
	djnz l0e88h		;0e88
	dec c			;0e8a
	jr nz,l0e6eh		;0e8b
l0e8dh:
	inc bc			;0e8d
	bit 1,b		;0e8e
	jr z,l0e8dh		;0e90
	exx			;0e92
l0e93h:
	add a,b			;0e93
	ld b,a			;0e94
	rst 10h			;0e95
	ret			;0e96
	rst 18h			;0e97
	ccf			;0e98
	nop			;0e99
	push af			;0e9a
	rst 18h			;0e9b
	dec c			;0e9c
	ld (bc),a			;0e9d
	rst 28h			;0e9e
	ld a,0cfh		;0e9f
	push hl			;0ea1
	di			;0ea2
l0ea3h:
	call sub_0eddh		;0ea3
	ld a,c			;0ea6
	cp 0a5h		;0ea7
	jr nz,l0ea3h		;0ea9
	ld b,a			;0eab
	call sub_0ed9h		;0eac
	ld h,c			;0eaf
	pop de			;0eb0
	push de			;0eb1
	add hl,de			;0eb2
	ex de,hl			;0eb3
	call sub_0ed9h		;0eb4
	ld h,c			;0eb7
	dec hl			;0eb8
	ld a,b			;0eb9
	pop bc			;0eba
	add hl,bc			;0ebb
	ld b,a			;0ebc
l0ebdh:
	ex de,hl			;0ebd
	call sub_0eddh		;0ebe
	ex af,af'			;0ec1
	ld a,c			;0ec2
	cp (hl)			;0ec3
	jr z,l0ecbh		;0ec4
	pop af			;0ec6
	jr z,l0ed6h		;0ec7
	push af			;0ec9
	ld (hl),c			;0eca
l0ecbh:
	inc hl			;0ecb
	ex de,hl			;0ecc
	ex af,af'			;0ecd
	jr c,l0ebdh		;0ece
	call sub_0eddh		;0ed0
	pop af			;0ed3
	inc b			;0ed4
	ret z			;0ed5
l0ed6h:
	jp 0078fh		;0ed6
sub_0ed9h:
	call sub_0eddh		;0ed9
	ld l,c			;0edc
sub_0eddh:
	exx			;0edd
	ld b,001h		;0ede
l0ee0h:
	ld a,0a7h		;0ee0
l0ee2h:
	add a,b			;0ee2
	ld hl,02000h		;0ee3
	bit 0,(hl)		;0ee6
	jr z,l0ef1h		;0ee8
	dec a			;0eea
	jr nz,l0ee2h		;0eeb
	exx			;0eed
	ld a,c			;0eee
	jr l0e93h		;0eef
l0ef1h:
	ld b,0dah		;0ef1
l0ef3h:
	ld a,0a9h		;0ef3
	djnz l0ef3h		;0ef5
	ld b,05ah		;0ef7
l0ef9h:
	ld c,(hl)			;0ef9
	rr c		;0efa
	adc a,000h		;0efc
	djnz l0ef9h		;0efe
	rlca			;0f00
	exx			;0f01
	rr c		;0f02
	exx			;0f04
	jr l0ee0h		;0f05
l0f07h:
	ld b,b			;0f07
	daa			;0f08
	ld d,d			;0f09
	ld b,l			;0f0a
	ld b,c			;0f0b
	ld b,h			;0f0c
	ld e,c			;0f0d
	dec c			;0f0e
	ld c,h			;0f0f
	ld c,c			;0f10
	ld d,e			;0f11
	ld d,h			;0f12
	add a,h			;0f13
	ld e,(hl)			;0f14
	ld d,d			;0f15
	ld d,l			;0f16
	ld c,(hl)			;0f17
	add a,h			;0f18
	dec bc			;0f19
	ld c,(hl)			;0f1a
	ld b,l			;0f1b
	ld d,a			;0f1c
	add a,e			;0f1d
	call m,04153h		;0f1e
	ld d,(hl)			;0f21
	ld b,l			;0f22
	adc a,(hl)			;0f23
	jr nc,l0f75h		;0f24
	ld c,h			;0f26
	ld b,h			;0f27
	adc a,(hl)			;0f28
	sub a			;0f29
	ld b,l			;0f2a
	ld b,h			;0f2b
	ld c,c			;0f2c
	ld d,h			;0f2d
	add a,d			;0f2e
	sbc a,c			;0f2f
	ld c,(hl)			;0f30
	ld b,l			;0f31
	ld e,b			;0f32
	ld d,h			;0f33
	add a,l			;0f34
	ld h,h			;0f35
	ld c,c			;0f36
	ld c,(hl)			;0f37
	ld d,b			;0f38
	ld d,l			;0f39
	ld d,h			;0f3a
	add a,(hl)			;0f3b
	ld l,h			;0f3c
	ld c,c			;0f3d
	ld b,(hl)			;0f3e
	add a,h			;0f3f
	ld b,c			;0f40
	ld b,a			;0f41
	ld c,a			;0f42
	ld d,h			;0f43
	ld c,a			;0f44
	add a,h			;0f45
	ld d,e			;0f46
	ld b,e			;0f47
	ld b,c			;0f48
	ld c,h			;0f49
	ld c,h			;0f4a
	add a,h			;0f4b
	call p,04e55h		;0f4c
	ld b,h			;0f4f
	ld c,a			;0f50
	ld d,h			;0f51
	add a,(hl)			;0f52
	call z,04552h		;0f53
	ld d,h			;0f56
	add a,l			;0f57
	ld (de),a			;0f58
	ld d,h			;0f59
	ld b,c			;0f5a
	ld c,e			;0f5b
	ld b,l			;0f5c
	add a,(hl)			;0f5d
	ld h,021h		;0f5e
	add a,h			;0f60
	ld c,l			;0f61
	inc hl			;0f62
	add a,h			;0f63
	ld c,l			;0f64
l0f65h:
	ld b,(hl)			;0f65
	ld c,a			;0f66
	ld d,d			;0f67
	adc a,(hl)			;0f68
	jr l0fbbh		;0f69
	ld d,d			;0f6b
	ld c,c			;0f6c
	ld c,(hl)			;0f6d
	ld d,h			;0f6e
	add a,h			;0f6f
	add a,b			;0f70
	ld b,h			;0f71
	ld c,a			;0f72
	ld d,h			;0f73
	add a,(hl)			;0f74
l0f75h:
	rst 8			;0f75
	ld b,l			;0f76
	ld c,h			;0f77
	ld d,e			;0f78
	ld b,l			;0f79
	add a,h			;0f7a
	ld c,l			;0f7b
	ld b,d			;0f7c
	ld e,c			;0f7d
	ld d,h			;0f7e
	ld b,l			;0f7f
	adc a,l			;0f80
	rst 38h			;0f81
	ld d,a			;0f82
	ld c,a			;0f83
	ld d,d			;0f84
	ld b,h			;0f85
	adc a,l			;0f86
	cp 041h		;0f87
	ld d,d			;0f89
	ld d,d			;0f8a
	inc h			;0f8b
	pop bc			;0f8c
	dec bc			;0f8d
	ld d,e			;0f8e
	ld d,h			;0f8f
	ld c,a			;0f90
	ld d,b			;0f91
	add a,e			;0f92
	rla			;0f93
	ld c,b			;0f94
	ld c,a			;0f95
	ld c,l			;0f96
	ld b,l			;0f97
	add a,h			;0f98
	sub 087h		;0f99
	ld e,e			;0f9b
	ld d,d			;0f9c
	ld c,(hl)			;0f9d
	ld b,h			;0f9e
	adc a,h			;0f9f
	adc a,a			;0fa0
	ld c,l			;0fa1
	ld b,l			;0fa2
	ld c,l			;0fa3
	adc a,l			;0fa4
	sbc a,d			;0fa5
	ld c,e			;0fa6
	ld b,l			;0fa7
	ld e,c			;0fa8
	call 042abh		;0fa9
	ld e,c			;0fac
	ld d,h			;0fad
	ld b,l			;0fae
	call 057bch		;0faf
	ld c,a			;0fb2
	ld d,d			;0fb3
	ld b,h			;0fb4
	call 050a5h		;0fb5
	ld d,h			;0fb8
	ld d,d			;0fb9
	add a,a			;0fba
l0fbbh:
	ld l,c			;0fbb
	ld d,(hl)			;0fbc
	ld b,c			;0fbd
	ld c,h			;0fbe
	rst 0			;0fbf
	ld (hl),b			;0fc0
	ld b,l			;0fc1
	ld d,c			;0fc2
	adc a,l			;0fc3
	jp nz,04e49h		;0fc4
	ld d,h			;0fc7
	jp z,026bch		;0fc8
	adc a,l			;0fcb
	rst 18h			;0fcc
	ld d,l			;0fcd
	ld d,e			;0fce
	ld d,d			;0fcf
	adc a,00fh		;0fd0
	ld b,h			;0fd2
	ld c,a			;0fd3
	ld d,h			;0fd4
	add a,(hl)			;0fd5
	call c,07787h		;0fd6
	ld d,e			;0fd9
	ld d,h			;0fda
	ld b,l			;0fdb
	ld d,b			;0fdc
	add a,l			;0fdd
	jr z,l0f65h		;0fde
	ld hl,(05441h)		;0fe0
	add a,h			;0fe3
	cp h			;0fe4
	ld e,b			;0fe5
	inc h			;0fe6
	add a,h			;0fe7
	sbc a,b			;0fe8
	ld e,c			;0fe9
	inc h			;0fea
	add a,h			;0feb
	sbc a,e			;0fec
	add a,h			;0fed
	adc a,(hl)			;0fee
	ld b,e			;0fef
	ld c,b			;0ff0
	ld d,d			;0ff1
	inc h			;0ff2
	adc a,015h		;0ff3
	add a,(hl)			;0ff5
	dec bc			;0ff6
	ld b,l			;0ff7
	ld c,h			;0ff8
	ld d,e			;0ff9
	ld b,l			;0ffa
	add a,h			;0ffb
	ld a,(de)			;0ffc
	adc a,b			;0ffd
	dec de			;0ffe
	nop			;0fff

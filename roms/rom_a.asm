; ****************************************************************************
; * Assembly File Listing to generate 4K "ROM A" for Galaksija microcomputer *
; ****************************************************************************

; Introduction
; ************

; Disassembled from a binary ROM image and annotated by
; Tomaz Solc (tomaz.solc@tablix.org)
; using z80dasm (http://www.tablix.org/~avian/blog/articles/z80dasm)
; between September 2006 and September 2007

; The original assembly listing, complete with its lack of useful comments 
; is available at:

; http://www.galaksija.org/hr/index.php?title=Disasemblirani_ROM_A

; (Titled "MALI RACUNAR GALAKSIJA" by Voja Antonic 03.01.1984)

; $Id: rom1.asm,v 1.26 2007-09-23 12:06:17 avian Exp $

; "ROM A" contains basic operating system of Galaksija, which can be roughly
; separated into following sections:

;	o Initialization routines,
;	o video driver,
;	o keyboard scanning and simple terminal emulation,
;	o BASIC interpreter,
;	o RPN FP calculator and
;	o audio cassette load/save routines.

; This ROM is a work of art when you consider how tighly optimized for size 
; it is and a nightmare if you wish to completely understand or even modify 
; anything in it.

; This disassembly is a work in progress. Sections of the code remain 
; uncommented, however this file should assemble into a binary that is 
; identical to the original ROM image.

; Any contributions (for example additional comments on the code, patches, 
; etc.) are most welcome at tomaz.solc@tablix.org.


; Code sightseeing
; ****************

; A must-see list of 10 most-interesting parts of code:

; l0098h	Part of video driver code used as ASCII string for 
;		BASIC interpreter.

; l00a0h	Part of video driver code used a 1.0 floating point
;		constant.

; l0038h	Video driver code as a whole, tuned to one T cycle accuracy.

; l038ch	A tutorial on how to use "ld" instructions instead of "jr"
; l0393h	and save a few bytes in the process.
; l0396h 

; l0018h	A function that gets its arguments from bytes in ROM that 
;		follow its call.

; l0d2ah	Increasing randomness of pseudo-random generator by changing 
;		the seed after some keys are pressed.

; l0d70h	One look-up table nested inside unused space of another.

; l06cfh	DOT - a true multi-purpose function: query, set or reset a 
;		pseudo-graphic pixel or turn real time clock on or off
;		all in one block of code.

; l0e58h	Record one additional garbage byte at the end of an audio tape
;		because it saves one "jr" instruction in ROM.

; l0fffh	One spare byte for future expansions.


; About the latch
; ***************

; A 6-bit register (called "latch" in the original documentation) can be 
; accessed on all memory addresses that can be written in binary as

; 0 0 1 0  0 x x x  x x 1 1  1 x x x  
; (for example 207fh as used in VIDEO_INT)

; The content is write-only. A read from these addresses will return an 
; unspecified value.

; Individual bits have the following meaning:
;
;  7	Clamp RAM A7 to one (1 disabled, 0 enabled)
;  ---
;  6    Cassette port output bit 0
;  ---
;  5    Character generator row bit 3
;  ---
;  4	Character generator row bit 2
;  ---
;  3	Character generator row bit 1
;  ---
;  2	Character generator row bit 0
;	Cassette port output bit 1
;  ---
;  1	Unused
;  ---
;  0	Unused

;  Character generator row bits hold the current row of the character being
;  drawn to the screen.

;  Cassette port is high if both output bits are 1, low if both are 0 and
;  zero if one bit is 1 and one is 0.

;  Bit 7 forces RAM address line A7 to one. This is required because the top
;  bit of the R register never changes (only bottom 7 bits are incremented
;  during each opcode).



; ROM A is mapped to memory addresses from 0000h to 0fffh

	org	00000h


; 'START'
; =======
; At power on Z80 starts to execute code here. Interrupt mode is set to 0.

;; START
l0000h:
	di		;0000   Disable interrupts
	sub a		;0001	Clear accumulator
	jp l03dah	;0002	Jump forward to START_2, the remainder of
			;	the initialization code.

; 'EVALUATE NEXT INTEGER ARGUMENT'
; ================================
; Evaluate an integer expression at DE behind a ASCII comma. If comma is not
; found, jump to WHAT_RST.

;; EVAL_INT_EXP_NEXT
l0005h:
	rst 18h		;0005	Call READ_PAR
	db ','		;0006	
	db l0034h-$-1	;0007	Jump to WHAT_RST if there is no next argument
			;	at DE.

; 'EVALUATE INTEGER EXPRESSION'
; =============================
; Evaluate an integer expression at DE and return the result in HL.

;; EVAL_INT_EXP
l0008h:
	call l0ab2h	;0008	Call EVAL_EXPRESSION
	jp l0a6dh	;000b	Jump to FP_TO_INT and return.

; 'FAST MODE'
; ===========
; Disable video interrupt.

;; FAST
l000eh:	
	di		;000e
	ret		;000f	

; 'COMPARE HL WITH DE'
; ====================
; This function compares HL with DE register pair and sets C and Z flags 
; accordingly

; Parameters:
;	DE, HL: values to be compared
; Returns:
;	C, Z flag
; Destroys:
;	A, all other flags

;; CMP_HL_DE
l0010h:
	ld a,h		;0010	Load H into A
	cp d		;0011	Compare with D
	ret nz		;0012	Return if not equal
	ld a,l		;0013	Load L into A
	cp e		;0014	Compare with E
	ret		;0015	Return

; 'SLOW MODE'
; ===========
; Enable video interrupt.

;; SLOW
l0016h:
	ei		;0016
	ret		;0017

; 'READ PARAMETER'
; ================
; This function reads the byte following the calling "rst" instruction and
; returns to a different location (specified with the second following byte) 
; if the byte doesn't match the first non-space character in the string pointed 
; to by DE register.

; Example:
;	rst 18h		; 0005
;	db ','		; 0006
;	db 02ch		; 0007
;       ...		; 0008

; This compares the first non-space character in DE with ASCII comma ',' 
; ignoring any leading space. If it matches, READ PARAMETER returns to the next
; instruction following the two bytes (at 0008h). If not, it adds 02ch to this
; return address (in this case it would return to 0034h). In the first case
; DE is also incremented to account for the matched byte.

; In pseudo-code:
;
; If (**SP) == (EAT_SPACE(DE)) Then
;	*SP=*SP+2
; 	DE=DE+1
; Else
;	*SP=*SP+2+(*(*SP+1))		
; End

; Parameters:
;	DE: Pointer a string.
; Returns:
;	DE: Skips leading space and increments DE, if there is a match.
;	A: First non-space character in DE.
;	Zf: Set if character matches, reset if not.
; Destroys: 
;	flags.

;; READ_PAR
l0018h:
	ex (sp),hl	;0018	Load a pointer from top of stack into HL

	call l0105h	;0019	Call EAT_SPACE	      

	cp (hl)		;001c	Compare memory pointed by HL with A
	jp l0194h	;001d	Jump to the rest of the function at READ_PAR_2

; 'PUT CHARACTER ON SCREEN'
; =========================
; Print a character in A to the screen at the current cursor position 
; (CURSOR_POS)

; Parameters:
;	A: Character to print
; Returns:
;	HL': Position of the printed character + 1
; Destroys:
;	flags

;; PUTCH_RST
l0020h:
	exx		;0020	Save BC, DE and HL registers

	cp 020h		;0021	Set C flag if character is ASCII special.
			;	(ASCII code less than 20h)

	call l09b5h	;0023	Jump to remainder of function.
	exx		;0026	Restore BC, DE and HL registers.
	ret		;0027	Return

; 'CLEAR HL'
; ==========
; Loads 0000h into HL

;; CLEAR_HL
l0028h:
	ld hl,l0000h	;0028	Load 0000h into HL
	ret		;002b	Return


; 'ONE OVER TEN FLOATING POINT CONSTANT'
; ======================================
; Approximately 0.1 in four-byte floating point format.

;; FP_ONE_OVER_TEN
l002ch:
	db	0cch	;002c	Mantissa: cccccch
	db	0cch	;002d
	db 	0cch	;002e	Sign: 00h
	db	07eh	;002f   Exponent: fdh

; 'NEXT BASIC STATEMENT'
; ======================
; Continue execution of the next BASIC statement. BASIC commands call this
; function at the end. It never returns.

;; BASIC_NEXT
l0030h:
	pop af		;0030	Remove return address from stack
	call l0414h	;0031	Call CONTINUE

l0034h:
	jp l078fh	;0034	Jump to WHAT_RST if CONTINUE found no
			;	valid next command.

; 'ROM A VERSION'
; ===============

;; ROM_VERSION
	db	28	;0037

; 'VIDEO INTERRUPT DRIVER'
; ========================
; This routine gets called 50 times per second via the Z80's maskable 
; interrupt. 

; Interrupt gets triggered on the vertical sync impulse. Video synchronization 
; hardware then makes sure (by inserting WAIT states) that the first opcode 
; starts to execute exactly in sync with the next horizontal sync.

; Timing is very important here! This routine must execute in perfect sync
; with the video hardware.

; The routine must make sure that the R and I registers are properly set at
; exactly the right time so that the Z80's memory refresh feature can start
; reading video line data from video RAM. It also must latch the correct video
; line number into the register connected to the character generator ROM and
; adjust the RAM memory map if needed (A7 line).

; The address of a character on screen:
;
;					A7 from latch
;                                       |
;                    <-- I register |   | | R register -->
;              ||                   ||  v |              ||
; Address bits || 11 | 10 |  9 |  8 ||  7 |  6 |  5 |  4 ||  3 |  2 |  1 |  0
;              ||              |    ||              |    ||
;                              |                    |
;     <-- Base address (2800h) |  Row (4 bits)      | Column (5 bits)

;; VIDEO_INT			T states
l0038h:
	push af		;0038	11	Save all used registers on the stack.
	push bc		;0039	11	
	push de		;003a	11
	push hl		;003b	11

	ld hl,02bb0h	;003c	10	Load SCROLL_CNT address to HL
	ld a,0c0h	;003f	7	Load A with 192 
	sub (hl)	;0041	7
	sub (hl)	;0042	7
	sub (hl)	;0043	7	Subtract 3 * SCROLL_CNT from A
	ld e,a		;0044 	4	Load result into E

	ld a,(hl)	;0045	7	Load A with value from SCROLL_CNT
	rrca		;0046	4	Rotate right A three times
	rrca		;0047	4
	rrca		;0048	4	
	ld b,a		;0049	4 	Load result into B

	or a		;004a	4 	set Z flag if A = 0
			;		reset C flag
			;	-----
			;       113 

; The following code is a pause with length (24 + B * 18) T states. 
; This determines the vertical position of the screen.

	jr z,l004dh	;004b	12/7	Wait 5 T states if Z set...
l004dh:
	jr z,l0054h	;004d	12/7	and jump forward
	dec (hl)	;004f	11	... else decrement SCROLL_CNT
	xor a		;0050	4	    clear A (reset C flag)
l0051h:
	ret c		;0051	5	    wait 5 T states 
			;		    (C flag always reset)
	djnz l0051h	;0052	13/8        ... loop B times


l0054h:
	inc hl		;0054	6	Load SCROLL_FLAG address to HL
	ld (hl),a	;0055	13	Set SCROLL_FLAG = 0

	ld b,e		;0056	4	Set B = 192 - 3 * SCROLL_CNT
	ld hl,0207fh	;0057	10	Load latch address to HL
	ld c,l		;005a	4	Load C with 7fh

	ld a,(02ba8h)	;005b	13	Load A with HORIZ_POS
	rra		;005e	4 	Divide A with 2 (C flag always reset)
			;		load bit 0 into C flag.
			;	----
			;	54

; B holds the total number of scanlines to be drawn.

; C holds the current line number

; During one iteration of VIDEO_DISPLAY_LOOP one line of characters is drawn.

; Here is another pause with length (2 + 5 * Cf + 16 * A) T states.
; This determines the horizontal position of the screen.
; Note: HORIZ_POS must be >= 2.

; On later iterations of VIDEO_DISPLAY_LOOP A is always set to 3, this means
; a constant pause of 43 T states

	jr c,l0061h	;005f	12/7	Wait 5 T if HORIZ_POS odd.

;; VIDEO_DISPLAY_LOOP
l0061h:
	dec a		;0061	4	Decrement A
	jr nz,l0061h	;0062	12/7	...loop A times

	jr l006dh	;0064	12	Jump forward

; 'HARD BREAK'
; ============
; On a non-maskable interrupt, Z80 jumps here. This is used as a "hard break"
; button on Galaksija.

;; HARD_BREAK
	di		;0066		Disable interrupts.

; 'RESET BASIC'
; =============
; Resets BASIC interpreter.

;; RESET_BASIC
l0067h:
	ld sp,02ba8h	;0067	Load HORIZ_POS address to SP
	jp l0317h	;006a	Jump to the rest at RESET_BASIC_2

; Continuing VIDEO_DISPLAY_LOOP

l006dh:
	inc c		;006d	4	Increment C

	ld a,c		;006e	4	Load A with C
	and 008h	;006f	7	Set A = A & 08h
	rrca		;0071	4	Rotate A right 3 times
	rrca		;0072	4
	rrca		;0073	4	
	or 028h		;0074	7 	Set A = A | 28h
	ld i,a		;0076	9	Load I with result

			;		I now has the upper 8 bits of the
			;		address for the line that will
			;		be drawn to the sceeen (either 28h
			;		or 29h)

	inc de		;0078	6	NOP
	ld de,0080ch	;0079	10	Load DE with 080ch
	ld a,c		;007c	4	Load A with C
	rrca		;007d	4	Rotate A right 3 times
	rrca		;007e	4
	rrca		;007f	4
	ccf		;0080	4	Complement C flag
	rr d		;0081	8	Rotate D right through C flag
			;		D is now 84h or 04h

			;		The MSB determines whether the RAM
			;		address line A7 will be forced to 1

	or 01fh		;0083	7	Set A = A | 1fh
	rlca		;0085	4	Rotate left
	sub 040h	;0086	7	Subtract 40h
	rrca		;0088	4	Rotate right
	ld r,a		;0089	9	Load R with A

; E holds the number of scan lines to be drawn for this line of characters.

; During one iteration of VIDEO_LINE_LOOP one scanline of video is drawn.

;; VIDEO_LINE_LOOP
l008bh:
	ld (hl),d	;008b	7 	Latch value in D to the character
			;		generator register

; Opcodes are arbitrary, but must all consist of 4 T states (one M state) - 
; 8 pixels are drawn during each opcode.

	inc d		;008c	4
	inc d		;008d	4
	inc d		;008e	4
	inc d		;008f	4	
	xor a		;0090	4
	scf		;0091	4
	rra		;0092	4
	rra		;0093	4	
	xor d		;0094	4	
	ld d,a		;0095	4
	ld h,c		;0096	4
	ld a,b		;0097	4

;; BREAK_STRING
l0098h:

; This part of the line drawing code also serves as a string "BREAK" for the
; basic interepreter.

	ld b,d		;0098	4 	B 
	ld d,d		;0099	4 	R 
	ld b,l		;009a	4 	E 
	ld b,c		;009b	4 	A 
	ld c,e		;009c	4 	K 
	nop		;009d	4 	\0  

	ld b,a		;009e	4
	ld c,h		;009f	4

; This part of the line drawing code also serves as a constant 1.0 in four-byte
; floating point format.

;; FP_ONE
l00a0h:
	nop		;00a0	4	00h	Mantissa: 800000h
	nop		;00a1	4	00h
	add a,b		;00a2	4	80h	Sign bit: 00h
	nop		;00a3	4	00h	Exponent: 01h

	xor a		;00a4	4
	scf		;00a5	4
	rra		;00a6	4
	rra		;00a7	4
	rra		;00a8	4
	ld h,a		;00a9	4
	rla		;00aa	4

; At the end of line drawing:
; 	A = 40h
;	B remains unmodified
;	C remains unmodified
;	D = 40h XOR (D + 4)
;	E remains unmodified
; 	HL remains unmodified (207fh)

	ld (hl),a	;00ab	10	During the last character we clear 
			;		the register so nothing gets
			;		drawn outside the screen (character
			;		generator line 0)

; End of line drawing

	dec b		;00ac	4	Decrement B
	jr z,l00beh	;00ad	12/7	Break from loop if B is zero.

	ld a,r		;00af	9	Load A with R
	sub 027h	;00b1	7	Subtract 27h
	and l		;00b3	4	Clear the top bit (L = 7fh)
			;		This bit is provided by A7 clamp
	ld r,a		;00b4	9	Load R with A

	dec e		;00b6	4	Decrement E
	jp nz,l008bh	;00b7	12/7	If not zero jump to VIDEO_LINE_LOOP

	ld a,003h	;00ba	7	Load A with 03h
	jr l0061h	;00bc	12	Jump to VIDEO_DISPLAY_LOOP

; At this point the screen has been drawn. Timing is no longer critical.
l00beh:
	ld (hl),0bch	;00be	Latch bch into the register
			;	This disables A7 clamp and sets character
			;	generator to an empty line 15 so that nothing
			;	gets drawn outside the screen

; The following code increments the real-time clock in BASIC string $Y.

; The clock only works correctly if Y$ contains one of the following
; ASCII combinations:

; Y$ = "HH:MM:SS:PP\0", Y$ = "HH:MM:SS\0PP", Y$ = "HH:MM\0SS:PP"

; Where HH are hours, MM minutes, SS seconds and PP 1/100th of a second

	ld a,(02a82h)	;00c0	Load memory location 2a82h into A
			;	This is third character in Y$
	cp 03ah		;00c3	Compare A with 3ah (ASCII ':')
	jr nz,l00fbh	;00c5	Jump to VIDEO_END if not equal

	ld a,(02bafh)	;00c7 	Load CLOCK_ON into A
	rlca		;00ca	Move MSB into C flag
	jr nc,l00fbh	;00cb	Jump to VIDEO_END if MSB is zero

; Clock is enabled and seems to contain a valid ASCII string.
; HL contains pointer to the current character
; B contains number of characters left

	ld hl,02a8ah	;00cd	Load 2a8ah into HL 
			;	This is the last (11th) character in string Y$
	ld de,03930h	;00d0	Load 3930h into DE
			;	D = '9' E = '0'
	ld b,008h	;00d3	Load 08h into B
	ld a,d		;00d5	Load 39h into A
			;	A = '9'

	inc (hl)	;00d6	Increment last character (1/100th s) two times
	inc (hl)	;00d7 	(this routine is called 50 times per second)
	cp (hl)		;00d8	Compare last character with '9'

	jr l00dfh	;00d9	Jump forward

; This code propagates change in the 1/100th field to seconds, minutes and 
; hours 

l00dbh:
	inc (hl)	;00db	Increment character
	cp (hl)		;00dc	Compare character with A
	ld a,035h	;00dd	Load '5' into A

l00dfh:
	jr nc,l00ebh	;00df	If character less or equal to A ('9' or '5') 
			;	then jump forward.

	ld (hl),e	;00e1	Replace current character with '0'
	dec hl		;00e2	Move pointer to the next character.
	bit 0,b		;00e3	If B even...
	jr z,l00e9h	;00e5	...jump forward

	dec hl		;00e7	Else move pointer again (to skip ':' or '\0')
	ld a,d		;00e8	Load '9' into A

l00e9h:
	djnz l00dbh	;00e9	Loop until B equals 0
l00ebh:

	dec b		;00eb	Decrement B
	djnz l00fbh	;00ec	Jump to VIDEO_END if B not equal to 0...
			;	...else hours field was updated and must
			;	   be checkd for overflow

	ld a,(hl)	;00ee	Load the character into A
	cp 034h		;00ef	Compare with '4'
	jr c,l00fbh	;00f1	If character less or equal to '4' jump to 
			;	VIDEO_END

	dec hl		;00f3	Move pointer to the next character
	bit 1,(hl)	;00f4	Test bit 1 (character equal to '2' or more)
	jr z,l00fbh	;00f6	If bit 1 not set jump to VIDEO_END...

	ld (hl),e	;00f8	Else load '0' in the last two characters
	inc hl		;00f9
	ld (hl),e	;00fa	

;; VIDEO_END
l00fbh:
	jp (iy)		;00fb	Jump to video hook (jumps to l00fdh by
			;	default)

l00fdh:
	pop hl		;00fd	Restore all registers from stack
	pop de		;00fe	
	pop bc		;00ff	
	pop af		;0100	

	ei		;0101	Enable interrupts
	reti		;0102	Return from interrupt

; 'EAT SPACE'
; ===========
; Increments DE until it points to a non-ASCII space (20h) character

; Parameters:
;	DE: starting position
; Returns:
;	A:  first non-space character
;	DE: address of the character in A
; Destroys:
;	flags

l0104h:
	inc de		;0104	Increment DE

;; EAT_SPACE
l0105h:
	ld a,(de)	;0105	Load memory byte pointed by DE into A
	cp 020h		;0106	Compare A with ASCII ' '
	jr z,l0104h	;0108	Loop if equal...
	ret		;010a	...else Return 

; 'ARR$'
; ======
;; ARR$ BASIC command

;; ARR$
l010bh:
	inc hl			;010b	23 	# 
	xor a			;010c	af 	  
	call l0df3h		;010d	cd f3 0d 	      
	ld (02a99h),hl		;0110	22 99 2a 	"   * 
	rst 30h			;0113	f7 	  
l0114h:
	rst 8			;0114	cf 	  
	inc hl			;0115	23 	# 
	xor a			;0116	af 	  
	call l0df3h		;0117	cd f3 0d 	      
	push de			;011a	d5 	  
	ld de,(02a99h)		;011b	ed 5b 99 2a 	  [   * 
	inc de			;011f	13 	  
	rst 10h			;0120	d7 	  
	jr nc,l0154h		;0121	30 31 	0 1 
	jr l0146h		;0123	18 21 	  ! 

; 'LOCATE BASIC NUMERIC VARIABLE'
; ===============================
; Locates a BASIC variable containing 4-byte floating point number and stores
; its address in HL.

; Recognizes ordinary variables from A - Z and A(I) array.

; Returns:
;	HL: Location of the variable

;; LOCATE_VARIABLE
l0125h:
	call l0105h	;0125	Fetch the next character (call EAT_SPACE)

; Return with Cf set if character not between 'A' and 'Z'

	sub 041h	;0128	Subtract ASCII value 'A'
	ret c		;012a	Return if less

	cp 01ah		;012b 	Compare character with ASCII value 'Z' + 1
	ccf		;012d	
	ret c		;012e	Return if greater or equal

	inc de		;012f	Move to the next character
	and a		;0130	
	jr nz,l015eh	;0131	Jump to LOCATE_VARIABLE_BZ if character 
			;	is not A

	rst 18h		;0133	Call READ_PAR
	db '('		;0134
	db l015dh-$-1	;0135	Jump to LOCATE_VARIABLE_A if character A is
			;	not followed by '('

; A(I) array

	rst 8		;0136 	HL = index (call EVAL_INT_EXP)
	inc hl		;0137	Increment index

	add hl,hl	;0138	HL = index * 4
	add hl,hl	;0139	

	push de		;013a	Save DE on stack
	jr c,l0154h	;013b	Jump to SORRY_RST on carry (index too large)

	ld de,(02a99h)	;013d	HL = index * 4 + ARRAY_LEN
	add hl,de	;0141

	pop de		;0142	Fetch DE from stack
	push de		;0143

	jr c,l0153h	;0144	Jump to SORRY_RST_PUSH_DE on carry 
			;	(index too large)
l0146h:
	pop de		;0146	Restore DE

	rst 18h		;0147	Call READ_PAR
	db ')'		;0148
	db l0153h-$-1	;0149	Jump to SORRY_RST_PUSH_DE if no closing ')' 
			;	found.

	push de		;014a	Save DE

	ex de,hl	;014b	DE = index * 4 + ARRAY_LEN
	call l0183h	;014c	Call FREE_MEM

	rst 10h		;014f	Call CMP_HL_DE

	jr nc,l0188h	;0150	Jump to SUB_RAMTOP_HL if enough memory and 
			;	return

	db 03eh		;0152	Dummy ld a,nn (ignore push de command)

; '"SORRY" ERROR RESTART'
; =======================
; This restart is called when there is not enough memory available to 
; complete a function or command.

;; SORRY_RST_PUSH_DE
l0153h:
	push de		;0153	Push current parser address to stack.
;; SORRY_RST
l0154h:
	call l0799h		;0154	Call BASIC_ERROR
	dm "SORRY", 00dh	;0157

; Ordinary variable

;; LOCATE_VARIABLE_A
l015dh:
	xor a		;015d	Clear A
;; LOCATE_VARIABLE_BZ
l015eh:
	ld h,02ah	;015e	HL = 2a00h + A * 4
	rla		;0160	
	rla		;0161	
	ld l,a		;0162

	xor a		;0163	Clear A and Cf

	ret		;0164	Return

; 'CONVERT ASCII HEX CHAR TO AN INTEGER'
; ======================================
; This function converts a single ASCII character to its hexadecimal numerical 
; value (for example 'B' returns 11) and increments DE.

; Parameters:
;	DE: Pointer to the character to be converted
; Returns:
;	A: Numerical value of character in (DE) or the character in (DE) on 
;	   error (character not between ASCII '0' and '9').
;	DE: Incremented by 1 or unmodified on error.
;	C flag: Set on error, reset otherwise
; Destroys:
;	Flags

;; HEXCHAR_TO_INT
l0165h:
	call l0172h	;0165	First try to convert an ASCII integer
	ret nc		;0168	return if call to CHAR_TO_INT succeeded

	cp 041h		;0169	Return with Cf set if character less than 'A'
	ret c		;016b	

	add a,009h	;016c	Add 09h to ASCII code (lower 4 bits are now
			;	equal to the hex value)

	cp 050h		;016e	Compare with 'F' + 09h + 1

	jr l0178h	;0170	Jump forward (check for error, clear upper
			;	for bits and return)

; 'CONVERT ASCII CHAR TO AN INTEGER'
; ==================================
; This function converts a single ASCII character to its decimal numerical 
; value and increments DE.

; Parameters:
;	DE: Pointer to the character to be converted
; Returns:
;	A: Numerical value of character in (DE) or the character in (DE) on 
;	   error (character not between ASCII '0' and '9').
;	DE: Incremented by 1 or unmodified on error.
;	C flag: Set on error, reset otherwise
; Destroys:
;	Flags

;; CHAR_TO_INT
l0172h:
	ld a,(de)	;0172	Load (DE) into A
	cp 030h		;0173	Compare with 30h (ASCII '0')...
	ret c		;0175	...and return if smaller.

	cp 03ah		;0176	Compare with 3ah (ASCII '9' + 1)...
l0178h:
	ccf		;0178	   (complement carry flag)
	ret c		;0179	...and return if larger or equal.

	inc de		;017a	Increment DE
l017bh:
	and 00fh	;017b	A = A & 0fh (clear upper 4 bits)
			;	also resets carry flag

	ret		;017d	Return

l017eh:
	ld (hl),a			;017e	77 	w 
l017fh:
	inc hl			;017f	23 	# 
	ld a,l			;0180	7d 	} 
	jr l017bh		;0181	18 f8 	    

; 'FREE MEMORY REMAINING'
; =======================
; Calculate bytes available from end of BASIC program to top of RAM

; Returns:
;	HL: Free bytes available.

;; FREE_MEM
l0183h:
	push de		;0183	Save DE to stack

	ld de,(02c38h)	;0184	Load BASIC_END into DE

; 'SUBTRACT HL FROM RAM_TOP'
; ==========================

; Returns:
;	HL: HL = RAM_TOP - HL

;; SUB_RAMTOP_HL
l0188h:
	ld hl,(02a6ah)	;0188	Load RAM_TOP into DE

	ld a,l		;018b	HL = HL & 0fff0h
	and 0f0h	;018c	(resets Cf)
	ld l,a		;018e

	sbc hl,de	;018f	HL = HL - DE - 0

	pop de		;0191	Restore DE
	xor a		;0192	Clear A (resets carry)

	ret		;0193	Return

; 'READ PARAMETER (cont.)'
; ========================

;; READ_PAR_2
l0194h:
	inc hl		;0194	Increment HL
	jr z,l019eh	;0195	Jump forward if character in DE matches

	push bc		;0197	Save BC on stack
	ld c,(hl)	;0198	Load (HL) into BC
	ld b,000h	;0199
	add hl,bc	;019b	Add BC to HL
	pop bc		;019c	Restore BC from stack

	dec de		;019d	Decrement DE

l019eh:
	inc de		;019e	Increment DE
	inc hl		;019f	Increment HL
	ex (sp),hl	;01a0	Store HL back to the top of the stack
	ret		;01a1	Return

; 'CONVERT STRING TO FLOATING POINT NUMBER'
; =========================================
; Converts a string at DE to a floating point number and pushes it to the
; arithmetic stack.

; Returns:
;	Zf: Set if no errors occured

;; STRING_TO_FP
l01a2h:
	call l0248h	;01a2	Clear HL' C' (call CLEAR_CX_HLX_B6)

	ld b,000h	;01a5	Clear B and C
	ld c,b		;01a7

	call l0105h	;01a8	Skip any leading whitespace (call EAT_SPACE)

l01abh:
	call l01b0h	;01ab	Call STRING_TO_FP_FETCH_DECIMAL
	jr l01abh	;01ae	Loop

;		L'	H'	C'	L	H
; ----------------------------------------------------------
;		24 bit mantissa		Exp	Sign

; B register (holds status of the conversion)

; bit	7	6	5	4	3	2	1	0
; ----------------------------------------------------------------------
; 	Mantissa overflow

;		Mantissa started with a number

;			Exponent started with a number

;							Negative exponent

;								Decimal part

; C register holds (negative) number of decimals after the decimal point.


; Stack: Top
;	 -> STRING_TO_FP

;; STRING_TO_FP_FETCH_DECIMAL
l01b0h:
	call l0172h	;01b0	Call CHAR_TO_INT
	jr c,l01d5h	;01b3	Jump on conversion error

	set 6,b		;01b5	Set bit 6 of B

	bit 7,b		;01b7
	jr nz,l01d0h	;01b9	Jump forward on mantissa overflow.

	call l01c3h	;01bb	Call STRING_TO_FP_ADD_DECIMAL

	bit 0,b		;01be
	ret z		;01c0	Decrement C if after decimal point.

	dec c		;01c1	
	ret		;01c2	Return


; Stack: Top
;	 -> STRING_TO_FP
;        -> STRING_TO_FP_FETCH_DECIMAL

;; STRING_TO_FP_ADD_DECIMAL
l01c3h:
	call l024fh	;01c3	Call FP_MUL_10_ADD_A

	ret z		;01c6	Return if no overflow in mantissa

; Restore original mantissa if there was an overflow

	exx		;01c7	
	ld h,d		;01c8	Load DE' into HL'
	ld l,e		;01c9	
	ex af,af'	;01ca	
	ld c,a		;01cb	Load A' into C'
	exx		;01cc	

	set 7,b		;01cd	Set bit 7 of B

	pop af		;01cf	Remove top return address from stack.
			;	(will return to STRING_TO_FP)

l01d0h:
	bit 0,b		;01d0
	ret nz		;01d2	Increment C if before decimal point.

	inc c		;01d3	
	ret		;01d4	Return

; Stack: Top
;	 -> STRING_TO_FP

l01d5h:
	rst 18h		;01d5	Call READ_PAR
	db '.'		;01d6
	db l01ddh-$-1	;01d7

; Decimal point found

	bit 0,b		;01d8
	set 0,b		;01da	
	ret z		;01dc	Return if bit 0 not set,
			;	else set bit 0 of B.

			;	Two decimal points found
l01ddh:
	pop af		;01dd	Remove top return address from stack.

	bit 6,b		;01de	
	ret z		;01e0	Return from STRING_TO_FP if first character
			;	of mantissa was not a number.

	ld hl,l0018h	;01e1	Exponent = 24, sign = positive
	push bc		;01e4	Save BC on stack
	push de		;01e5	Save DE on stack

	exx		;01e6
	call l0914h	;01e7	Call CORRECT_EXP_ADD_IX_10

	pop de		;01ea	Restore DE from stack

	ld bc,l01f3h	;01eb	Push STRING_TO_FP_PARSE_EXP address on stack.
	push bc		;01ee	

	push de		;01ef	Save DE on stack
	jp l0b6dh	;01f0	Jump to STORE_ARITHM_RET and return 
			;	to STRING_TO_FP_PARSE_EXP

; At this point mantissa is on the top of arithmetic stack and DE points
; to the beginning of the exponent.

; Stack: Top
;	 -> STRING_TO_FP

;; STRING_TO_FP_PARSE_EXP
l01f3h:
	pop bc		;01f3	Restore BC from stack
	push de		;01f4	Save DE on stack

	rst 18h		;01f5	Call READ_PAR
	db 'E' 		;01f6	
	db l0213h-$-1	;01f7	No exponent

	rst 18h		;01f8	Call READ_PAR
	db '+'		;01f9	
	db l01fdh-$-1	;01fa	Ignore leading + sign

	jr l0202h	;01fb

l01fdh:
	rst 18h		;01fd	Call READ_PAR
	db '-'		;01fe
	db l0202h-$-1	;01ff

	set 1,b		;0200	Mark negative exponent

;; STRING_TO_FP_GET_EXP
l0202h:
	call l024ah	;0202	Call CLEAR_CX_HLX

l0205h:
	call l0172h	;0205	Call CHAR_TO_INT
	jr c,l0217h	;0208	Break from loop on conversion error

	set 5,b		;020a	Mark exponent started with number

	call l024fh	;020c	Add decimal to the exponent
			;	(call FP_MUL_10_ADD_A)

	jr nz,l0225h	;020f	Jump to HOW_RST_PUSH_DE on exponent overflow

	jr l0205h	;0211	Loop

l0213h:
	pop de		;0213	Restore DE
	xor a		;0214	Clear A
	jr l022eh	;0215	

l0217h:
	bit 5,b		;0217	
	jr z,l0213h	;0219	Jump to FIXME if exponent did not start with
			;	a number

	pop af		;021b	FIXME

	exx		;021c	
	ld a,c		;021d	
	or h		;021e	Test C' and H'

	ld a,l		;021f	A = L'

	exx		;0220

	jr nz,l0225h	;0221	If C' or H' not equal to zero, call HOW_RST
			;	(exponent overflowed)
	bit 7,a		;0223	
l0225h:
	jp nz,l065ah	;0225	If mantissa overflowed, call HOW_RST

	bit 1,b		;0228	If exponent negative, negate A
	jr z,l022eh	;022a	
	neg		;022c
l022eh:

	add a,c		;022e	Add exponent and number of decimal points

; Mantissa is still on the top of the arithmetic stack. Exponent is in A. 

; Multiply mantissa with 10^A.

;; STRING_TO_FP_EXP_LOOP
l022fh:
	and a		;022f	
	jr z,l0245h	;0230	If A zero, jump to STRING_TO_FP_END

	bit 7,a		;0232
	jr z,l023dh	;0234	Multiply by 10 if exponent positive,
			;	else divide by 10

	inc a		;0236	Increment A
	push af		;0237	Save A on stack
	call l0af4h	;0238	Call FP_DIV_10
	jr l0242h	;023b

l023dh:
	dec a		;023d	Decrement A
	push af		;023e	Save A on stack
	call l0ae3h	;023f	Call FP_MUL_10

l0242h:
	pop af		;0242	Restore A from stack
	jr l022fh	;0243	Jump to STRING_TO_FP_EXP_LOOP

;; STRING_TO_FP_END
l0245h:
	bit 6,b		;0245	Test bit 6 of B (valid mantissa)
	ret		;0247	Return


; 'CLEAR C' HL''
; ==============
; Loads 00 0000h into the mantissa in C' HL' and clears bit 6 of B

;; CLEAR_CX_HLX_B6
l0248h:
	res 6,b		;0248	Clear bit 6 of B

;; CLEAR_CX_HLX
l024ah:
	exx		;024a	Exchange BC,DE,HL with BC',DE',HL'
	rst 28h		;024b	Call CLEAR_HL
	ld c,l		;024c	Load 00h into C
	exx		;024d	Exchange BC,DE,HL with BC',DE',HL'
	ret		;024e	Return

; 'ADD A DECIMAL NUMBER TO MANTISSA'
; ==================================
; Multiplies floating point number's mantissa in HL' C' by 10 and adds integer 
; in A to it.

; Parameters:
;	HL' C': Input mantissa (24 bit)
;	A: Integer to add
; Returns:
;	HL' BC': Output mantissa (32 bit)
;	DE' A': Unmodified input mantissa (24 bit)
;	Zf: Set if B' is zero

;; FP_MUL_10_ADD_A
l024fh:
	ex af,af'	;024f	
	exx		;0250

	ld d,h		;0251	DE' A' = HL' C'
	ld e,l		;0252
	ld a,c		;0253

	ld b,000h	;0254	Clear B'

	push af		;0256	Push AF' on stack

;		L'	H'	C'	B'	L	H
; ----------------------------------------------------------
;		32 bit mantissa		(MSB)	Exp	Sign

	add hl,hl	;0257	HL' BC' = HL' BC' * 2
	rl c		;0258	
	rl b		;025a	

	add hl,hl	;025c	HL' C' = HL' C' * 2
	rl c		;025d	
	rl b		;025f	

	add hl,de	;0261	HL' BC' = HL' BC' + DE' A'
	adc a,c		;0262	
	ld c,a		;0263	

	ld a,000h	;0264	
	adc a,b		;0266
	ld b,a		;0267

; We now have HL' BC' = HL' BC' * 5

	pop af		;0268	Pop AF' from stack

	push de		;0269	Push DE' to stack

	ld d,000h	;026a	Clear D'

	add hl,hl	;026c	HL' BC' = HL' BC' * 2
	rl c		;026d	
	rl b		;026f

; We now have HL' BC' = HL' BC' * 10 

	ex af,af'	;0271	Exchange AF with AF'

	ld e,a		;0272	Load A into E'

	add hl,de	;0273	HL' BC' = HL' BC' + E'

	ld a,d		;0274	
	adc a,c		;0275	
	ld c,a		;0276	

	ld a,d		;0277
	adc a,b		;0278	
	ld b,a		;0279	

	pop de		;027a	Pop DE' from stack

	exx		;027b	
	ret		;027c	Return

; 'EDIT'
; ======
; "EDIT" BASIC command.

; Edit a line of BASIC with a simple line editor. Takes one integer argument
; which is the line number to edit.

; Delete key was pressed while in line editor mode. Remove one character
; at '_' cursor position.

;; EDIT_DELETE
l027dh:
	ld e,l		;027d	DE' = HL'
	ld d,h		;027e	

l027fh:
	inc de		;027f	(DE') = (DE' + 1)
	ld a,(de)	;0280	
	dec de		;0281	
	ld (de),a	;0282	

	inc de		;0283	Increment DE'

	cp 00dh		;0284 	Loop until end of line is reached
	jr nz,l027fh	;0286	

	jr l02afh	;0288	Continue with EDIT_LOOP

;; EDIT_LEFT
l028ah:
	ld a,l		;028a	Check if cursor is at the beginning of buffer.
	cp 0b6h		;028b	
	jr z,l02afh	;028d	

	dec hl		;028f	Move cursor one position left
	jr l02afh	;0290	Continue with EDIT_LOOP

;; EDIT_RIGHT
l0292h:
	ld a,(hl)	;0292	Check if cursor is at the end of buffer.
	cp 00dh		;0293	
	jr z,l02afh	;0295	

	jr l02eah	;0297	Move cursor one position right
			;	and continue with EDIT_LOOP

; Entry point to the function

;; EDIT
l0299h:
	call l0cd3h	;0299	HL = line number to edit or 0 on error
			;	(call STRING_TO_INT)

	call l07f2h	;029c	DE = start of the BASIC line
			;	(call FIND_LINE)

	jp c,l065ah	;029f	Jump to HOW_RST_PUSH_DE if exact line number
			;	in argument was not found.

	ld a,00ch	;02a2	Clear screen with PUTCH_RST
	rst 20h		;02a4	(print ASCII FF)

	ld hl,02bb6h	;02a5	Load INPUT_BUFFER address into HL

	ld (02a68h),hl	;02a8	Move cursor at the beggining of the buffer
			;	(update CURSOR_POS)

	call l0931h	;02ab	Print the selected line into buffer
			;	(call PRINT_BASIC_LINE)

			;	HL' = address of the last character
			;             in buffer + 1

	exx		;02ae

;; EDIT_LOOP
l02afh:
	ld de,02800h	;02af	Set CURSOR_POS to the top left corner of the
	ld (02a68h),de	;02b2	screen.

; Print the BASIC line in buffer on the screen with the '_' cursor inserted 
; at HL'.

	ld de,02bb6h	;02b6	DE' = INPUT_BUFFER

	ld c,(hl)	;02b9	Save character at HL' in C'
	ld (hl),000h	;02ba	and overwrite it with ASCII NUL

	call l0937h	;02bc	Call PRINTSTR

			;	DE' = address of the first character after 
			;	      inserted ASCII NUL

	ld a,05fh	;02bf	Load cursor character (ASCII '_') into A

	call l07b6h	;02c1	Decrement DE'
			;	Restore character in C' to HL'
			;	Call PUTCH_PRINTSTR

			;	DE' = address of the last character in the
			;	      buffer.

	call l0cf5h	;02c4	Wait for a keypress (call KEY)

	cp 00dh		;02c7	"RETURN" pressed...
	jr z,l033ch	;02c9	...call BASIC_CMDLINE_ENTRY and proceed as if
			;	   the buffer was entered on the command line.

	or a		;02cb	"DELETE" pressed...
	jr z,l027dh	;02cc	...jump to EDIT_DELETE

	cp 01dh		;02ce	"LEFT" pressed...
	jr z,l028ah	;02d0	...jump to EDIT_LEFT

	cp 01eh		;02d2	"RIGHT" pressed...
	jr z,l0292h	;02d4	...jump to EDIT_RIGHT

	jr c,l02afh	;02d6	Ignore any other special keys (scancode < 1eh)
			;	(loop to EDIT_LOOP)

; Alfanumeric key was pressed...

	ld b,a		;02d8	Load ASCII code into B

	push hl		;02d9	Save '_' cursor address on stack

	ld hl,02c34h	;02da	Check there is space in the buffer for
			;	another character.
	rst 10h		;02dd	(call CMP_HL_DE)

	pop hl		;02de	Restore '_' cursor address.

	jr c,l02afh	;02df	Ignore key press that would overflow the
			;	buffer (loop to EDIT_LOOP)

; Make space for the inserted character by moving all character in front
; one position to the right.

l02e1h:
	dec de		;02e1	(DE') = (DE' - 1) 
	ld a,(de)	;02e2	
	inc de		;02e3	
	ld (de),a	;02e4	

	dec de		;02e5	Decrement DE'
	rst 10h		;02e6	Compare with '_' cursor position in HL'

	jr nz,l02e1h	;02e7	Loop until cursor position is reached

	ld (hl),b	;02e9	Insert ASCII code into string

l02eah:
	inc hl		;02ea	Move '_' cursor to the right.
	jr l02afh	;02eb	Loop to EDIT_LOOP

; 'MOVE CURSOR INTO A NEW LINE'
; =============================
; This routine prints a new line if the cursor is not in the upper left corner
; of the screen.

;; NEWLINE
l02edh:
	ld a,(02a68h)	;02ed	Set Zf if cursor in upper left corner of the
	and 01fh	;02f0	screen.

	ld a,00dh	;02f2	Load ASCII CR into A
	ld (02bb5h),a	;02f4	Load 0dh into FIXME

	ret z		;02f7	Print ASCII CR if Zf not set.	
	rst 20h		;02f8
	ret		;02f9

; 'CHECK IF "BREAK" KEY IS PRESSED'
; =================================
; This function checks if "BREAK" key is pressed. If so it executes the BREAK
; routine.

l02fah:
	ld a,(02033h)	;02fa	Check for "DELETE" key press.
	rrca		;02fd	
	ret c		;02fe	Return if key is not pressed. Else check for
			;	BREAK keypress again.

			;	FIXME: Phantom keypress recognition?

;; CHECK_BREAK
l02ffh:
	ld a,(02031h)	;02ff	Check for "BREAK" key press.
	rrca		;0302	 	  
	jr c,l02fah	;0303	If key is pressed (LSB of A is 0), continue 
			;	to the BREAK function. Else jump.

; 'BREAK BASIC INTERPRETER'
; =========================
; This function gets called whenever the "BREAK" key is pressed during the 
; execution of the BASIC interpreter.

;; BREAK
l0305h:
	call l02edh		;0305	cd ed 02 	      
	ld de,l0098h		;0308	11 98 00 	      
	call l0937h		;030b	cd 37 09 	  7   
	ld de,(02a9fh)		;030e	ed 5b 9f 2a 	  [   * 
	ld a,d			;0312	7a 	z 
	or e			;0313	b3 	  
	call nz,l08edh		;0314	c4 ed 08 	      

; 'RESET BASIC (cont.)'
; =====================

;; RESET_BASIC_2
l0317h:
	ei		;0317	Enable interrupts

	call l02edh	;0318	Call NEWLINE

	ld de,l0f07h	;031b	Print "READY" string
	call l0937h	;031e	(call PRINTSTR)

;; BASIC_CMDLINE_LOOP
l0321h:

; Reset BASIC interpreter variables

	rst 28h		;0321	Call CLEAR_HL
	ld de,03031h	;0322	
	ld sp,02aa7h	;0325	

	push de		;0328	Load 3031h into KEY_DIFF	(2aa5-2aa6)
	push hl		;0329	Clear FIXME			(2aa3-2aa4)
	push hl		;032a	Clear FIXME 			(2aa1-2aa2)
	push hl		;032b	Clear BASIC_LINE                (2a9f-2aa0)

	ld hl,(02c36h)	;032c	Load BASIC_START+2 into HL 
	inc hl		;032f	
	inc hl		;0330	

	push hl		;0331	Load HL into 2a9dh (FIXME)

	ld sp,02ba8h	;0332	Restore CPU and arithmetic stack pointers.
	ld ix,02aach	;0335

	call l07bbh	;0339	Get command line (call GETSTR)

; Process string in input buffer and either store a BASIC line to memory or 
; execute and immediate command.

;; BASIC_CMDLINE_ENTRY
l033ch:
	push de		;033c	Push address of the end of the string to stack,

	ld de,02bb6h	;033d	Load INPUT_BUFFER address into DE

	call l0cd3h	;0340	Call STRING_TO_INT

			;	Stores line number in HL, or set Zf if
			;	no line number was entered.

	pop bc		;0343	Restore end address into BC.

	jp z,l038ch	;0344	No line number, jump to IMMEDIATE

; Store the entered BASIC line in memory

; Example: 20 XXX entered on the command line

	dec de		;0347	Store line number at (DE-2)	
	ld a,h		;0348	(two bytes before the start of the line 
	ld (de),a	;0349   contents)
	dec de		;034a
	ld a,l		;034b
	ld (de),a	;034c

	push bc		;034d	Save line end address and line start address
	push de		;034e	on stack.

	ld a,c		;034f	A = C - E
	sub e		;0350	

	push af		;0351	

	call l07f2h	;0352	(call FIND_LINE)

	push de		;0355	Store start address of the next line on stack
	jr nz,l0368h	;0356

; Entered line number doesn't exist yet

	push de		;0358

	call l0811h	;0359	Move DE to the beginning of the line 
			;	(call FIND_LINE_NEXT)

	pop bc		;035c	BC = start address of the next line

	ld hl,(02c38h)	;035d	2a 38 2c 	* 8 , 

	call l0944h	;0360	Call MOVE_MEM

	ld h,b		;0363	60 	` 
	ld l,c		;0364	69 	i 
	ld (02c38h),hl	;0365	22 38 2c 	" 8 , 
l0368h:
	pop bc		;0368	c1 	  
	ld hl,(02c38h)	;0369	2a 38 2c 	* 8 , 
	pop af		;036c	f1 	  
	push hl		;036d	e5 	  
	cp 003h		;036e	fe 03 	    
	jr z,l0321h	;0370	28 af 	(   
	ld e,a		;0372	5f 	_ 
	ld d,000h	;0373	16 00 	    
	add hl,de	;0375	19 	  
	ld de,(02a6ah)	;0376	ed 5b 6a 2a 	  [ j * 
	rst 10h		;037a	d7 	  
	jp nc,00153h	;037b	d2 53 01 	  S   
	ld (02c38h),hl	;037e	22 38 2c 	" 8 , 
	pop de		;0381	d1 	  
	call l094ch	;0382	cd 4c 09 	  L   
	pop de		;0385	d1 	  
	pop hl		;0386	e1 	  
	call l0944h	;0387	cd 44 09 	  D   
	jr l0321h	;038a	Jump to BASIC_CMDLINE_LOOP

; 'PARSE AN IMMEDIATE COMMAND'
; ============================
; Parses and executes a BASIC command entered on the command line.

; Calls PARSE with BASIC_CMDLINE_TABLE

;; IMMEDIATE
l038ch:
	ld hl,l0317h	;038c	Push RESET_BASIC_2 address on stack
	push hl		;038f

	ld l,(l0f0fh-1)&00ffh
			;0390					HL = 0f0eh
	db 1		;0392  					BC = xx

; 'EVALUATE NUMERIC FUNCTIONS'
; ============================
; Evaluates any functions from the numeric function table that appear at DE.

; Calls PARSE with BASIC_FUNC_TABLE.

;; EVAL_FUNCTIONS
l0393h:
	ld l,(l0f9ch-1)&00ffh
			;0393			HL = 0f9bh
	db 1		;0395   		BC = xx		BC = xx
l0396h:
	ld l,0eeh	;0396	HL = 0feeh	

; 'BASIC FUNCTION PARSER'
; =======================
; Parse BASIC commands at DE. 

; Parameters:
;	DE: String containing BASIC commands.
;	L: Low byte of a pointer to the appropriate command table.

;; PARSE
l0398h:
	ld h,00fh	;0398

;; PARSE_FIRST
l039ah:
	call l0105h	;039a	Skip leading space and get first character 
			;	from string in DE (Call EAT_SPACE)

	push de		;039d	Store address of the first character on stack

	inc de		;039e	Increment DE and HL
	inc hl		;039f

	cp (hl)		;03a0	Compare first character with first character
			;	in table

	jr z,l03a9h	;03a1	Jump to PARSE_COMPARE if equal.

	bit 7,(hl)	;03a3	Test MSB of (HL)
	jr nz,l03b3h	;03a5	Jump to PARSE_END if set

	jr l03bah	;03a7	Jump to PARSE_NEXT if characters do not match

; Compares string in DE (BASIC line) with string in HL (BASIC command table)

;; PARSE_COMPARE
l03a9h:
	ld a,(de)	;03a9	Get next character

	inc de		;03aa	Increment DE and HL
	inc hl		;03ab

	cp (hl)		;03ac	Compare character
	jr z,l03a9h	;03ad	Loop if they match

	bit 7,(hl)	;03af	Test MSB of (HL)
	jr z,l03b6h	;03b1	Jump to PARSE_DOT if not set.

; Complete table has been checked and no matching BASIC command has been found

;; PARSE_END
l03b3h:
	dec de		;03b3	Decrement DE
	jr l03c8h	;03b4	Jump to PARSE_MATCH

; A matching BASIC command has been found

;; PARSE_DOT
l03b6h:
	cp 02eh		;03b6	Compare last character with ASCII '.'
	jr z,l03c3h	;03b8	If equal then jump to PARSE_MATCH_PARTIAL
			;	else continue checking with next command in 
			;	the command table.

; Move (HL) to the next entry in the BASIC command table

;; PARSE_NEXT
l03bah:
	inc hl		;03ba	Increment HL until MSB of (HL) is set
	bit 7,(hl)	;03bb	
	jr z,l03bah	;03bd

	inc hl		;03bf	Increment HL
	pop de		;03c0	Restore DE
	jr l039ah	;03c1	Jump to PARSE_FIRST

;; PARSE_MATCH_PARTIAL
l03c3h:
	inc hl		;03c3	Increment HL until MSB of (HL) is set
	bit 7,(hl)	;03c4	
	jr z,l03c3h	;03c6

;; PARSE_MATCH
l03c8h:
	ld a,(hl)	;03c8	HL = (HL) & 7fffh 
	inc hl		;03c9	number in (HL) is big endian!
	ld l,(hl)	;03ca	
	and 07fh	;03cb	
	ld h,a		;03cd

	pop af		;03ce	Removed saved DE from stack
	bit 6,h		;03cf	Test bit 6 of H
	res 6,h		;03d1	Reset bit 6 of H

	push hl		;03d3	Push HL to stack

	call nz,l0a6ah	;03d4	Call EVAL_PAREN_INT if bit 6 of H set.
			;	(get function's argument)

	jp 02ba9h	;03d7	Jump to BASIC_LINK (Returns to address in HL)

; 'START (cont.)'
; ===============
; This is the rest of the boot code (it is executed only once, at power on)

;; START_2
l03dah:
	im 1		;03da	Set interrupt mode 1
	ld iy,l00fdh	;03dc	Load 00fdh into IY 
			;	(default video interrupt hook)

	ld hl,027ffh	;03e0	Load latch address (27ffh) into HL
	ld (hl),l	;03e3	Load ffh into the latch (disable A7 clamp, 
			;	empty character scanline)

	ld b,l		;03e4	Load ffh into B.

; This routine clears the entire RAM, starting at 2800h, if A holds 00h.

l03e5h:
	inc hl		;03e5	Increment HL
	ld (hl),b	;03e6	Load B (ffh) into (HL)
	inc (hl)	;03e7	Increment (HL)
			;	(HL) should now hold 00h if the address in HL
			;	is mapped to RAM.

	jr nz,l03edh	;03e8	If not zero, break from loop 
			;	(reached the end of RAM)

	or (hl)		;03ea	If (HL) | A ...
	jr z,l03e5h	;03eb	... is zero, loop

l03edh:
	ld (02a6ah),hl	;03ed	Store the last address in RAM + 1 into RAM_TOP

	ld sp,02badh	;03f0	Set SP to 2badh 
	ld hl,0c90bh	;03f3	Load c90bh into HL
	push hl		;03f6	Store c9h (ret) into 2bach (VIDEO_LINK)
			;	Store 0bh into 2babh

	dec sp		;03f7	Decrement SP (2baah)
	push hl		;03f8	Store c9h (ret) into 2ba9h (BASIC_LINK)
			;	Store 0bh into 2ba8h (HORIZ_POS)

	ld a,00ch	;03f9	Load 0ch (ASCII FF) into A
	rst 20h		;03fb	Call PUTCH_RST
			;	This clears the screen and places cursor in
			;	the top left corner

; Execution now continues to the NEW command. DE is (probably) set to 0000h 
; after reset (points to the start of the ROM). Since there is no valid ASCII 
; string there the code below behaves as if NEW command was called without an 
; argument.
	
; 'NEW'
; =====
; "NEW" BASIC command line command.

;; NEW
l03fch:
	call l0cd3h	;03fc	Read command argument (BASIC offset)
			;	into HL (if any)
			;	(call STRING_TO_INT)

	ld de,02c3ah	;03ff	Load 2c3ah (USER_MEM) into DE
	add hl,de	;0402	Add DE to HL

	ld sp,02c3ah	;0403	Load 2c3ah (USER_MEM) into SP
	push hl		;0406	Store HL to 2c38 (BASIC_END)
	push hl		;0407	Store HL to 2c36 (BASIC_START)
l0408h:
	jp l0067h	;0408	Jump to RESET_BASIC

; 'RUN'
; =====
; "RUN" BASIC command line command

;; RUN
l040bh:
	call l0cd3h	;040b	Read command argument
			;	(call STRING_TO_INT)

	ld de,(02c36h)	;040e	Load BASIC_START address into DE
l0412h:
	jr l0422h	;0412	Jump to RUN_DO    

; 'CONTINUE'
; ==========
; Continue execution of a BASIC program.

; A call to this function will try to execute the next command on the line
; or will continue to the next line. If a valid command is found this function
; never returns. On the other hand if neither ':' nor line end is encountered, 
; it returns.

;; CONTINUE
l0414h:
	ld (02bb5h),a	;0414	Load A into FIXME

	rst 18h		;0417	Call READ_PAR
	db ':'		;0418	
	db l041dh-$-1	;0419	Check for ':'. If not found jump to CONTINUE_CR

;; ELSE
l041ah:
	pop af		;041a	Remove return address from stack.
	jr l042dh	;041b	Execute the rest of the line 
			;	(jump to RUN_CONT_LINE)

;; CONTINUE_CR
l041dh:
	rst 18h		;041d	Call READ_PAR
	db 00dh		;041e	
	db l0440h-$-1	;041f	Check for ASCII CR. If not found return.

	pop af		;0420	Remove return address from stack and 
			;	execute next BASIC line.

; 'INTERPRET NEXT LINE OF BASIC'
; =============================
; Jump to this location finds the next BASIC line following DE and starts BASIC 
; interpreter at the BASIC.

;; RUN_NEXT_LINE
l0421h:
	rst 28h		;0421	Call CLEAR_HL

;; RUN_DO
l0422h:
	call l07f6h	;0422	Call FIND_LINE_SCOPE

	jr c,l0408h	;0425	Jump to RESET_BASIC if line was not found.

; 'INTERPRET A LINE OF BASIC'
; =============================
; Jump to this location starts BASIC interpreter at the BASIC line at DE.

;; RUN_THIS_LINE
l0427h:
	ld (02a9fh),de	;0427	Load DE into BASIC_LINE
	inc de		;042b	DE = DE + 2 
	inc de		;042c	(points to the ASCII part of the line)

; 'INTERPRET THE REST OF THE LINE'
; ================================
; Jump to this location interprets the rest of the line at DE.

;; RUN_CONT_LINE
l042dh:
	call l02ffh	;042d	Call CHECK_BREAK

	ld ix,02aach	;0430	Load ARITHM_STACK into IX

	ld l,(l0f30h-1)&00ffh	
			;0434	Load 2fh into L

	jp l0398h	;0436	Jump to PARSE with pointer to the
			;	BASIC_CMD_TABLE.

; 'EVALUATE RELATIONAL OPERATORS (cont.)'
; =======================================
; Fetches the next expression at DE and compares its value with the top of 
; the stack.

; Returns:
;	HL: 0000h
;	Flags: result of comparisson

;; EVAL_RELATIONAL_2
l0439h:
	call l068eh	;0439	Call EVAL_ARITHMETIC
	call l0b10h	;043c	Call FP_COMPARE
	rst 28h		;043f	Call CLEAR_HL
l0440h:
	ret		;0440	Return

;; IF
l0441h:
	rst 8			;0441	cf 	  
	ld a,h			;0442	7c 	| 
	or l			;0443	b5 	  
	jr nz,l042dh		;0444	20 e7 	    
	call l081ch		;0446	cd 1c 08 	      

l0449h:
	jr nc,l0427h	;0449	Jump to RUN_THIS_LINE
	jr l0408h	;044b	...else jump to RESET_BASIC

; 'COMMENT'
; =========
; "!" BASIC command. Does nothing. NOTE: An ELSE with IF also points here.

;; COMMENT
l044dh:
	rst 28h		;044d	Call CLEAR_HL
	call l0813h	;044e	Find next line (call FIND_LINE_NEXT_2)
	jr l0449h	;0451	

; 'GOTO'
; ======
; "GOTO" BASIC command.

;; GOTO
l0453h:
	rst 8		;0453	Get command argument
	push de		;0454	Save DE on stack

	call l07f2h	;0455	Call FIND_LINE.
	jp nz,l065bh	;0458	Jump to HOW_RST, if exact line number in
			;	argument was not found.

l045bh:
	pop af		;045b	Remove saved DE from stack.
	jr l0427h	;045c	Jump to RUN_THIS_LINE.

; 'LIST'
; ======
; "LIST" BASIC command line command.

;; LIST
l045eh:
	call l0cd3h	;045e	Read argument into HL (call STRING_TO_INT)

; Note: if called from KEY, HL contains 0000h.

;; LIST_KEY
l0461h:
	call l02edh	;0461	Move cursor to a new line (call NEWLINE)
	call l07f2h	;0464	Find the required BASIC line (call FIND_LINE)
l0467h:
	jr c,l0408h	;0467	Jump to RESET_BASIC if line not found

; Keep printing BASIC lines as long as RETURN or LIST key is pressed.

;; LIST_LOOP
l0469h:
	call l0931h	;0469	Call PRINT_BASIC_LINE
	call l07f6h	;046c	Find the following line (call FIND_LINE_SCOPE)

	jr c,l0467h	;046f	Jump to RESET_BASIC if line not found

;; LIST_KEY_LOOP
l0471h:
	call l02ffh	;0471	Call CHECK_BREAK

	ld a,(02030h)	;0474	Load "RETURN" key status into A
	ld hl,02034h	;0477	Load "LIST" key address into HL
	and (hl)	;047a	
	rrca		;047b	
	jr nc,l0469h	;047c	If either "RETURN" or "LIST" is pressed, loop
			;	to LIST_LOOP

	jr l0471h	;047e	Else loop to LIST_KEY_LOOP

; 'PRINT'
; =======
; "PRINT" BASIC command.

;; PRINT
l0480h:
	rst 18h		;0480	Call READ_PAR
	db ':'		;0481
	db l0488h-$-1	;0482

			;	If ':' follows the PRINT command, just print
			;	a carriage return and continue execution
			;	at the rest of the line.

	ld a,00dh	;0483	Print ASCII CR
	rst 20h		;0485	(call PUTCH_RST)
	jr l042dh	;0486	Jump to RUN_CONT_LINE

l0488h:
	rst 18h		;0488	Call READ_PAR
	db 00dh		;0489	(ASCII CR)
	db l04d1h-$-1	;048a	
	
			;	Jump to PRINT_DO if there is an argument

			;	Just PRINT without and argument prints a
			;	carriage return.

	rst 20h		;048b	Print ASCII CR
l048ch:
	jr l0421h	;048c	Jump to RUN_NEXT_LINE

;; PRINTSTR_QUOTE
l048eh:
	rst 18h		;048e	Call READ_PAR
	db '"'		;048f
	db l04e5h-$-1	;0490	

			;	If the argument doesn't begin with a quote
			;	evaluate its contents. Jump to FIXME

			;	If the argument begins with a quote, print
			;	the quoted string.

	call l0938h	;0491	Print string following command ending with 
			;	'"'. (call PRINTSTR_A)

	jr nz,l048ch	;0494	No closing '"' found. Ignore this error and
			;	jump to RUN_NEXT_LINE

	jr l04adh	;0496	Jump FIXME
;; X$
l0498h:
	ld l,05ch		;0498	2e 5c 	. \ 
	db 001h		;049a	Dummy ld bc,nn (skip next instruction)
;; Y$
l049bh:
	ld l,060h	;049b
l049dh:
	ld h,02ah		;049d	26 2a 	& * 
	call l060eh		;049f	cd 0e 06 	      
l04a2h:
	ld a,(hl)			;04a2	7e 	~ 
	inc hl			;04a3	23 	# 
	or a			;04a4	b7 	  
	jr z,l04adh		;04a5	28 06 	(   
	rst 20h			;04a7	e7 	  
	ld a,l			;04a8	7d 	} 
	and 00fh		;04a9	e6 0f 	    
	jr nz,l04a2h		;04ab	20 f5 	    

l04adh:
	rst 18h		;04ad	Call READ_PAR
	db ','		;04ae
	db l04cbh-$-1	;04af

l04b0h:
	ld a,(02a68h)		;04b0	3a 68 2a 	: h * 
	and 007h		;04b3	e6 07 	    
	jr z,l04ceh		;04b5	28 17 	(   
	ld a,020h		;04b7	3e 20 	>   
	rst 20h			;04b9	e7 	  
	jr l04b0h		;04ba	18 f4 	    
;; AT
l04bch:
	rst 8			;04bc	cf 	  
	ld a,h			;04bd	7c 	| 
	or 028h		;04be	f6 28 	  ( 
	and 029h		;04c0	e6 29 	  ) 
	ld h,a			;04c2	67 	g 
	ld (02a68h),hl		;04c3	22 68 2a 	" h * 
	rst 18h			;04c6	df 	  
	inc l			;04c7	2c 	, 
	ld (bc),a			;04c8	02 	  
	jr l04ceh		;04c9	18 03 	    
l04cbh:
	rst 18h		;04cb	Call READ_PAR
	db ';'		;04cc
	db l04e1h-$-1	;04cd

l04ceh:
	call l0414h		;04ce	cd 14 04 	      

; 'PRINT (cont.)'
; ===============

;; PRINT_DO
l04d1h:
	ld l,(l0fe1h-1)&00ffh	
			;04d1	Jump to PARSE with pointer to the 
	jp l0398h	;04d3	BASIC_PRINT_TABLE

; 'HOME'
; ======
; "HOME" BASIC command

;; HOME
l04d6h:
	call l0cd3h	;04d6	Get command argument (call STRING_TO_INT)

	ld (02a6ch),hl	;04d9	Store argument into WINDOW_LEN

	jr nz,l04e4h	;04dc	If there was a non-zero argument, that is all.
			;	Call BASIC_NEXT

	ld a,00ch	;04de	Load ASCII FF into A
	db 001h		;04e0	Dummy "ld bc,nn" (skip next two instructions)
l04e1h:
	ld a,00dh	;04e1	Load ASCII CR into A

	rst 20h		;04e3	Call PUTCH_RST
l04e4h:
	rst 30h		;04e4	Call BASIC_NEXT

l04e5h:
	call l0396h		;04e5	cd 96 03 	      
	jr nz,l04f1h		;04e8	20 07 	    
	call l0ab2h		;04ea	cd b2 0a 	      
	call l08f6h		;04ed	cd f6 08 	      

; following two lines from Diss_019.jpg
	db 03eh			;04f0	Dummy LD A,
l04f1h:	
	rst 20h			;04f1	e7 	>   

	jr l04adh		;04f2	18 b9 	    
;; CALL
l04f4h:
	call l0974h		;04f4	cd 74 09 	  t   
	rst 8			;04f7	cf 	  
	push de			;04f8	d5 	  
	call l07f2h		;04f9	cd f2 07 	      
	jp nz,l065bh		;04fc	c2 5b 06 	  [   
	ld hl,(02a9fh)		;04ff	2a 9f 2a 	*   * 
	push hl			;0502	e5 	  
	ld hl,(02aa3h)		;0503	2a a3 2a 	*   * 
	push hl			;0506	e5 	  
	rst 28h			;0507	ef 	  
	ld (02aa1h),hl		;0508	22 a1 2a 	"   * 
	add hl,sp			;050b	39 	9 
	ld (02aa3h),hl		;050c	22 a3 2a 	"   * 
	jp l0427h		;050f	c3 27 04 	  '   
;; RET
l0512h:
	ld hl,(02aa3h)		;0512	2a a3 2a 	*   * 
	ld a,h			;0515	7c 	| 
	or l			;0516	b5 	  
	jp z,l065ah		;0517	ca 5a 06 	  Z   
	ld sp,hl			;051a	f9 	  
	pop hl			;051b	e1 	  
	ld (02aa3h),hl		;051c	22 a3 2a 	"   * 
	pop hl			;051f	e1 	  
	ld (02a9fh),hl		;0520	22 9f 2a 	"   * 
	pop de			;0523	d1 	  
l0524h:
	call l0959h		;0524	cd 59 09 	  Y   
	rst 30h			;0527	f7 	  
;; STEP
l0528h:
	rst 8			;0528	cf 	  
	db 001h		;0529	Dummy ld bc,nn (skip next two instructions)

l052ah:
	rst 28h		;052a
	inc hl		;052b
	ld (02a91h),hl		;052c	22 91 2a 	"   * 
	ld hl,(02a9fh)		;052f	2a 9f 2a 	*   * 
	ld (02a93h),hl		;0532	22 93 2a 	"   * 
	ex de,hl			;0535	eb 	  
	ld (02a95h),hl		;0536	22 95 2a 	"   * 
	ld bc,l0005h+5		;0539	01 0a 00 	      
	ld hl,(02aa1h)		;053c	2a a1 2a 	*   * 
	ex de,hl			;053f	eb 	  
	rst 28h			;0540	ef 	  
	add hl,sp		;0541	39 	9 
; Following two lines from Diss_019.jph
	db 03eh			;0542	Dummy LD A,
l0543h:
	add hl,bc		;0543	09 	>   

	ld a,(hl)		;0544	7e 	~ 
	inc hl			;0545	23 	# 
	or (hl)			;0546	b6 	  
	jr z,l055fh		;0547	28 16 	(   
	ld a,(hl)			;0549	7e 	~ 
	dec hl			;054a	2b 	+ 
	cp d			;054b	ba 	  
	jr nz,l0543h		;054c	20 f5 	    
	ld a,(hl)			;054e	7e 	~ 
	cp e			;054f	bb 	  
	jr nz,l0543h		;0550	20 f1 	    
	ex de,hl			;0552	eb 	  
	rst 28h			;0553	ef 	  
	add hl,sp			;0554	39 	9 
	ld b,h			;0555	44 	D 
	ld c,l			;0556	4d 	M 
	ld hl,l0005h+5		;0557	21 0a 00 	!     
	add hl,de			;055a	19 	  
	call l094ch		;055b	cd 4c 09 	  L   
	ld sp,hl			;055e	f9 	  
l055fh:
	ld hl,(02a95h)		;055f	2a 95 2a 	*   * 
	ex de,hl			;0562	eb 	  
	rst 30h			;0563	f7 	  
; 'NEXT'
; ======
; "NEXT" BASIC command

;; NEXT
l0564h:
	call l078bh	;0564	Call LOCATE_VARIABLE_ERR
	ld (02a9bh),hl	;0567	Load variable location into NEXT_VAR
l056ah:
	push de		;056a	Save parser address on stack

	ex de,hl	;056b	DE = NEXT_VAR

	ld hl,(02aa1h)	;056c	Load FOR_POINTER into HL

	ld a,h		;056f
	or l		;0570	
	jp z,l065bh	;0571	Jump to HOW_RST if FOR_POINTER is 0000h

	rst 10h		;0574	Run CMP_HL_DE

	jr z,l0580h	;0575	Jump to FIXME if FOR_POINTER == NEXT_VAR

	pop de		;0577	Remove DE from stack

	call l0959h	;0578	cd 59 09 	  Y   
	ld hl,(02a9bh)	;057b	2a 9b 2a 	*   * 
	jr l056ah	;057e	18 ea 	   

l0580h:
	call l0a45h	;0580	Call PUSH_FP
	call l0a6dh	;0583	Call FP_TO_INT

	ex de,hl	;0586	HL = NEXT variable address
			;	DE = NEXT variabe value

	ld hl,(02a91h)	;0587	Load FOR_STEP value into HL

	push hl		;058a	Save FOR_STEP to the stack

	add hl,de	;058b	HL = current NEXT variable value + FOR_STEP

	push hl		;058c	Save HL on stack

	call l0abch	;058d	Call INT_TO_FP

	ld hl,(02aa1h)	;0590	Load FOR_POINTER into HL
	call l073bh	;0593	Store new value into variable (call POP_FP)

	pop de		;0596	DE = value of the NEXT variable
	ld hl,(02a6eh)	;0597	HL = FOR_TO value 
	pop af	 	;059a	AF = FOR_STEP

	rlca		;059b	07 	  
	jr nc,l059fh	;059c	30 01 	0   

	ex de,hl		;059e	eb 	  
l059fh:
	ld a,h			;059f	7c 	| 
	xor d			;05a0	aa 	  
	jp p,l05a5h		;05a1	f2 a5 05 	      
	ex de,hl			;05a4	eb 	  
l05a5h:
	rst 10h			;05a5	d7 	  
	pop de			;05a6	d1 	  
	jp c,l0524h		;05a7	da 24 05 	  $   
	ld hl,(02a93h)		;05aa	2a 93 2a 	*   * 
	ld (02a9fh),hl		;05ad	22 9f 2a 	"   * 
	jr l055fh		;05b0	18 ad 	    
l05b2h:
	jp z,l0736h		;05b2	ca 36 07 	  6   
l05b5h:
	push hl			;05b5	e5 	  
	call l05fch		;05b6	cd fc 05 	      
	jr c,l05cah		;05b9	38 0f 	8   
	jr z,l05e2h		;05bb	28 25 	( % 
	ex (sp),hl			;05bd	e3 	  
	pop bc			;05be	c1 	  
l05bfh:
	ld a,(bc)			;05bf	0a 	  
	or a			;05c0	b7 	  
	jr z,l05edh		;05c1	28 2a 	( * 
	inc bc			;05c3	03 	  
	call l017eh		;05c4	cd 7e 01 	  ~   
	jr nz,l05bfh		;05c7	20 f6 	    
	ret			;05c9	c9 	  
l05cah:
	pop hl			;05ca	e1 	  
	rst 18h			;05cb	df 	  
; Following lines from Diss_020.jpg
	db '"'			;05cc
	db 000h			;05cd
l05ceh:
	call l05d9h		;05ce	cd d9 05 	  
	jr z,l05edh		;05d1	28 1a 	(   
	inc de			;05d3	13 	  
	call l017eh		;05d4	cd 7e 01 	  ~   
	jr nz,l05ceh		;05d7	20 f5 	    
l05d9h:
	ld a,(de)		;05d9	1a 	  
	cp 00dh		;05da	fe 0d 	    
	ret z			;05dc	c8 	  
	cp 022h		;05dd	fe 22 	  " 
	ret nz			;05df	c0 	  
	inc de			;05e0	13 	  
	ret			;05e1	c9 	  
l05e2h:
	dec de			;05e2	1b 	  
	call l0396h		;05e3	cd 96 03 	      
	jr z,l05cah		;05e6	28 e2 	(   
	pop hl			;05e8	e1 	  
	call l017eh		;05e9	cd 7e 01 	  ~   
	ret z			;05ec	c8 	  
l05edh:
	rst 18h			;05ed	df 	  
	dec hl			;05ee	2b 	+ 
	ld (bc),a			;05ef	02 	  
	jr l05b5h		;05f0	18 c3 	    
	ld (hl),000h		;05f2	36 00 	6   
l05f4h:
	call l017fh		;05f4	cd 7f 01 	     
	ret z			;05f7	c8 	  
	ld (hl),030h		;05f8	36 30 	6 0 
	jr l05f4h		;05fa	18 f8 	    
l05fch:
	call l0125h		;05fc	cd 25 01 	  %   
	ret c			;05ff	d8 	  
l0600h:
	dec de			;0600	1b 	  
	ld a,(de)			;0601	1a 	  
	inc de			;0602	13 	  
	cp 029h		;0603	fe 29 	  ) 
	ret z			;0605	c8 	  
	ld a,(de)			;0606	1a 	  
	cp 024h		;0607	fe 24 	  $ 
	jr z,l060dh		;0609	28 02 	(   
;; FIXME catch all
l060bh:
	xor a			;060b	af 	  
	ret			;060c	c9 	  
l060dh:
	inc de			;060d	13 	  
l060eh:
	ld a,l			;060e	7d 	} 
	sub 05ch		;060f	d6 5c 	  \ 
	jr nz,l061dh		;0611	20 0a 	    
	ld l,070h		;0613	2e 70 	. p 
	rst 18h			;0615	df 	  
	jr z,l061bh		;0616	28 03 	(   
	call l0114h		;0618	cd 14 01 	      
l061bh:
	or h			;061b	b4 	  
	ret			;061c	c9 	  
l061dh:
	cp 007h		;061d	fe 07 	    
	jp nc,l078fh		;061f	d2 8f 07 	      
	ld l,080h		;0622	2e 80 	.   
	or h			;0624	b4 	  
	ret			;0625	c9 	  
;; TAKE
l0626h:
	call l05fch		;0626	cd fc 05 	      
	jr c,l0663h		;0629	38 38 	8 8 
	push de			;062b	d5 	  
	push af			;062c	f5 	  
	push hl			;062d	e5 	  
	ld de,(02a9dh)		;062e	ed 5b 9d 2a 	  [   * 
	ld hl,(02c38h)		;0632	2a 38 2c 	* 8 , 
l0635h:
	rst 18h			;0635	df 	  
	inc hl			;0636	23 	# 
	ld (bc),a			;0637	02 	  
	jr l063dh		;0638	18 03 	    
	rst 18h			;063a	df 	  
	inc l			;063b	2c 	, 
	rrca			;063c	0f 	  
l063dh:
	pop hl			;063d	e1 	  
	pop af			;063e	f1 	  
	call l05b2h		;063f	cd b2 05 	      
l0642h:
	ld (02a9dh),de		;0642	ed 53 9d 2a 	  S   * 
	pop de			;0646	d1 	  
	rst 18h			;0647	df 	  
	inc l			;0648	2c 	, 
	ld b,e			;0649	43 	C 
	jr l0626h		;064a	18 da 	    
l064ch:
	ld a,(de)			;064c	1a 	  
	inc de			;064d	13 	  
	cp 00dh		;064e	fe 0d 	    
	jr nz,l064ch		;0650	20 fa 	    
	inc de			;0652	13 	  
	inc de			;0653	13 	  
	rst 10h			;0654	d7 	  
	jr nc,l0635h		;0655	30 de 	0   
	pop hl			;0657	e1 	  
l0658h:
	pop af			;0658	f1 	  
; from Diss_020.jph

	db 00eh			;0659	Dummy LD,C

; '"HOW?" ERROR RESTART'
; =======================
; This restart is called when an argument for a function or command is invalid.
; (for example out of range)

;; HOW_RST_PUSH_DE
l065ah:
	push de		;065a	Push current parser address on stack.

;; HOW_RST
l065bh:
	call l0799h	;065b	Call BASIC_ERROR
	dm "HOW?", 00dh ;065e

l0663h:
	rst 8			;0663	cf 	  
	push de			;0664	d5 	  
	call l07f2h		;0665	cd f2 07 	      
	inc de			;0668	13 	  
	inc de			;0669	13 	  
	jr l0642h		;066a	18 d6 	    
;; INPUT
l066ch:
	push de			;066c	d5 	  
	ld a,03fh		;066d	3e 3f 	> ? 
	call l07bdh		;066f	cd bd 07 	      
	ld de,02bb6h		;0672	11 b6 2b 	    + 
	rst 18h			;0675	df 	  
	dec c			;0676	0d 	  
	dec b			;0677	05 	  
	pop de			;0678	d1 	  
	call l05fch		;0679	cd fc 05 	      
	rst 30h			;067c	f7 	  
	pop de			;067d	d1 	  
	push de			;067e	d5 	  
	call l05fch		;067f	cd fc 05 	      
	jr c,l065bh		;0682	38 d7 	8   
	push de			;0684	d5 	  
	ld de,02bb6h		;0685	11 b6 2b 	    + 
	call l05b2h		;0688	cd b2 05 	      
	pop de			;068b	d1 	  
	pop af			;068c	f1 	  
	rst 30h			;068d	f7 	  

; 'EVALUATE ARITHMETIC OPERATORS'
; ===============================
; Evaluates an arithmetic expression at DE and returns its value on arithmetic
; stack.

;; EVAL_ARITHMETIC
l068eh:

; Start by checking for a leading "+" or "-" character.

	rst 18h		;068e	Call READ_PAR
	db '-'		;068f	
	db l0697h-$-1	;0690

; Leading "-" sign - add an implicit 0 to arithmetic stack and jump to 
; subtraction.

	rst 28h		;0691	Call CLEAR_HL
	call l0abch	;0692	Call INT_TO_FP
	jr l06abh	;0695	Jump to subtraction

l0697h:	
	rst 18h		;0697	Call READ_PAR
	db '+'		;0698
	db 000h		;0699

; Ignore a leading plus sign. Load level 2 value to arithmetic stack.

	call l06b3h	;069a	Call EVAL_LVL2

; Level 1 - Evaluation of addition and subtraction

;; EVAL_LVL1
l069dh:
	rst 18h		;069d	Call READ_PAR
	db '+'		;069e
	db l06a8h-$-1	;069f

; Addition. Load a value from level 2 and add them together

	call l06b3h	;06a0	Call EVAL_LVL2
	call l0b32h	;06a3	Call FP_ADD
	jr l069dh	;06a6	Jump back to EVAL_LVL1

l06a8h:
	rst 18h		;06a8	Call READ_PAR
	db '-'		;06a9
	db l078ah-$-1	;06aa	Return if operand is neither "+" nor "-"

; Subtraction. Load a value from level 2 and add them together

l06abh:
	call l06b3h	;06ab	Call EVAL_LVL2
	call l0b1eh	;06ae	Call FP_SUB
	jr l069dh	;06b1	Jump back to EVAL_LVL1

; Level 2 - Evaluation of multiplication and division

;; EVAL_LVL2
l06b3h:
	call l0393h	;06b3	Call EVAL_FUNCTIONS
l06b6h:
	rst 18h		;06b6	Call READ_PAR
	db '*'		;06b7
	db l06c1h-$-1	;06b8

; Multiplication

	call l0393h 	;06b9	Call EVAL_FUNCTIONS
	call l0ae6h	;06bc	Call FP_MUL
	jr l06b6h	;06bf	Return back to level 2 evaluation

l06c1h:
	rst 18h		;06c1	Call READ_PAR
	db '/'		;06c2
	db l078ah-$-1 	;06c3	Return if operand is neither "+" nor "-"

; Division

	call l0393h	;06c4	Call EVAL_FUNCTIONS
	call l0af7h	;06c7	Call FP_DIV
	jr l06b6h	;06ca	Return back to level 2 evaluation	  

; 'UNDOT'
; =======
; "UNDOT" BASIC command.

;; UNDOT
l06cch:
	ld a,001h	;06cc	Load 01h into A (Zf = 0, Sf = 0)

	db 001h		;06ce	Dummy ld bc,nn (skip next instruction)

; 'DOT'
; =====
; "DOT" BASIC command.

;; DOT
l06cfh:
	ld a,080h	;06cf	Load 80h into A (Zf = 0, Sf = 1)

	push af		;06d1	Store AF on stack

	rst 18h		;06d2	Call READ_PAR
	db '*'		;06d3
	db l06dah-$-1	;06d4

; DOT* and UNDOT* versions of command: turn clock on or off

	pop af		;06d5	Restore AF from stack

	ld (02bafh),a	;06d6	Store A into CLOCK_ON
	rst 30h		;06d9	Continue with the next command (call BASIC_NEXT)

l06dah:
	pop af		;06da	Restore AF from stack
	db 006h		;06db	Dummy "ld b,nn" (skip next two commands so that
			;	flags remain unchanged)

; 'DOT FUNCTION'
; ==============
; "DOT" BASIC function.

;; DOT_FUNC
l06dch:
	xor a		;06dc	Clear A, set Zf and clear Sf
	and a		;06dd

; Meaning of flags at this point:
;
; Zf	Sf	function
; -----------------------------------------
; 1	x	Query pixel (DOT function)
; 0	0	Clear pixel (UNDOT command)
; 0	1	Draw pixel  (DOT command)

	push af		;06de	Save A on stack

	rst 8		;06df	Get X coordinate (call EVAL_INT_EXP)
	push hl		;06e0	Save X on stack

	call l0005h	;06e1	Get Y coordinate (call EVAL_INT_EXP_NEXT)
	push de		;06e4	Save DE on stack
	ex de,hl	;06e5	Move Y to DE (actually E, since Y < 48)

	ld bc,32	;06e6	Load 32 into BC

	inc e		;06e9	Increment E
	ld hl,02800h	;06ea	Load VIDEO_MEM into HL

; HL = 2800h + 32 * (E / 3)
; A = 1 << (E % 3)

;; DOT_DIV_3_LOOP
l06edh:
	ld d,3		;06ed	Load 3 into D
	ld a,1		;06ef	Load 1 into A

;; DOT_DIV_1_LOOP
l06f1h:
	dec e		;06f1	Decrement E
	jr z,l06feh	;06f2	Break from loop if E = 0

	rlca		;06f4	Rotate A left 2 times
	rlca		;06f5

	dec d		;06f6	Decrement D, loop to DOT_DIV_1_LOOP if not zero
	jr nz,l06f1h	;06f7

	add hl,bc	;06f9	Add 32 to HL for each 3 decrements of E
	res 1,h		;06fa	HL = HL & 01ff
	jr l06edh	;06fc	Loop to DOT_DIV_3_LOOP

; HL contains address of the character line that holds the required graphics
; coordinates.

l06feh:
	ld b,a		;06fe	Save A to B (?)
	pop de		;06ff	Restore DE from stack

	ex (sp),hl	;0700	Save line address to stack, move X to HL

	res 7,l		;0701	X = X & 001f
	res 6,l		;0703

	srl l		;0705	X = X / 2

	jr nc,l070ah	;0707	Shift A left if X odd
	rlca		;0709
l070ah:

	ld h,000h	;070a	Clear H

	pop bc		;070c	Get line address from stack
	add hl,bc	;070d	Add X / 2.

	ld b,a		;070e	Save A to B

	pop af		;070f	Restore flags from stack
	ld a,b		;0710	

; HL now contains the address of the character, A contains the bitmask.

	jr nz,l071fh	;0711	If Zf not set, jump to DOT_DRAW_OR_CLEAR

; Check if pixel is set and return a floating point value 1 or 0

	bit 7,(hl)	;0713	If (HL) is not graphics character (bit 7 not
	jr z,l0718h	;0715	set), jump over and return 0.

	and (hl)	;0717	Check if bit in A is set in (HL)
l0718h:
	rst 28h		;0718	Call CLEAR_HL

	jr z,l071ch	;0719	If bit was set HL = 1 else HL = 0
	inc hl		;071b
l071ch:
	jp l0abch	;071c	Jump to INT_TO_FP and return

; Draw or clear the pixel

;; DOT_DRAW_OR_CLEAR
l071fh:
	push af		;071f	Save flags on stack

	bit 7,(hl)	;0720	If (HL) is not already a graphics character
	jr nz,l0726h	;0722	write a blank character (80h).
	ld (hl),080h	;0724	
l0726h:

	pop af		;0726	Restore flags from stack
	jp m,l072dh	;0727	If sign negative, draw a pixel, else clear
			;	a pixel.

	cpl		;072a	Clear bit in A in (HL)
	and (hl)	;072b 	
	db 006h		;072c	Dummy ld b,nn (skip next instruction)
l072dh:
	or (hl)		;072d	Set bit in A in (HL)

	ld (hl),a	;072e	Store result back to (HL)
	rst 30h		;072f	Continue with the next command (call BASIC_NEXT)

l0730h:
	call l078bh	;0730	Call LOCATE_VARIABLE_ERR

	rst 18h		;0733	Call READ_PAR
	db '='		;0734
	db l078fh-$-1	;0735	Else jump to WHAT_RST

l0736h:
	push hl			;0736	e5 	  
	call l0ab2h		;0737	cd b2 0a 	      
	pop hl			;073a	e1 	  

; 'POP FLOATING POINT NUMBER FROM STACK'
; ======================================
; Fetches a floating point number from the top of the arithmetic stack and
; stores it in 4-byte format at (HL).

; IX Offset	0	1	2	3	4
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

; IX Offset	0        1        2	   3        4
; -------------------------------------------------------------
;		MMMMMMMM MMMMMMMM 1MMMMMMM EEEEEEEE S0000000
;		(LSB)		  (MSB)

; HL Offset	0        1        2	   3
; --------------------------------------------------
;		MMMMMMMM MMMMMMMM EMMMMMMM SEEEEEEE
;		(LSB)		  (MSB)

;; POP_FP
l073bh:
	call l090eh	;073b	Call SUB_IX_5

	ld bc,0004h	;073e	Load 4 into BC
	push de		;0741	Save HL and DE to stack
	push hl		;0742	

	ex de,hl	;0743	Store HL to DE
	push ix		;0744   Store IX to HL
	pop hl		;0746	

	ldir		;0747	Transfer 4 bytes from (IX) to (HL)
			;	DE = DE_orig + 4

	ex de,hl	;0749	Restore HL and DE

	dec hl		;074a	HL = HL_orig + 2
	dec hl		;074b
	rl (hl)		;074c	Rotate left (HL_orig + 2)

	inc hl		;074e	HL = HL_orig + 3
	ld a,(ix+4)	;074f	Sign bit to Cf
	rla		;0752	
	rr (hl)		;0753	Store sign bit to MSB of (HL_orig + 3)
			;	LSB of exponent to Cf.

	dec hl		;0755	HL = HL_orig + 2
	rr (hl)		;0756	Store LSB of exponent in MSB of (HL_orig + 2)

	pop hl		;0758	Restore HL and DE from stack
	pop de		;0759	
	ret		;075a	Return

;; CATCH-ALL-COMMAND
l075bh:
	call l05fch		;075b	cd fc 05 	      
	jr c,l0768h		;075e	38 08 	8   
	push af			;0760	f5 	  
	rst 18h			;0761	df 	  
	dec a			;0762	3d 	= 
	dec hl			;0763	2b 	+ 
	pop af			;0764	f1 	  
	call l05b2h		;0765	cd b2 05 	      
l0768h:
	rst 30h			;0768	f7 	  

;; PTR
l0769h:
	ld h,d			;0769	62 	b 
	ld l,e			;076a	6b 	k 
	call l05fch		;076b	cd fc 05 	      
	jr l071ch		;076e	18 ac 	    
;; VAL
l0770h:
	push de			;0770	d5 	  
	ex de,hl			;0771	eb 	  
	call l0ab2h		;0772	cd b2 0a 	      
	pop de			;0775	d1 	  
	ret			;0776	c9 	  

; 'BASIC NUMERIC EXPRESSION EVALUATION' 
; =====================================
; This function is called if no other BASIC function matches. It evaluates a
; numeric expression at DE.

;; NUMBER
l0777h:
	call l0125h	;0777	Call LOCATE_VARIABLE

	jp nc,l0a45h	;077a	Store variable contents on stack and return
			;	(call PUSH_FP)

; Not a variable

	call l01a2h	;077d	Call STRING_TO_FP
	ret nz		;0780	Return if valid.

; Not a constant

; 'EVALUATE PARENTHESIS'
; ======================
; This function evaluates an expression enclosed in parenthesis at DE 
; and returns its value on the top of arithmetic stack.

;; EVAL_PAREN
l0781h:
	rst 18h		;0781	Call READ_PAR
	db '('		;0782	
	db l078fh-$-1	;0783	If '(' not found, jump to WHAT_RST

	call l0ab2h	;0784	Call EVAL_EXPRESSION

	rst 18h		;0787	Call READ_PAR
	db ')'		;0788
	db l078bh-$-1	;0789

l078ah:
	ret		;078a	Return if closing ')' found

; Closing ')' not found.

; 'LOCATE VARIABLE OR ERROR'
; ==========================
; Like LOCATE_VARIABLE, but jumps to "WHAT?" error if variable is not found.

;; LOCATE_VARIABLE_ERR
l078bh:
	call l0125h	;078b	Call LOCATE_VARIABLE

	ret nc		;078e	Return if variable found, else continue to 
			;	WHAT_RST

; '"WHAT?" ERROR RESTART'
; =======================
; This restart is called when an unknown function or command is called.

;; WHAT_RST
l078fh:
	push de			;078f	Store current parser address on stack.

	call l0799h		;0790	Store address of the "WHAT?" string
				;	on the stack and call BASIC_ERROR.

	dm "WHAT?", 00dh	;0793

; 'BASIC ERROR'
; =============
; Pointer to the error message is the first 16 bit value on the CPU stack. 
; Current parser address is the second 16 bit value on the CPU stack.

;; BASIC_ERROR
l0799h:
	pop de		;0799	Load address of the error message into DE

	call l0937h	;079a	Call PRINTSTR

	ld de,(02a9fh)	;079d	Load BASIC_LINE into DE

	ld a,e		;07a1	
	or d		;07a2	Set Z flag if BASIC_LINE is zero.

	ld hl,l0317h	;07a3	Load RESET_BASIC_2 address into
	ex (sp),hl	;07a6	the address at the top of the stack
			;	and store stack value into HL.

			;	Top of the stack stores the current parser 
			;	address or return address of the calling 
			;	function.

	ret z		;07a7	Return into RESET_BASIC_2 if BASIC_LINE = 0

	rst 10h		;07a8	Call CMP_HL_DE

	ret c		;07a9	Return into RESET_BASIC_2 if 
			;	BASIC_LINE > current parser address

			;	(stack did not contain a valid parser address)

	ld c,(hl)	;07aa	Save character at current parser addr. into C
	push bc		;07ab	Store BC on stack

	ld (hl),000h	;07ac	Store 00h (ASCII NUL) to current parser addr.
	push hl		;07ae	Store HL on stack

	call l0931h	;07af	Call PRINT_BASIC_LINE

	pop hl		;07b2	Restore BC and HL from stack.
	pop bc		;07b3

	ld a,03fh	;07b4	Load ASCII '?' into A



l07b6h:
	dec de		;07b6	DE = BASIC_LINE - 1
	ld (hl),c	;07b7	Restore character at the current parser 
			;	address.

	jp l0936h	;07b8	Jump to	PUTCH_PRINTSTR and return into
			;	RESET_BASIC_2

; 'GET STRING FROM KEYBOARD'
; ==========================
; This function reads a string from the keyboard into the input buffer. String
; is terminated with ASCII CR. Some minimal editing is supported ("LEFT" key
; acts as a backspace, "SHIFT-DELECT" clears the buffer and screen)

; Returns:
;	DE: Address of the last character in the string + 1

;; GETSTR
l07bbh:
	ld a,'>'	;07bb	Load prompt into A

l07bdh:
	ld de,02bb6h	;07bd	Load INPUT_BUFFER address into DE
	rst 20h		;07c0 	Display prompt.

;; GETSTR_LOOP_CURS
l07c1h:
	exx		;07c1
	ld (hl),'_'	;07c2	Print cursor at location (HL')
	exx		;07c4	Note: HL' is set by PUTCH_RST.

;; GETSTR_LOOP
l07c5h:
	call l0cf5h	;07c5	Read a key and print it (call KEY)
	rst 20h		;07c8	(call PUTCH_RST)

	exx		;07c9	
	ld (hl),'_'	;07ca	Print cursor
	exx		;07cc

	cp 00dh		;07cd	
	jr z,l07ddh	;07cf	"ENTER" pressed, jump to GETSTR_ADD

	cp 01dh		;07d1	
	jr z,l07eah	;07d3	"LEFT" pressed, jump to GETSTR_BACKSPACE

	cp 00ch		;07d5
	jr z,l07bbh	;07d7	"SHIFT-DELETE" pressed - begin from the start

	cp 020h		;07d9	 	    
	jr c,l07c5h	;07db	Ignore if key code is less than 20h otherwise

;; GETSTR_ADD
l07ddh:
	ld (de),a	;07dd	Load ASCII code of the pressed key into the
	inc de		;07de	buffer and increment DE

	cp 00dh		;07df	If "ENTER" was pressed, return.
	ret z		;07e1

	ld a,e		;07e2	Compare DE with 2c36h (end of buffer)
	cp 034h		;07e3

	jr nz,l07c5h	;07e5	If end of buffer not reached, 
			;	loop to GETSTR_LOOP...

	ld a,01dh	;07e7	...else delete last pressed character from the
	rst 20h		;07e9	   screen and buffer.

;; GETSTR_BACKSPACE
l07eah:
	ld a,e		;07ea	Compare DE with 2bb6h (start of buffer)
	cp 0b6h		;07eb	
	jr z,l07bbh	;07ed	If not at start of buffer decrement DE
	dec de		;07ef	
	jr l07c1h	;07f0	Jump to GETSTR_LOOP_CURS    

; 'FIND BASIC LINE'
; =================
; Finds BASIC line with line number equal or greater than HL in the entire 
; BASIC code.

;; FIND_LINE
l07f2h:
	ld de,(02c36h)	;07f2	Load BASIC_START into DE and continue with
			;	FIND_LINE_SCOPE

; 'FIND BASIC LINE IN SCOPE'
; ==========================
; Finds BASIC line with line number equal or greater than HL, starting at DE. 
; If line number was not found after DE, Cf is set.

; Parameters:
;	DE: Pointer to the start of a BASIC line where the search starts.
;	HL: Line number to find.
; Returns:
;	DE: Pointer to the start of the BASIC line if a matching line number 
;           is found
;	Cf: Set if line number was not found.
;	Zf: Set if line number found is equal to HL.

;; FIND_LINE_SCOPE
l07f6h:
	push hl		;07f6	Save HL on stack

; Check if DE is within the expected margins of the BASIC program.

	ld hl,(02c36h)	;07f7	Load BASIC_START-1 into HL
	dec hl		;07fa

	rst 10h		;07fb	(call CMP_HL_DE)
	jp nc,l0317h	;07fc	Jump to RESET_BASIC_2 if DE < BASIC_START

	ld hl,(02c38h)	;07ff	Load BASIC_END-1 into HL
	dec hl		;0802

	rst 10h		;0803	(call CMP_HL_DE)

	pop hl		;0804	Restore HL

	ret c		;0805	Return if DE >= BASIC_END

	ld a,(de)	;0806	Subtract HL from 16-bit line number at (DE)
	sub l		;0807	
	ld b,a		;0808
	inc de		;0809	
	ld a,(de)	;080a	
	sbc a,h		;080b	BA = (DE)-HL

l080ch:
	jr c,l0812h	;080c	Jump to FIND_LINE_NEXT if HL > line number

	dec de		;080e	Decrement DE

	or b		;080f	Check if HL is equal to line number at (DE)

	ret		;0810	Return

l0811h:
	inc de		;0811	Increment DE

; Increments DE until start of the next BASIC line.

;; FIND_LINE_NEXT
l0812h:
	inc de		;0812	Increment DE (points to first character after
			;	line number)

; 'FIND NEXT BASIC LINE'
; ========================
; A call to this location moves DE to the start of the next BASIC line if 
; HL contains 0000h.

;; FIND_LINE_NEXT_2
l0813h:
	ld a,(de)	;0813	Load character into A

	cp 00dh		;0814
	jr nz,l0812h	;0816	Loop until equal to CR

l0818h:
	inc de		;0818	Increment DE (points to line number of the next
			;	line)

	jr l07f6h	;0819	Loop

;; FIXME: catch all
l081bh:
	inc de			;081b	13 	  
l081ch:
	ld a,(de)			;081c	1a 	  
	rst 28h			;081d	ef 	  
	cp 00dh		;081e	fe 0d 	    
	jr z,l0818h		;0820	28 f6 	(   
	cp 021h		;0822	fe 21 	  ! 
	jr z,l0812h		;0824	28 ec 	(   
	cp 022h		;0826	fe 22 	  " 
	jr nz,l0834h		;0828	20 0a 	    
l082ah:
	inc de			;082a	13 	  
	ld a,(de)			;082b	1a 	  
	cp 00dh		;082c	fe 0d 	    
	jr z,l0818h		;082e	28 e8 	(   
	cp 022h		;0830	fe 22 	  " 
	jr nz,l082ah		;0832	20 f6 	    
l0834h:
	cp 045h		;0834	fe 45 	  E 
	jr nz,l081bh		;0836	20 e3 	    
	ld l,0f6h		;0838	2e f6 	.   
	jp l0398h		;083a	c3 98 03 	      

; 'PRINT A FLOATING POINT NUMBER (cont.)'
; =======================================
; Prints a floating point number on the top of the arithmetic stack at the 
; current cursor position. Number must not be zero.

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; PRINTFP_DO


; First print the sign character and make the floating point number positive.

l083dh:
	ld a,(ix-1)	;083d	Load sign bit into A
	and a		;0840	
	ld a,' '	;0841	If sign is positive, store ASCII ' ' in A
			;	else store ASCII '-'.
	jr z,l0847h	;0843	
	ld a,'-'	;0845
l0847h:

	rst 20h		;0847	Print sign character (call PUTCH_RST)

	xor a		;0848
	ld (ix-1),a	;0849	Clear sign bit.

	dec a		;084c	A = -1

; Convert the number into floating point format with base of exponent 10.

;; PRINTFP_MUL10_LOOP
l084dh:
	push af		;084d	Store AF to stack

	ld hl,l002ch	;084e	Load FP_ONE_OVER_TEN address into HL

	call l0b05h	;0851	Call FP_COMPARE_HL

	jr nc,l0863h	;0854	If number printed is greater or equal to 0.1, 
			;	jump to next step.

	call l0ae3h	;0856	Multiply number by 10 (call FP_MUL_10)

	pop af		;0859	Restore AF from stack

	dec a		;085a	Decrement A

	jr l084dh	;085b	Jump to PRINTFP_MUL10_LOOP

;; PRINTFP_DIV10_LOOP
l085dh:
	call l0af4h	;085d	Divide number by 10 (call FP_DIV_10)
	pop af		;0860	Restore AF from stack
	inc a		;0861	Increment A
	push af		;0862	Save AF to stack

l0863h:
	ld hl,l00a0h	;0863	Load FP_ONE address into HL
	call l0b05h	;0866	Call FP_COMPARE_HL

	jr nc,l085dh	;0869	If number is greater or equal to 1,
			;	jump to PRINTFP_DIV10_LOOP

; M = abs( N * 10^(-1 - A) )

; 1 > M >= 0.1

; where N is the original number, and M is the number in HL' C' HL and at the
; top of the arithmetic stack. A is stored at the top of the arithmetic stack.

	ld a,(ix-2)	;086b	Load negative exponent (base 2) into A
	neg		;086e

; Apply base 2 exponent to the number's mantissa

;; PRINTFP_APPLY_EXP2
l0870h:
	jr z,l087dh	;0870	Break from loop if exponent is zero.
	exx		;0872
	srl c		;0873	Shift mantissa right (divide by 2)
	rr h		;0875
	rr l		;0877
	exx		;0879
	dec a		;087a	Decrement exponent
	jr l0870h	;087b	Loop to PRINTFP_APPLY_EXP2


; M = O * 2^(-24)

; where O is the number in HL' C'

; Build 8 digit binary-coded decimal at the top of the arithmetic stack

l087dh:
	ld b,7		;087d	B = 7
	push ix		;087f	HL = IX (top of arithmetic stack)
	pop hl		;0881	
	ld (hl),000h	;0882	Load 0 into first BCD digit.
	inc hl		;0884	Increment HL

; This loop multiplies O by 10 in each iteration and stores the part of O
; that is before decimal point into (HL)

;; PRINTFP_BCD_LOOP
l0885h:

	xor a		;0885	Clear A
	call l024fh	;0886	Call FP_MUL_10_ADD_A

	exx		;0889	
	ld a,b		;088a
	exx		;088b
	ld (hl),a	;088c	Load B' (mantissa overflow) into HL
	inc hl		;088d	Increment HL

	djnz l0885h	;088e	Loop 7 times to PRINTFP_BCD_LOOP

; HL	-8	-7	-6	-5	-4	-3	-2	-1
; -------------------------------------------------------------------
;	0	X	X	X	X	X	X	Y

;	<-- most significant                least significant --> 

; P = M * 10^7 = abs( N * 10^(6 - A) )

; Round the lowest X digit up, if Y digit >= 5.

	ld bc,l0600h	;0890	B = 6
			;	C = 0 	

	dec hl		;0893	Decrement HL
	ld a,(hl)	;0894	
	cp 5		;0895	Compare last digit with 5

; Propagate carry and also set the bitmap in C

;; PRINTFP_ROUND_LOOP
l0897h:
	ccf		;0897	Cf set if >=5, reset if <5
			;	Cf set if carry from the previous decimal digit.

	ld a,0		;0898	Add 1 to the digit one place higher if Cf set.
	dec hl		;089a	
	adc a,(hl)	;089b
	sla c		;089c	Shift C left
	cp 10		;089e	Compare corrected digit with 10

	jr c,l08a4h	;08a0	
	ld a,000h	;08a2	Load 0 into A if greater or equal to 10
l08a4h:

	ld (hl),a	;08a4	Load corrected digit into (HL)
	push af		;08a5	Save Cf on stack

	and a		;08a6	
	jr z,l08abh	;08a7	If digit not zero, set bit 0 of C.
	set 0,c		;08a9	
l08abh:
	pop af		;08ab	Restore Cf from stack
	djnz l0897h	;08ac	Loop 6 times to PRINTFP_ROUND_LOOP

	ld a,c		;08ae	Load bitmask into A

	pop bc		;08af	Restore exponent from stack into B
	jr c,l08b8h	;08b0	If no carry on the most significant digit, 
			;	break from loop...
	inc b		;08b2   ...else increment base 10 exponent
	push bc		;08b3	   Save exponent back to stack

	ld b,001h	;08b4	  
	jr l0897h	;08b6      loop one more time to PRINTFP_ROUND_LOOP

; P = abs( N * 10^(6 - A) )

l08b8h:
	ld c,a		;08b8	Move bitmask back to C
	ld a,b		;08b9	Move exponent back to A

	inc a		;08ba	Jump to PRINTFP_EXP if A not between 0 and 6
	jp m,l08c8h	;08bb	
	cp 7		;08be	
	jr nc,l08c8h	;08c0	

; No exponential notation necessary. Just print the mantissa and exit.

	ld b,a		;08c2	Exponent to B
	call l091ch	;08c3	Call PRINT_BCD

	jr l090bh	;08c6	Finish (remove stored values from stack, and
			;	return)

; Number either too large or too small. Print in exponential notation.

;; PRINTFP_EXP
l08c8h:
	push bc		;08c8	Save exponent and bitmask to stack

	ld b,001h	;08c9	Print mantissa 	
	call l091ch	;08cb	(call PRINT_BCD)

	ld a,'E'	;08ce	Print exponent character 'E'
	rst 20h		;08d0

; Convert exponent into decimal and print it.

	pop bc		;08d1	Restore BC from stack

	bit 7,b		;08d2	Check sign bit of the exponent

	ld a,'+'	;08d4	
	jr z,l08e0h	;08d6	If exponent positive, jump to PRINTFP_EXP_POS

; Exponent base 10 is negative

	ld a,'-'	;08d8	Print minus sign
	rst 20h		;08da	(call PUTCH_RST)

	ld a,b		;08db	Load negative exponent base 10 into A
	neg		;08dc	
	jr l08e2h	;08de	Jump to PRINTFP_EXP_ABS

;; PRINTFP_EXP_POS
l08e0h:
	rst 20h		;08e0	Print plus sign (call PUTCH_RST)
	ld a,b		;08e1	Load exponent base 10 into A

; Absolute value of exponent base 10 in A. Now split exponent into two decimal
; digits: B contains tens (+ ASCII offset), A contains ones.

;; PRINTFP_EXP_ABS
l08e2h:
	ld b,'0'	;08e2	Initialize B
l08e4h:
	cp 10		;08e4	
	jr c,l0904h	;08e6	Jump to PRINTFP_END if number of ones is less 
			;	than 10.

	add a,-10	;08e8	Subtract 10 from number of ones and add 1 to
	inc b		;08ea 	the number of tens.

	jr l08e4h	;08eb	Loop

; 'PRINT A 16 BIT NUMBER'
; =======================
; Prints a 16 bit number at DE to the screen at current cursor position.

; Parameters:
;	DE: Pointer to the 16 bit number to print.
; Returns:
;	DE: DE + 2

;; PRINT_WORD
l08edh:
	ld a,(de)	;08ed	Load BASIC line number (at DE) into HL and
	ld l,a		;08ee	DE = DE + 2
	inc de		;08ef	
	ld a,(de)	;08f0	
	ld h,a		;08f1	
	inc de		;08f2

	call l0abch	;08f3	Push line number to arithmetic stack
			;	(Call INT_TO_FP)

; 'PRINT A FLOATING POINT NUMBER'
; ===============================
; Prints a floating point number on the top of the arithmetic stack at the 
; current cursor position.

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; PRINTFP
l08f6h:
	push de		;08f6	Save BC,DE and HL to stack
	push bc		;08f7	
	push hl		;08f8

	ld a,(ix-2)	;08f9	
	cp 080h		;08fc	
	jp nz,l083dh	;08fe	Jump to PRINTFP_DO if line number is not 0

	xor a		;0901	Clear A
	ld b,020h	;0902	Load ASCII ' ' into B

;; PRINTFP_END
l0904h:
	or 030h		;0904	Convert integer in A to ASCII numeral
	ld c,a		;0906	and store it into C

	ld a,b		;0907	Print character in B
	rst 20h		;0908	(Call PUTCH_RST)
	ld a,c		;0909	Print character in C
	rst 20h		;090a	(Call PUTCH_RST)

l090bh:
	pop hl		;090b	Restore HL and BC from stack
	pop bc		;090c

; 'STORE ARITHMETIC RESULT & RETURN (cont.)'
; ==========================================
; Restores DE register from CPU stack, removes the top value from the 
; arithmetic stack and returns.

;; STORE_ARITHM_RET_2
l090dh:
	pop de		;090d	

; 'SUB IX,5'
; ==========
; Subtracts 5 from the contents of the IX register. Stores -5 in BC.

;; SUB_IX_5
l090eh:
	ld bc,0fffbh	;090e	Load -5 into BC

; ADD_IX_10 jumps here
l0911h:
	add ix,bc	;0911	Add BC to IX
	ret		;0913	Return

; 'CORRECT EXPONENT & ADD IX,10'
; ==============================
; Corrects exponent of FP number in HL C' HL' and adds 10 to IX (

;; CORRECT_EXP_ADD_IX_10
l0914h:
	call l0c4ch	;0914	Call CORRECT_EXP

; 'ADD IX,10'
; ===========
; Adds 10 to the contents of the IX register. Stores 10 in BC.

;; ADD_IX_10
l0917h:
	ld bc,0000ah	;0917	Load 10 into BC
	jr l0911h	;091a	Jump forward

; 'PRINT A BINARY-CODED DECIMAL NUMBER'
; =====================================
; Prints a BCD number at HL. Each byte represents one digit. B holds the number
; of digits before decimal point.

; Parameters:
;	HL: Pointer to the BCD number.
;	B: Location of the decimal point (after B digits)
;	C: Bitmap of the digits (0 means zero digit, 1 means non-zero digit)

; BCD digit	HL+7	HL+6	HL+5	HL+4	HL+3	HL+2	HL+1	HL
; C bit		7	6	5	4	3	2	1	0

;; PRINT_BCD
l091ch:
	inc b		;091c 	

;; PRINT_BCD_LOOP
l091dh:
	djnz l0922h	;091d	Decrement B. 

	ld a,'.'	;091f	Print decimal point if B == 0
	rst 20h		;0921	(call PUTCH_RST)
l0922h:

	ld a,(hl)	;0922	Print BCD digit in (HL)
	or 030h		;0923	
	rst 20h		;0925	(call PUTCH_RST)

	inc hl		;0926	Move HL to the next digit.

	srl c		;0927	Shift C right and...
	jr nz,l091dh	;0929	...loop to PRINT_BCD_LOOP if there are further 
			;	   non-zero digits

; There are only zeroes left. Note: B remains unmodified.

	dec b		;092b	
	dec b		;092c	
	ret m		;092d	Return if B <= 1  
	inc b		;092e	

	jr l091ch	;092f	Restart to PRINT_BCD.

; 'PRINT A BASIC LINE TO SCREEN'
; ==============================
; Print a complete BASIC line to screen. First the line number is printed,
; followed by ASCII space and line contents.

; Parameters:
;	DE: Pointer to the BASIC line.

;; PRINT_BASIC_LINE
l0931h:
	call l08edh	;0931	Print line number (call PRINT_WORD)
	ld a,020h	;0934	Load ASCII ' ' into A

; 'PRINT A CHARACTER FOLLOWED BY A STRING TO SCREEN'
; ==================================================
; Call PUTCH_RST and PRINTSTR

;; PUTCH_PRINTSTR
l0936h:
	rst 20h		;0936	Call PUTCH_RST

; 'PRINT A STRING TO SCREEN'
; ==========================
; Print a string of characters at (DE) to the screen at the current cursor 
; position (CURSOR_POS).

; String must be terminated with 00h (NUL) or 0d (CR). In the second case a
; new line added at the end of the string.

; Parameters:
;	DE: Address of the first character in the string.
; Returns:
;	Zf: Set if string ended with NUL, reset if it ended with CR.
;	HL': Address of the last printed character on screen + 1
;	DE: Address of the last read character + 1
; Destroys:
;	A,B,flags

;; PRINTSTR
l0937h:
	xor a		;0937	A = ASCII NUL

; 'PRINT A STRING TO SCREEN ENDING ON A'
; ======================================
; Like PRINTSTR, except string is terminated with character in A (which is not 
; printed) or CR (which is printed).

; Returns:
;	Zf: Set if string ended with character in A, reset if it ended with CR.

;; PRINTSTR_A
l0938h:
	ld b,a		;0938	Load A into B

l0939h:
	ld a,(de)	;0939	Load character pointed by DE into A
	inc de		;093a	Increment DE

	cp b		;093b	Compare A with B...
	ret z		;093c	...and return if equal

	rst 20h		;093d	Call PUTCH_RST

	cp 00dh		;093e	Compare A with 0dh (CR)...
	jr nz,l0939h	;0940	...and loop if not equal

	inc a		;0942	Increment A
	ret		;0943	Return.

; 'MOVE MEMORY BLOCK'
; ===================
;
; -------------     -------------
; |source     |     |destination|
; -------------     -------------
; ^            ^    ^
; |            |    |
; DE           HL   BC

;; MOVE_MEM
l0944h:
	rst 10h		;0944	Call CMP_HL_DE
	ret z		;0945	Return if HL == DE

	ld a,(de)	;0946	(BC) = (DE)
	ld (bc),a	;0947	

	inc de		;0948	Increment BC and DE
	inc bc		;0949	

	jr l0944h	;094a	Loop

l094ch:
	ld a,b			;094c	78 	x 
	sub d			;094d	92 	  
	jr nz,l0953h		;094e	20 03 	    
	ld a,c			;0950	79 	y 
	sub e			;0951	93 	  
	ret z			;0952	c8 	  
l0953h:
	dec de			;0953	1b 	  
	dec hl			;0954	2b 	+ 
	ld a,(de)			;0955	1a 	  
	ld (hl),a			;0956	77 	w 
	jr l094ch		;0957	18 f3 	    
l0959h:
	pop bc			;0959	c1 	  
	pop hl			;095a	e1 	  
	ld (02aa1h),hl		;095b	22 a1 2a 	"   * 
	ld a,h			;095e	7c 	| 
	or l			;095f	b5 	  
	jr z,l0972h		;0960	28 10 	(   
	pop hl			;0962	e1 	  
	ld (02a91h),hl		;0963	22 91 2a 	"   * 
	pop hl			;0966	e1 	  
	ld (02a6eh),hl		;0967	22 6e 2a 	" n * 
	pop hl			;096a	e1 	  
	ld (02a93h),hl		;096b	22 93 2a 	"   * 
	pop hl			;096e	e1 	  
	ld (02a95h),hl		;096f	22 95 2a 	"   * 
l0972h:
	push bc			;0972	c5 	  
	ret			;0973	c9 	  

l0974h:
	ld hl,-02b38h	;0974	     
	pop bc		;0977	Remove BC from stack
	add hl,sp	;0978	 
	jp nc,l0153h	;0979	Jump to SORRY_RST_PUSH_DE if SP < 2b38h

	ld hl,(02aa1h)	;097c	2a a1 2a 	*   * 
	ld a,h		;097f	7c 	| 
	or l		;0980	b5 	  
	jr z,l0996h	;0981	28 13 	(   

	ld hl,(02a95h)		;0983	2a 95 2a 	*   * 
	push hl			;0986	e5 	  
	ld hl,(02a93h)		;0987	2a 93 2a 	*   * 
	push hl			;098a	e5 	  
	ld hl,(02a6eh)		;098b	2a 6e 2a 	* n * 
	push hl			;098e	e5 	  
	ld hl,(02a91h)		;098f	2a 91 2a 	*   * 
	push hl			;0992	e5 	  
	ld hl,(02aa1h)		;0993	2a a1 2a 	*   * 

l0996h:
	push hl			;0996	e5 	  
	push bc			;0997	c5 	  
	ret			;0998	c9 	  

; 'EVALUATE RELATIONAL OPERATORS'
; ===============================
; Evaluates a relational operator at DE and returns HL = 1 if true or HL = 0
; if false.

; If a relational expression is not found, it returns two functions up.

; Returns:
;	HL: Result of the relational operator.

;; EVAL_RELATIONAL
l0999h:
	rst 18h		;0999	Call READ_PAR
	db '>'		;099a
	db l09a3h-$-1	;099b

	call l0439h	;099c	Call EVAL_RELATIONAL_2

	ret z		;099f	Return HL = 1 if greater
	ret c		;09a0
	inc hl		;09a1
	ret		;09a2

l09a3h:
	rst 18h		;09a3	Call READ_PAR  
	db '='		;09a4
	db l09ach-$-1	;09a5	

	call l0439h	;09a6	Call EVAL_RELATIONAL_2

	ret nz		;09a9	Return HL = 1 if equal
	inc hl		;09aa	
	ret		;09ab	

l09ach:
	rst 18h		;09ac	Call READ_PAR
	db '<'		;09ad
	db l0a02h-$-1	;09ae	Return two functions up.

	call l0439h	;09af	Call EVAL_RELATIONAL_2
	ret nc		;09b2	Return HL = 1 if less
	inc hl		;09b3	
	ret		;09b4

; 'PUT CHARACTER ON SCREEN'
; =========================
; Print a character in A to the screen at the current cursor position 
; (CURSOR_POS).

; This function holds Galaksija's "terminal emulation" routines. Several
; special ASCII characters are recognized if C flag is set. Video output
; can be redirected with the use of VIDEO_LINK.

; Parameters:
;	A: Character to print
;	C flag: Character is considered special if C flag is set
; Returns:
;	HL: Position of the printed character + 1

; Destroys:
;	BC,DE

;; PUTCH
l09b5h:
	push af		;09b5	Push AF to stack
	call 02bach	;09b6	Call VIDEO_LINK
	ld hl,(02a68h)	;09b9	Load CURSOR_POS into HL

	jr c,l0a04h	;09bc	If carry set, jump to SPECIAL_CHAR

	ld (hl),a	;09be	Write character in A to screen
	inc hl		;09bf	Increment HL

; Scroll the screen if necessary

;; PUTCH_SCROLL
l09c0h:
	ld a,02ah	;09c0	Load 2ah into A
	cp h		;09c2	Compare with H
	jr nz,l09ffh	;09c3	If cursor is still within video memory,
			;	jump to PUTCH_END.

; Scroll screen contents content up one line, skipping WINDOW_LEN characters
; on top.

	ld hl,02bb0h	;09c5	Load SCROLL_CNT address into HL
	call l0a3dh	;09c8	Call WAIT_INT (wait for soft scroll to finish)

	push hl		;09cb	Push HL to stack
	inc hl		;09cc	Increment HL (now points to SCROLL_FLAG)

	inc (hl)	;09cd	Set SCROLL_FLAG
	call l0a3dh	;09ce	Call WAIT_INT (sync to video refresh)

	or a		;09d1	?

	ld de,(02a6ch)	;09d2	Load WINDOW_LEN into DE
	res 1,d		;09d6	Reset bit 1 of D

	ld hl,001e0h	;09d8	Load 480 into HL (32 characters * 15 lines)
	sbc hl,de	;09db	Substract DE from HL

	jr z,l09edh	;09dd	Jump forward if result is zero...
	jr c,l09edh	;09df	...or less

	ld b,h		;09e1	Load HL into BC
	ld c,l		;09e2	(number of characters moved)

	set 3,d		;09e3	D = D | 28h
	set 5,d		;09e5

	ld hl,32	;09e7	HL (source) = DE (dest) + 32 
	add hl,de	;09ea	(one line of characters lower)

	ldir		;09eb	Block transfer 

; Soft scroll screen up one line, if WINDOW_LEN is zero

l09edh:
	ld hl,(02a6ch)	;09ed	Load WINDOW_LEN into HL 

	ld a,h		;09f0	Load top byte of WINDOW_LEN into A
	or l		;09f1	A = A | L

	pop hl		;09f2	Pop HL from stack (HL points to SCROLL_CNT)

	jr nz,l09f7h	;09f3	If WINDOW_LEN is not zero, jump forward...
	ld (hl),003h	;09f5	Else load 3 into SCROLL_CNT

; Clear bottom line

l09f7h:
	ld hl,029e0h	;09f7	Load 29e0h into HL (start of the bottom line
			;	on the screen)
	push hl		;09fa	Push HL on stack
	call l0a34h	;09fb	Call CLEAR_LINE
	pop hl		;09fe	Pop HL from stack

; Update cursor position and return.

;; PUTCH_END
l09ffh:
	ld (02a68h),hl	;09ff	Update cursor position

l0a02h:
	pop af		;0a02	Pop AF from stack
	ret		;0a03	Return

; Interpret special characters

;; SPECIAL_CHAR
l0a04h:
	cp 00dh		;0a04	Compare A with 0dh (ASCII CR)	    
	jr nz,l0a16h	;0a06	If not equal jump forward

; Put cursor on the next line

	ld a,h		;0a08	Load A with H
	cp 02bh		;0a09	Compare H with 2bh (is cursor on screen?)

	jr c,l0a11h	;0a0b	If H less than 2bh jump forward...
	ld (hl),00dh	;0a0d	...else put character on screen
	jr l09ffh	;0a0f	   and jump to PUTCH_END

l0a11h:
	call l0a34h	;0a11	Call CLEAR_LINE (puts cursor on the start
			;	of the next line)
	jr l09c0h	;0a14	Jump to PUTCH_SCROLL

l0a16h:
	cp 00ch		;0a16	Compare A with 0ch (ASCII FF)
	jr nz,l0a27h	;0a18	If not equal jump forward

; Clear screen

	ld hl,029ffh	;0a1a	Load 29ffh to HL (last character on screen)
l0a1dh:
	ld (hl),020h	;0a1d	Load 20h (ASCII space) to (HL)
	dec hl		;0a1f	Decrement HL
	bit 1,h		;0a20	Test bit 1 of H
	jr z,l0a1dh	;0a22	If zero, loop

l0a24h:
	inc hl		;0a24	Increment HL 
			;	(points to the first char on screen)
	jr l09ffh	;0a25	Jump to PUTCH_SCROLL

l0a27h:
	cp 01dh		;0a27	Compare A with 1dh (ASCII GS)    
	jr nz,l09ffh	;0a29	If not equal jump to PUTCH_END

; Clear current character and move cursor one position back

	ld (hl),020h	;0a2b	Load 20h (ASCII space) to (HL)
	dec hl		;0a2d	Decrement HL

	bit 1,h		;0a2e	Test bit 1 of H
	jr nz,l0a24h	;0a30	If not zero (cursor went off screen), jump
			;	to increment back HL.
	jr l09ffh	;0a32	Jump to PUTCH_END

; 'CLEAR LINE'
; ============
; This function fills a line with ASCII space (20h) characters from the 
; location pointed by HL to the end of the line.

; Parameters:
;	HL: Pointer to the start of the line to be filled.
; Returns:
;	HL: Pointer to the start of the next line
; Destroys:
;	A, flags

;; CLEAR_LINE
l0a34h:
	ld (hl),020h	;0a34	Store ASCII space at location pointed to by HL
	inc hl		;0a36	Increment HL

	ld a,l		;0a37	Load L into A
	and 01fh	;0a38	A = A & 1fh

	jr nz,l0a34h	;0a3a	If A not zero, loop...
	ret		;0a3c	...else return

; 'WAIT FOR INTERRUPT'
; ====================
; This function waits for an interrupt routine to reset a flag pointed to
; by HL register.

; Function returns immediately if interrupts are disabled.

; Parameters:
;	HL: pointer to the flag (interrupt must set this to 0)
; Destroys:
;	A, flags

;; WAIT_INT
l0a3dh:
	ld a,i		;0a3d	Load FF2 state into P/V flag
	ret po		;0a3f	Return if interrupts are disabled

l0a40h:
	ld a,(hl)	;0a40	Load flag byte into A
	or a		;0a41	Update Z flag
	jr nz,l0a40h	;0a42	If byte is not zero, loop...
	ret		;0a44	...else return

; 'PUSH FLOATING POINT NUMBER ON STACK'
; =====================================
; Stores a 4-byte floating point number at (HL) on the arithmetic stack.

; IX Offset	0	1	2	3	4
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

; IX Offset	0        1        2	   3        4
; -------------------------------------------------------------
;		MMMMMMMM MMMMMMMM 1MMMMMMM EEEEEEEE S0000000
;		(LSB)		  (MSB)

; HL Offset	0        1        2	   3
; --------------------------------------------------
;		MMMMMMMM MMMMMMMM EMMMMMMM SEEEEEEE
;		(LSB)		  (MSB)

;; PUSH_FP
l0a45h:
	push de		;0a45	Save DE, HL and AF on stack
	push hl		;0a46	
	push af		;0a47	

	ld bc,00004h	;0a48	Load 4 into BC

	push ix		;0a4b	Load IX into DE
	pop de		;0a4d

	ldir		;0a4e	Transfer 4 bytes starting from (HL) into (IX)

	rl (ix+2)	;0a50	Extract sign bit from IX+2 and IX+3
	rl (ix+3)	;0a54

	ld a,b		;0a58	Store sign bit in IX+4
	rra		;0a59	
	ld (ix+4),a	;0a5a

	scf		;0a5d	Set top bit of mantissa
	rr (ix+2)	;0a5e

	ld c,005h	;0a62	IX = IX + 5
	add ix,bc	;0a64	

	pop af		;0a66	Restore DE, HL and AL from stack
	pop hl		;0a67	
	pop de		;0a68	

	ret		;0a69	Return

; 'EVALULATE INTEGER VALUE IN PARENTHESIS'
; ========================================
; Evaluates expression in parenthesis at DE, converts it to integer and returns
; it in DE.

;; EVAL_PAREN_INT
l0a6ah:
	call l0781h	;0a6a	Call EVAL_PAREN

; 'FLOATING POINT TO INTEGER'
; ===========================
; Convert floating point at the top of the arithmetic stack to integer.

; Returns:
;	HL: Integer value

;; FP_TO_INT
l0a6dh:
	exx		;0a6d	
	call l090eh	;0a6e	Call SUB_IX_5

	ld de,l0000h	;0a71	Clear DE'

; IX Offset	0	1	2	3	4
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

	ld a,(ix+3)	;0a74	Load exponent into A
	ld c,(ix+4)	;0a77	Load sign into C'

	cp 080h		;0a7a	Return 0 if exponent equal to -128
	jr z,l0aaah	;0a7c	

	cp 001h		;0a7e	Return 0 if exponent less than 1
	jp m,l0aaeh	;0a80	(why not jump to l0aaah like above?)

	cp 010h		;0a83	Jump to error if exponent greater than 16
	exx		;0a85	
	jp p,l065ah	;0a86	
	exx		;0a89	

; DE = mantissa * 2 ^ exponent

	ld b,a		;0a8a	Load exponent into B'

	ld a,(ix+000h)	;0a8b	Load mantissa into HL' A'
	ld l,(ix+001h)	;0a8e	
	ld h,(ix+002h)	;0a91

l0a94h:
	sla a		;0a94	Shift left HL' A'
	adc hl,hl	;0a96

	rl e		;0a98	Shift left DE'
	rl d		;0a9a

	djnz l0a94h	;0a9c	Loop

l0a9eh:
	sla c		;0a9e	Jump forward if sign is positive 
	jr nc,l0aaah	;0aa0	

	or h		;0aa2	Increment DE' if HL' A' not zero
	or l		;0aa3	
	jr z,l0aa7h	;0aa4
	inc de		;0aa6
l0aa7h:
	call l0ad7h	;0aa7	DE' = -DE' (Call NEG_DE)

l0aaah:
	push de		;0aaa	Load result into HL
	exx		;0aab	
	pop hl		;0aac 	  
	ret		;0aad	Return

l0aaeh:
	ld a,0ffh	;0aae	Set A to -1
	jr l0a9eh	;0ab0	

; 'EVALUATE NUMERIC EXPRESSION'
; =============================
; Evaluate numeric expression at DE and push the result on the arithmetic 
; stack.

;; EVAL_EXPRESSION
l0ab2h:
	call l068eh	;0ab2	Call EVAL_ARITHMETIC
	call l0999h	;0ab5	Call EVAL_RELATIONAL
			;	Returns to the calling function, if no
			;	relational operator found.

	db 001h		;0ab8	Dummy ld bc,nn (skip the following instruction)

; 'PUSH 10 TO ARITHMETIC STACK'
; ============================
; Pushes floating point constant 10 to the arithmetic stack.

;; PUSH_FP_10
l0ab9h:
	ld hl,0000ah	;0ab9

; Push result from EVAL_RELATIONAL to stack.

; 'INTEGER TO FLOATING POINT'
; ===========================
; Converts integer in HL to floating point and stores it into the arithmetic
; stack.

; Parameters:
;	HL: Integer to convert.	

;; INT_TO_FP
l0abch:
	push de		;0abc	Save DE on stack.

;; INT_TO_FP_2
l0abdh:
	ex de,hl	;0abd	DE = integer to convert

	call l0917h	;0abe	Call ADD_IX_10
	call l0ad4h	;0ac1	Call ABS_DE

	push de		;0ac4	Save DE on stack

	ld hl,0010h	;0ac5	Load 16 into L
	rr h		;0ac8	Set MSB of H to sign bit.

	exx		;0aca

	pop de		;0acb	Restore DE' from stack
	rst 28h		;0acc	Clear HL' (Call CLEAR_HL)
	ld h,e		;0acd	Load E' into H'
	ld c,d		;0ace	Load D' into C'

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

	call l0c4ch	;0acf	Call CORRECT_EXP
	jr l0b03h	;0ad2	Jump to STORE_ARITHM_RET_0

; 'ABSOLUTE VALUE DE'
; ===================
; Calculates absolute value of integer in DE.

; Parameters:
;	DE
; Returns:
;	DE: Absolute value.
;       Cf: Set if DE was negative, reset otherwise.
; Destroys:
;	A

;; ABS_DE
l0ad4h:
	xor a		;0ad4	Clear A
	add a,d		;0ad5	Add D to A.
	ret p		;0ad6	Return if D positive, otherwise continue to 
			;	NEG_DE

; 'NEGATE DE'
; ===========
; Negates the value of integer in DE.

; Parameters:
;	DE
; Returns:
;	DE: Absolute value.
;       Cf: Always Set.
; Destroys:
;	A

;; NEG_DE
l0ad7h:
	ld a,e		;0ad7	E = -E
	neg		;0ad8	
	ld e,a		;0ada

	ld a,d		;0adb	D = ~D + ~Cf
	cpl		;0adc	
	ccf		;0add	
	adc a,000h	;0ade	
	ld d,a		;0ae0 	

	scf		;0ae1	Set carry flag
	ret		;0ae2	Return

; 'MULTIPLY BY 10'
; ================
; Multiplies the number on the top of the arithmetic stack by 10

;; FP_MUL_10
l0ae3h:
	call l0ab9h	;0ae3	Push 10 on the arithmetic stack 
			;	(call PUSH_FP_10)

;; FP_MUL
l0ae6h:
	call l0c68h	;0ae6	Call FETCH_TWO_FP
	jr z,l0b29h	;0ae9	If first operand is zero, just remove the 
			;	second operand from stack and return (jumps 
			;	to STORE_ARITHM_RET_2)

	cp e		;0aeb	If the second operand is zero, store a zero
	jp z,l0b6bh	;0aec	floating point value on stack and return
			;	(jump to STORE_ZERO_RET)

	call l0b81h	;0aef	Call FP_MUL_DO
	jr l0b03h	;0af2	Jump to STORE_ARITHM_RET_0

; 'DIVIDE BY 10'
; ================
; Divides the number on the top of the arithmetic stack by 10

;; FP_DIV_10
l0af4h:
	call l0ab9h	;0af4	Push 10 on the arithmetic stack
			;	(call PUSH_FP_10)
;; FP_DIV
l0af7h:
	call l0c68h		;0af7	cd 68 0c 	  h   
	jr z,l0b29h		;0afa	28 2d 	( - 
	cp e			;0afc	bb 	  
	jp z,l065bh		;0afd	ca 5b 06 	  [   
	call l0baeh		;0b00	cd ae 0b 	      

; 'STORE ARITHMETIC RESULT TRAMPOLINE'
; ====================================

;; STORE_ARITHM_RET_0
l0b03h:
	jr l0b6dh		;0b03	Jump to STORE_ARITHM_RET

; 'COMPARE VARIABLE WITH ARITHMETIC STACK'
; ========================================
; Compares the number at the top of the arithmetic stack with the 4-byte
; floating point at (HL)

;; FP_COMPARE_HL
l0b05h:
	call l0a45h	;0b05	Call PUSH_FP
	call l0c68h	;0b08	Call FETCH_TWO_FP

	ld bc,0fffbh	;0b0b	Load -5 into BC	      
	jr l0b16h	;0b0e	Jump into FP_COMPARE (remove the only the value
			;	pushed on the stach by PUSH_FP)


; 'COMPARE TWO FLOATING POINT NUMBERS'
; ====================================
; Pops two floating point numbers from the top of the arithmetic stack, 
; compares them and returns the result in the flags register.

;; FP_COMPARE
l0b10h:
	call l0c68h	;0b10	Call FETCH_TWO_FP
	ld bc,0fff6h	;0b13	
l0b16h:
	add ix,bc	;0b16	Subtract -10 from IX

	cp l		;0b18	Compare A (80h) with L  
	call l0be6h	;0b19	Jump to the rest of the function

	pop de		;0b1c	Restore DE
	ret		;0b1d	Return

;; FP_SUB
l0b1eh:
	call l0c68h		;0b1e	cd 68 0c 	  h   
	jr nz,l0b28h		;0b21	20 05 	    
	call l0b62h		;0b23	cd 62 0b 	  b   
	jr l0b58h		;0b26	18 30 	  0 
l0b28h:
	cp e			;0b28	bb 	  
l0b29h:
	jr z,l0b7eh	;0b29	Jump to STORE_ARITHM_RET_2
	xor d			;0b2b	aa 	  
	ld d,a			;0b2c	57 	W 
	jr l0b3ah		;0b2d	18 0b 	    
	call l0a45h		;0b2f	cd 45 0a 	  E   

; 'ADD TWO FLOATING POINT NUMBERS'
; ================================
; Pops two numbers from the top of the arithmetic stack, adds them and pushes
; the result on the stack.

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		E'	D'	B'	E	D
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

; IX Offset	-10	-9	-8	-7	-6
; ---------------------------------------------------
;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; FP_ADD
l0b32h:
	call l0c68h	;0b32	Call FETCH_TWO_FP
	jr z,l0b63h	;0b35	Second number is zero.

	cp e		;0b37	
	jr z,l0b7eh	;0b38	First number is zero. Just remove the second 
			;	operand from stack.

			;	Jump to STORE_ARITHM_RET_2

l0b3ah:
	call l0c04h	;0b3a	Call FP_COMPARE_ABS
	jr z,l0b4dh	;0b3d	Mantissa and exponent are equal

	jr nc,l0b48h	;0b3f	If DE' B' DE > HL' C' HL, exchange operands

	ex de,hl	;0b41	exchange DE' B' DE and HL' C' HL
	exx		;0b42	
	ex de,hl	;0b43	
	ld a,c		;0b44	
	ld c,b		;0b45
	ld b,a		;0b46
	exx		;0b47

l0b48h:
	call l0c17h	;0b48	Call FP_ADD_DO
	jr l0b6dh	;0b4b	Jump to STORE_ARITHM_RET

; Mantissa and exponent of operands are equal

l0b4dh:
	ld a,h		;0b4d	A = XOR of both sign bits
	xor d		;0b4e
	jr nz,l0b6bh	;0b4f	Signs different: jump to STORE_ZERO_RET

	ld e,001h	;0b51	Signs equal: Multiply by 2
	call l0c3fh	;0b53	Jump to FP_MUL_EXP

	jr l0b6dh	;0b56	Jump to STORE_ARITHM_RET

l0b58h:
	ld a,(ix-1)		;0b58	dd 7e ff 	  ~   
	xor 080h		;0b5b	ee 80 	    
	ld (ix-1),a		;0b5d	dd 77 ff 	  w   
	pop de			;0b60	d1 	  
	ret			;0b61	c9 	  
l0b62h:
	push de			;0b62	d5 	  

; Second operand of addition is zero.

;; FP_ADD_ZERO_2
l0b63h:
	ld h,d		;0b63	HL' C' HL = DE' B' DE
	ld l,e		;0b64	
	exx		;0b65	
	ld l,e		;0b66
	ld h,d		;0b67
	ld c,b		;0b68
	exx		;0b69

	db 001h		;0b6a	Dummy ld bc,nn (skip ld l,080h)

; 'STORE ZERO RESULT & RETURN'
; ============================

;; STORE_ZERO_RET
l0b6bh:
	ld l,080h	;0b6b

; 'STORE ARITHMETIC RESULT & RETURN'
; ==================================
; JP to this location is used by arithmetic functions with two operands to
; store the result on the arithmetic stack at IX. 

; DE pointer is restored from CPU stack before returning.

; Top two values are removed from the stack and the Floating point number in
; HL' C' HL is stored.

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; STORE_ARITHM_RET
l0b6dh:
	ld (ix-6),h		;0b6d	Store result in the second-to-last  
	ld (ix-7),l		;0b70	stack location.
	exx			;0b73	
	ld (ix-10),l		;0b74	
	ld (ix-9),h		;0b77	
	ld (ix-8),c		;0b7a
	exx			;0b7d

l0b7eh:
	jp l090dh		;0b7e	Jump to STORE_ARITHM_RET_2

; 'MULTIPLY TWO FLOATING POINT NUMBERS (cont.)'
; =============================================
; Multiplies two floating point numbers (both not equal to zero).

; (first operand, result)

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		E'	D'	B'	E	D
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

; (second operand)

; IX Offset	-10	-9	-8	-7	-6
; ---------------------------------------------------
;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; FP_MUL_DO
l0b81h:
	ld a,h		;0b81	Sign bit of the result = XOR sign bits of
	xor d		;0b82	operands.
	ld h,a		;0b83

	dec e		;0b84	Decrement first exponent.

	push hl		;0b85	Save HL and BC on stack
	push bc		;0b86	

	ld b,018h	;0b87	06 18 	    
	call l0c81h	;0b89	cd 81 0c 	      

	xor a		;0b8c	af 	  

	rst 28h		;0b8d	Call CLEAR_HL

	ld c,a			;0b8e	4f 	O 
l0b8fh:
	exx			;0b8f	d9 	  
	srl c		;0b90	cb 39 	  9 
	rr h		;0b92	cb 1c 	    
	rr l		;0b94	cb 1d 	    
	exx			;0b96	d9 	  
	jr nc,l0b9dh		;0b97	30 04 	0   
	add hl,de			;0b99	19 	  
	ld a,c			;0b9a	79 	y 
	adc a,b			;0b9b	88 	  
	ld c,a			;0b9c	4f 	O 
l0b9dh:
	exx			;0b9d	d9 	  
	djnz l0ba5h		;0b9e	10 05 	    
	pop bc			;0ba0	c1 	  
	pop hl			;0ba1	e1 	  
	exx			;0ba2	d9 	  
	jr l0bd5h		;0ba3	18 30 	  0 
l0ba5h:
	exx			;0ba5	d9 	  
	rr c		;0ba6	cb 19 	    
	rr h		;0ba8	cb 1c 	    
	rr l		;0baa	cb 1d 	    
	jr l0b8fh		;0bac	18 e1 	    
l0baeh:
	ld a,e			;0bae	7b 	{ 
	neg		;0baf	ed 44 	  D 
	ld e,a			;0bb1	5f 	_ 
	ld a,h			;0bb2	7c 	| 
	xor d			;0bb3	aa 	  
	ld h,a			;0bb4	67 	g 
	push hl			;0bb5	e5 	  
	push bc			;0bb6	c5 	  
	ld b,019h		;0bb7	06 19 	    
	exx			;0bb9	d9 	  
l0bbah:
	sbc hl,de		;0bba	ed 52 	  R 
	ld a,c			;0bbc	79 	y 
	sbc a,b			;0bbd	98 	  
	ld c,a			;0bbe	4f 	O 
	jr nc,l0bc4h		;0bbf	30 03 	0   
	add hl,de		;0bc1	19 	  
	adc a,b			;0bc2	88 	  
	ld c,a			;0bc3	4f 	O 
l0bc4h:
	exx			;0bc4	d9 	  
	ccf			;0bc5	3f 	? 
	adc hl,hl		;0bc6	ed 6a 	  j 
	rl c		;0bc8	cb 11 	    
	djnz l0bd7h		;0bca	10 0b 	    
	push hl			;0bcc	e5 	  
	push bc			;0bcd	c5 	  
	exx			;0bce	d9 	  
	pop bc			;0bcf	c1 	  
	pop hl			;0bd0	e1 	  
	exx			;0bd1	d9 	  
	pop bc			;0bd2	c1 	  
	pop hl			;0bd3	e1 	  
	exx			;0bd4	d9 	  
l0bd5h:
	jr l0c35h		;0bd5	18 5e 	  ^ 
l0bd7h:
	exx			;0bd7	d9 	  
	add hl,hl			;0bd8	29 	) 
	rl c		;0bd9	cb 11 	    
	jr nc,l0bbah		;0bdb	30 dd 	0   
	ccf			;0bdd	3f 	? 
	sbc hl,de		;0bde	ed 52 	  R 
	ld a,c			;0be0	79 	y 
	sbc a,b			;0be1	98 	  
	ld c,a			;0be2	4f 	O 
	or a			;0be3	b7 	  
	jr l0bc4h		;0be4	18 de 	    

; 'COMPARE TWO FLOATING POINT NUMBERS (cont.)'
; ============================================

;		E'	D'	B'	E	D
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign


; signs	A B	- -	- +	+ -	+ +
; |A| > |B|	A < B	A < B	A > B	A > B
; |A| = |B|	A = B	A < B	A > B	A = B
; |A| < |B|	A > B	A < B	A > B	A < B

;; FP_COMPARE_2
l0be6h:
	jr z,l0bf2h	;0be6	HL' C' HL == 0 

	cp e		;0be8	
	jr z,l0bfah	;0be9	DE' B' DE == 0

	ld a,h		;0beb	A = XOR of both sign bits
	xor d		;0bec	(resets Cf)

	call z,l0c04h	;0bed	Call FP_COMPARE_ABS if signs are equal

			;	Different signs: Cf = 0, Zf = 0

			;	Equal signs:				Cf Zf
			;		|HL' C' HL| > |DE' B' DE| :	0  0
			;		|HL' C' HL| = |DE' B' DE| :	0  1
			;		|HL' C' HL| < |DE' B' DE| :	1  0

	jr l0bf9h	;0bf0	Jump forward

l0bf2h:
	cp e		;0bf2	Return if both numbers are 0
	ret z		;0bf3

			;	HL' C' HL == 0
			;	DE' B' DE != 0

	scf		;0bf4			Cf Zf
	bit 7,d		;0bf5	DE' B' DE > 0 :	1  1
			;	DE' B' DE < 0 :	1  0

	jr l0bfch	;0bf7	

l0bf9h:
	ret z		;0bf9	Return if sign, mantissa and exponent are equal

; also jumps here if DE' B' DE == 0 (Cf = 0)

l0bfah:				
			;			Zf
	bit 7,h		;0bfa	HL' C' HL > 0 : 1
			;	HL' C' HL < 0 :	0

; Cf	Zf	Result	Cf	Zf
; ------------------------------------
; 0	0		1	0
; 0	1		0	1
; 1	0		0	0
; 1	1		1	1

l0bfch:
	ccf		;0bfc	
	ret nz		;0bfd 	Return with complemented Cf if Zf = 0
	ccf		;0bfe	

	rra		;0bff	A = A | 01h
	scf		;0c00	
	rl a		;0c01	Clear Zf
	
	ret		;0c03	Return with original Cf if Zf = 1

; 'COMPARE ABSOLUTE VALUES'
; =========================
; Compares mantissa and exponent of two floating point numbers.

; Parameters:
;	DE' B' DE, HL' C' HL: Floating point numbers to compare

; Returns:
;	Cf, Zf: Result of (HL' C' HL - DE' B' DE) comparisson.

;		E'	D'	B'	E	D
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; FP_COMPARE_ABS
l0c04h:
	ld a,l		;0c04	Subtract exponents
	sub e		;0c05	

	jr z,l0c0fh	;0c06	Equal exponents: Compare mantissa

	jp po,l0c0dh	;0c08	Negate top bit of result on overflow
	neg		;0c0b	
l0c0dh:
	rlca		;0c0d	Shift top bit into Cf
	ret		;0c0e	Return

l0c0fh:
	exx		;0c0f	
	ld a,c		;0c10	Compare top bytes of mantissa
	cp b		;0c11	
	jr nz,l0c15h	;0c12	
	rst 10h		;0c14	Compare lower two bytes if top bytes equal
			;	(Call CMP_HL_DE)
l0c15h:
	exx		;0c15	
	ret		;0c16	Return


; 'ADD TWO FLOATING POINT NUMBERS (cont.)'
; ========================================
; Adds number in DE' B' DE to HL' C' HL. HL' C' HL must be larger than 
; DE' B' DE.

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		E'	D'	B'	E	D
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

; IX Offset	-10	-9	-8	-7	-6
; ---------------------------------------------------
;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; FP_ADD_DO
l0c17h:
	ld a,l		;0c17	
	sub e		;0c18	A = L - E
	jr z,l0c29h	;0c19	Jump forward if exponents already equal

	cp 24		;0c1b	
	ret nc		;0c1d	If L - E >= 24, return
			;	(DE' B' DE is too small to affect HL' C' HL)

; Make exponents equal

	exx		;0c1e	
l0c1fh:
	srl b		;0c1f	Shift mantissa (DE' B') right
	rr d		;0c21	
	rr e		;0c23
	dec a		;0c25	Loop A times
	jr nz,l0c1fh	;0c26

	exx		;0c28

l0c29h:
	ld e,000h	;0c29	Clear
	ld a,h		;0c2b	A = XOR both sign bits
	xor d		;0c2c	 	  

	jp m,l0c46h	;0c2d	Signs different

	exx		;0c30	HL' C' = HL' C' + DE' B'
	add hl,de	;0c31
	ld a,c		;0c32
	adc a,b		;0c33
	ld c,a		;0c34
l0c35h:
	jr nc,l0c3eh	;0c35	If carry, rotate mantissa right to
	rr c		;0c37	include the carry bit.
	rr h		;0c39	
	rr l		;0c3b	
	scf		;0c3d	Clear carry flag.
l0c3eh:
	exx		;0c3e

; Multiply with Cf and return

; 'MULTIPLY FLOATING POINT NUMBER WITH 2^(E+Cf)'
; ==============================================
; Multiplies floating point number in HL' C' HL with 2^(E+Cf)

; Parameters:
;	E, Cf: Number to multiply with
;	HL' C' HL: Floating point number
; Return:
;	HL' C' HL: Result

;; FP_MUL_EXP
l0c3fh:
	ld a,l		;0c3f	A = L + E + Cf
	adc a,e		;0c40
l0c41h:
	jp pe,l0c61h	;0c41	Jump to CORRECT_EXP_OVERFLOW if exponent 
			;	overflowed...  
	ld l,a		;0c44	...else load A into L and return
	ret		;0c45	

l0c46h:
	exx			;0c46	d9 	  
	sbc hl,de		;0c47	ed 52 	  R 
	ld a,c			;0c49	79 	y 
	sbc a,b			;0c4a	98 	  
	ld c,a			;0c4b	4f 	O 

; 'CORRECT EXPONENT'
; ==================
; This function removes any leading zeros in the mantissa and corrects
; the exponent.

; It is always called with the C' HL' register set selected.

; Parameters:
;	HL C' HL': Input floating point number
; Returns:
;	HL C' HL': Corrected floating point number.

;; CORRECT_EXP
l0c4ch:
	ld b,018h	;0c4c	Load 24 into B'
	xor a		;0c4e	Clear A

	inc c		;0c4f	Set S flag for C'
	dec c		;0c50	
l0c51h:
	jp m,l0c5dh	;0c51	Break from loop top bit of C' HL' set

	dec a		;0c54	Decrement A

	add hl,hl	;0c55	Shift C' HL' left
	rl c		;0c56	 

	djnz l0c51h	;0c58	Loop

; all 24 bits of C' HL' are zero.

;; CORRECT_EXP_ZERO
l0c5ah:
	ld l,080h	;0c5a	Set exponent to -128
	ret		;0c5c	Return

l0c5dh:
	exx		;0c5d
	add a,l		;0c5e	Add L to A
	jr l0c41h	;0c5f	Check for overflow.

; Negative overflow in the exponent occured.

;; CORRECT_EXP_OVERFLOW
l0c61h:
	ld a,h		;0c61	
	or a		;0c62
	jp p,l0658h	;0c63	Jump to "HOW?" error if number was positive...
	jr l0c5ah	;0c66	...else jump to CORRECT_EXP_ZERO

; 'FETCH TWO FLOATING POINT NUMBERS FROM STACK'
; =============================================
; Fetches two floating point number from the top of the arithmetic stack and
; stores them HL' C' HL and DE' B' DE registers. Does not decrement IX.

; Returns:
;	A: 80h
;	DE' B' DE: First floating point number
;	HL' C' HL: Second floating point number
;	Zf: Set if second number is 0.

; IX Offset	-5	-4	-3	-2	-1
; ---------------------------------------------------
;		E'	D'	B'	E	D
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

; IX Offset	-10	-9	-8	-7	-6
; ---------------------------------------------------
;		L'	H'	C'	L	H
; ---------------------------------------------------
;		24 bit mantissa	(MSB)	Exp	Sign

;; FETCH_TWO_FP
l0c68h:
	pop hl			;0c68	
	push de			;0c69	Store DE and HL on stack
	push hl			;0c6a	

	ld d,(ix-1)		;0c6b	
	ld e,(ix-2)		;0c6e
	ld h,(ix-6)		;0c71
	ld l,(ix-7)		;0c74
	exx			;0c77
	ld e,(ix-5)		;0c78
	ld d,(ix-4)		;0c7b
	ld b,(ix-3)		;0c7e
l0c81h:
	ld l,(ix-10)		;0c81
	ld h,(ix-9)		;0c84
	ld c,(ix-8)		;0c87
	exx			;0c8a

	ld a,080h		;0c8b	Is second number equal to zero?
	cp l			;0c8d

	ret			;0c8e 	Return	  

; 'RANDOM'
; ========
; "RND" BASIC command.
;
; This pseudo-random number generator pushes a random floating point number
; on the arithmetic stack.

;; RND
l0c8fh:
	push de		;0c8f	Save DE on stack

	exx		;0c90	

	ld hl,02aa7h	;0c91	Load RND_SEED address into HL'
	push hl		;0c94	Save HL' on stack

	ld e,(hl)	;0c95	Load contents of RND_SEED into DE' B'
	inc hl		;0c96	
	ld d,(hl)	;0c97	
	inc hl		;0c98	 	
	ld b,(hl)	;0c99	

	exx		;0c9a	

			;	Clear HL' C' HL

	call l0248h	;0c9b	Call CLEAR_CX_HLX_B6
	rst 28h		;0c9e	Call CLEAR_HL

	ld c,003h	;0c9f	Load 03h into C
l0ca1h:
	ld b,008h	;0ca1	Load 8 into B
	ld d,(hl)	;0ca3	Load (HL) into D

l0ca4h:
	exx		;0ca4	
	add hl,hl	;0ca5	Rotate HL' C' left
	rl c		;0ca6  
	exx		;0ca8	

	rl d		;0ca9	Rotate D left
	jr nc,l0cb3h	;0cab	Add DE' B' if top bit of D is set...

	exx		;0cad	
	add hl,de	;0cae   HL' C' = HL' C' + DE' B'
	ld a,c		;0caf
	adc a,b		;0cb0	
	ld c,a		;0cb1	
	exx		;0cb2	

l0cb3h:
	djnz l0ca4h	;0cb3	Loop 8 times

	inc hl		;0cb5	Increment HL

	dec c		;0cb6	Decrement C
	jr nz,l0ca1h	;0cb7	Loop 3 times

	rst 28h		;0cb9	Call CLEAR_HL

	exx		;0cba	
	pop de		;0cbb	Restore RND_SEED address from stack into DE'

	ld a,l		;0cbc	L' = L' + 65h
	add a,065h	;0cbd	(RND_SEED) = L'
	ld (de),a	;0cbf
	inc de		;0cc0	Increment DE'
	ld l,a		;0cc1	

	ld a,h		;0cc2	H' = H' + b0h + Cf
	adc a,0b0h	;0cc3	(RND_SEED+1) = H'
	ld (de),a	;0cc5
	inc de		;0cc6	Increment DE'
	ld h,a		;0cc7	

	ld a,c		;0cc8	C' + 05h + Cf
	adc a,005h	;0cc9	(RND_SEED+2) = C'
	ld (de),a	;0ccb	
	ld c,a		;0ccc	

	call l0914h	;0ccd	Call CORRECT_EXP_ADD_IX_10
	jp l0b6dh	;0cd0	Jump to STORE_ARITHM_RET

; 'CONVERT STRING TO AN INTEGER'
; ==============================
; Converts string at DE into an integer. String must start with a numeral.

; Parameters:
;	DE: Pointer to the string to be converted.
; Returns:
;	HL: Converted integer or 0 on error.
;	Zf: Set on error or clears on success.
;	DE: First character after the converted number.

;; STRING_TO_INT
l0cd3h:
	rst 28h		;0cd3	Call CLEAR_HL
	call l0105h	;0cd4	Call EAT_SPACE

	call l0172h	;0cd7	Check if the next character is a number 
			;	(call CHAR_TO_INT)

	jr c,l0ce3h	;0cda	If it's not, jump forward

	dec de		;0cdc	Decrement DE (step back to character used for 
			;	CHAR_TO_INT)

			;	Convert the string at DE to integer in HL.

	call l01a2h	;0cdd	Call STRING_TO_FP
	call l0a6dh	;0ce0	Call FP_TO_INT
l0ce3h:
	ld a,h		;0ce3	Check if HL contains 0 (either the number
	or l		;0ce4	read is 0 or the conversion failed)

	ret		;0ce5	Return

; 'READ A KEY FROM KEYBOARD'
; ==========================
; Waits for a key press on the keyboard and returns the code of the pressed
; key in A (for most keys this means the ASCII code of the character printed
; on the key. Special keys return their own scan code).

; A press to the "list" key causes a jump to the LIST function.

; A press to the "break" key causes a jump to the BREAK function.

; Returns:
;	A: Code of the key pressed
; Destroys:
;	Flags

; A key had been seen as released. Key code in A. Address in DE.

; Clear the key's position in KEY_DIFF (HL), if this key has been recently
; pressed.

;; KEY_RELEASED
l0ce6h:
	cp h		;0ce6	Compare A with H...
	jr nz,l0cebh	;0ce7	...and jump forward if not equal

	ld h,000h	;0ce9	...else reset H
l0cebh:
	cp l		;0ceb	Compare A with L...
	jr nz,l0cf0h	;0cec	...and jump to KEY_READ_NEXT if not equal

	ld l,000h	;0cee	...else reset L

; Scan the next key, or start from the beginning if on the last key.

;; KEY_READ_NEXT
l0cf0h:

	dec e		;0cf0	Decrement E, move to the next key
	jr nz,l0cfeh	;0cf1	Jump to KEY_READ if more keys to read
	jr l0cfbh	;0cf3	Jump to KEY_RESTART if on the last key.

; Entry point into the function

;; KEY
l0cf5h:
	exx		;0cf5	Save BC, DE and HL registers

	ld hl,(02aa5h)	;0cf6	Load KEY_DIFF into HL

	ld c,00eh	;0cf9	Load 0eh into C (speed of the "repeat" key)

; Restart scanning from the beginning.

;; KEY_RESTART
l0cfbh:
	ld de,02034h	;0cfb	Load 2034h into DE
			;	This is the address of the last key on the
			;	keyboard except for "shift".

;; KEY_READ
l0cfeh:
	ld a,(de)	;0cfe	Load (DE) into A
	rrca		;0cff	Rotate A right through carry flag
	ld a,e		;0d00	Load E (code of the current key) into A

	jr c,l0ce6h	;0d01	Jump to KEY_RELEASED if low bit of A is set.

	cp 032h		;0d03	Compare A with 32h...
	jr nz,l0d0fh	;0d05	...and jump to KEY_PRESSED, if not equal

; "rept" key is pressed. This key is special because it causes the last 
; keypress to be repeated.

	dec c		;0d07	Decrement C...
	jr nz,l0ce6h	;0d08	...and jump to KEY_RELEASED if not zero

	ld a,(02bb4h)	;0d0a	Load LAST_KEY into A
	jr l0d54h	;0d0d	Jump to KEY_END

; A key had been seen as pressed. Key code in A. Address in DE.

;; KEY_PRESSED
l0d0fh:
	cp h		;0d0f	Compare A with H...
	jr z,l0cf0h	;0d10	...and jump to KEY_READ_NEXT if equal

	cp l		;0d12	Compare A with L...
	jr z,l0cf0h	;0d13	...and jump to KEY_READ_NEXT if equal

; Wait for 256 cycles for key release (to filter out switch bounces)

	ld b,000h	;0d15	Clear B
l0d17h:
	rst 10h		;0d17	Call CMP_HL_DE (pause)

	ld a,(de)	;0d18	Load (DE) into A
	rrca		;0d19	Rotate A right through carry flag...
	jr c,l0ce6h	;0d1a	...and jump to KEY_RELEASED if carry set.

	djnz l0d17h	;0d1c	Loop 256 times

; Fill in an empty position in KEY_DIFF (HL)

	ld a,h		;0d1e	Load H into A
	or a		;0d1f	Set Z flag...
	jr nz,l0d25h	;0d20	...and jump forward if A not zero

	ld h,e		;0d22	Load E into H
	jr l0d2ah	;0d23	Jump forward

l0d25h:
	ld a,l		;0d25	Load L into A
	or a		;0d26	Set Z flag...
	jr nz,l0cfeh	;0d27	...and jump to KEY_READ if A not zero
	ld l,e		;0d29	Load E into L

; A valid key press has been detected. Check for special keys, add proper 
; ASCII offsets and look keys up in the shift table. DE holds the key's 
; memory address.

;; KEY_COMPUTE
l0d2ah:
	ld (02aa5h),hl	;0d2a	Load HL into KEY_DIFF 
	rst 28h		;0d2d	Call CLEAR_HL
	ld a,e		;0d2e	Load E into A 

; Check for special keys, that directly invoke functions in the BASIC 
; interpreter.

	cp 034h		;0d2f	Compare A with 34h ("list" key) and...
	jp z,l0461h	;0d31	...jump to LIST_KEY if equal

	cp 031h		;0d34	Compare A with 31h ("break" key) and... 
	jp z,l0305h	;0d36	...jump to BREAK if equal

	cp 01bh		;0d39	Compare A with 1bh ("up" key).
	ld hl,02035h	;0d3b	Load 2035h into HL ("shift" key address)
	jr c,l0d59h	;0d3e	Jump to KEY_END_ALPHA if A less than 1bh

	cp 01fh		;0d40	Compare A with 1fh ("space" key address)
	jr c,l0d54h	;0d42	Jump to KEY_END if A is less than 1fh
			;	("up", "down", "left" or "right" keys)

; Code for numerical and symbol keys, that are looked up in KEY_SHIFT_SYM_TABLE

	sub 01fh	;0d44	Subtract 1fh from A
	rr (hl)		;0d46	Rotate (HL) right
			;	Since HL contains the address of the "shift"
			;	key, this moves that status of the "shift" key
			;	into carry flag.

	rla		;0d48	Rotate A left. 
			;	A = A * 2 + 0 (if shift is pressed)
			;	A = A * 2 + 1 (if shirt is released)

	ld c,a		;0d49	Load A into C

	ld hl,l0d70h	;0d4a	Load KEY_SHIFT_SYM_TABLE address into HL
	add hl,bc	;0d4d	Add BC to HL

; This seeds the random generator with the value of the R register after
; some key presses.

	ld a,r		;0d4e	Load R into A
	ld (02aa8h),a	;0d50	Load A into 2nd byte of RND_SEED

	ld a,(hl)	;0d53	Load a character from the symbol table into A

; The code of the pressed key is in A. Store in LAST_KEY and return.

;; KEY_END
l0d54h:
	ld (02bb4h),a	;0d54	Load A into LAST_KEY
	exx		;0d57	Restore BC, DE and HL registers.	
	ret		;0d58	Return

; Pressed key is a letter. Add proper ASCII offset, check shift mapping in 
; table and return.

;; KEY_END_ALPHA
l0d59h:
	add a,040h	;0d59	Add 40h to A (ASCII offset)
	rr (hl)		;0d5b	Rotate (HL) right...
			;	Since HL contains the address of the "shift"
			;	key, this moves that status of the "shift" key
			;	into carry flag.
	jr c,l0d54h	;0d5d	...and jump to KEY_END if shift key not pressed.

	ld hl,l0d94h	;0d5f	Load KEY_SHIFT_YU_TABLE address into HL
	ld bc,l045bh	;0d62	Load 4 into B and 5bh into C

; B holds the length of the KEY_SHIFT_YU_TABLE, C holds the first ASCII code
; of the Yugoslavian character set.

l0d65h:
	cp (hl)		;0d65	Compare (HL) with A...
	jr z,l0d6dh	;0d66	Jump forward if equal
	inc hl		;0d68	Increment HL
	inc c		;0d69	Increment C
	djnz l0d65h	;0d6a	Loop 4 times

; If loops ends here, a dummy load instruction is executed. Else value in C
; (a different character) is stored into A

	db 00eh		;0d6c	These two bytes also form the instruction
l0d6dh:	
	ld a,c		;0d6d	"ld c,079h"

	jr l0d54h	;0d6e	Jump to KEY_END

; 'KEYBOARD TABLES'
; =================

; This table contains characters, that are obtained by pressing keys with
; addresses from 1fh ("space") to 30h ("return").

; The first character in table is obtained by pressing shift-key and the
; second is obtained by pressing the key alone.

;; KEY_SHIFT_SYM_TABLE
l0d70h:
	db	' ',	' '	; 1fh
	db	'_',	'0'	; 20h
	db	'!',	'1'	; 21h
	db	'"',	'2'	; 22h
	db	'#',	'3'	; 23h
	db	'$',	'4'	; 24h
	db	'%',	'5'	; 25h
	db	'&',	'6'	; 26h
	db	0bfh,	'7'	; 27h (bfh is block graphics character)
	db	'(',	'8'	; 28h
	db	')',	'9'	; 29h
	db	'+',	';'	; 2ah
	db	'*',	':'	; 2bh
	db	'<',	','	; 2ch
	db	'-',	'='	; 2dh
	db	'>',	'.'	; 2eh
	db	'?',	'/'	; 2fh
	db	00dh,	00dh	; 30h (CR)

; This table contains characters, that are mapped to Yugoslavian characters
; when the shift-key is pressed.

; It also serves as the KEY_SHIFT_SYM_TABLE entries for "break" and "repeat" 
; keys, which have special functions and are never looked up here.

;; KEY_SHIFT_YU_TABLE
l0d94h:
	db	'X' 		; C with caron		31h
	db 	'C'		; C with acute
	db 	'Z'		; Z with caron		32h
	db	'S'		; S with caron

; KEY_SHIFT_SYM_TABLE entry for the "delete" key

	db	0ch,	00h	; 33h (clear screen - shift delete, delete)

; 'MEM'
; =====
; "MEM" BASIC function

;; MEM
l0d9ah:
	call l0183h	;0d9a	Call FREE_MEM

	ld bc,(02a99h)	;0d9d	Subtract array length from 
	sbc hl,bc	;0da1

	jr l0dbfh	;0da3	Jump to INT_TO_FP and return

; 'WORD'
; ======
; "WORD" BASIC function

;; WORD
l0da5h:
	ld c,(hl)	;0da5	Load word at (HL) into HL
	inc hl		;0da6	
	ld h,(hl)	;0da7	
	ld l,c		;0da8

	jr l0dbfh	;0da9	Jump to INT_TO_FP and return.

; 'KEY'
; =====
; "KEY" BASIC function

;; KEY_CMD
l0dabh:
	ld a,h		;0dab	Check if HL = 0
	or l		;0dac	
	jr nz,l0db4h	;0dad	If HL = 0 (no argument), 
			;	read which key has been pressed and return

	call l0cf5h	;0daf	Call KEY
	jr l0dbah	;0db2	Jump to KEY_CMD_END

l0db4h:
	set 5,h		;0db4	HL = HL | 2000h

	ld a,(hl)	;0db6	Load value from keyboard into A
	cpl		;0db7	Complement A
l0db8h:
	and 001h	;0db8	Filter out LSB.

;; KEY_CMD_END
l0dbah:
	ld l,a		;0dba	Move A into L.
	db 03eh		;0dbb	Dummy "ld a,nn" (skip next instruction - 
			;	clear H and jump to INT_TO_FP)

; 'BYTE'
; ======
; "BYTE" BASIC function

;; BYTE_FUNC
l0dbch:
	ld l,(hl)	;0dbc	Load byte at (HL) into HL
	ld h,000h	;0dbd

l0dbfh:
	jp l0abch	;0dbf	Jump to INT_TO_FP and return.

;; EQ
l0dc2h:
	call l05fch		;0dc2	cd fc 05 	      
	push hl			;0dc5	e5 	  
	rst 18h			;0dc6	df 	  
	inc l			;0dc7	2c 	, 
	nop			;0dc8	00 	  
	call l05fch		;0dc9	cd fc 05 	      
	pop bc			;0dcc	c1 	  
l0dcdh:
	ld a,(bc)			;0dcd	0a 	  
	cp (hl)			;0dce	be 	  
	jr nz,l0ddch		;0dcf	20 0b 	    
	or a			;0dd1	b7 	  
	jr z,l0ddbh		;0dd2	28 07 	(   
	inc hl			;0dd4	23 	# 
	inc bc			;0dd5	03 	  
	ld a,l			;0dd6	7d 	} 
	and 00fh		;0dd7	e6 0f 	    
	jr nz,l0dcdh		;0dd9	20 f2 	    

; following lines from Diss_010.jpg
l0ddbh:
	db 03eh			;0ddb
l0ddch:
	xor a			;0ddc	af 	>   
	jr l0db8h		;0ddd	18 d9 	    
;; HEX
l0ddfh:
	call l0165h	;0ddf	Test the first character 
			;	(Call HEXCHAR_TO_INT_

	jr c,l0df8h	;0de2	Jump to HOW_RST_PUSH_DE if conversion failed

	dec de		;0de4	Move DE back to the beginning

	rst 28h		;0de5	Call CLEAR_HL

;; HEX_LOOP
l0de6h:
	call l0165h	;0de6	Call HEXCHAR_TO_INT

	jr c,l0dbfh	;0de9	Jump to INT_TO_FP and return on end of hex
			; 	number (on first non-hex character)

	rlca		;0deb	A = A << 4
	rlca		;0dec	
	rlca		;0ded	
	rlca		;0dee	

	ld bc,l0de6h	;0def	Load HEX_LOOP address to the top of the
	push bc		;0df2	stack

; Shift four bits in A to HL

l0df3h:
	ld b,004h	;0df3	
l0df5h:
	rlca		;0df5	HL A = HL A << 4
	adc hl,hl	;0df6	
l0df8h:
	jp c,l065ah	;0df8	Jump to HOW_RST_PUSH_DE on overflow

	djnz l0df5h	;0dfb	Loop

	ret		;0dfd	Jump to HEX_LOOP

; 'WORD'
; ======
; "WORD" BASIC command.

l0dfeh:
	db 0f6h		;0dfe	Dummy "or nn" 
			;	(skip next instruction, clear Zf)

; 'BYTE'
; ======
; "BYTE" BASIC command.

;; BYTE
l0dffh:
	xor a		;0dff	Set Zf
	push af		;0e00	Push flags on sack

	rst 8		;0e01	Get address (call EVAL_INT_EXP)
	push hl		;0e02	Save address on stack.

	call l0005h	;0e03	Get content (call EVAL_INT_EXP_NEXT)

	ex (sp),hl	;0e06	HL = address
	pop bc		;0e07	BC = content

	ld (hl),c	;0e08	Load lower byte into (HL)

	pop af		;0e09	Get flags from stack

	jr z,l0e0eh	;0e0a	If Zf not set, store upper byte into (HL+1) 
	inc hl		;0e0c	 
	ld (hl),b	;0e0d	
l0e0eh:
	rst 30h		;0e0e	f7 	  

; 'USR'
; =====
; "USR" BASIC function.

;; USR
l0e0fh:
	push de		;0e0f	Save DE pointer on stack
	ld de,l0abdh	;0e10	Load INT_TO_FP_2 address on stack
	push de		;0e13
	jp (hl)		;0e14	Jump to user function
			;	(returns back to INT_TO_FP_2, which pushes
			;	result to arithmetic stack and restores DE
			;	pointer)

;; CHR$
l0e15h:
	or d			;0e15	b2 	  
	ld a,l			;0e16	7d 	} 
	ret			;0e17	c9 	  
;; FOR
l0e18h:
	call l0974h		;0e18	cd 74 09 	  t   
	call l0730h		;0e1b	cd 30 07 	  0   
	ld (02aa1h),hl		;0e1e	22 a1 2a 	"   * 
	rst 18h			;0e21	df 	  
	ld d,h			;0e22	54 	T 
	or d			;0e23	b2 	  
	rst 18h			;0e24	df 	  
	ld c,a			;0e25	4f 	O 
	xor a			;0e26	af 	  
	rst 8			;0e27	cf 	  
	ld (02a6eh),hl		;0e28	22 6e 2a 	" n * 
	ld l,0d8h		;0e2b	2e d8 	.   
	jp l0398h		;0e2d	c3 98 03 	      

; 'SAVE'
; ======
; "SAVE" BASIC command.

;; SAVE
l0e30h:	
	ld hl,02c36h	;0e32 	Load BASIC_START address into HL...
	push hl		;0e33	...and save it to stack

	ld hl,(02c38h)	;0e34	Load BASIC_END into HL

	rst 18h		;0e37	Call READ_PAR
	db 00dh		;0e38	ASCII CR
	db l0e3ch-$-1	;0e39

	jr l0e42h	;0e3a	There is no parameter on the rest of the line.
			;	Jump forward

; This looks like the SAVE nnnn,nnnn variant of the command.

l0e3ch:
	rst 8		;0e3c	Call EVAL_INT_EXP

	ex (sp),hl	;0e3d	Replace BASIC_START address on the stack with
			;	the number from EVAL_INT_EXP
	call l0005h	;0e3e	Call EVAL_INT_EXP_NEXT

	inc hl		;0e41	Replace BASIC_END address in HL with the number
			;	from EVAL_INT_EXP_NEXT + 1.

l0e42h:
	pop de		;0e42	...restore BASIC_START address into DE
			;	(address of the first byte of the block to 
			;	save)

	ld b,060h	;0e43	Load 60h into B
	di		;0e45	Disable interrupts

; Save 96 sync bytes (00h)

l0e46h:
	xor a		;0e46	Clear A
	call l0e68h	;0e47	Call SAVE_BYTE
	djnz l0e46h	;0e4a	Repeat 96 times

; B = 0 and from now on holds the sum of all saved bytes.

; Save start byte (a5h)

	ld a,0a5h	;0e4c	Load a5h into A
	call l0e68h	;0e4e	Call SAVE_BYTE

	call l0e62h	;0e51	Call SAVE_WORD
			;	Saves DE (start address)
	call l0e62h	;0e54	Call SAVE_WORD
			;	Saves HL (end address)

	dec hl		;0e57	Decrement HL 
			;	(address of the last byte of the block to save)

; Save data (from DE to HL inclusive)

l0e58h:
	ld a,(de)	;0e58	Load byte at (DE) into A
	inc de		;0e59	Increment DE
	call l0e68h	;0e5a	Call SAVE_BYTE
	jr nc,l0e58h	;0e5d	If DE <= HL then loop

	ld a,b		;0e5f	Load sum into A
	cpl		;0e60	Complement A (make checksum)
	ld e,a		;0e61	Load checksum into E

; Save checksum and one garbage byte in D and return.

; 'SAVE WORD'
; ===========
; This function saves one word (16 bits) to the audio cassette.

; Parameters:
;	DE: word to be saved
; Returns:
;	HL: holds previous contents of DE
;	DE: holds previous contents of HL
;	B: B + sum of both saved bytes
; Destroys:
;	A

;; SAVE_WORD
l0e62h:
	ex de,hl	;0e62	Exchange contents of DE and HL registers.
	ld a,l		;0e63	Load L into A
	call l0e68h	;0e64	Call SAVE_BYTE

	ld a,h		;0e67	Load H into A

; Save the second byte and return.

; 'SAVE BYTE'
; ===========
; This function saves one byte to the audio cassette.

; Parameters:
;	A: byte to be saved
; Returns:
;	B: B = B + A
;	flags: output of CMP_HL_DE
; Destroys:
;	A

;; SAVE_BYTE
l0e68h:
	exx		;0e68	Exchange BC,DE,HL with BC',DE',HL'

	ld c,010h	;0e69	Load 16 into C
	ld hl,02038h	;0e6b	Load latch address (2038h) into HL

;; SAVE_BYTE_LOOP
l0e6eh:
	bit 0,c		;0e6e	Test bit 0 of C
	jr z,l0e77h	;0e70	If C even, always make an impulse on output...
	rrca		;0e72	...else rotate A right (stores LSB in C flag)
	ld b,064h	;0e73	   load 100 into B
	jr nc,l0e86h	;0e75	   skip impulse if LSB not set

l0e77h:
	ld (hl),0fch	;0e77	Set output to high
	ld b,032h	;0e79	Load 50 into B
l0e7bh:
	djnz l0e7bh	;0e7b	Wait (approx. 650 T)
	ld (hl),0b8h	;0e7d	Set output to low
	ld b,032h	;0e7f	Load 50 into B
l0e81h:
	djnz l0e81h	;0e81	Wait (approx. 650 T)
	ld (hl),0bch	;0e83	Set output to zero
	inc b		;0e85	Load 01h into B
l0e86h:
	djnz l0e86h	;0e86	Wait (13 or 1300 T, depending whether 
			;	C was even or odd)
l0e88h:
	djnz l0e88h	;0e88	Wait (approx. 3328 T)
	dec c		;0e8a	Decrement C
	jr nz,l0e6eh	;0e8b	Jump to SAVE_BYTE_LOOP

			;	BC = 0
			;	The following loop waits for 512 cycles
l0e8dh:
	inc bc		;0e8d	Increment BC
	bit 1,b		;0e8e	Test bit 1 of B...
	jr z,l0e8dh	;0e90	... and loop if not set.

	exx		;0e92	Exchange BC,DE,HL with BC',DE',HL'

; LOAD_BYTE function jumps here at the end
l0e93h:
	add a,b		;0e93	Add B to A
	ld b,a		;0e94	B = A + B
	rst 10h		;0e95	Call CMP_HL_DE

	ret		;0e96	Return


; 'OLD'
; =====
; "OLD" BASIC command.

; Verifies saved data if there is a '?' character after the command.

;; OLD
l0e97h:
	rst 18h		;0e97	Call READ_PAR
	db '?' 		;0e98
	db l0e9ah-$-1	;0e99	Check for '?' in the argument
l0e9ah:

	push af		;0e9a	Push result of READ_PAR. 

	rst 18h		;0e9b	Call READ_PAR
	db 00dh		;0e9c	ASCII CR
	db l0ea0h-$-1	;0e9d

	rst 28h		;0e9e	Call CLEAR_HL
	db 03eh		;0e9f	Dummy ld a,	(ignores "rst 8" instruction,
			;			if there was no parameter)
l0ea0h:
	rst 8		;0ea0	Read load offset to HL (Call EVAL_INT_EXP)

	push hl		;0ea1	Store load offset on stack

	di		;0ea2	Disable interrupts

; Wait for the start byte (a5h)

l0ea3h:
	call l0eddh	;0ea3	Call LOAD_BYTE
	ld a,c		;0ea6	
	cp 0a5h		;0ea7	Compare loaded byte with a5h and ...
	jr nz,l0ea3h	;0ea9	... loop if not equal.

	ld b,a		;0eab	Load a5h into B 
			;	(value of the first loaded byte, for checksum)
	call l0ed9h	;0eac	Call LOAD_WORD (start address)
	ld h,c		;0eaf

	pop de		;0eb0	Fetch load offset from stack and add it
	push de		;0eb1	to the start address.
	add hl,de	;0eb2

	ex de,hl	;0eb3	DE = start address

	call l0ed9h	;0eb4	Call LOAD_WORD (end address)
	ld h,c		;0eb7

	dec hl		;0eb8	Decrement end address 
			;	HL = address of last byte to load

	ld a,b		;0eb9	Save checksum to A

	pop bc		;0eba	Add load offset
	add hl,bc	;0ebb	

	ld b,a		;0ebc	Restore checksum to B

l0ebdh:
	ex de,hl	;0ebd	HL = address of the current byte
			;	DE = address of the last byte

	call l0eddh	;0ebe	Call LOAD_BYTE
	ex af,af'	;0ec1	F' holds results of CMP_HL_DE

	ld a,c		;0ec2	Compare loaded byte with (HL) and ...
	cp (hl)		;0ec3		
	jr z,l0ecbh	;0ec4	... jump forward if equal

	pop af		;0ec6	Restore flags 
	jr z,l0ed6h	;0ec7	Jump to WHAT_RST if loaded byte not equal 
			;	to memory byte and verify mode is enabled
			;	(Z flag is set by the READ_PAR function).
	push af		;0ec9	Save flags

	ld (hl),c	;0eca	Store loaded byte in memory

l0ecbh:
	inc hl		;0ecb	Increment HL

	ex de,hl	;0ecc	DE = address of the current byte
			;	HL = address of the last byte

	ex af,af'	;0ecd 	  
	jr c,l0ebdh	;0ece	Loop if current address < last address

	call l0eddh	;0ed0	Call LOAD_BYTE (checksum)
	pop af		;0ed3	Remove stored flags from stack

	inc b		;0ed4	Return if B = ffh, else display WHAT? error
	ret z		;0ed5	

l0ed6h:
	jp l078fh	;0ed6	Jump to WHAT_RST
			;	Tape loading error

; 'LOAD WORD'
; ===========
; Loads one word (16 bits) from the audio cassette. It executes CMP_HL_DE
; function and returns its result in the flag register.

; Returns:
;	L: low byte
;	C: high byte
;	B: B = B + sum of both loaded bytes
;	flags: Result of the CMP_HL_DE function.

;; LOAD_WORD
l0ed9h:
	call l0eddh	;0ed9	Call LOAD_BYTE
	ld l,c		;0edc	Save result into L

; Continue with another LOAD_BYTE and return

; 'LOAD BYTE'
; ===========
; This function loads one byte from the audio cassette.

; Returns:
;	C: byte loaded 
;	B: B = B + C

;; LOAD_BYTE
l0eddh:
	exx		;0edd
	ld b,001h	;0ede	Load 1 into B'

l0ee0h:
	ld a,0a7h	;0ee0	Load 167 into A

; This block waits for an impulse on the cassette port. If B' = 1 (on first 
; iteration), it waits indefinitely. If B' = 0 it waits for A loop iterations.

; 49 T * 167 = 8183 T = 2.7ms

;; LOAD_WAIT_PULSE
l0ee2h:
	add a,b		;0ee2	4	Add B' to A
	ld hl,02000h	;0ee3	10	Load cassette port address into HL'
	bit 0,(hl)	;0ee6	12	Test bit 0 
	jr z,l0ef1h	;0ee8	12,7	If impulse was detected, break loop...
	dec a		;0eea	4	...else decrement A and
	jr nz,l0ee2h	;0eeb	12,7	   loop to LOAD_WAIT_PULSE if not zero

	exx		;0eed	4	
	ld a,c		;0eee	4	Load C into A

	jr l0e93h	;0eef		B = A + B, compare HL with DE
			;		and return from function

l0ef1h:

; Pause for 4369 T = 1.42 ms

	ld b,0dah	;0ef1	7	Load 218 into B'
l0ef3h:
	ld a,0a9h	;0ef3	7	Load a9h into A
	djnz l0ef3h	;0ef5	13,8	Loop

	ld b,05ah	;0ef7	7	Load 90 into B'

; This loop checks if the first pulse is followed by another one in specified
; time interval. It has 90 iterations, each 35 T (11.4us) long. If input is 
; low in more than 4 iterations (so that A doesn't overflow), then bit 1 is 
; loaded into C. Else bit 0.

; This gives a minimum pulse width of 140 T (45 us). 

;; LOAD_READ_PULSE
l0ef9h:
	ld c,(hl)	;0ef9	7	Load C' from cassette port
	rr c		;0efa	8	Move bit 0 into carry flag...
	adc a,000h	;0efc	7	...and add it to A
	djnz l0ef9h	;0efe	13,8	Loop to LOAD_READ_PULSE

	rlca		;0f00	Rotate A left (MSB into carry flag)
	exx		;0f01
	rr c		;0f02	Rotate C right (carry flag into MSB)
	exx		;0f04

	jr l0ee0h	;0f05	Loop LOAD_WAIT_PULSE (B' = 0)

; **********************************
; * BASIC INTERPRETER DATA SECTION *
; **********************************

; 'READY STRING'
; ==============
; Command prompt string, printed when in command line mode.
;; READY
l0f07h:
	dm 040h, 027h			;0f07
	dm "READY", 00dh		;0f09

; 'BASIC TABLES'
; ==============
; Following section contains tables for the BASIC interpreter 
; (NOTE: complete table must fit into 0fxxh page)

; Format of the table is:
;	dm 	"function name"
;	db 	"high byte of function's address" + 80h 
;			( + 40h if function takes an integer argument in 
;			parenthesis)
;	db 	"low byte of function's address"

; A catch-all rule lacks the function name.

; 'BASIC COMMAND LINE TABLE'
; ==========================
; These BASIC commands take zero or one integer argument and can only appear 
; on the command line.

;; BASIC_CMDLINE_TABLE
l0f0fh:
	dm "LIST"			;0f0f
	db ((l045eh>>8)&00ffh)+80h	;0f13
	db (l045eh)&00ffh		;0f14

	dm "RUN"			;0f15
	db ((l040bh>>8)&00ffh)+80h	;0f18
	db (l040bh)&00ffh		;0f19

	dm "NEW"			;0f1a
	db ((l03fch>>8)&00ffh)+80h	;0f1d
	db (l03fch)&00ffh		;0f1e

	dm "SAVE"			;0f1f
	db ((l0e30h>>8)&00ffh)+80h	;0f23
	db (l0e30h)&00ffh		;0f24

	dm "OLD"			;0f25
	db ((l0e97h>>8)&00ffh)+80h	;0f28
	db (l0e97h)&00ffh		;0f29

	dm "EDIT"			;0f2a
	db ((l0299h>>8)&00ffh)+80h	;0f2e
	db (l0299h)&00ffh		;0f2f

; 'BASIC COMMAND TABLE'
; =====================
; These BASIC commands take zero or one integer argument and jump to 
; RUN_THIS_LINE routine (or one of interpreter's other entry points) at the
; end.

;; BASIC_CMD_TABLE
l0f30h:
	dm "NEXT"			;0f30
	db ((l0564h>>8)&00ffh)+80h	;0f34
	db (l0564h)&00ffh		;0f35

	dm "INPUT"			;0f36
	db ((l066ch>>8)&00ffh)+80h	;0f3b
	db (l066ch)&00ffh		;0f3c

	dm "IF"				;0f3d
	db ((l0441h>>8)&00ffh)+80h	;0f3f
	db (l0441h)&00ffh		;0f40

	dm "GOTO"			;0f41
	db ((l0453h>>8)&00ffh)+80h	;0f45
	db (l0453h)&00ffh		;0f46

	dm "CALL"			;0f47
	db ((l04f4h>>8)&00ffh)+80h	;0f4b
	db (l04f4h)&00ffh		;0f4c

	dm "UNDOT"			;0f4d
	db ((l06cch>>8)&00ffh)+80h	;0f52
	db (l06cch)&00ffh		;0f53
	
	dm "RET"			;0f54
	db ((l0512h>>8)&00ffh)+80h	;0f57
	db (l0512h)&00ffh		;0f58

	dm "TAKE"			;0f59
	db ((l0626h>>8)&00ffh)+80h	;0f5d
	db (l0626h)&00ffh		;0f5e

	dm "!"				;0f5f
	db ((l044dh>>8)&00ffh)+80h	;0f60
	db (l044dh)&00ffh		;0f61

	dm "#"				;0f62
	db ((l044dh>>8)&00ffh)+80h	;0f63
	db (l044dh)&00ffh		;0f64

	dm "FOR"			;0f65
	db ((l0e18h>>8)&00ffh)+80h	;0f68
	db (l0e18h)&00ffh		;0f69

	dm "PRINT"			;0f69
	db ((l0480h>>8)&00ffh)+80h	;0f6f
	db (l0480h)&00ffh		;0f70

	dm "DOT"			;0f71
	db ((l06cfh>>8)&00ffh)+80h	;0f74
	db (l06cfh)&00ffh		;0f75

	dm "ELSE"			;0f76
	db ((l044dh>>8)&00ffh)+80h	;0f7a
	db (l044dh)&00ffh		;0f7b

	dm "BYTE"			;0f7c
	db ((l0dffh>>8)&00ffh)+80h	;0f80
	db (l0dffh)&00ffh		;0f81

	dm "WORD"			;0f82
	db ((l0dfeh>>8)&00ffh)+80h	;0f86
	db (l0dfeh)&00ffh		;0f87

	dm "ARR$"			;0f88
	db ((l010bh>>8)&00ffh)+80h+40h	;0f8c
	db (l010bh)&00ffh		;0f8d

	dm "STOP"			;0f8e
	db ((l0317h>>8)&00ffh)+80h	;0f92
	db (l0317h)&00ffh		;0f93

	dm "HOME"			;0f94
	db ((l04d6h>>8)&00ffh)+80h	;0f98
	db (l04d6h)&00ffh		;0f99

; Catch-all rule for BASIC commands.

	db ((l075bh>>8)&00ffh)+80h	;0f9a
	db (l075bh)&00ffh		;0f9b

; 'BASIC FUNCTION TABLE'
; ======================
; These BASIC functions take zero or one integer arguments and leave a
; floating point value on the arithmetic stack after they return.

;; BASIC_FUNC_TABLE
l0f9ch:
	dm "RND" 			;0f9c
	db ((l0c8fh>>8)&00ffh)+80h	;0f9f
	db (l0c8fh)&00ffh		;0fa0

	dm "MEM"			;0fa1
	db ((l0d9ah>>8)&00ffh)+80h	;0fa4
	db (l0d9ah)&00ffh		;0fa5

	dm "KEY" 			;0fa6
	db ((l0dabh>>8)&00ffh)+80h+40h	;0fa9
	db (l0dabh)&00ffh		;0faa

	dm "BYTE"			;0fab
	db ((l0dbch>>8)&00ffh)+80h+40h	;0faf
	db (l0dbch)&00ffh		;0fb0

	dm "WORD"			;0fb1
	db ((l0da5h>>8)&00ffh)+80h+40h	;0fb5
	db (l0da5h)&00ffh		;0fb6

	dm "PTR"			;0fb7
	db ((l0769h>>8)&00ffh)+80h	;0fba
	db (l0769h)&00ffh		;0fbb

	dm "VAL"			;0fbc
	db ((l0770h>>8)&00ffh)+80h+40h	;0fbf
	db (l0770h)&00ffh		;0fc0

	dm "EQ"				;0fc1
	db ((l0dc2h>>8)&00ffh)+80h	;0fc3
	db (l0dc2h)&00ffh		;0fc4

	dm "INT"			;0fc5
	db ((l0abch>>8)&00ffh)+80h+40h	;0fc8
	db (l0abch)&00ffh		;0fc9

	dm "&"				;0fca
	db ((l0ddfh>>8)&00ffh)+80h	;0fcb
	db (l0ddfh)&00ffh		;0fcc

	dm "USR"			;0fcd
	db ((l0e0fh>>8)&00ffh)+80h+40h	;0fd0
	db (l0e0fh)&00ffh		;0fd1

	dm "DOT"			;0fd2
	db ((l06dch>>8)&00ffh)+80h	;0fd5
	db (l06dch)&00ffh		;0fd6

; Catch-all rule for BASIC functions.

	db ((l0777h>>8)&00ffh)+80h	;0fd7
	db (l0777h)&00ffh		;0fd8

	dm "STEP"			;0fd9
	db ((l0528h>>8)&00ffh)+80h	;0fdd
	db (l0528h)&00ffh		;0fde

; Catch-all rule

	db ((l052ah>>8)&00ffh)+80h	;0fdf
	db (l052ah)&00ffh		;0fe0

; 'BASIC "PRINT" COMMAND TABLE'
; =============================
; These BASIC commands can only appear after the "PRINT" command. They
; jump to RUN_THIS_LINE routine (or one of interpreter's other entry points)
; at the end.

;; BASIC_PRINT_TABLE
l0fe1h:

	dm "AT"				;0fe1
	db ((l04bch>>8)&00ffh)+80h	;0fe3
	db (l04bch)&00ffh		;0fe4

	dm "X$"				;0fe5
	db ((l0498h>>8)&00ffh)+80h	;0fe7
	db (l0498h)&00ffh		;0fe8

	dm "Y$"				;0fe9
	db ((l049bh>>8)&00ffh)+80h	;0feb
	db (l049bh)&00ffh		;0fec

; Catch-all rule

	db ((l048eh>>8)&00ffh)+80h	;0fed
	db (l048eh)&00ffh		;0fee
	
	dm "CHR$"			;0fef
	db ((l0e15h>>8)&00ffh)+80h+40h	;0ff3
	db (l0e15h)&00ffh		;0ff4

; Catch-all rule

	db ((l060bh>>8)&00ffh)+80h	;0ff5
	db (l060bh)&00ffh		;0ff6

	dm "ELSE"			;0ff7
	db ((l041ah>>8)&00ffh)+80h	;0ffb
	db (l041ah)&00ffh		;0ffc

; Catch-all rule

	db ((l081bh>>8)&00ffh)+80h	;0ffd
	db (l081bh)&00ffh		;0ffe

; One (!) spare byte

	db 00h				;0fff

	end

; * Galaksija ROM B assembly listing
;
;  It macthes the binary file ROM_B.bin
;  Original images from https://www.voja.rs/galaksija/ROM%20B%20Listing%20Scans/ROM_B_listing.htm
;  Thanks Voja!
;
; * About this version;
;  author: issalig 14/02/2025
;  Converted to txt and translated with an LLM from the listing images
;  The prompt used was:
;     'I have a listing of z80 assembler. The typical line contains the address, the code of the instruction
;   in hexadecimal, the number of line, a label, a mnemonic of the instruction, the parameters of the
;   instruction and the comments. I want to convert it to text and translate into English the comments that
;   are the end of the lines. Also put a ";" before the comment if it does not have it. please provide the
;   full listing and do not miss any column'
;
;  Then some hours of sanding, polishing, hammering and comparing it with the original binary.
;  LLMs are incredibly helpful but they are not still perfect.
;
;  Some labels are renamed not to be in confllict with instrucions or directives: ABS_, CPI_, SUB_
;  <- has been converted to >> in order to work with pasmo and sjasmplus
;  MONITOR has been included to provide different versions of the ROM
; * Assembler
;  To assemble it you can use
;  - sjasmplus --raw=file.bin file.asm
;  - pasmo -v  file.asm file.bin

; 011078

;********************************************************
;*                                                      *
;*         "GALAKSIJA" ROM B                            *
;*                                                      *
;*                             VOJA ANTONIC 12.07.84.   *
;*                                                      *
;********************************************************
SPACE    EQU     90
SHOMEM   EQU     2A97H
SHOFOR   EQU     2BB2H
OPTION   EQU     2BB3H
FIELD    EQU     2BB6H+34
INS1     EQU     FIELD+5
INS2     EQU     INS1+1
INS3     EQU     INS2+3
IXIY     EQU     INS3+3
CODE     EQU     IXIY+1
ADDR     EQU     CODE+5
TEXTBR   EQU     ADDR+2
TEMP1    EQU     TEXTBR+1
TEMP2    EQU     TEMP1+2
KRUG     EQU     2AAAH
FLAG2    EQU     2AABH
FREE     EQU     TEMP2+3
IXPOS2   EQU     FREE+2
DISPL    EQU     IXPOS2+2
FLAG     EQU     2BB5H
PLUS     EQU     0B32H
MINUS    EQU     0B1EH
PUTA     EQU     0AE6H
KROZ     EQU     0AF7H
CPIXIX   EQU     0B10H

MONITOR  EQU     0CH  ; ROM_B.bin is 0C
                      ; ROM_B_monitor_value_13.bin 0D                        
                      ; ROM_B_monitor_fix.bin 0B

        ORG     1000H
        LD      HL,(2A6AH) ; IF (ENDMEM)=0 THEN (ENDMEM)=0FFFFH
        LD      A,H
        OR      L
        JR      NZ,NOT56K ; ENDMEM > 0
        DEC     HL ; CORRECTED ENDMEM
        LD      (2A6AH),HL
NOT56K:  LD      A,0CH
        JR      GOINI
ZALINK:  EX      (SP),HL
        PUSH    DE
        LD      DE,75BH ; THIS IS THE POSITION WHERE IT WOULD JUMP IF NOT...
        RST     10H ; ...RECOGNIZED WORD IN BASIC PROGRAM
        JR      NZ,DRUGIP
        LD      HL,TEXT1-1 ; TABLE OF NEW WORDS
        POP     DE
CASE1:   POP     AF
        JP      39AH ; RECOGNIZE NEW WORD; IF IT DOESN'T EXIST IN TABLE...
KAO75B:  JP      75BH ; ...JUMP TO 10FH, THEN TO 75BH (SEE Z100)
GOINI:   RST     20H
; this byte #1023 changes in different versions of the ROM
; ROM_B_monitor_value_13.bin byte is 13(D)  
; ROM_B.bin is 12(C)
; ROM_B_monitor_fix.bin 11 (B)
        LD      A, MONITOR; 0CH ; NEW HORIZONTAL POSITION
        LD      (2BA8H),A
        LD      HL,LINKS ; INSERT JP INSTEAD OF RET IN LINKS
        LD      DE,2BA9H
        LD      BC,6
        LDIR ; INITIALIZATION OF ROM-A 2
        RET
DRUGIP:  LD      DE,48EH ; SECOND ATTEMPT: CHECK IF IT'S CORRECTLY RECOGNIZED...
        RST     10H ; WORD 'PRINT', IF IT IS, CHECK WHAT FOLLOWS
        JR      NZ,TRECIP
        POP     DE
        EX      (SP),HL
        POP     AF
        RST     18H
        DEFB    '%'
        DEFB    KAO48E-$-1
        RST     8
        LD      A,' ' ; WRITE BLANK
        RST     20H
        CALL    HEX16B ; WRITE NUMBER IN HEX FORMAT
        JP      4ADH
KAO48E:  JP      48EH ; CONTINUES WHERE IT STARTED IF '%' DOESN'T FOLLOW
TRECIP:  LD      DE,777H ; THIRD ATTEMPT: CHECK IF IT TRIED TO RECOGNIZE...
        RST     10H ; ...FUNCTION, BUT FAILED (777H IS ADDRESS...
        POP     DE ; ...TO WHICH IT WOULD JUMP IN THAT CASE)
        EX      (SP),HL
        RET     NZ
        LD      HL,TEXT3-1 ; TABLE OF NEW FUNCTIONS
        JR      CASE1 ; END IS SAME AS IN FIRST ATTEMPT
KAO777:  JP      777H
LPRINT:  LD      BC,480H ; 'LPRINT' ENTRY POINT: RET ADDRESS TO 'PRINT'
        PUSH    BC ; GOES TO STACK
COPY:    LD      A,0FFH ; SETS LPRINT FLAG
        LD      (FLAG),A
        RET
LLIST:   CALL    COPY ; 'LLIST' ENTRY POINT: SET FLAG
        CALL    0CD3H ; CONTINUE AS LLIST
        JP      464H
VIDEO:   PUSH    AF ; ADDITION TO SUBPROGRAM THAT WRITES CHARACTER TO...
        LD      HL,(FLAG) ; ...VIDEO MEM (958H, BUT HERE IS CHECKING...
        INC     L ; IS THE FLAG FOR PRINTER SET?
        JR      NZ,NCOPY ; IF NOT, EXIT
        LD      HL,2AABH ; CHECK IF FLAG IS SET TO NOT WRITE...
        BIT     0,(HL) ; ...CONTROL CHARS?
        JR      NZ,STAND ; IF YES, SKIP CHARACTER CHANGE
        LD      HL,TABCZS ; IF NOT, POINTER TO TABLE
        LD      B,4 ; TOTAL 4 CHARS FOR COMPARISON
TEST4:   CP      (HL) ; IS THIS THE SEARCHED WORD?
        INC     HL
        JR      Z,FOUND4 ; YES, JUMP
        INC     HL
        DJNZ    TEST4 ; TRY NEXT
        DEFB    26H ; AS 'LD H,ZEH' - TO SAVE MEMORY...
FOUND4:  LD      A,(HL) ; ...SKIP NEXT WORD
STAND:   PUSH    AF ; ...SAVE NEW WORD
RDY:     CALL    2FFH ; 'BREAK' TEST
        IN      A,(255)
        RLA
        JR      C,RDY ; JUMP IF PRINTER IS BUSY
        POP     AF
        OUT     (255),A ; PRINTER FREE - SEND CHARACTER
NCOPY:   POP     AF
        RET
TABCZS:  DEFB    91 ; = C caron
        DEFB    'C'
        DEFB    92
        DEFB    'C' ; = C acute
        DEFB    93
        DEFB    'Z' ; = Z caron
        DEFB    94
        DEFB    'S' ; = S caron
LINKS:   DEFB    0C3H
        DEFW    ZALINK ; CHECK LINE 655 (C3H=JP)
        DEFB    0C3H
        DEFW    VIDEO
GOASS:   LD      HL,(2A9FH) ; ********** ASSEMBLER **********
        LD      A,H ; IS IT COMMAND MODE?
        OR      L
        JP      Z,1626D ; IF YES
        EX      DE,HL ; MAIN POINTER WILL BE HL
        LD      A,1 ; SET OPT 1
        LD      (OPTION),A
        CALL    START1 ; CALL PROGRAM FOR ASSEMBLY
        LD      IX,2AACH ; RETURN CORRECT VALUE IX REGISTER
        DEC     HL
        EX      DE,HL ; RETURN POINTER DE
        RST     30H ; GO BACK TO BASIC
START1:  XOR     A
        LD      (KRUG),A ; FIRST ASSEMBLY PASS
        LD      (INS1),A ; EXECUTE OPCODE TOKEN
        EX      DE,HL ; SAVE HL IN DE
        RST     28H ; THIS IS LD HL,0
        LD      (DISPL),HL
        LD      (SHOMEM),HL ; FOR 'REG'; SHOWS 0 BYTES OF MEMORY
        LD      HL,(2A6AH) ; = ENDMEM
        DEC     HL
        LD      (HL),A ; 0 = TERMINATOR TABLE FOR LABELS
        DEC     HL
        LD      (HL),A
        EX      DE,HL ; RETURN HL
        CALL    FINDCR ; FIND END OF LINE WHERE IS '<'
        PUSH    HL ; SAVE POINTER FOR SECOND PASS
        CALL    ASS ; FIRST ASSEMBLY PASS
        LD      HL,KRUG
        INC     (HL) ; SET SECOND PASS
        XOR     A
        LD      (INS1),A ; EXECUTE OPCODES
        POP     HL ; RETURN POINTER TO START 1...
ASS:     XOR     A ; ...ENTER IN SECOND PASS
        LD      (TEXTBR),A ; 0 WORDS IN TEXT
        LD      (ADDR),A ; ERASE LABEL ADDRESS IN PROGRAM
        LD      (ADDR+1),A
LOOP     EQU     $ ; FOLLOWING 13 LINES ARE MAIN LOOP
        LD      (2A9FH),HL ; POSITION OF CURRENT LINE(FOR ERROR CASE)
        LD      DE,(2C38H) ; END OF BASIC
        RST     10H
        RET     NC ; RETURN IF IT'S END AND NO '>'
        LD      A,(INS1)
        CP      8
        RET     Z ; RETURN IF IT'S '>'
        CALL    2FFH ; 'BREAK' TEST
        CALL    PROG1 ; FIRST PART: PUTTING TOKEN IN TABLE
        PUSH    HL
        CALL    PROG2 ; SECOND PART: CODE FORMING
        POP     HL
        JR      LOOP ; BACK TO MAIN LOOP
PROG2:   LD      HL,GOON ; THIS IS RET ADDRESS FOR END OF SUBROUTINE
        PUSH    HL
        LD      HL,INS2
        LD      IX,FIELD+3
        LD      A,(INS1)
        OR      A
        RET     Z ; NOTHING IN THIS LINE - GO TO GOON
        CP      9 ; IS IT SPECIAL WORD (TOKEN=9)
        JP      NC,NCOMM ; NO - NEXT WORD FOR ASSEMBLY
        DEC     A
        JR      NZ,NSTAT ; NOT TOKEN 1
        LD      HL,BRKPT ; TOKEN 1: 'REG' (BREAKPOINT)
        LD      (CODE+1),HL ; BREAKPOINT ADDRESS
        LD      A,0CDH ; CODE FOR 'CALL'
        LD      (CODE),A
        LD      A,3
        LD      (CODE+4),A ; 3 BYTES CODED LENGTH
        LD      HL,(INS2+1) ; IS THERE MEMORY DISPLAY?
        LD      A,H
        OR      L
        RET     Z ; NO - GO TO GOON
        CALL    IFNUM2 ; IS IT NUMERIC VALUE (IF NOT-WHAT?)
        LD      (SHOMEM),HL ; SHOW HL MEMORY
        LD      A,(INS3+1) ; HOW MANY ROWS?
        OR      A
        JR      NZ,IMA ; NUMBER OF ROWS SPECIFIED
        INC     A ; NOT SPECIFIED - THEN 1 ROW
IMA:     LD      (SHOFOR),A ; = SHOW FORMAT
        RET
NSTAT:   DEC     A
        JR      NZ,NTEXT ; NOT TOKEN 2
        LD      A,(HL) ; TOKEN 2: 'TEXT'
        LD      (TEXTBR),A ; NUMBER OF TEXT WORDS
        LD      DE,CODE
TEXTIT:  LD      B,3 ; 3 BYTES IN ONE ROW
TXT4:    LD      A,(TEXTBR) ; HOW MANY WORDS LEFT?
        OR      A
        RET     Z ; NONE - GO TO GOON
        DEC     (IX+17) ; DECREASE WORD COUNT
        LD      HL,(INS2+1) ; TEXT ADDRESS IN PROGRAM
        LD      A,(HL) ; TAKE WORD OR CHARACTER
        INC     HL ; INCREASE POINTER
        LD      (INS2+1),HL ; AND RETURN IT
        LD      (DE),A ; PUT CHARACTER IN CODE
        INC     DE ; INCREASE CODE POINTER
        INC     (IX+14) ; INCREASE BYTE COUNT
        DJNZ    TXT4 ; DO THIS 3 TIMES IN EACH ROW
        RET ; GO TO GOON
NTEXT:   DEC     A
        JR      NZ,NWORD ; NOT TOKEN 3
        INC     A ; TOKEN 3: 'WORD'
        LD      (IX+14),A ; BYTE COUNT=1 (AND ON 5120 WILL BE +1)
NWORD:   DEC     A
        JR      NZ,NBYTE ; NOT TOKEN 4 OR 3
        CALL    IFNUM1 ; TOKEN 4: 'BYTE'
        LD      HL,(INS2+1) ; TAKE CODE
        LD      (CODE),HL ; PUT IT IN ITS PLACE
        JP      IXGOON ; SEE 5120
NBYTE:   DEC     A
        JR      NZ,NOPT ; NOT TOKEN 5
        CALL    IFNUM2 ; TOKEN 5: 'OPT' (IF >255, WHAT)
        LD      HL,(INS2+1) ; TAKE NUMBER OPTION
        LD      A,L ; U A REG
        AND     4 ; IF BIT 2 IS SET (4-5-6-7)
;new page
        CALL NZ,COPY ; SET FLAG FOR PRINTER
        LD A,L
        AND 3
        LD (OPTION),A ; MASK TO BE LESS THAN 4
        LD A,(INS3)
        OR A ; IS RELOCATION REQUESTED ON WRITE?
        RET Z ; NO - GO TO GOON
        CP 40H
        JP NZ,WHATHL ; NOT NUMERIC - ERROR
        LD HL,(INS3+1) ; RELOCATION SIZE...
        LD (DISPL),HL ; ...TO ITS PLACE
        RET
NOPT:    DEC A
        JR NZ,NORG ; NOT TOKEN 6
        CALL IFNUM1 ; TOKEN 6: 'ORG'
        LD HL,(INS2+1)
        LD (TEMP1),HL ; TEMPORARY ADDRESS
SKR4:    LD (ADDR),HL ; MAIN POINTER OF PC ADDRESS
        RET
NORG:    DEC A
        RET NZ ; END = TOKEN 8 '>'
        CALL IFNUM1 ; TOKEN 7: 'EQU'
        LD BC,(INS2+1)
        LD (TEMP1),BC ; LABEL ADDRESS
        CALL CREATE ; FORM LABEL
        JP Z,WHATHL ; IF NOT PROVIDED - WHAT
        POP AF ; RESTORE STACK - WON'T GO TO GOON
        JP GOON1 ; BUT TO GOON1
CREATE:  LD A,(KRUG) ; ---- LABEL FORMATION ----
        OR A
        RET NZ ; CANNOT BE FORMED IN SECOND PASS
        LD HL,(FIELD+2)
        LD A,H
        OR L
        RET Z ; RETURN IF LABEL ADDRESS DOESN'T EXIST
        CALL LOCAT2 ; CHECK IF IT'S ALREADY FORMED
        JP Z,HOWHL ; IF IT EXISTS - CANNOT BE FORMED TWICE (HOW?)
TRANSF:  PUSH HL
        LD HL,(2C38H) ; END OF BASIC PROGRAM
        RST 10H
        POP HL
        JP NC,339D ; SORRY - NO MEMORY
        LD A,(HL)
        LD (DE),A ; TRANSFER LETTER BY LETTER TO TABLE
        INC HL
        DEC DE
        CALL NCSLBR ; IF LETTER OR NUMBER
        JR NC,TRANSF ; ...CONTINUE WITH TRANSFER
NOTRAN:  EX DE,HL
        INC HL
        SET 7,(HL) ; WORD TERMINATOR = BIT 7 SET
        DEC HL
        LD (HL),B ; BC = LABEL VALUE
        DEC HL
        LD (HL),C
        DEC HL
        LD (HL),0 ; TABLE TERMINATOR
        EX DE,HL ; HL = POINTER NOW BEHIND NAME
        XOR A ; RESET Z FLAG (SIGN THAT EVERYTHING IS OK)
        INC A ; NEW POSITION IN TABLE
        RET
;new page
LOCATE:  LD    A,(KRUG) ; ---- LOOP LABEL ----
        OR    A
        JR    NZ,LOCAT2 ; ONLY IN SECOND LOOP
        DEC   HL ; AND IN 1. LOOP JUST SKIP NAME
SRC20H:  INC   HL
        CALL  NCSLBR
        JR    NC,SRC20H
        XOR   A
        LD    B,A
        LD    C,A
        RET
LOCAT2:  PUSH  HL
        EXX
        LD    HL,(2A6AH) ; END OF MEMORY (START OF COMPARISON)
        DEC   HL
        JR    IFF1R ; START
GOSRCH:  POP   DE ; RECONSTRUCT POINTER
        PUSH  DE
GOSRC2:  LD    A,(DE) ; TAKE FROM PROGRAM TEXT
        CP    (HL) ; AND COMPARE WITH LABEL LIST
        JR    Z,FOUNDV ; ONE WORD MATCHES
        OR    80H ; SET BIT 7 (AS IN THE LAST CHARACTER)
        CP    (HL) ; AND COMPARE AGAIN (MAYBE IT'S THE END)
        JR    Z,BASFDU ; STILL - SUCCESSFUL COMPARISON
SRCHV:   BIT   7,(HL) ; NO - FIND END OF THIS NAME IN LIST
        DEC   HL
        JR    Z,SRCHV ; NOT THE END YET
        DEC   HL ; SKIP VALUE IN LIST
        DEC   HL ; ONE MORE BYTE
IFF1R:   LD    A,(HL) ; NEXT NAME (FIRST CHARACTER)
        OR    A ; MAYBE IT'S NULL (TERMINATOR TABLE)?
        JR    NZ,GOSRCH ; NO - CONTINUE COMPARISON
        PUSH  HL ; TRANSFER HL TO DE
        EXX ; ...OF ALTERNATIVE SET
        POP   DE ; DE = NEW POSITION IN TABLE
        POP   HL ; RECONSTRUCT HL
        INC   A ; A=1 (SIGN THAT NAME NOT FOUND)
        RET
FOUNDV:  DEC   HL ; COMPARISON GOING WELL
        INC   DE ; GO TO NEW CHARACTER
        JR    GOSRC2 ; CONTINUE COMPARISON
BASFDU:  INC   DE ; GO TO NEW CHARACTER IN PROGRAM
        EX    DE,HL
        CALL  NCSLBR ; IF IT'S WORD OR NUMBER, RESET CARRY
        EX    DE,HL
        JR    NC,SRCHV ; SO SAY LONG-NO SUCCESSFUL COMPARISON
        DEC   HL ; FULLY SUCCESSFUL COMPARISON; GO TO VALUE
        LD    B,(HL) ; HIGH BYTE
        DEC   HL
        LD    C,(HL) ; BC = VALUE
        EX    DE,HL ; HL = POINTER TO NAME
        POP   DE ; DE = START POINTER
        XOR   A ; A = 0 (SIGN THAT NAME IS FOUND IN LIST)
        RET
GOON:    LD    BC,(ADDR) ; ---- END OF PROCESSING ONE WORD ----
        CALL  CREATE ; CREATE NEW LABEL IF EXISTS
GOON1:   LD    DE,IXIY ; DE POINTS TO IXIY FLAG IN RAM-U
        LD    A,(DE)
        OR    A ; IS THERE SOMETHING HERE?
        JR    NZ,IMAGA ; JUMP IF INSTRUCTION REFERS TO IX OR IY
        LD    HL,CODE ; NO - CHECK CODE FOR ONE POSITION LOWER
        LD    BC,4
;new page
        LDIR
        LD    (DE),A ; PUT NULL IN LAST BYTE
        JR    PRES1
IMAGA:   CP    0EDH ; IS IT 0EDH?
        JR    Z,PRES1 ; IF YES-THEN NEITHER IX NOR IY
        LD    HL,FIELD+17 ; HL POINTS TO NUMBER OF BYTES THAT
        INC   (HL) ; INCREASES IT
        LD    A,(IX+3)
        CP    86H ; IS THE OPERAND 1...
        JR    Z,F1 ; ...IX IN BRACKETS?
        LD    A,(IX+6) ; IF YES JUMP
        CP    86H ; OR MAYBE OPERAND 2...
F1:      CALL  Z,EXTRA ; ...IX IN BRACKETS?
; IF YES CALL EXTRA SERVICE
PRES1:   LD    B,(IX+14)
        INC   B
        DEC   B ; IF IT'S NULL, SKIP
        JP    Z,NEMABY
        LD    HL,(ADDR) ; TAKE PROGRAM COUNTER
        CALL  HEX16 ; WRITE VALUE
        LD    A,' ' ; BLANK
        CALL  ZAPRIN
PRVIK1:  LD    DE,IXIY
PUTABY:  LD    A,(KRUG)
        OR    A ; WHICH ASSEMBLY PASS IS THIS
        JR    Z,PRVIK ; IF FIRST - SKIP
        PUSH  BC
        LD    B,L ; B = LOW BYTE OF PROGRAM COUNTER
        LD    C,253 ; OUTPUT ADDRESS FOR HIGH BYTE
        OUT  (C),H ; HIGH BYTE GOES TO LATCH EMULATOR
        INC   C ; NEW OUTPUT ADDRESS
        LD    A,(OPTION)
        AND   2
        LD    A,(DE) ; TAKE BYTE CODE
        OUT  (C),A ; SEND TO EMULATOR
        POP   BC
        JR    Z,NOWMR ; IF SELECTED OPTION DOESN'T REQUIRE WRITING...
        PUSH  HL ; ...TO MEMORY - SKIP
        PUSH  DE
        LD    DE,(DISPL) ; IS THERE RELOCATION WRITING?
        ADD   HL,DE ; ADD RELOCATION VALUE
        LD    (HL),A ; ****** WRITE BYTE TO MEMORY ******
        POP   DE
        POP   HL
NOWMR:   CALL  HEX8 ; PRINT BYTE ON SCREEN
        INC   DE
PRVIK:   INC   HL ; INCREASE POINTERS
        DJNZ  PUTABY ; RETURN AS MANY TIMES AS YOU HAVE BYTES
        LD    (ADDR),HL ; NEW ADDRESS OF PROGRAM COUNTER
        LD    A,(TEXTBR) ; IS THERE ANY CODE TEXT?
        OR    A
        JR    Z,NEMAB1 ; IF NOT - JUMP
        LD    A,0DH ; IMA - NEW LINE
        CALL  ZAPRIN
        LD    (IX+14),0 ; NUMBER OF BYTES = 0
        LD    DE,CODE-1 ; TAKE NEW 3 BYTES OF TEXT
        CALL  TEXTIT
        JR    PRES1 ; CONTINUE IF WORKING WITH TEXT
NEMAB1:  LD    A,(KRUG)
        OR    A
        RET   Z ; RETURN IF IT'S FIRST PASS
        LD    A,(OPTION)
        RRA
        RET   NC ; RETURN IF PRINTING IS NOT REQUIRED
GOBL:    LD    A,(2A68H) ; CURSOR POSITION
        AND   1FH ; TAKE ONLY POSITION IN LINE
;new page
        CP    0BH ; IS IT LESS THAN 11
        JR    NC,VEC11 ; NO - SKIP
        LD    A,20H ; BLANK
        RST   20H
        JR    GOBL ; WRITE BLANKS UNTIL YOU REACH TAB(11)
VEC11:   LD    DE,(2A9FH) ; TAKE POSITION OF CURRENT LINE
        CALL  RELIX1 ; PREPARE IX FOR ARITHMETIC
        LD    A,(OPTION) ; WHICH OPTION?
        RRA
        JR    NC,RELIX2 ; IF NOT PRINT TO SCREEN
        CALL  08EDH ; WRITE PROGRAM LINE NUMBER
        LD    A,(FIELD+3) ; IS THERE A LABEL?
        OR    A
        JR    NZ,UVUCI ; EXISTS - LEAVE CURSOR WHERE IT IS
        LD    A,' ' ; BLANK
        RST   20H ; ONCE
        RST   20H ; TWICE
UVUCI:   CALL  934H ; WRITE PROGRAM LINE TEXT
RELIX2:  LD    IX,(IXPOS2) ; RESTORE OLD IX
        RET ; FINISHED WITH LINE PROCESSING
NEMABY:  LD    HL,(TEMP1) ; ONLY PROGRAM COUNTER
        CALL  HEX16 ; WRITE IT
        JR    NEMAB1 ; AND WRITE LINE NUMBER AND TEXT
IFNUM1:  CALL  TEST3 ; ** IF THERE IS SECOND OPERAND...
IFNUM2:  LD    A,(INS2) ; ...OR FIRST IS NOT NUMERIC...
        CP    40H ; ...THEN WHAT
        RET   Z ; ** IF FIRST OPERAND IS NOT...
ZASN:    JP    WHATHL ; ...NUMERIC - THEN WHAT
NCOMM:   DEC   A ; CHECK IF IT'S A SIMPLE INSTRUCTION...
        LD    C,A
        CP    2AH ; ...(GROUP 2) ILI ED+ (GROUP3)
        JP    NC,CBPLUS ; IF NOT ONE OR THE OTHER, GO ON
        LD    B,6 ; TEST 6 BYTES
        XOR   A ; IN GROUP 'INS2' AND 'INS3'
XX6:     OR    (HL)
        INC   HL
        DJNZ  XX6 ; IF ANY OPERAND EXISTS
        JR    NZ,ZASN ; THEN GO TO WHAT
        LD    A,C
        CP    15H ; IS IT ED+
        JR    C,NOED ; IF NOT SKIP
        LD    (IX+9),0EDH ; STORE ED
        INC   (IX+14) ; INCREASE NUMBER OF BYTES
NOED:    LD    HL,TABY1-8 ; FIND CODED BYTE IN TABLE
        ADD   HL,BC ; ...COLLECTION...
        LD    A,(HL) ; TAKE IT FROM TABLE
        LD    (IX+10),A ; AND PUT IT IN ITS PLACE
IXGOON:  INC   (IX+14) ; INCREASE NUMBER OF BYTES
        RET ; DONE
HEX16B:  LD    A,'&' ; ****** WRITE IN HEX FORMAT HL UNCONDITIONALLY
        RST   20H ; FIRST WRITE CHARACTER '&' IN HEX NUMBER
        LD    A,1 ; SET PRINTING CONDITIONS
        LD    (OPTION),A
        LD    (KRUG),A
HEX16:   LD    A,H ; ****** WRITE IN HEX FORMAT HL CONDITIONALLY
        CALL  HEX8 ; FIRST HIGH BYTE
HEX8L:   LD    A,L ; ****** WRITE IN HEX FORMAT L CONDITIONALLY
HEX8:    LD    C,A ; ****** WRITE IN HEX FORMAT A CONDITIONALLY
        AND   0F0H ; MASK UPPER 4 BITS
        CALL  RLC4 ; ROTATE AND PUT IN LOWER 4
        CALL  HCONV ; CONVERT TO HEX DIGIT (0-9; A-F) AND WRITE
        LD    A,C
        AND   0FH ; AND SAME FOR LOWER 4 BITS
;newpage
HCONV:   ADD    A,30H ; CONVERTS TO ASCII CHARACTER
        CP     3AH ; ABOVE 9?
        JR     C,ZAPRIN ; NO - SKIP
        ADD    A,7 ; IF YES ADD 7 (TO A-F)
ZAPRIN:  PUSH   AF
        LD     A,(KRUG) ; TEST FIRST CONDITION
        OR     A ; WHICH IS ROUND?
        JR     Z,RETK1 ; IF FIRST - DON'T CONTINUE
        LD     A,(OPTION) ; TEST SECOND CONDITION
        RRA ; WHICH OPTION?
        JR     C,NORET1 ; IF PRINTING IS REQUESTED - SKIP
RETK1:   POP    AF
        RET
NORET1:  POP    AF
        RST    20H ; WRITE CHARACTER TO SCREEN AND...
        RET ; ...POTENTIALLY TO PRINTER
CBPLUS   EQU    $
        CALL   IXIYHL ; SAVE IX IY OR HL DEPENDING ON HL
        LD     A,C
        LD     B,0
        CP     34H ; IS IT GROUP 4 (CB+)
        JP     NC,GRUPA5 ; IF NOT CONTINUE
        LD     HL,TAB4-2AH ; ELSE - POINT TO TABLE
        ADD    HL,BC ; CALCULATE POSITION
        LD     B,(HL) ; GET CODE
        LD     (IX+10),0CBH ; FIRST BYTE: CB
        LD     (IX+11),B ; SECOND BYTE: FROM TABLE
        LD     (IX+14),2 ; NUMBER OF BYTES: 2
        LD     HL,INS3
        CP     31H ; SOME OF CB+ INSTRUCTIONS DON'T HAVE...
        JR     C,NOBIT ; ...NUMERIC FIELD
        CALL   ZAINS2 ; GET NUMERIC FIELD WITH ALL TESTS
        CP     8 ; FOR BIT/SET/RES; IF BIT>7
        JP     NC,HOWHL ; THEN IT'S AN ERROR
        RLCA ; ROTATE NUMBER OF BITS INTO YOUR FIELD
        RLCA
        RLCA
        OR     (IX+11) ; AND PUT IT IN CODE
        LD     (IX+11),A
        JR     RHLIXY ; CHECK WHICH REGISTER IT IS
NOBIT:   LD     A,(HL) ; WE SAID THERE'S NO NUMERIC FIELD
        OR     A ; ...AND HERE IT IS; SO ERROR
WHATNZ:  JP     NZ,WHATHL ; WHICH REGISTER (BCDEHL)A
        LD     HL,INS2
RHLIXY:  CALL   KOJR2
SKRLD:   OR     (IX+11) ; PUT IT IN CODE
        LD     (IX+11),A
        INC    HL
        LD     L,(HL)
        LD     A,(IXIY) ; IS THIS THE SAVED IX/IY CASE?
        OR     A
        RET    Z ; NO - RETURN
        LD     H,(IX+11) ; YES - THEN 2-BYTE CODE
ZAGOHL:  LD     (CODE+1),HL
        RET
GRUPA5:  CP     3CH ; IS IT GROUP 5 (ARITHMETIC GROUP)
        LD     (IX+14),1
        JP     NC,GRUPA6 ; NO - CONTINUE
        LD     HL,TAB5-34H ; TABLE OF GROUP 5
        ADD    HL,BC ; CALCULATE POSITION IN TABLE
        LD     E,(HL) ; GET CODE INTO E REGISTER
        LD     HL,INS2
        LD     A,(HL)
; new page
        CP     6 ; IS HL IN PARENTHESES?
        JR     Z,HL16 ; YES - THEN SPECIAL PROCESSING
        LD     A,(INS3)
        OR     A ; IS THERE A SECOND OPERAND?
        JR     Z,PRESK3 ; NO - SKIP ITS PROCESSING
        LD     A,(HL) ; IS THIS THE FIRST OPERAND?
        CP     0EH ; IS IT 'A'?
        JR     NZ,WHATNZ ; IF NOT - ERROR
        LD     HL,INS3 ; POINT TO OPER 3
PRESK3:  LD     A,(HL)
        CP     40H ; NUMBER WITHOUT PARENTHESES?
        JR     Z,NUMLOG ; YES - SPECIAL PROCESSING
        CALL   KOJR2 ; WHICH REGISTER
        OR     E ; PUT IN CODE
ADJUST:  INC    HL
ADJ1:    LD     (IX+10),A ; FIRST BYTE OF CODE
        LD     A,(HL)
        LD     (IX+11),A ; SECOND BYTE OF CODE
        RET
SUB_:    INC    (IX+14) ; INCREMENT NUMBER OF BYTES
        INC    HL
        INC    HL ; HL POINTS TO HIGH BYTE OF NUMBER
        LD     A,(KRUG)
        OR     A ; WHICH ROUND?
        JR     Z,NEU1 ; FIRST - THEN DON'T CHECK FOR ERROR
        LD     A,(HL)
        OR     A
        JP     NZ,HOWHL ; GREATER THAN 255; THUS OVERFLOW
NEU1:    DEC    HL ; POINT TO LOW BYTE
        RET
NUMLOG:  CALL   SUB_ ; OVERFLOW TEST
        LD     A,E
        OR     46H ; REWORK CODE
        JR     ADJ1 ; PUT IT IN PLACE FOR CODES
PARREG:  LD     E,1 ; *** TESTS WHICH REGISTER OR...
        CALL   RTEST ; ...PAIR OF REGISTERS AND FORMS MICROCODE
        JR     NC,RLC3 ; NC MEANS IT'S 8-BIT REGISTER
        INC    E ; HERE IT'S 16-BIT PAIR
KOJPAR:  LD     A,(HL)
KOP1:    CP     8 ; MORE THAN 8 ARE 8-BIT REGISTERS
        JR     NC,WHATNC ; SO THIS IS AN ERROR
        SUB    4 ; SUBTRACT 4 FOR IX/IY/AF
        JR     C,SKWHAT ; AND WITH THEM NO ARITHMETIC...
RLC4:    RLCA ; ...OPERATIONS
RLC3:    RLCA
        RLCA
        RLCA
        RET
HL16:    LD     A,C ; 16-BIT OPERATIONS WITH HL REGISTER
        CP     37H ; IS IT 'SUB' INSTRUCTION?
WHATNC:  JR     NC,SKWHAT ; YES - BUT THIS CAN'T BE FOR 16-BIT REG
        LD     HL,CODE
        CP     34H ; IS IT 'ADD' INSTRUCTION?
        JR     Z,ADDINS ; YES - SKIP ADDING ONE BYTE
        LD     A,(IXIY) ; IS IX/IY INVOLVED?
        OR     A
        JR     NZ,SKWHAT ; YES - NOT ALLOWED
        LD     (HL),0EDH ; ADD ED+
        INC    HL
        INC    (IX+14) ; INCREMENT NUMBER OF BYTES
ADDINS:  PUSH   HL
        LD     HL,INS3 ; IN SECOND OPERAND...
;new page
        CALL   KOJPAR ; ...WHICH IS REGISTER PAIR
        LD     HL,TAB6-34H
        ADD    HL,BC ; CALCULATE MICROCODE
        OR     (HL) ; AND PUT IT IN CODE
        POP    HL
        LD     (HL),A ; PUT IN PLACE FOR CODES
        RET
GRUPA6:  CP     3EH ; IS IT GROUP 6 (INC - DEC)
        JR     NC,GRUPA7 ; NO - GO FURTHER
        CALL   IF3SN ; IF IT HAS OPER 2 THEN WHAT
        CALL   PARREG ; WHICH REGISTER OR REGISTER PAIR?
        LD     D,A
        LD     A,C
        DEC    E ; E = NUMBER OF BIT/8; E=2 FOR 16-BIT
        JR     Z,BYTE1 ; IF E=1; THEN 8-BIT
        CP     3CH ; 3CH = 'INC'
        JR     Z,INCJE1 ; SKIP 'DEC' PROCESSING
        LD     A,0BH ; 'DEC' MICROCODE
        DEFB   21H ; 21H='LD HL,NN'; JUST SKIPS 2 BYTES
INCJE1:  LD     A,3 ; 3 = 'DEC'
        OR     D ; INCLUDE IN MICROCODE
CODRET:  LD     (CODE),A
        RET
BYTE1:   CP     3CH ; 3CH = 'INC' TOKEN
        JR     Z,INCJE ; SKIP 'DEC' PROCESSING
        LD     A,5 ; 5 = 'DEC' MICROCODE
        DEFB   21H ; 21H='LD HL,NN'; JUST SKIPS 2 BYTES
INCJE:   LD     A,4 ; 4 = 'INC' MICROCODE
        OR     D
        LD     HL,INS2
        JP     ADJUST ; PUT IN PLACE FOR CODES
IF3SN:   LD     HL,INS2
TEST3:   LD     A,(INS3) ; IF THERE EXISTS SECOND OPERAND
        OR     A
        RET    Z
SKWHAT:  JP     WHATHL ; ... THEN GO TO WHAT
GRUPA7:  CP     3FH ; 7. GROUP (LD/EX)
        JP     Z,EXJE ; IF IT'S JFN (EX) SKIP
        JP     NC,GRUPA8 ; IF IT'S >3FH GO FURTHER
        LD     B,11 ; 11 CASES FOR TESTING
        LD     HL,TESTAB ; 'LD' TABLE
        CALL   TEST ; FIND COINCIDENT CASE
        JR     NZ,NFOU1 ; NOT SPECIAL CASE - SKIP
        CP     3 ; IS IT LD A,(NN) OR (NN),A?
        JR     NC,NOTNN ; NEITHER ONE NOR OTHER - SKIP
        LD     HL,INS2+1 ; GET OPER1
        DEC    A
        JR     Z,NNA ; REMAINING OPER BECAUSE IT'S LD (NN)
        LD     HL,INS3+1 ; OPER2
NNA:     LD     (IX+14),3 ; 3 BYTES INSTRUCTION LENGTH
        LD     A,(HL)
        LD     (CODE+1),A ; LOW BYTE OF NUMERIC FIELD NN
        INC    HL
        LD     A,(HL)
        LD     (CODE+2),A ; HIGH BYTE
CODEB:   LD     (IX+10),B ; 32H OR 3AH (LD (NN),A OR LD A,(NN))
        RET
NOTNN:   CP     8 ; IS IT LD A,I/I,A/A,R/R,A
        LD     HL,CODE
        JR     C,SIMPLE ; NONE OF THESE
        LD     (HL),0EDH ; FIRST BYTE OF CODE IS 0EDH
;new page
        INC     HL
        INC     (IX+14) ; COUNTER BYTE = 1
SIMPLE:  LD    (HL),B ; CODE
        RET
NFOU1:   LD     HL,INS2 ; LOAD R,R / R,N / RR,NN
        CALL    RTEST ; FIRST REGISTER
        JR      C,BYTE2 ; 16 - BIT
        RLCA ; 8 - BIT
        RLCA
        RLCA
        LD      E,A ; MICROCODE IN E REG
        LD      HL,INS3
        LD      A,(HL)
        CP      40H
        JR      Z,NUMLD ; NUMERIC 8-BIT LOAD
        CALL    KOJR2 ; SECOND REGISTER
        OR      E
        CP      36H ; IF LD (HL),(HL) IT'S AN ERROR
        JR      Z,SKWHAT
        OR      40H ; SET BIT 6
        LD      (CODE),A
        LD      A,(INS3+1)
        OR      (IX+4)
        LD      (CODE+1),A
        RET
NUMLD:   LD     A,E
        OR      6 ; SET BIT 5 AND BIT 6 MICROCODE
        LD      (CODE),A
        CALL    SUB_ ; INSERT BYTE COUNT AND WHAT TEST
        LD      A,(HL)
        LD      HL,INS2
        JP      SKRLD ; DO CODE
BYTE2:   LD   (IX+14),3 ; 16-BIT LOAD; THERE ARE 3 BYTES
        LD      DE,INS3
        LD      A,(DE)
        CP      40H ; NUMERIC LOAD WITHOUT BRACKETS?
        JR      Z,DDNN ; YES - JUMP
        LD      B,8 ; MICROCODE
        CP      0C0H ; DOES IT REFER TO HL?
        JR      Z,OSTAJE ; YES - KEEP 3 BYTES
        LD      A,(HL) ; IS IT ANOTHER OPERAND HL?
        CP      0C0H
        JR      Z,OSTAJ2 ; YES - KEEP 3 BYTES
        CP      7 ; DOES IT REFER TO SP?
        JR      NZ,WHL2 ; NO - THEN IT'S AN ERROR
        LD      A,(DE) ; IS IT LD SP
        CP      6
WHL2:    JR     NZ,NZWHAT ; WHAT
OSTAJ2:  EX    DE,HL
        LD      B,0 ; MICROCODE = 0
OSTAJE:  CALL  KOJPAR ; CHECK PAR REGISTER
        OR      2 ; FORM CODE
        OR      B
        LD      B,A
        AND     30H
        CP      20H
        LD      A,B
        JR      Z,IPAKHL ; TAKE 3-BYTE CASE
        LD     (IX+9),0EDH ; FIRST BYTE IS 0EDH
        INC     (IX+14) ; 4 - BYTE INSTRUCTION
        OR      41H ; CHANGE CODE
IPAKHL:  LD    (CODE),A
        EX      DE,HL
;new page
        INC     HL
        LD      E,(HL) ; LOW BYTE OF CODE
        INC     HL
        LD      D,(HL) ; HIGH BYTE OF CODE
        EX      DE,HL
        JP      ZAGOHL ; PUT 2 BYTES OF CODE IN PLACE
DDNN:    CALL    KOJPAR ; LD DD CASE
        INC     A ; NUMERIC 16-BIT LOAD
        JR      IPAKHL
EXJE:    LD      A,(INS2) ; 'EX' GROUP
        CALL    IFIXIY
        LD      HL,TEST2 ; NO EXCHANGE CODE IX I IY
        LD      B,3 ; 'EX' TABLE...
        CALL    TEST ; ...OF 3 MEMBERS
NZWHAT:  JP     NZ,WHATHL
        JP      CODEB ; NOT FOUND - ERROR
TEST:    LD      A,(INS2) ; GET OPERAND 1
        CP      (HL) ; COMPARE WITH TABLE
        INC     HL
        JR      NZ,FAIL1 ; NO MATCH FOUND
        LD      A,(INS3) ; MAYBE OPER 2?
        CP      (HL)
        JR      Z,MATCH ; MATCH FOUND
FAIL1:   INC     HL
        INC     HL
        DJNZ    TEST ; TRY 8 TIMES
        RET
MATCH:   INC     HL
        LD      A,B ; GET COUNT (N-NUMBER OF TRIES)
        LD      B,(HL) ; GET MICROCODE
        RET
GRUPA8:  LD     HL,INS2
        LD      DE,INS3
        LD      BC,WHATHL
        PUSH    BC ; FUTURE 'RET' MEANS 'JDI NA WHAT'
        LD      BC,1 ; IS IT 'OUT' TOKEN?
        CP      41H
        JR      Z,OUTJE ; YES - JUMP
        JR      NC,GRUPA9 ; IF IT'S >41H, CONTINUE
        EX      DE,HL
        LD      BC,800H
OUTJE:   BIT     7,(HL) ; IF NOT IN BRACKETS
        RET     Z
        BIT     6,(HL)
        JR      Z,NIJENN ; NOT NUMERIC 'IN'
        INC     HL
        INC     HL
        LD      A,(HL)
        OR      A
        RET     NZ ; IF NUMERIC EXISTS AT OPER2 PLACE
        DEC     HL
        LD      A,(HL)
        LD      (CODE+1),A ; NUMERIC VALUE AT PLACE OF 2ND BYTE
        LD      A,(DE)
        CP      0EH ; IS IT A REGISTER?
        RET     NZ ; NO-ERROR
        LD      A,0D3H ; MICROCODE FOR A REGISTER
        OR      B
        JR      CONTNN
NIJENN:  LD     A,(HL) ; IS REGISTER IN BRACKETS C?
        CP      089H
; new page
        RET     NZ ; NO-ERROR
        LD      (IX+9),0EDH ; FIRST BYTE OF CODE
        EX      DE,HL
        CALL    KOJR2 ; WHICH REGISTER IS IN/OUT (C)?
        CP      6 ; IS IT (HL)?
        RET     Z ; IT'S NOT IN ORDER
        RLCA
        RLCA
        RLCA
        OR      40H ; ADD BIT 5 TO MICROCODE
        OR      C ; FORM CODE
CONTNN   EQU    $
        LD      (CODE),A
        POP     AF
        JP      IXGOON
IFIXIY:  CP     5
        RET     NZ
        LD      A,(IXIY) ; IS IT THE SAME IN (IXIY)?
        OR      A
        JR      RETIFZ ; RETURN IF NOT, OTHERWISE ERROR
GRUPA9:  LD     C,A ; 'JUMP'/'CALL'/'RET'
        CP      44H
        JR      NZ,NOJPHL ; IF NOT JP (HL)/(IX)/(IY) JUMP
        LD      A,(HL)
        CP      86H
        LD      A,C
        JR      NZ,NOJPHL ; IF NOT HL IN BRACKETS JUMP
        LD      A,0E9H ; CODE FOR JP (HL)
SVEOK:   POP    DE
        JR      ZAGOV7 ; PUT CODE IN PLACE
NOJPHL:  CP     46H
        JR      Z,RETJE ; JUMP IF 'RET' TOKEN
        JR      NC,GRUP10 ; IF TOKEN IS GREATER
        SUB     42H
        RLCA
        LD      E,A
        CALL    CC ; CHECK IF CONDITIONAL JP/RET EXISTS
        LD      A,E
        JR      NC,NOTCC ; JUMP IF NOT CONDITIONAL
        INC     A
        DEC     A
        RET     Z ; IF IT IS CONDITIONAL - WHAT
        DEC     A
        DEC     A
        JR      NZ,NOTCC ; IF NOT JR
        BIT     5,B ; IF JR PO/PE/P/M
        RET     NZ ; ...THEN IT'S AN ERROR
NOTCC:   PUSH   HL
        LD      D,0
        LD      HL,TABJP
        ADC     HL,DE ; CALCULATE POSITION IN TABLE
        LD      A,(HL) ; FIRST ELEMENT MICROCODE
        OR      B ; SECOND ELEMENT MICROCODE
        LD      (CODE),A
        POP     HL
        LD      A,3 ; 3-BYTE JP/CALL
        LD      (IX+14),A
        LD      A,(HL)
        CP      40H
        RET     NZ ; IF NOT NUMERIC - ERROR
        POP     AF
        INC     HL
; new page
        LD      E,(HL) ; LOW BYTE OF NUMERIC
        INC     HL
        LD      D,(HL) ; HIGH BYTE OF NUMERIC
        LD      (CODE+1),DE ; ...GO INTO 2 AND 3 BYTE OF INSTRUCTION
        LD      A,C
        CP      44H
        RET     NC ; RETURN IF IT'S JP/CALL/RET
        DEC     (IX+14) ; ONLY 2 BYTES AND NOT 3
        LD      HL,(ADDR)
        INC     HL
        INC     HL ; RAISE 2 BYTES JR/DJNZ FIELD
        EX      DE,HL
        OR      A
        SBC     HL,DE ; CALCULATE RELATIVE JUMP
        LD      (IX+11),L ; RELATIVE JUMP
        LD      (IX+12),0 ; HIGH BYTE = 0
ADJOV:   BIT    7,L
        JR      NZ,NEGATL ; JUMP BACKWARD (NEGATIVE)
        DEC     H
NEGATL:  INC    H
RETIFZ:  RET    Z ; RETURN IF JUMP IS POSITIVE AND H=0
IFOV:    LD   DE,(KRUG)
        DEC     E
        RET     NZ ; RETURN IF IT'S FIRST CIRCLE
HOWHL:   LD   DE,(2A9FH) ; GO TO "HOW" AFTER SETTING SIGN...
        INC     DE ; ...QUESTIONS AT START OF LINE
        INC     DE
        JP      65AH
RETJE:   CALL    CC ; CONDITIONAL RETURN
        INC     (HL)
        DEC     (HL)
        RET     NZ ; ERROR IF OPER2 EXISTS
        LD      A,0C9H ; RET CODE = 0C9H
        POP     DE ; REMOVE 'WHAT' ENTRY POINT FROM STACK
        JR      NC,ZAGOV7 ; UNCONDITIONAL RET
        LD      A,0C0H ; CONDITIONAL RET: MICROCODE...
        OR      B ; ...AND READY CODE
ZAGOV7:  JP     CODRET
GRUP10:  SUB     49H ; GROUP 10: RST I IM
        JR      NC,PSHPOP ; IF IT'S >49H
        LD      C,A
        CALL    IFNUM1 ; IF NOT OPERAND NUMERIC OR IF...
        INC     HL ; OPERAND2 EXISTS
        INC     HL
        LD      A,(HL) ; ...THEN WHAT
        OR      A
        CALL    NZ,IFOV ; IF IT'S >255 AND IF 2ND CIRCLE-ERROR
        DEC     HL
        INC     C
        JR      NZ,RSTP ; GO TO 'RESTART' PROCESSING
        INC     (IX+14) ; HERE IT'S 'IM'; 2 BYTES
        LD      (IX+9),0EDH ; FIRST BYTE
        LD      A,(HL)
        LD      B,A
        CP      3
        CALL    NC,IFOV ; LARGEST IM IS 2; ABOVE THAT IS ERROR
        LD      A,56H ; CODE FOR IM 1
        DEC     B
        JR      Z,SVEOK1
        LD      A,5EH ; CODE FOR IM 2
        DEC     B
        JR      Z,SVEOK1
        LD      A,46H ; CODE FOR IM 3
SVEOK1:  JP     SVEOK
; new page
RSTP:    LD      A,(HL)
        AND     0C7H ; RESTART PROCESSING
        CALL    NZ,IFOV ; IMAGE IS ERROR
        LD      A,(HL)
        OR      0C7H ; MICROCODE
        JR      SVEOK1
PSHPOP:  RLCA ; PUSH/POP PROCESSING
        RLCA
        LD      C,A
        LD      A,(DE)
        OR      A
        RET     NZ ; IF OPERATOR 2 EXISTS - ERROR
        LD      A,(HL)
        CP      7
        RET     Z ; IF IT'S PUSH/POP SP
        CP      3
        JR      NZ,NOTAF
        LD      A,7 ; FOR AF A SPECIAL CODE
NOTAF:   CALL    KOP1 ; FORMING MICROCODE
        OR      0C1H
        OR      C ; THIS IS READY CODE
        JR      SVEOK1
CC:      LD      B,0 ; MICROCODE CONDITIONAL OPERATION
        LD      A,(HL)
        CP      9
        JR      NZ,NREGC
        LD      A,14H ; SPECIAL CASE; C FLAG IS NOT
        LD      (HL),A ; NEEDED BUT REGISTER C IS!
NREGC:   SUB     11H
        CCF
        RET     NC ; NC IF TOKEN=11H (REGISTER!)
        CP      8
        RET     NC
        RLCA
        RLCA
        RLCA
        INC     HL
        INC     HL
        INC     HL
        LD      B,A ; B IS MICROCODE
        SCF ; C SET = CONDITION OK
        RET
ZAINS2:  LD      A,(IX+3) ; ** IF NUMERIC LESS THAN 256...
        SUB     40H ; ...RETURN
        OR      (IX+5)
        JR      NZ,ZAWH1 ; OTHERWISE WHAT
        LD      A,(IX+4)
        RET
KOJREG:  LD      E,1 ; E=1 THIS IS SIGN THAT IT'S 8-BIT REG
KOJR2:   CALL    RTEST ; TAKE TOKEN REGISTER
        RET     NC
ZAWH1:   JP      WHATHL ; IF DELETED IS NOT REGISTER
RTEST:   LD      A,(HL)
        OR      A
        JR      Z,ZAWH1 ; IF WITH IT STILL HAS NUMERIC VALUE
        CP      86H ; IF (HL) INDIRECTLY
        LD      A,6
        RET     Z ; THEN MICROCODE=6
        LD      A,(HL) ; READY CASE (HL)INDIRECTLY
        CP      0FH
; new page
        CCF
        RET     C
        SUB     8
        RET     C
        CP      6
        JR      NZ,ZARET1 ; RETURN WITH MICROCODE IF IT'S <6
        INC     A ; INCREMENT TO 7 IF IT'S A REG.
ZARET1:  OR      A ; SET FLAGS
        RET
IXIYHL   EQU     $ ; *** REDUCTION IX/IY TO HL CASE
        CALL    ZAM ; REDUCE CASE FOR OPER 1
        LD      HL,INS3
        JR      NZ,ZAM ; REDUCE CASE FOR OPER 2
        LD      D,B
        CALL    ZAM
        RET     NZ
        LD      A,B
        CP      D
        RET     Z
        JR      ZAWH1 ; 'IY' FIRST BYTE (REST IS AS HL)
ZAM:     LD      B,0FEH
        LD      A,(HL)
        AND     3FH
        CP      6
        RET     Z
        DEC     B
        DEC     A
        JR      NZ,NOIX
        LD      B,0DDH ; 'IX' FIRST BYTE (REST IS AS HL)
        DEFB    3EH
NOIX:    DEC     A
        RET     NZ
        LD      (IX+9),B ; STORE FIRST BYTE AT SPEC. IXIY POSITION
        LD      A,(HL)
        AND     0C0H
        OR      6
        LD      (HL),A
        XOR     A
        RET
PROG1    EQU     $ ; ***** TOKEN FORMATION 1...
        LD      DE,FIELD+18 ; ...PUTTING IN TABLE *******
        LD      B,18
        XOR     A
CLFLD:   DEC     DE
        LD      (DE),A ; CLEARING ENTIRE TABLE
        DJNZ    CLFLD
        PUSH    DE
        POP     IX ; IX TAKES FIRST POSITION (FOR OPER 1)
        INC     HL
        INC     HL
        PUSH    HL
        LD      HL,(ADDR)
        LD      (TEMP1),HL
        POP     HL
        PUSH    HL
        LD      A,(HL)
        CP      '!' ; '!' IS PRIMARY
        CALL    NZ,RELOAD ; CALL TOKENIZATION IF NOT PRIMARY
        POP     HL
FINDCR:  LD      A,0DH ; FIND END OF LINE
SRCHCR:  CP      (HL)
; new page
        INC    HL ; IT'S NOT $0D - GO FURTHER
        RET    Z
        JR     SRCHCR
RELOAD:  PUSH   HL ; **** TOKEN GENERATION ****
        CALL   SUB1A ; RECOGNIZE OPCODE OR OPERAND
        JR     NZ,NOLAB ; IF RECOGNIZED WORD - JUMP
; IF NOT RECOGNIZED - FIND LABEL
        POP    HL
        LD     (FIELD+2),HL ; STORE LABEL ADDRESS IN PROGRAM
SRCH20:  INC    HL ; SEARCH FOR END OF LABEL (BLANK OR CR)
        LD     A,(HL)
        CP     0DH
        JR     Z,BLANK ; IF CR - EXIT
        CP     ' '
        JP     NZ,SRCH20 ; IF NOT BLANK - SEARCH FURTHER
        INC    HL ; FIRST POSITION AFTER BLANK
BLANK:   CALL   IF0 ; CHECK IF IT'S END OR REM
        CALL   SUB1 ; RECOGNIZE OPCODE
        JR     Z,NEAR ; IF NOT RECOGNIZED - WHAT
        PUSH   AF
NOLAB:   POP    AF
        LD     A,C
        AND    7FH ; MASK ALL EXCEPT BIT 7
        LD     (IX+5),A ; STORE OPCODE
        CALL   IFTXT0 ; CHECK IF IT'S 'TEXT' TOKEN
        CALL   TRANS1 ; PROCESS CASE FOR OPER1
        LD     IX,FIELD+3 ; SET IX FOR OPER2
        CALL   IF0 ; CHECK IF IT'S END OR REM
        CALL   SKIP2 ; SKIP POTENTIAL BLANKS
        CP     ','
        JR     NZ,NEAR ; IF NOT COMMA
        CALL   TRANS2 ; PROCESS CASE FOR OPER2
        CALL   IF0 ; CHECK IF IT'S END OR REM
NEAR:    JP     WHSK ; IF NOT - ERROR
TRANS1:  DEC    HL
TRANS2:  CALL   SKIPBL ; SKIP POTENTIAL BLANKS
        CP     '('
        JR     NZ,NEZAG ; NOT '(' - JUMP
        INC    HL ; SKIP '(' IF EXISTS
        SET    7,(IX+6) ; SET BIT TO INDICATE BRACKETS
NEZAG:   LD     DE,TABEL2-1 ; TABLE 2; OPERAND
        PUSH   HL
        CALL   PREPOZ ; FIND WHAT IS
        INC    C
        RES    7,C
        EX     DE,HL
        OR     A
        JR     Z,NEPREP ; NOT RECOGNIZED; MAYBE EXPRESSION?
        CALL   SKIPBL ; SKIP POTENTIAL BLANKS
        POP    AF
        LD     A,(IX+6)
        OR     C ; STORE TOKEN IN OPERAND FIELD
        LD     (IX+6),A
        LD     A,C
        CP     3
        JR     NC,ZATZAG ; IF NOT IX OR IY
        CALL   SKIP2 ; SKIP POTENTIAL BLANKS
        CP     ')'
        JR     Z,ZATZ2 ; THIS IS LIKE (IX+0) OR (IY+0)
        CP     '-'
        JR     Z,ZNAK
        CP     '+'
        JR     NZ,ZATZ3
ZNAK:    CALL   IZRAZ ; PUT EXPRESSION VALUE IN HL
; 011096
        PUSH    HL ; NOT IN SCAN BUT IN DUMP !!!
        EX      DE,HL
        CALL    ADJOV ; TEST JUMP -128<DE<+127
        LD      E,L ; E=L0 BYTE
        POP     HL
        JR      SKR1 ; FIND CLOSED PARENTHESIS
ZATZAG:  CALL    SKIP2 ; SKIP BLANKS
        CP      ')'
        JR      NZ,ZATZ3 ; IF NOT CLOSED PARENTHESIS
ZATZ2:   CPL
        INC     HL
NOTZZ:   XOR     (IX+6) ; XOR WITH OLD STATE OF PARENTHESIS
        RET     P ; RETURN IF FIRST NUMBER OF PARENTHESIS
WHSK:    JP      WHATHL ; IF NOT - ERROR
ZATZ3:   XOR     A ; CLEAR A REG
        JR      NOTZZ
NEPREP:  SET     6,(IX+6) ; BIT 6 MEANS NUMERIC VALUE
        POP     HL
        CALL    IZRAZ ; CALCULATE NUMERIC EXPRESSION
        LD      (IX+8),D ; PUT IT IN NUMERIC...
SKR1:    LD      (IX+7),E ; ...OPERAND FIELD
        JR      ZATZAG
SUB1A:   PUSH    HL
        LD      DE,TABEL2-1 ; OPERAND TABLE
        CALL    PREPOZ ; RECOGNIZE WORD IN TABLE
        POP     HL
WHSK2:   JR      NZ,WHSK ; IF RECOGNIZED - MEANS THAT...
SUB1:    LD      DE,TABEL1-1 ; ...OPERAND IN WRONG PLACE; ERROR!
        CALL    PREPOZ ; RECOGNIZE WORD IN TABLE
        INC     C
        EX      DE,HL
        INC     HL
        OR      A ; IF NOT NZ
        RET ; MEANS RECOGNITION SUCCESSFUL
IFTXT0:  SUB     2 ; 2 = 'TEXT' TOKEN
        JR      NZ,IF0 ; IF NOT SKIP
        CALL    SKIPBL ; SKIP EVENTUAL BLANKS
        CP      '"'
        JR      NZ,WHSK ; IF NOT QUOTE
        INC     HL ; THEN ERROR
        LD      (INS2+1),HL ; TEXT START TO TEXT REGISTER
        LD      C,0
FINDZN:  LD      A,(HL)
        CP      '"' ; END OF TEXT?
        INC     HL
        JR      Z,IF0T ; YES - GO OUT
        CP      0DH
        JR      Z,WHSK ; END OF LINE, NO QUOTE; WHAT
        INC     C
        JR      FINDZN ; CONTINUE SEARCHING QUOTE
IF0T:    LD      A,C
        LD      (INS2),A ; NUMBER OF WORDS TEXT
IF0:     CALL    SKIP2 ; SKIP EVENTUAL BLANKS
IF01:    CP      '!'
        JR      Z,REMJE ; IF REM SKIP
        CP      0DH
        RET     NZ ; RETURN IF NOT CR
        POP     AF ; IF CR - REMOVE LAST RET...
        RET ; ...FROM STACK AND RETURN NO...
; ...ONE PLACE EARLIER
REMJE:   INC     HL
        LD      A,(HL) ; IF ':' - THIS IS REM; FIND END OF LINE
; 011097
        CP      0DH ; CR - END OF LINE
        JR      NZ,REMJE ; IT'S NOT END OF LINE
        POP     AF ; RETURN AND LOCATION EARLIER (AS AT 12510)
        RET
NCSLBR:  LD      A,(HL)
        CALL    173H ; IF IT'S 0-9 (NEXT DIGIT)
        DEC     DE ; ...THEN RESET CARRY FLAG...
        RET     NC ; ...AND RETURN
        INC     DE
LETNCA:  CP      41H ; IF IT'S A-Z (NEXT LETTER) - RESET CARRY
        RET     C
        CP      5FH
        CCF
        RET
JEDANX:  CALL    JEDAN ; CALCULATE ONE MEMBER AND VALUE IN HL
        LD      BC,(TEMP2) ; TAKE PREVIOUS VALUE IN BC
        RET
IZRAZ    EQU     $
        EX      DE,HL
        RST     28H ; THIS IS LD HL
        RST     18H ; TEST IF NEXT CHARACTER IS...
        DEFB    '+' ; ...PLUS...
        DEFB    0 ; ...AND SKIP ONLY IT IF YOU ARE
        CP      '-' ; OR IF IT'S MINUS...
        CALL    NZ,JEDAN ; ...PUT MEMBER IN HL...
STORE:   LD      (TEMP2),HL ; ...STORE IN REGISTER OF PREVIOUS VALUE
        CALL    CLAN ; CALCULATE ONE MEMBER
        JP      C,HOWHL ; IF IT'S OVERFLOW
        JR      STORE ; CONTINUE MAIN LOOP OF CALCULATING EXPRESSION
CLAN:    RST     18H ; CALCULATE ONE MEMBER OF EXPRESSION AND VALUE IN HL
        DEFB    '+' ; IS IT PLUS?
        DEFB    CL1-$-1 ; IF NOT GO TO CL1
        CALL    JEDANX ; CALCULATE MEMBER
        ADD     HL,BC ; ADD IT WITH PREVIOUS VALUE
        RET
CL1:     RST     18H
        DEFB    '-' ; IS IT MINUS?
        DEFB    CL2-$-1 ; IF NOT GO TO CL2
        CALL    JEDAN
        OR      A
        LD      B,H
        LD      C,L
        LD      HL,(TEMP2)
        SBC     HL,BC ; SUBTRACT FROM PREVIOUS VALUE
        OR      A
        RET
CL2:     RST     18H
        DEFB    '<' ; IS SHIFT LEFT?
        DEFB    CL3-$-1 ; IF NOT GO TO CL3
        CALL    JEDAN
        LD      B,L ; B=NUMBER OF SHIFTS
        LD      HL,(TEMP2)
ROTHL1:  ADD     HL,HL ; ADD IS SHIFT LEFT
        DJNZ    ROTHL1 ; DO IT B TIMES
        OR      A ; CLEAR CARRY (NO OVERFLOW)
        RET
CL3:     RST     18H
        DEFB    '>' ; IS SHIFT RIGHT?
        DEFB    CL4-$-1 ; IF NOT GO TO CL4
        CALL    JEDAN
        LD      B,L
; 011098
        LD      HL,(TEMP2)
ROTHL2:  SRL     H ; SHIFT RIGHT 8 TIMES
        RR      L
        DJNZ    ROTHL2
        OR      A
        RET
CL4:     RST     18H
        DEFB    '#' ; IS IT '#' (MEANS AND)
        DEFB    CL5-$-1 ; DON'T GO TO CL5
        CALL    JEDANX
        LD      A,H
        AND     B ; AND HIGH BYTE
        LD      H,A
        LD      A,L
        AND     C ; AND LOW BYTE
        LD      L,A
        RET
CL5:     CP      ')' ; TERMINATORS: BRACKET, COMMA
        JR      Z,TERMIN
        CP      0DH ; END OF LINE
        JR      Z,TERMIN
        CP      '!' ; REM
        JR      Z,TERMIN
        CP      ',' ; COMMA
        JR      NZ,WHATHL
TERMIN:  POP     AF
        LD      HL,(TEMP2)
        EX      DE,HL ; TAKE IN DE THE EXPRESSION
        RET
; *** ONE MEMBER OF EXPRESSION CALCULATED IN HL ***
JEDAN:   CALL    105H ; SKIP POSSIBLE BLANKS
        CALL    173H ; IF NOT DIGIT 0-9
        JR      C,NEDEC ; ...THEN SKIP
        DEC     DE
        CALL    RELIX1 ; PREPARE FOR ARITHMETIC
        CALL    3283D ; CALCULATE DECIMAL NUMBER
        JP      RELIX2 ; RETURN 1%
NEDEC:   CP      '&' ; IS IT HEX NUMBER SIGN?
        JR      NZ,NEHEX ; NO - SKIP
        INC     DE
        CALL    357D ; READ HEX DIGIT
        JP      C,HOWHL ; NOT HEX DIGIT? HOW!
        DEC     DE
        RST     28H ; THIS IS LD HL,0
GOCONV:  CALL    357D ; READ HEX DIGIT
        RET     C ; NOT HEX DIGIT - END OF JOB
        CALL    RLC4 ; ROTATE 4 PLACES LEFT (+16)
        LD      BC,GOCONV ; PREPARE RET ADDRESS
        JP      3570D ; CONTINUE CONVERSION
NEHEX:   EX      DE,HL
        CALL    LETNCA ; IF LETTER A-Š
        JR      C,NLABEL ; NO - LABEL IS NOT LABEL
        CALL    LOCATE ; LOCATE LABEL
        JR      NZ,WHATHL ; NO JE - WHAT?
        LD      A,(INS1)
        CP      6 ; IF OPKOD=ORG THEN WHAT
        JR      Z,WHATHL ; (WE MUST NOT CALL ON LABEL)
        LD      D,B
        LD      E,C
        EX      DE,HL
        RET
NLABEL:  EX      DE,HL
        RST     18H
        DEFB    '"'
        DEFB    NIZAGR-$-1 ; NOT ASCII - GO FURTHER
; 011099
ASCX:    LD    A,(DE) ; TAKE ASCII CHARACTER
        INC   DE
        LD    L,A
        LD    H,0 ; PLACE IT IN HL
        RST   18H
        DEFB  '"' ; CLOSING CHARACTER NEEDED - THIS IS HOW IT SHOULD BE IF IT'S NOT - ERROR
        DEFB  WHATHL-$-1
        RET
NIZAGR:  RST   18H
        DEFB  '$' ; IS IT A PC LOCATION?
        DEFB  WHATHL-$-1 ; IT - THAT IS NOT NOTHING; ERROR
        LD    HL,(ADDR) ; YES - TAKES FROM PC REGISTER
        RET
WHATHL:  LD    DE,(2A9FH) ; *** WHAT *** INPUT POINT
        INC   DE
        INC   DE ; PUTS QUESTION MARK AT START OF LINE
        JP    78FH ; RIGHT TO WHAT IN ROM-U 1
PREPOZ:  LD    B,7FH ; **** WORD RECOGNITION ****
        LD    A,(HL)
Z1C0C:   LD    C,(HL)
        EX    DE,HL
Z1C0E:   INC   HL ; FIND WORD START IN TABLE (BIT 7=1)
        OR    (HL)
        JP    P,Z1C0E ; SEARCH FOR START
        INC   B
        LD    A,(HL) ; IF (HL)=80
        AND   7FH ; THEN IT'S THE END OF TABLE
        RET   Z ; RETURN IF =80 (CHARACTER NOT RECOGNIZED)
        CP    C
        JR    NZ,Z1C0E ; THIS CHARACTER IS NOT SAME - TRY NEW WORD
        EX    DE,HL ; CHARACTER SAME - THEREFORE IT'S GOOD
        PUSH  HL
Z1C1D:   INC   DE
        LD    A,(DE) ; TAKE NEW CHARACTER FROM TABLE
        OR    A
        JP    M,Z1C39 ; THIS IS THEN START OF NEXT WORD
        LD    C,A
Z1C2B:   INC   HL
        LD    A,(HL) ; TAKE NEW CHARACTER FROM PROG. LINE
        CP    C
        JR    Z,Z1C1D ; IF IT'S SAME
PHL:     POP   HL
        JR    Z1C0C ; NOT SAME; TRY NEW WORD
Z1C39:   INC   HL ; SUCCESSFUL COMPARISON; RECOGNIZED WORD
        CALL  NCSLBR ; IS IT THE END OF WORD IN PROGRAM?
        DEC   HL
        JR    C,X1C39 ; YES; LAST TEST SUCCESSFUL
        DEC   DE ; NOT END - SO COMPARISON UNSUCCESSFUL
        JR    PHL ; TRY SOME OTHER WORD FROM TABLE
X1C39:   LD    C,B ; C=B=TOKEN
        POP   AF ; A WILL COME TO IT; THIS IS JB; CHARACTER TO BE...
        EX    DE,HL
        OR    A ; ...RECOGNIZED WORD
        RET
SKIPBL:  INC   HL ; SKIP BLANKS FROM NEXT POSITION
SKIP2:   EX    DE,HL ; SKIP BLANKS FROM THIS POSITION
        CALL  105H ; SKIP POSSIBLE BLANKS
        EX    DE,HL
        RET
RELIX1:  LD    (IXPOS2),IX ; SAVE OLD IX...
        LD    IX,2AACH ; ...AND PREPARE IX FOR...
; ...ARITHMETIC IN ROM-U 1
;011100
        RET
BRKPT    EQU      $ ; *** BREAKPOINT (REG) ***
        LD        (FIELD+SPACE-1),SP ; SAVE SP FOR RETURN
        LD        SP,FIELD+SPACE-1 ; TAKE NEW SP
        PUSH      AF ; MOVES ALL REGISTERS TO MEMORY
        PUSH      BC
        PUSH      DE
        PUSH      HL
        PUSH      IX
        LD        HL,(FIELD+SPACE-1)
        INC       HL
        INC       HL
        PUSH      HL ; HL IS HERE SP+2 (SP BEFORE NEG...)
        LD        E,(HL) ; ...WHAT CAME TO REG
        INC       HL
        LD        D,(HL) ; DE = LAST ITEM ON STACK-U
        EXX
        EX        AF,AF'
        PUSH      AF ; PUTS ALTERNATIVE REGISTERS IN MEM
        PUSH      BC
        PUSH      DE
        PUSH      HL
        PUSH      IY
        EXX
        PUSH      DE ; PUTS LAST ITEM FROM STACK-A IN MEM
        CALL      2EDH ; IDI TO NEW ORDER (IF NOT ALREADY BEGINNING)
        LD        DE,NASLOV
        CALL      937H ; PRINT: AF BC DE HL IXIY SP()
        LD        DE,FIELD+SPACE-2
        LD        B,2 ; TWO LINES TO PRINT
RED:     PUSH      BC
        LD        B,6 ; SIX MEMBERS TO PRINT
SABL:    LD        A,' ' ; FIRST BLANK
        RST       20H
        LD        A,(DE) ; TAKES FROM MEMORY IN GROUPS OF...
        DEC       DE ; ...TWO BYTES WHAT WAS PUT...
        LD        H,A ; ...IN LINES 14580-14790
        LD        A,(DE)
        DEC       DE
        LD        L,A ; HL=TWO-BYTE VALUE OF PAIR REGISTERS
        CALL      HEX16 ; WRITE HL
        DJNZ      SABL ; DO THAT 6 TIMES
        LD        A,0DH ; GO TO NEW LINE
        RST       20H
        POP       BC
        DJNZ      RED ; DO ONE MORE TIME (FOR ALT.REG.)
        LD        HL,(SHOMEM)
        LD        A,H
        OR        L ; SHOULD MEMORY BE SHOWN?
        LD        A,(SHOFOR)
        CALL      NZ,PMEM ; IF NEEDED
        CALL      0CF5H ; WAIT FOR ANY KEY TO BE PRESSED
        POP       AF ; RETURNS ALL VALUES FROM MEMORY...
        POP       AF ; ...TO CPU REGISTERS...
        POP       HL ; ...AS I SET WHEN IT...
        POP       DE ; ...NOTHING HAPPENED
        POP       BC
        POP       AF
        EX        AF,AF'
        EXX
        POP       AF
        POP       AF
        POP       HL
        POP       DE
        POP       BC
; 011101
        POP    AF
        LD     SP,(FIELD+SPACE-1)
        RET ; At the end is taken 1 stack pointer
PMEM:    LD     D,A ; *** Print HEX number from HL total A rows
PMEM2:   CALL   HEX16B ; First memory address
        LD     A,':' ; Then two dots
        RST    20H
        LD     B,8 ; 8 bytes per row
RED8:    LD     A,' ' ; First blank
        RST    20H
        LD     A,(HL)
        CALL   HEX8 ; Print byte
        INC    HL
        DJNZ   RED8 ; And so eight times
        CALL   2FFH ; Test 'BREAK' or 'DEL' key
        LD     A,0DH
        RST    20H ; New row
        DEC    D
        JR     NZ,PMEM2 ; And so D rows
        RET
DEL:     LD     A,3
        PUSH   AF
        RST    8 ; Calculate first member ('DD' line)
        PUSH   DE
        CALL   7F2H ; Does this line exist?
        JR     NZ,SKRHOW ; Does not exist! HOW
        POP    HL
        PUSH   DE
        PUSH   DE
        EX     DE,HL
        CALL   5 ; Test memory and calculate 'DO' line
        CALL   7F2H ; Does this line exist?
        JR     NZ,SKRHOW ; No? Error
        EX     (SP),HL ; Check if second is greater than first
        RST    10H
        EX     (SP),HL
        JP     C,359H ; If yes, throw everything from first to second
SKRHOW:  JP    65BH ; If not, HOW
NAME:    RST    8 ; *** REN *** Limited renumbering
        LD     A,H
        OR     A ; If step is greater than 255
        PUSH   DE
        JR     NZ,SKRHOW ; ...then HOW
        OR     L ; If step = 0
        JR     Z,SKRHOW ; ...then HOW
        LD     B,H
        LD     C,L
        RST    28H ; This is LD HL,0
        PUSH   HL
        LD     DE,(2C36H) ; Start of BASIC program
THRU:    LD     HL,(2C38H) ; End of BASIC program
        EX     DE,HL
        RST    10H ; Sort current pointer (DE) and end
        EX     DE,HL
        POP    HL
        JR     NC,NAMED ; If they are same or current is greater-ready
        ADD    HL,BC ; Add with step
        BIT    7,H ; If is overflow (>7FFF) HOW
        JR     NZ,SKRHOW
        PUSH   HL
; 011102
        EX    DE,HL
        LD    (HL),E ; NEW LINE NUMBER - LOW BYTE
        INC   HL
        LD    (HL),D ; NEW LINE NUMBER - HIGH BYTE
        EX    DE,HL
FOD:     INC   DE ; FIND END OF LINE
        LD    A,(DE)
        CP    0DH
        JR    NZ,FOD ; NOT END YET - CONTINUE SEARCHING
        INC   DE
        JR    THRU ; GO TO NEXT LINE
NAMED:   POP   DE
KAD48:   RST   30H ; SET BASIC
FIND     EQU   $ ; *** / *** (FINDING SEQUENCE OF CHARACTERS IN PROGRAM)
        PUSH  DE
        LD    HL,(2C36H) ; START OF BASIC
        DEC   HL
TRAZ1:   INC   HL
TRAZ19:  LD DE,(2C38H) ; END OF BASIC
        RST   10H
        JR    NC,IZLAZF ; IF EQUAL - FINISHED
        CALL  2FFH ; 'BREAK' - 'DEL' TEST
        LD    B,H
        LD    C,L
        INC   HL
        PUSH  HL
NISTO:   POP   HL
        INC   HL
        LD    A,(HL)
        CP    0DH ; END OF LINE?
        JR    Z,TRAZ1 ; YES- SEARCH NEXT
        POP   DE
        PUSH  DE
        PUSH  HL
TRAZ12:  LD A,(DE) ; GET NEXT CHARACTER
        CP    (HL) ; COMPARE WITH CHARACTER IN PROGRAM
        JR    NZ,NISTO ; NOT SAME - START OVER
        INC   DE
        LD    A,(DE) ; GET NEXT CHARACTER
        CP    0DH ; END OF LINE?
        JR    Z,TOTAL ; YES - COMPARISON SUCCESSFUL
        INC   HL
        JR    TRAZ12 ; NOT SUCCESSFUL - CONTINUE SEARCH
TOTAL:   POP   AF
        PUSH  DE
        PUSH  BC
        PUSH  BC
        POP   DE
        CALL  2353D ; PRINT LINE ON SCREEN
        POP   HL
        POP   DE
        INC   HL
FEND:    INC   HL ; FIND END WHERE?
        LD    A,(HL)
        CP    0DH
        JR    NZ,FEND ; NOT CR YET
        JR    TRAZ1 ; SEARCH IN NEXT LINE
IZLAZF:  POP   DE
FEND2:   INC   DE ; FIND END WHERE?
        LD    A,(DE)
        CP    0DH
        JR    NZ,FEND2 ; NOT CR YET
        RST   30H ; SET BASIC
LDUMP:   CALL  COPY ; *** LDUMP *** LINE PRINTER FLAG
;011103
DUMP     EQU    $ ; *** DUMP *** Memory Print Subroutine
        RST    8 ; From which address?
        PUSH   HL ; Address is in HL
        CALL   5 ; Test character 1 from which address?
        LD     A,L
        OR     A ; If it's more than 0 rows
        POP    HL
        PUSH   DE
        CALL   NZ,PMEM ; Call memory printing
        POP    DE
        RST    30H ; Return to BASIC
; ***** FLOATING-POINT CONSTANTS *****
C2:      DEFW   04F5H ; 0.707107
        DEFW   0035H
C3:      DEFW   56AEH ; 0.598979
        DEFW   0019H
C4:      DEFW   22F3H ; 0.961471
        DEFW   0076H
C5:      DEFW   0AA3DH ; 2.88539
        DEFW   0138H
CPI_:    DEFW   0FD6H ; 3.1415926
        DEFW   0149H
PIPOLA:  DEFW   0FD6H ; PI/2
        DEFW   00C9H
PI2:     DEFW   0FD6H ; 2*PI
        DEFW   01C9H
X1EM3:   DEFW   126DH ; 1E-3
        DEFW   7B83H
CS1:     DEFW   0000H ; -6
        DEFW   81C0H
CS2:     DEFW   0000H ; 120
        DEFW   03F0H
CS3:     DEFW   8000H ; -5040
        DEFW   869DH
CS4:     DEFW   3000H ; 362880
        DEFW   09B1H
CX2:     DEFW   7213H ; 0.693147
        DEFW   0031H
CE1:     DEFW   0F84FH ; 2.71828182
        DEFW   012DH
CE2:     DEFW   0B5CH ; 1.3888889E-3
        DEFW   7BB6H
CE3:     DEFW   8885H ; 8.333333E-3
        DEFW   7D08H
CE4:     DEFW   0AAA8H ; 0.0416667
        DEFW   7E2AH
CE5:     DEFW   0AAA9H ; 0.166667
        DEFW   7F2AH
C1:      DEFW   0 ; 0.5
        DEFW   0
C7:      DEFW   0 ; 1
        DEFW   80H
CE8:     DEFW   0 ; 1
        DEFW   80H
CT1:     DEFW   0D758H ; 2.86623E-3
        DEFW   7C3BH
CT2:     DEFW   6DECH ; -1.61657E-2
        DEFW   0FD84H
CT3:     DEFW   0C1F6H ; 4.29096E-2
        DEFW   7E2FH
CT4:     DEFW   311CH ; -7.5289E-2
; 011104
        DEFW    0FE9AH
CT5:     DEFW    3DB1H ; 0.106563
        DEFW    7EDAH
CT6:     DEFW    7FC6H ; -0.142089
        DEFW    0FF11H
CT7:     DEFW    0BC03H ; 0.199936
        DEFW    7F4CH
CT8:     DEFW    0AA7CH ; -0.333332
        DEFW    0FFAAH
RADDEG:  DEFW   2EDEH ; 57.29578
        DEFW    0365H
PI:      LD      HL,CPI_ ; PI CONSTANT
        JP      0A45H
DUBL2:   CALL    DUBLIX ; DUPLICATE IX IN ARITHMETIC STACK - TWICE
DUBLIX:  LD      B,5 ; DUPLICATE IX IN ARITHMETIC STACK - ONCE
MOVE5:   LD      A,(IX-5)
        LD      (IX),A
        INC     IX
        DJNZ    MOVE5 ; MOVE 5 BYTES
        RET
CP0:     CALL    DUBLIX ; *** COMPARE (IX) WITH ZERO
        RST     28H ; THIS IS LD HL
        CALL    0ABCH ; MOVE HL TO (IX)
        JR      COMP ; COMPARE (IX-5) WITH (IX)
CP1:     LD      HL,C7 ; *** COMPARE (IX) WITH ONE
CPHL:    PUSH    HL
        CALL    DUBLIX ; DUPLICATE (IX)
        POP     HL
CPHL1:   CALL    0A45H ; STORE (HL) TO (IX)
COMP:    JP      0B10H ; COMPARE (IX-5) WITH (IX)
IXM10:   LD     BC,0FFFFH-9 ; IX = IX - 10
        JR      SKRBC
IX5:     LD      BC,5 ; IX = IX + 5
SKRBC:   ADD     IX,BC
        RET
ISPOD2:  LD    HL,0FFFFH-9 ; TAKE TWO NUMBERS FROM ARITHMETIC STACK...
        JR      SKRISP ; ...BUT SAVE THE LAST ONE
ISPOD3:  LD    HL,0FFFFH-14 ; TAKE THREE NUMBERS FROM ARITHMETIC STACK...
SKRISP:  PUSH   DE ; ...BUT SAVE THE LAST ONE
        PUSH    IX ; STORE HL/5 NUMBERS TO ARITHMETIC STACK...
        POP     DE ; ...BUT SAVE THE LAST ONE
        ADD     HL,DE
        LD      BC,5
        LDIR
        PUSH    DE
        POP     IX
        POP     DE
        RET
LOG      EQU     $ ; NATURAL LOGARITHM
LOGIT:   CALL    781H
LOGIT2:  CALL   CP0
        JP      C,65AH
        JP      Z,65AH
; 011105
        LD    (IX+15),0 ; exponent = 0
CONT1:   CALL  CP1 ; less than 1?
        JR    C,OVER1 ; yes, goto
        LD    HL,C1 ; multiply by 0.5
        CALL  PUTAHL
        INC   (IX+15) ; increase exponent
        JR    CONT1
OVER1:   LD    HL,C1 ; greater than 0.5?
        CALL  CPHL
        JR    NC,OVER2 ; yes, goto
        LD    HL,C1 ; multiply by 0.5 (*2)
        CALL  KROZHL
        DEC   (IX+15) ; decrease exponent
        JR    OVER1
OVER2:   CALL  DUBLIX ; double arith
        LD    HL,C2 ; arith = arith - 0.707107
        CALL  MINHL
        CALL  ISPOD2
        LD    HL,C2 ; arith = arith + 0.707107
        CALL  PLUSHL
        CALL  KROZ ; division pregled(ix)
        CALL  MOVE0
        CALL  DUBL2
        CALL  PUTA ; *
        LD    HL,C3 ; arith = arith * 0.508919
        CALL  PUTAHL
        LD    HL,C4 ; arith = arith + 0.961471
        CALL  PLUSHL
        CALL  ISPOD2
        CALL  DUBLIX
        CALL  PUTA ; *
        CALL  PUTA ; *
        LD    HL,C5 ; arith = arith + 2.88539
        CALL  PLUSHL
        CALL  PUTA ; *
        LD    L,(IX+15)
        LD    H,0 ; positive
        BIT   7,L ; negative
        JR    Z,POZL
        DEC   H
POZL:    CALL  0ABCH ; (ix)<-HL
        CALL  PLUS ; +
        LD    HL,C1
        CALL  MINHL ; arith = arith - 0.5
        LD    HL,CX2
PUTAHL:  CALL  0A45H ; arith = arith * 0.693147
        JP    PUTA
ABS_:    CALL  781H ; ABSOLUTE VALUE
ABSA:    LD    A,(IX-1)
ABS2:    RES   7,(IX-1)
        RET
TAN:     PUSH  DE ; TANGENT
        CALL  SIN
        POP   DE
        CALL  COS
ZAKROZ:  JP   KROZ
ABSDEG:  LD   BC,ABSA ; TAKES ABSOLUTE VALUE OF EXPRESSION...
        PUSH  BC ; ...DIVIDES IT WITH CONSTANT 57.29578...
        RST   18H ; ...FOLLOWED BY LETTER D (DEGREE)
        DEFB  'D'
        DEFB  NODEGR-$-1
        CALL  781H
        LD    HL,RADDEG
; 011106
KROZHL:  CALL   0A45H
        JR     ZAKROZ
NODEGR:  JP     781H
COS:     CALL   ABSDEG ; COSINE
        LD     HL,PIPOLA
        CALL   PLUSHL
        XOR    A
        JR     KAOSIN
SIN:     CALL   ABSDEG ; SINE
        RLCA
KAOSIN:  LD     (IX+20),A ; COSINE CONTINUES AS SINE
        LD     HL,PI2
        PUSH   HL
        CALL   CPHL
        POP    HL
        JR     C,LTH2PI
        PUSH   HL
        CALL   KROZHL
        CALL   DUBLIX
        CALL   0A6DH
        CALL   0ABCH
        CALL   MINUS
        POP    HL
        CALL   PUTAHL
LTH2PI   EQU    $
        LD     HL,CPI_
        PUSH   HL
        CALL   CPHL
        POP    HL
        JR     C,LTHPI
        CALL   MINHL
        INC    (IX+20)
LTHPI    EQU    $
        LD     HL,PIPOLA
        CALL   CPHL
        JR     C,LTH90
        CALL   DUBLIX
        CALL   IXM10
        CALL   PI
        CALL   IX5
        CALL   MINUS
LTH90    EQU    $
        LD     HL,X1EM3
        CALL   CPHL
        RET    C
        CALL   DUBL2
        LD     HL,CS1-4
        LD     B,4
D04:     PUSH   BC
        PUSH   HL
        CALL   ISPOD3
        CALL   ISPOD3
        CALL   PUTA
        CALL   ISPOD3
        CALL   PUTA
        PUSH   IX
        LD     BC,0FFFFH-19
        ADD    IX,BC
        LD     HL,15
        CALL   SKRISP
        POP    IX
        POP    HL
        INC    HL
; 011107
        INC    HL
        INC    HL
        INC    HL
        PUSH   HL
        CALL   KROZHL
        CALL   PLUS
        POP    HL
        POP    BC
        DJNZ   D04
        BIT    0,(IX+10)
        JR     Z,MOVE02
        SET    7,(IX-1)
MOVE02:  CALL MOVE0
MOVE0:   CALL IXM10 ; IX=IX-10
MOVE:    RST   28H ; HL<-0
        CALL   0ABCH ; HL on stack
        CALL   IX5 ; IX=IX+5
        JR     ZAPLUS
PLUSHL:  CALL 0A45H
ZAPLUS:  JP  PLUS
POW:     RST    18H ; EXPONENTIATION
        DEFB   '('
        DEFB   WH-$-1
        CALL   0AB2H
        CALL   LOGIT2
        RST    18H
        DEFB   ','
        DEFB   WH-$-1
        CALL   0AB2H
        RST    18H
        DEFB   ')'
        DEFB   WH-$-1
FORSOR:  CALL PUTA
        JR     EXP2
OUTP:    RST    8 ; *** OUTPUT ***
        PUSH   HL
        CALL   5
        POP    BC
        OUT    (C),L
        RST    30H
INP:     LD     C,L ; *** INPUT ***
        LD     B,H
        IN     L,(C)
        JR     FORDBD
ASCII:   CALL   ASCX ; *** ASCII CHARACTER IN NUMERIC EXPRESSION ***
FORDBD:  JP    0DBDH
SQR:     CALL   781H ; SQUARE ROOT
        CALL   CP0
        RET    Z
        CALL   LOGIT2
        LD     HL,C1
        CALL   0A45H
        JR     FORSOR
EXP:     CALL   781H ; E TO THE POWER OF X
EXP2:    CALL   ABSA
        RLA
        PUSH   AF
; 011108
        CALL    DUBLIX
        CALL    0A6DH
        PUSH    HL
        CALL    0ABCH
        CALL    MINUS
        RST     28H
        INC     HL
        CALL    0ABCH
        POP     HL
        LD      A,H
        OR      A
WH:      JP      NZ,65AH
        OR      L
        JR      Z,NOLOOP
DOHL:    PUSH    HL
        LD      HL,CE1
        CALL    PUTAHL
        POP     HL
        DEC     L
        JR      NZ,DOHL
NOLOOP:  LD      HL,CE2
        PUSH    HL
        CALL    0A45H
        POP     HL
        LD      B,6
EXP6:    PUSH    BC
        INC     HL
        INC     HL
        INC     HL
        INC     HL
        PUSH    HL
        CALL    ISPOD3
        CALL    PUTA
        POP     HL
        PUSH    HL
        CALL    PLUSHL
        POP     HL
        POP     BC
        DJNZ    EXP6
        CALL    PUTA
        POP     AF
        JP      NC,MOVE0
        CALL    IXM10
        LD      HL,C7
        CALL    0A45H
        CALL    IX5
        JP      KROZ
MINHL:   CALL    0A45H
        JP      MINUS
ATN:     CALL    ABS_ ; ARCTANGENT
        RLA
        PUSH    AF
        CALL    CP0
        JP      Z,NCOPY
        CALL    CP1
        PUSH    AF
        JR      C,NEKROZ
        CALL    DUBLIX
        CALL    IXM10
        LD      HL,C7
        CALL    0A45H
        CALL    IX5
        CALL    KROZ
NEKROZ:  CALL    DUBL2
; 011109
        CALL    PUTA
        RST     28H
        CALL    0ABCH
        LD      HL,CT1
        LD      B,8
TAYLB:   PUSH    BC
        PUSH    HL
        CALL    PLUSHL
        CALL    ISPOD2
        CALL    PUTA
        POP     HL
        INC     HL
        INC     HL
        INC     HL
        INC     HL
        POP     BC
        DJNZ    TAYLB
        LD      HL,C7
        CALL    PLUSHL
        CALL    ISPOD3
        CALL    PUTA
        POP     AF
        JR      C,YLTH1
        CALL    DUBLIX
        CALL    IXM10
        LD      HL,PIPOLA
        CALL    0A45H
        CALL    IX5
        CALL    MINUS
YLTH1:   POP     AF
        JR      NC,XGTH0
        SET     7,(IX-1)
XGTH0:   JP      MOVE02
TEXT1    EQU     $ ; New BASIC commands table
        DEFM    'LPRINT'
        DEFB    (LPRINT >> 8)|$80 ; High byte with bit 7 set ; LPRINT<-8+80H
        DEFB    LPRINT & $FF
        DEFM    'LLIST'
        DEFB    (LLIST >> 8)|$80 ; High byte with bit 7 set; LLIST<-8+80H
        DEFB    LLIST & $FF
        DEFM    'OUT'
        DEFB    (OUTP >> 8)|$80 ; OUTP<-8+80H
        DEFB    OUTP & $FF
        DEFM    '<'
        DEFB    (GOASS >> 8)|$80 ; GOASS<-8+80H
        DEFB    GOASS & $FF
        DEFM    '/'
        DEFB    (FIND >> 8)|$80 ; FIND<-8+80H
        DEFB    FIND & $FF
        DEFM    'REN'
        DEFB    (NAME >> 8)|$80 ; NAME<-8+80H
        DEFB    NAME & $FF
; 011110
        DEFM    'LDUMP'
        DEFB    (LDUMP >> 8)|$80 ; LDUMP<-8+80H
        DEFB    LDUMP & $FF
        DEFM    'DUMP'
        DEFB    (DUMP >> 8) | $80 ; DUMP<-8+80H
        DEFB    DUMP & $FF
        DEFM    'DEL'
        DEFB    (DEL >> 8)|$80 ; DEL<-8+80H
        DEFB    DEL & $FF
        DEFB    (KAO75B >> 8)|$80 ; KAO75B<-8+80H
        DEFB    KAO75B & $FF
TEXT3:   DEFM    'SQR' ; TABLE OF NEW FUNCTIONS FOR BASIC
        DEFB    (SQR >> 8)|$80 ; SQR<-8+80H
        DEFB    SQR & $FF
        DEFM    'LN'
        DEFB    (LOG >> 8)|$80 ; LOG<-8+80H
        DEFB    LOG & $FF
        DEFM    'ABS'
        DEFB    (ABS_ >> 8)|$80 ; ABS_<-8+80H
        DEFB    ABS_ & $FF
        DEFM    'SIN'
        DEFB    (SIN >> 8)|$80 ; SIN<-8+80H
        DEFB    SIN & $FF
        DEFM    'COS'
        DEFB    (COS >> 8)|$80 ; COS<-8+80H
        DEFB    COS & $FF
        DEFM    'TG'
        DEFB    (TAN >> 8)|$80 ; TAN<-8+80H
        DEFB    TAN & $FF
        DEFM    'ARCTG'
        DEFB    (ATN >> 8)|$80 ; ATN<-8+80H
        DEFB    ATN & $FF
        DEFM    'PI'
        DEFB    (PI >> 8)|$80 ; PI<-8+80H
        DEFB    PI & $FF
        DEFM    'EXP'
        DEFB    (EXP >> 8)|$80 ; EXP<-8+80H
        DEFB    EXP & $FF
        DEFM    'POW'
; 011111
        DEFB    (POW >> 8)|$80 ; High byte with bit 7 set ; POW<-8+80H
        DEFB    POW & $FF
        DEFM    'INP'
        DEFB    (INP >> 8)|$80|$40 ; High byte with bits 7,6 set ; INP<-8+80H+40H
        DEFB    INP & $FF
        DEFM    '"'
        DEFB    (ASCII >> 8)|$80 ; High byte with bit 7 set ; ASCII<-8+80H
        DEFB    ASCII & $FF
        DEFB    (KAO777 >> 8)|$80 ; High byte with bit 7 set; KAO777<-8+80H
        DEFB    KAO777 & $FF
TAB4:    DEFW    1000H ; CPU Instructions
        DEFW    1808H ; RRC RR
        DEFW    2820H ; SLA SRA
        DEFW    4038H ; SRL BIT
        DEFW    80C0H ; SET RES
        DEFB    0 ; Table Terminator
TAB5:    DEFW    08880H ; 8-bit Arithmetic
        DEFW    09098H ; SBC SUB
        DEFW    0B0A0H ; AND OR
        DEFW    0B8A8H ; XOR CP
        DEFB    0 ; Table Terminator
TAB6:    DEFW    4A09H ; 16-bit Arithmetic
        DEFB    42H ; SBC
TABJP:   DEFW    00010H ; Conditional and Unconditional Jumps
        DEFW    02018H ; JR
        DEFW    0C2C3H ; JP
        DEFW    0C4CDH ; CALL
TABY1:   DEFW    02F00H ; Simple Instructions
        DEFW    0373FH
        DEFW    0F376H
        DEFW    0D9FBH
        DEFW    01707H
        DEFW    01F0FH
        DEFB    27H
        DEFW    0A0B0H ; ED Instructions
        DEFW    0A8B8H
        DEFW    0A1B1H
        DEFW    0A9B9H
        DEFW    0A2B2H
        DEFW    0AABAH
        DEFW    0A3B3H
        DEFW    0ABBBH
        DEFW    04D44H
        DEFW    06F45H
        DEFB    67H
        DEFB    0 ; Table Terminator
TESTAB:  DEFW    0F0EH ; A,I (LOAD)
        DEFB    57H
        DEFW    0E0FH ; I,A
        DEFB    47H
        DEFW    100EH ; A,R
        DEFB    5FH
        DEFW    0E10H ; R,A
        DEFB    4FH
        DEFW    840EH ; A,(BC)
        DEFB    0AH
; 011112
        DEFW    850EH ; A,(DE)
        DEFB    1AH
        DEFW    0E84H ; (BC),A
        DEFB    02H
        DEFW    0E85H ; (DE),A
        DEFB    12H
        DEFW    0607H ; SP,HL
        DEFB    0F9H
        DEFW    0C00EH ; A,(NN)
        DEFB    3AH
        DEFW    0EC0H ; (NN),A
        DEFB    32H
TEST2:   DEFW    687H ; (SP),HL     EXCHANGE
        DEFB    0E3H
        DEFW    303H ; AF,AF'
        DEFB    008H
        DEFW    605H ; DE,HL
        DEFB    0EBH
TABEL1:  DEFB    'R'+80H ; GROUP 1: COMMANDS
        DEFM    'EG'
        DEFB    'T'+80H
        DEFM    'EXT'
        DEFB    'W'+80H
        DEFM    'ORD'
        DEFB    'B'+80H
        DEFM    'YTE'
        DEFB    'O'+80H
        DEFM    'PT'
        DEFB    'O'+80H
        DEFM    'RG'
        DEFB    'E'+80H
        DEFM    'QU'
        DEFB    '>'+80H
        DEFB    'N'+80H ; GROUP 2: SIMPLE INSTRUCTIONS
        DEFM    'OP'
        DEFB    'C'+80H
        DEFM    'PL'
        DEFB    'C'+80H
        DEFM    'CF'
        DEFB    'S'+80H
        DEFM    'CF'
        DEFB    'H'+80H
        DEFM    'ALT'
        DEFB    'D'+80H
        DEFM    'I'
        DEFB    'E'+80H
        DEFM    'I'
        DEFB    'E'+80H
; 011113
        DEFM    'XX'
        DEFB    'R'+80H
        DEFM    'LCA'
        DEFB    'R'+80H
        DEFM    'LA'
        DEFB    'R'+80H
        DEFM    'RCA'
        DEFB    'R'+80H
        DEFM    'RA'
        DEFB    'D'+80H
        DEFM    'AA'
        DEFB    'L'+80H ; Group 3: ED+
        DEFM    'DIR'
        DEFB    'L'+80H
        DEFM    'DI'
        DEFB    'L'+80H
        DEFM    'DDR'
        DEFB    'L'+80H
        DEFM    'DD'
        DEFB    'C'+80H
        DEFM    'PIR'
        DEFB    'C'+80H
        DEFM    'PI'
        DEFB    'C'+80H
        DEFM    'PDR'
        DEFB    'C'+80H
        DEFM    'PD'
        DEFB    'I'+80H
        DEFM    'NIR'
        DEFB    'I'+80H
        DEFM    'NI'
        DEFB    'I'+80H
        DEFM    'NDR'
        DEFB    'I'+80H
        DEFM    'ND'
        DEFB    'O'+80H
        DEFM    'TIR'
; 011114
        DEFB    'O'+80H
        DEFM    'UTI'
        DEFB    'O'+80H
        DEFM    'TDR'
        DEFB    'O'+80H
        DEFM    'UTD'
        DEFB    'N'+80H
        DEFM    'EG'
        DEFB    'R'+80H
        DEFM    'ETI'
        DEFB    'R'+80H
        DEFM    'ETN'
        DEFB    'R'+80H
        DEFM    'LD'
        DEFB    'R'+80H
        DEFM    'RD'
        DEFB    'R'+80H ; GROUP 4: BIT ROTATION AND MANIPULATION
        DEFM    'LC'
        DEFB    'R'+80H
        DEFM    'L'
        DEFB    'R'+80H
        DEFM    'RC'
        DEFB    'R'+80H
        DEFM    'R'
        DEFB    'S'+80H
        DEFM    'LA'
        DEFB    'S'+80H
        DEFM    'RA'
        DEFB    'S'+80H
        DEFM    'RL'
        DEFB    'B'+80H
        DEFM    'IT'
        DEFB    'S'+80H
        DEFM    'ET'
        DEFB    'R'+80H
        DEFM    'ES'
        DEFB    'A'+80H ; GROUP 5: ARITHMETIC AND LOGIC
        DEFM    'DD'
        DEFB    'A'+80H
        DEFM    'DC'
        DEFB    'S'+80H
; 011115
        DEFM    'BC'
        DEFB    'S'+80H
        DEFM    'UB'
        DEFB    'A'+80H
        DEFM    'ND'
        DEFB    'O'+80H
        DEFM    'R'
        DEFB    'X'+80H
        DEFM    'OR'
        DEFB    'C'+80H
        DEFM    'P'
        DEFB    'I'+80H ; Group 6: Increment - Decrement
        DEFM    'NC'
        DEFB    'D'+80H
        DEFM    'EC'
        DEFB    'L'+80H ; Group 7: Load and Exchange
        DEFM    'D'
        DEFB    'E'+80H
        DEFM    'X'
        DEFB    'I'+80H ; Group 8: Input - Output
        DEFM    'N'
        DEFB    'O'+80H
        DEFM    'UT'
        DEFB    'D'+80H ; Group 9: Jumps
        DEFM    'JNZ'
        DEFB    'J'+80H
        DEFM    'R'
        DEFB    'J'+80H
        DEFM    'P'
        DEFB    'C'+80H
        DEFM    'ALL'
        DEFB    'R'+80H
        DEFM    'ET'
        DEFB    'R'+80H ; Group 10: Return - Interrupt
        DEFM    'ST'
        DEFB    'I'+80H
        DEFM    'M'
        DEFB    'P'+80H ; Group 11: Push - Pop
        DEFM    'OP'
        DEFB    'P'+80H
        DEFM    'USH'
        DEFB    80H
TABEL2:  DEFB    'I'+80H ; Table 2: OPERANDS
        DEFM    'X'
        DEFB    'I'+80H
        DEFM    'Y'
        DEFB    'A'+80H
        DEFM    'F'
        DEFB    'B'+80H
; 011116
        DEFM    'C'
        DEFB    'D'+80H
        DEFM    'E'
        DEFB    'H'+80H
        DEFM    'L'
        DEFB    'S'+80H
        DEFM    'P'
        DEFB    'B'+80H
        DEFB    'C'+80H
        DEFB    'D'+80H
        DEFB    'E'+80H
        DEFB    'H'+80H
        DEFB    'L'+80H
        DEFB    'A'+80H
        DEFB    'I'+80H
        DEFB    'R'+80H
        DEFB    'N'+80H
        DEFM    'Z'
        DEFB    'Z'+80H
        DEFB    'N'+80H
        DEFM    'C'
        DEFB    'C'+80H
        DEFB    'P'+80H
        DEFM    'O'
        DEFB    'P'+80H
        DEFM    'E'
        DEFB    'P'+80H
        DEFB    'M'+80H
        DEFB    80H
NASLOV:  DEFM  '  AF   BC   DE   HL  IXIY SP()'
        DEFB    0DH
EXTRA:   LD      A,(INS1)
        CP      45H ; Will it open JP?
; 011117
        RET     Z ; RETURN IF IS STILL
        INC     (HL)
        RET ; AND IF NOT, INCREASE NUMBER OF BYTES
        ORG     1FFFH
        DEFB    5 ; VERSION 5
        END

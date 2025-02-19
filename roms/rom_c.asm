; Listing of ROM C for the "Galaxy Plus" computer
; "ROM C - Version 36, ??.??.8?"
;
; Authors: Nenad Balint and Milan Tadić, comments: Hindicki Ferenc
;
; This is a disassembled listing of ROM C from Galaksija Plus. The listing was created using the Monitor command *LD&E000,
; and later, sections with raw data, tables, and various tricks were corrected into a form acceptable for Galaksija.
; The comments are not original from the authors: I added them myself, and they are probably not entirely accurate.
; "Hacking" ROM C is not yet complete, as it still requires a lot of time and patience on my part,
; but there are already many valuable sections with explanations that will surely be useful to some.
;
; Conversion from pdf to text by issalig 14/02/25
;
; Translated comments to english and adapted to pasmo/sjasmplus
; Uses $ for numbers
; BYTE, TEXT, WORD have been replaced by DEFB, DEFW
; A portion of code was added to match original ROM C (ROM_C_PATCH)
; Some other typos have been fixed
;
; sjasmplus --raw=$file.bin file.asm
; pasmo -v file.asm file.bin 

ROM_C_PATCH EQU 1 ; generates portion of code to match original ROM_C.bin

DRAW    EQU $D8
UNDRAW  EQU $D5
PLOT    EQU $C6
UNPLOT  EQU $C3
GRAPH   EQU $45
TEKST   EQU $BA
SOUND   EQU $AE
QSAVE   EQU $18
QLOAD   EQU $1B
VERIFY  EQU $1E
FAST    EQU $BC
SLOW    EQU $BF
LINE    EQU $C5
KILL    EQU $D9
DESTROY EQU $F8
CLEAR   EQU $DB
HLOAD   EQU $21
HDUMP   EQU $24
HLDUMP  EQU $27
AUTO    EQU $2A
UP      EQU $30
DOWN    EQU $33
FILL    EQU $2D
R2D2    EQU $36

        ORG  $E000
        LD   DE,$2BA9       
        LD   HL,$E03E       
        LD   BC,$0006       
        LDIR                ;writes new command and video links
        LD   HL,($2A6A)     
        LD   DE,$0020       
        LD   A,L            
        AND  $E0            
        LD   L,A            ;RAMTOP address must be divisible by 16
        LD   A,$0C          
        LD   ($2BA8),A      ;centers the image
        SBC  HL, DE         
        LD   ($2A6A),HL     ;installs a new RAMTOP (old - 32)
        LD   DE,$E7D8       ;address of splash screen text
        CALL $0937          ;print introductory text
        LD   IY,$E496       ;new interapt link
        LD   B,$17          ;system variables from RAMTOP to RAMTOP+23
        LD   (HL),$0        ;...are reset
        INC  HL             
        DJNZ $E02B          
        LD   DE,$E598       ;address of character table
        LD   (HL),D         ;higher byte in RAMTOP+23
        DEC  HL             
        LD   (HL),E         ;low byte in RAMTOP+22
        DEC  HL             
        DEC  HL             
        DEC  HL             
        DEC  HL             
        DEC  HL             
        LD   (HL),$BF       ;at cursor in RAMTOP+17
        RET                 
        JP   $E7F8          ;new command link
        JP   $E195          ;new video link
        DEFB 36             ; ROM version 3.6 ?
GRAPH_CMD:        
        POP  AF             ;GRAPH command
        PUSH DE             ;save basic pointer
        CALL $E057          ; check and/or reserve graphics memory
        LD   A,$FF          
        LD   ($2BA8),A      ;indicator for graphic image = 255
        LD   A,$0C          
        RST  $20            ;clears the TEXT (and thus the GRAPH) screen
        HALT                ;wait for the next free appointment
        IM   $2             ;no table! I=$E0,($E0FF)=E3FB -> video driver
        POP  DE             ;return basic pointer
        RST  $30            ;return to basic
        CALL $E4CC          ;HL=RAMTOP+16
        INC  HL             
        INC  HL             
        INC  HL             ;HL=RAMTOP+19
        LD   A,(HL)         ;A=reserved graphics indicator
        INC  A              
        RET  Z              ;if A=255 - graphics reserved, $return
        LD   HL,($2A6A)     ;if not, HL=RAMTOP
        LD   DE,$1A00       ;DE=size 256x208 image in bytes        
        SBC  HL,DE          ;HL=future RAMTOP
        LD   DE,($2C38)     ;DE=end of basic program
        RST  $10            ;is there that much room?
        JP   C,$0154        ;if there is none, $SORRY
        LD   ($2A6A), HL    ; if there is, $install a new RAMTOP...
        CALL $E029          ;...and new system variables
        INC  HL             
        INC  HL             ;HL=RAMTOP+19
        LD   (HL),$FF       ;graphics reserved
        LD   DE,$000D       
        ADD  HL,DE          
        PUSH HL             ;HL=RAMTOP+32 (start of image) and onto the stack
        LD   A,L            ;setting 5 bytes for graphics (RAMTOP + 26-31)
        BIT  $7,A           
        LD   E,$2           
        JR   NZ,$E088       
        SET  $7,E           
        SUB  $5             
        LD   L,A            
        LD   A,$DB          
        LD   B,$0F          
        LD   C,$1           
        CP   L              
        JR   Z,$E09C        
        SUB  $20            
        RLC  B              
        RLC  C              
        JR   $E091          
        AND  $7F            
        POP  HL             ;HL=RAMTOP+32 from stack
        LD   D,H            
        DEC  HL             ;HL=RAMTOP+31
        LD   (HL),D         ;RAMTOP+31=higher byte of image start
        DEC  HL             ;HL=RAMTOP+30
        LD   (HL),A         
        DEC  HL             ;HL=RAMTOP+29
        LD   (HL),E         
        DEC  HL             ;HL=RAMTOP+28
        LD   (HL),$D0       ;RAMTOP+28=number of screen lines visible
        DEC  HL             ;HL=RAMTOP+27
        LD   (HL),B         
        DEC  HL             ;HL=RAMTOP+26
        LD   (HL),C         
        RET
SOUND_CMD:                         
        POP  AF             ;SOUND command
        RST  $8             ;read the first parameter
        LD   A,L            ;A=number of AY port
        OUT  ($BE),A        ;send to port 190
        CALL $0005          ;read second parameter
        LD   A,L            ;A=data for AY port
        OUT  ($BF),A        ;send to port 191
        RST  $30            ;return to basic
TEXT_CMD:        
        POP  AF             ;TEXT command
        LD   A,$0C          ;instead of the graphic indicator set...
        LD   ($2BA8),A      ;...position of TEXT image (centers)
        IM   $1             ;will play video again in ROM
        RST  $30            ;return to basic
UNPLOT_CMD:        
        XOR  A              ;UNPLOT command
        INC  A              ;A=1, $Z flag=0
        DEFB $06            ;false LD B,$AF for UNPLOT (plus 7T)
PLOT_CMD:        
        XOR  A              ;PLOT command (A=0, $Z flag=1)
        POP  BC             ;batali return address
        PUSH AF             ;save Z flag
        CALL $E46A          ;read coordinates Y,X in BC
        POP  AF             
        PUSH AF             ;refresh Z flag
        PUSH BC             ;pass coordinates to PLOT/UNPLOT subroutine
        CALL $E148          ;turns the dot on/off
        POP  AF             
        POP  DE             
        RST  $30            ;return to basic
UNDRAW_CMD:        
        XOR  A              ;UNDRAW command
        INC  A              ;A=1, $Z flag=0
        DEFB $06            ;false LD B,$AF for UNDRAW
DRAW_CMD:        
        XOR  A              ;DRAW command (A=0, $Z flag=1)
        POP  BC             ;batali return address
        PUSH AF             ;keep Z flag
        CALL $E46A          ;read coordinates Y2,X2 in BC
        CALL $E0E7          ;draw / erase line
        LD   IX,$2AAC       ;reset arithmetic stack pointer
        JR   $E0D2          ;return to basic
        LD   HL,($2A6A)     ;DRAW subroutine, HL=RAMTOP
        LD   DE,$0014       
        ADD  HL,DE          ;HL=RAMTOP+20
        LD   E,(HL)         ;E=current (initial) X1 coordinate
        INC  HL             ;HL=RAMTOP+21
        LD   D,(HL)         ;D=current (initial) Y1 coordinate
        EX   DE,HL          ;HL=Y1,X1
        LD   A,B            
        SUB  H              ;A=difference between Y1 and Y2 points
        LD   D,$1           ;D=Y step +1
        JR   NC,$E0FC       ;if Y2 is greater than Y1, $step +1
        LD   D,$FF          ; else Y step -1
        LD   A,H            
        SUB  B              
        LD   B,A            ;B=difference between Y2 and Y1 points
        JR   $E101          ;skip IM 2 vector
        DEFW $E3FB          ; IM2 vector E0FF. service address $E3FB
        LD   A,C            
        SUB  L              ;A=difference between X1 and X2 points
        LD   E,$1           ;E=X step +1
        JR   NC,$E10B       ;if X2 is greater than X1, $step +1
        LD   E,$FF          ;otherwise X step -1
        LD   A,L            
        SUB  C              
        LD   C,A            ;C=difference between X2 and X1 points
        POP  IX             ;IX=return address
        SUB  B              
        JR   NC,$E11E       
        POP  AF             
        SCF                 
        PUSH AF             
        LD   A,D            
        LD   D,E            
        LD   E,A            
        LD   A,H            
        LD   H,L            
        LD   L,A            
        LD   A,B            
        LD   B,C            
        LD   C,A            
        SUB  B              
        PUSH BC             
        INC  B              
        INC  C              
        EXX                 
        POP  DE             
        INC  E              
        DEC  E              
        EXX                 
        PUSH IX             
        RET  Z              
        POP  IX             
        SUB  B              
        JR   NC,$E134       
        ADD  A,C                                  
        EX   AF,AF'
        LD   A,H            
        ADD  A,D            
        LD   H,A            
        EX   AF,AF'          
        EX   AF,AF'          
        LD   A,L            
        ADD  A,E            
        LD   L,A            
        POP  AF             
        PUSH AF             
        PUSH HL             
        JR   NC,$E140       
        LD   A,H            
        LD   H,L            
        LD   L,A            
        EX   (SP), HL       
        EXX                 
        CALL $E148          
        EX   AF,AF'          
        JR   $E124          
        POP  HL             ;HL=return address, $stack=YX
        EX   (SP),HL        ;HL=YX, $stack=return address
        PUSH HL             ;stack=YX, $return address
        LD   HL,$E18A       ;HL=end address for PLOT
        JR   Z,$E153        ;jump if PLOT
        LD   HL,$E187       ;HL=end address for UNPLOT
        EX   (SP),HL        ;HL=YX, $stack=address of continuation
        LD   A, H           
        CP   $D0            
        JR   C,$E15C        ;if Y < 208, $then
        LD   A,$CF          ;if Y >= 208, $Y=207
        LD   H,A            ;H=limited Y
        PUSH HL             ;YX onto stack
        CPL                 
        SUB  $30            
        LD   H,A            
        LD   A,L            
        AND  $7             
        LD   B,$3           
        SRL  H              
        RR   L              
        DJNZ $E166          
        EX   (SP),HL        ;HL=YX, $stack=sequence number of bytes points
        PUSH HL             ;stack=YX
        LD   H,B            ;HL=order bit number of point
        LD   L,A            
        LD   BC,$E18D       ;BC=address of point bit mask table
        ADD  HL,BC          
        LD   A,(HL)         ;A=mask for bit points
        LD   HL,($2A6A)     
        LD   BC,$0014       
        ADD  HL,BC          ;HL=RAMTOP+20
        POP  BC             ;BC=YX
        LD   (HL),C         ; new rear X
        INC  HL             
        LD   (HL),B         ; new rear Y
        POP  BC             ;BC=sequence number of the byte in which the point is
        ADD  HL, BC         
        LD   BC,$000B       ;BC=offset from RAMTOP+20 to the beginning of the image
        ADD  HL,BC          ;HL=address of the byte where the point is
        RET                 ;continue from PLOT/UNPLOT address from stack
        CPL                 ;UNPLOT - turns off point
        OR   (HL)           
        DEFB $06            ;dummy LD B,$A6 for UNPLOT
        AND  (HL)           ;PLOT - lights point
        LD   (HL),A         
        RET                 ;end - return
        ; BEGIN this part is from the ROM dump but was not in the listing
            IF ROM_C_PATCH        
        CP $FD
        EI
	RST $30
	RST $28
	RST $18
	CP A
	LD A, A
            ENDIF        
        ; END this part is from the ROM dump but was not in the listing
        CALL VIDEO          ;$E4BB ;LINK TO VIDEO
        POP  HL             ;HL=$09B9 (forgot the return address from the link)
        POP  BC             ;BC=AF from stack
        POP  DE             ;DE=$0026 (return address in RST 20)
        POP  HL             ;HL=return address from RST 20 (caller's address)
        LD   A,L            
        CP   $A5            ;is it called from the EDIT command? ($02A5 - EDIT)
        JR   NZ,$E1A5       ;if not, $continue
        EXX                 ;if so, $EDIT is not executed
        JP   $0066          ; jump to basic reset (HARD-BREAK)
        CP   $C1            ; was it called from the old INPUT command? ($07C1 - GETSTR)
        JP   Z,$E26A        ;if old INPUT, $jump to new INPUT command
        PUSH HL             
        PUSH BC             
        CALL $E4CC          ;HL=RAMTOP+16
        INC  HL             
        INC  HL             ;HL=RAMTOP+18 (arrow execution indicator)
        CP   $B1            ;is it called from a NEW INPUT statement? ($E2B1)
        JR   Z,$E1D5        ;if so, $jump to print character
        CP   $0D            ;is it called from ......... ? ($E30D)
        JR   Z,$E1D5        ;if yes, $jump jump to print character
        LD   A,B            ;A=character to be printed
        CP   $20            ;is the character an old control code (0-31) ?
        JR   C,$E1F6        ;if so, $jump to control code processing
        CP   $DF            ;is the character a new control code (219-222, $arrows) ?
        JR   NC,$E1CE       ;if not, $check again for apostrophe (")
        CP   $DB            ; is the sign of any arrow ?
        JR   C,$E1CE        ;if not, $check again for apostrophe (")
        LD   B,(HL)         ;B=arrow execution indicator
        INC  B              ; are arrows printed? (B=255)
        JR   Z,$E1D6        ;if printing, $jump to print character
        AND  $3F            ;if executed, $A=old arrow code (27-30)
        JR   $E236          ;jump to cursor move
        CP   $22            ;is the character an apostrophe (")?
        JR   NZ,$E1D6       ;if not, $jump to print character
        LD   A,(HL)         ;if so, $arrow execution indicator...
        CPL                 ;...changes from 255 to 0 or vice versa
        LD   (HL),A         ;write the new state of the indicator
        LD   A,B            ;A=character to be printed
        LD   HL,($2A68)     
        LD   (HL),A         ;print character on text screen
        PUSH HL             ;store cursor address on stack
        CALL $E484          ;BC=XY cursor coordinate text
        CALL $E506          ;character is drawn on the graphics screen if GRAPH mode is enabled ($2BA8=255)
        INC  B              ;B=X+1, $(new cursor coordinate to the right of the written character)
        CALL $E4CA          ;HL=RAMTOP+Y (screen editor variable for the line where the cursor is)
        LD   A,(HL)         ;A=length of the line where the cursor is
        CP   B              ; is the new position of the cursor at the end of the line?
        JR   C,$E1EA        ;if right of end, $jump
        LD   B,A            ; if it is at the end of the line (or to the left of the end)
        LD   (HL),B         
        POP  HL             
        INC  HL             
        CALL $E4FC          
        POP  AF             
        CALL $106F          
        EXX                 
        RET                 
        CP   $0D            
        JR   NZ,$E1FF       
        CALL $E4E5          
        JR   $E1F0          
        CP   $0C            
        JR   NZ,$E22E       
        LD   HL,$E20A       
        PUSH HL             
        CALL $0A1A          
        LD   HL,($2A6A)     
        LD   B,$10          
        LD   (HL),$0        
        INC  HL             
        DJNZ $E20F          
        INC  HL             
        INC  HL             
        LD   (HL),$0        
        LD   A,($2BA8)      
        INC  A              
        JR   NZ,$E1F0       
        LD   DE,$000E       
        ADD  HL,DE          
        LD   BC,$1A00       
        LD   D,H            
        LD   E,L            
        INC  DE             
        LD   (HL),$FF       
        LDIR                
        JR   $E1F0          
        LD   B, (HL)        
        INC  B              
        JR   NZ,$E236       
        OR   $C0            
        JR   $E1D6          
        CP   $1B            
        JR   C,$E1F0        
        JR   NZ,$E23F       
        LD   DE,$FFE0       
        CP   $1C            
        JR   NZ,$E246       
        LD   DE,$0020       
        CP   $1D            
        JR   NZ,$E24D       
        LD   DE,$FFFF       
        CP   $1E            
        JR   NZ,$E254       
        LD   DE,$0001       
        LD   HL,($2A68)     
        ADD  HL,DE          
        LD   A,H            
        CP   $2A            
        JR   C,$E25F        
        LD   H,$28          
        CP   $28            
        JR   NC,$E265       
        LD   H,$29          
        LD   ($2A68),HL     
        JR   $E1F0          
        EXX                 ;save BC, $DE, HL - NEW INPUT COMMAND
        CALL $E4CC          ;HL=RAMTOP+16 (cursor flicker), $DE=16
        SRL  E              ;DE=8
        ADD  HL,DE          ;HL=RAMTOP+24 (use screen editor - 2 bytes)
        LD   DE,($2A68)     ;DE=address of screen cursor
        LD   (HL),E         
        INC  HL             
        LD   (HL),D         ;store cursor address in RAMTOP+24
        CALL $E4CC          ;HL=again RAMTOP+16
        LD   (HL),$1        ;set blink counter just before blink cursor
        CALL $0CF5          ;wait for keystroke
        CALL VIDEO          ;$E4BB ;turn off cursor blinking (AF is saved)
        LD   HL,($2A68)     ;HL=address of screen cursor
        PUSH AF             ;keep AF
        CALL $E484          ;BC=XY cursor coordinate text
        POP  AF             ;A=ASCII at pressed key
        OR   A              ; is it 0 ? (PART)
        JR   Z,$E29A        ;if 0, $process DELETE
        CP   $0D            ; is it ENTER ?
        JP   Z,$E317        ;if so, $process ENTER
        CP   $5F            ;is it "_" ? (SHIFT + 0)
        JR   Z,$E2D1        ;if yes, $process INSERT
        RST  $20            ;if it's something else, $print it
        JR   $E278          ;turn on the cursor again and wait for the next key
        PUSH HL             ;DELETE PROCESSING
        PUSH HL             ;cursor address 2x on stack
        CALL $E4CA          ;HL=RAMTOP+Y coordinate (screen row for screen editor)
        LD   A,(HL)         ;A=number of characters in line (empty line = 0)
        SUB  B              ;A=A-position of the cursor (X coordinate)
        JR   Z,$E2A5        ;if cursor is at end of line, $jump
        JR   NC,$E2A9       ;if the cursor is right at the end of the line, $jump
        POP  HL             ;no deletion (right !!)
        POP  HL             ;remove cursor addresses from stack 2x
        JR   $E278          ;turn on the cursor again and wait for the next key
        OR   A              
        JR   Z,$E2BA        
        LD   B,A            
        EX   (SP), HL       
        INC  HL             
        LD   A,(HL)         
        RST  $20            
        DJNZ $E2AE          
        EX   (SP), HL       
        BIT  $5,(HL)        
        INC  HL             
        LD   A,(HL)         
        JR   NZ,$E2A9       
        DEC  HL             
        EX   (SP), HL       
        CALL $E484          
        XOR  A              
        CP   B              
        JR   NZ,$E2C5       
        LD   B,$20          
        DEC  B              
        POP  HL             
        LD   A,$20          
        RST  $20            
        LD   (HL), B        
        POP  HL             
        LD   ($2A68),HL     
        JR   $E278          
        PUSH HL             
        CALL $E4CA          
        XOR  A              
        ADD  A,(HL)         
        JR   NC,$E2E0       
        POP  HL             
        CALL $E4F6          
        JP   $0154          
        BIT  $5,(HL)        
        INC  HL             
        JR   NZ,$E2D6       
        SUB  B              
        JR   Z,$E2EA        
        JR   NC,$E2ED       
        POP  HL             
        JR   $E278          
        DEC  HL             
        INC  (HL)           
        POP  HL             
        LD   D,$0           
        LD   E,A            
        ADD  HL,DE          
        LD   B,A            
        LD   DE,$29FF       
        RST  $10            
        JR   C,$E307        
        PUSH BC             
        PUSH HL             
        CALL $E388          
        POP  HL             
        LD   DE,$0020       
        SBC  HL, DE        
        POP  BC             
        LD   ($2A68),HL     
        DEC  HL             
        LD   A,(HL)         
        RST  $20            
        DJNZ $E307          
        LD   ($2A68),HL     
        LD   A,$20          
        RST  $20            
        JR   $E2CC          
        CALL $E4CA          
        XOR  A              
        CP   C              
        JR   Z,$E326        
        DEC  C              
        DEC  HL             
        BIT  $5,(HL)        
        JR   NZ,$E31B       
        INC  C              
        INC  HL             
        PUSH HL             
        LD   HL,$2800       
        JR   Z,$E333        
        LD   DE,$0020       
        LD   B,C            
        ADD  HL,DE          
        DJNZ $E330          
        EX   (SP), HL       
        POP  BC             
        PUSH BC             
        PUSH BC             
        LD   B,$0           
        LD   C,(HL)         
        EX   (SP), HL       
        ADD  HL, BC         
        EX   (SP), HL       
        INC  HL             
        BIT  $5,C           
        JR   NZ,$E339       
        CALL $E4CC          
        INC  HL             
        INC  HL             
        INC  (HL)           
        JR   Z,$E34B        
        DEC  (HL)           
        LD   E,$6           
        ADD  HL,DE          
        LD   E,(HL)         
        INC  HL             
        LD   D, (HL)        
        POP  BC             
        POP  HL             
        RST  $10            
        JR   NC,$E35D       
        PUSH HL             
        LD   H,B            
        LD   L,C            
        RST  $10            
        POP  HL             
        JR   NC,$E35E       
        EX   DE, HL         
        LD   H,B            
        LD   L,C            
        AND  A              
        SBC  HL, DE        
        PUSH DE             
        LD   DE,$007D       
        RST  $10            
        JR   C,$E374        
        LD   ($2A68),BC     
        CALL $E4E5          
        JP   $0154          
        LD   B,H            
        LD   C,L            
        POP  HL             
        LD   DE,$2BB6       
        INC  BC             
        LDIR                
        DEC  DE             
        LD   A,$0D          
        LD   (DE),A         
        INC  DE             
        PUSH DE             
        CALL $E4F6          
        POP  DE             
        RET                 
        LD   DE,($2A6C)     
        LD   HL,$01E0       
        LD   A,E            
        AND  $1F            
        INC  DE             
        JR   NZ,$E38F       
        DEC  DE             
        SBC  HL, DE        
        JR   Z,$E3DF        
        JR   C,$E3DF        
        LD   B,H            
        LD   C,L            
        SET  $3,D           
        SET  $5,D           
        PUSH HL             
        PUSH DE             
        LD   HL,$0020       
        ADD  HL, DE        
        LDIR                
        POP  HL             
        CALL $E484          
        CALL $E4CA          
        LD   A,C           
        INC  HL             
        LD   B,(HL)         
        DEC  HL             
        LD   (HL),B         
        INC  HL             
        INC  A              
        CP   $0F            
        JR   C,$E3B2        
        LD   A,($2BA8)      
        INC  A              
        JR   NZ,$E3DE       
        CALL $E4CC          
        ADD  HL, DE        
        PUSH HL             
        CALL $E58D          
        POP  BC             
        ADD  HL,BC          
        PUSH HL             
        ADD  HL, DE        
        POP  DE             
        EX   (SP),HL        
        PUSH DE             
        CALL $E484          
        CALL $E58D          
        POP  DE             
        LD   B,H            
        LD   C,L            
        POP  HL             
        LDIR                
        LD   A,$E1          
        LD   HL,$29E0       
        PUSH HL             
        CALL $E484          
        CALL $E4D5          
        CALL $E4CC          
        DEC  HL             
        LD   (HL),A         
        LD   E,$9           
        ADD  HL, DE        
        LD   A,(HL)         
        SUB  $20            
        LD   (HL),A         
        JR   NC,$E3F9       
        INC  HL             
        DEC  (HL)           
        POP  HL             
        RET                 
        PUSH AF             ;11 video driver
        PUSH BC             ;11
        PUSH DE             ;11
        PUSH HL             ;11
        EXX                 ;4 alternate registers
        PUSH BC             ;11
        PUSH DE             ;11
        PUSH HL             ;11
        LD   BC,$207F       ;10 BC'=latch address (B'=line length, $C'=?)
        LD   HL,($2A6A)     ;16 HL'=ramtop
        LD   DE,$001A       ;10 DE'=26
        ADD  HL,DE          ;11 HL'=ramtop+26
        LD   D, (HL)        ;7
        INC  HL             ;6 HL'=ramtop+27
        LD   E,(HL)         ;7 DE'=address ?
        INC  HL             ;6 HL'=ramtop+28
        PUSH HL             ;11 HL' onto stack
        LD   H, (HL)        ;7
        LD   L,$3E          ;7 H'=number of visible image lines, $L'=$3E
        EXX                 ;4 basic registers
        POP  HL             ;10 HL=ramtop+28 from stack
        PUSH IX             ;15 saves IX
        LD   IX,$E432       ;14 IX=main loop address
        INC  HL             ;6 HL=ramtop+29
        LD   D,(HL)         ;7 D=?
        INC  HL             ;6 HL=ramtop+30
        LD   A,$9           ;7 bit3+bit0 =1
        SRL  A              ;8 Cf=1 + bit2=1
        JR   C,$E426        ;12 breaks
        SRL  A              ;8 Cf=0 + bit1=1 (A=2)
        LD   B,A            ;4 B=2
        JR   C,$E42B        ;7 breaks
        DJNZ $E429          ;13+7+13+7+8 break
        LD   B,(HL)         ;7 B=(ramtop+30) for R
        INC  HL             ;6 HL=ramtop+31
        LD   C,(HL)         ;7 C=(ramtop+31) higher byte hires image
        LD   L, $BC           ;7 HL=xxBC
        LD   A,B            ;4 A=B, $main loop
        LD   ($207F),HL     ;16 $207F=L, $$2080=H
        JP   Z,$E460        ;10 if Zf=0 end (from DEC H, $number of lines)
        LD   R,A            ;9 R=B
        LD   A,C            ;4
        LD   I,A            ;9 I=C
        LD   ($207E),DE     ;20 $207E=E, $$207F=D
        LD   A,B            
        EXX                 
        ADD  A,B            
        AND  C              
        EXX                 
        LD   B,A            
        NOP                 
        NOP                 
        XOR  A              
        EXX                 
        RRC  D              
        RLA                 
        EXX                 
        ADD  A,C            
        LD   C,A            
        NOP                 
        XOR  A              
        EXX                 
        RRC  E              
        RRA                 
        OR   L              
        EXX                 
        LD   D,A            
        EXX                 
        DEC  H              
        EXX                 
        JP   (IX)           
        POP  IX             ;end of drawing image
        EXX                 ; restoration of alt. register
        POP  HL             
        POP  DE             
        POP  BC             
        EXX                 ;main registers
        JP   $00C0          ;continuation of RTC routine in ROM A
        RST  $8             ;take first parameter
        PUSH HL             ;first parameter on stack (X)
        CALL $0005          ;get second parameter (Y)
        LD   B,L            ;B=Y
        POP  HL             
        LD   C,L            ;C=X
        POP  HL             ;HL=return address
        POP  AF             ;AF=PLOT/UNPLOT value and flag
        PUSH DE             ;BASIC_pointer to stack
        PUSH AF             ;PLOT/UNPLOT value and flag on stack
        PUSH HL             ;address of return to the stack
        CALL $E4CC          ;HL=RAMTOP+16
        INC  HL             
        INC  HL             
        INC  HL             ;HL=RAMTOP+19 (graphics indicator)
        LD   A,(HL)         
        INC  A              ;Zf=1 - graphic screen reserved
        POP  HL             ;HL=return address
        JP   NZ,$E0D2       ;Zf=0 - graphic screen is not reserved, $return to basic
        JP   (HL)           ;continue PLOT/UNPLOT
        LD   A,$1F          ;from address on screen (HL) calculate coordinate text
        AND  L              
        LD   B,A            ;B=X
        RRC  H              
        LD   A,L            
        RRA                 
        RRA                 
        RRA                 
        RRA                 
        RRA                 
        AND  $0F            
        LD   C,A            ;C=Y
        RLC  H              ;HL is unchanged
        RET                 
        LD   A,$E0          ;interapt link
        LD   I,A            ;set high byte of interapt vector
        CALL $E4CC          ;HL=RAMTOP+16 (cursor blinking)
        LD   A,(HL)         
        CP   $1             ;is it blinking ?
        JR   C,$E4A6        ;if not, $jump
        DEC  (HL)           ;decrease counter to blink
        CALL Z,$E4A9        ;if counter is 0 change cursor state
        JP   $00FD          ;end interapt
        LD   (HL),$14       ;blink counter reset (0.4s)
        INC  HL             ;HL=RAMTOP+17
        LD   B,(HL)         ;B=character code under cursor or cursor
        LD   DE,($2A68)     ;DE=address of screen cursor
        LD   A,(DE)         ;A=at cursor or character
        LD   (HL),A         ;replace codes
        EX   DE,HL          ;HL=address of screen cursor
        LD   (HL),B         
        CALL $E484          ;BC=X,Y text coordinates from address (on 32x16)
        JP   $E506          
VIDEO:
        PUSH AF             
        CALL $E4CC          
        LD   (HL),$0        
        INC  HL             
        LD   A,$BF          
        CP   (HL)           
        CALL NZ,$E4AC       
        POP  AF             
        RET                 
        LD   E,C            
        DEFB 33             ;false LD HL,$101E (will hide LD E,$10 from CALL $E4CA !)
        LD   E,$10          
        LD   D,$0           ;DE=16
        LD   HL,($2A6A)     
        ADD  HL,DE          ;HL=RAMTOP+16 (cursor blinking)
        RET                 
        LD   A,$20          
        LD   (HL),A         
        PUSH HL             
        CALL $E506          
        INC  B              
        POP  HL             
        INC  HL             
        LD   A,L            
        AND  $1F            
        JR   NZ,$E4D5       
        RET                 
        LD   HL,($2A68)     
        CALL $E484          
        PUSH HL             
        CALL $E4CA          
        LD   (HL),B         
        POP  HL             
        CALL $E4D5          
        JR   $E4FC          
        INC  HL             
        LD   A,L            
        AND  $1F            
        JR   NZ,$E4F6       
        LD   A,H            
        CP   $2A            
        CALL NC,$E388       
        LD   ($2A68),HL     
        RET                 
        LD   A,($2BA8)      
        INC  A              
        RET  NZ             
        PUSH BC             
        PUSH HL             
        CALL $E58D          
        LD   C,B            
        LD   B,A            
        ADD  HL, BC         
        EX   (SP), HL       
        LD   A,(HL)         
        POP  HL             
        LD   BC,$0020       
        LD   DE,($2A6A)     
        ADD  HL, DE        
        ADD  HL,BC          
        CP   $5B            
        JR   C,$E558        
        CP   $5C            
        JR   C,$E548        
        JR   Z,$E548        
        CP   $5E            
        JR   C,$E54B        
        CP   $5F            
        JR   C,$E545        
        CP   $BF            
        JR   NZ,$E539       
        LD   A,$5B          
        JR   $E558          
        CP   $DB            
        JR   C,$E58B        
        CP   $DF            
        JR   NC,$E58B       
        SUB  $7F            
        JR   $E558          
        LD   A,$53          
        LD   DE,$433E       
        LD   DE,$5A3E       
        LD   (HL),$D7       
        JR   NZ,$E553       
        LD   (HL),$DF       
        ADD  HL, BC         
        LD   (HL),$EF       
        JR   $E55D          
        LD   (HL),$FF       
        ADD  HL,BC          
        LD   (HL),$FF       
        ADD  HL,BC          
        SUB  $20            
        JR   C,$E58B        
        PUSH HL             
        LD   E,$9           
        RST  $28            
        LD   H,A            
        LD   D,L            
        LD   A,$8           
        ADD  HL,HL          
        JR   NC,$E56E       
        ADD  HL, DE        
        DEC  A              
        JR   NZ,$E56A       
        PUSH HL             
        LD   HL,($2A6A)     
        LD   DE,$0016       
        ADD  HL, DE        
        LD   E,(HL)         
        INC  HL             
        LD   D, (HL)        
        POP  HL             
        ADD  HL,DE          
        EX   DE, HL         
        POP  HL             
        LD   A,$9           
        EX   AF,AF'          
        LD   A, (DE)        
        LD   (HL),A         
        INC  DE             
        ADD  HL, BC         
        EX   AF,AF'          
        DEC  A              
        JR   NZ,$E582       
        POP  BC             
        RET                 
        LD   DE,$01A0       ;DE=text line on graphics screen (13x32)
        RST  $28            ;HL=0
        LD   A,C            ;A=Y
        INC  A              
        DEC  A              
        RET  Z              ;if A=0, $return
        ADD  HL,DE          ;(multiply DE by the ordinal number of the text line)
        JR   $E593
	; character table
        DEFB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ;BLANK
        DEFB   $EF, $EF, $EF, $EF, $EF, $EF, $EF, $FF, $EF ;EXCLAMATION
        DEFB   $93, $93, $B7, $DB, $FF, $FF, $FF, $FF, $FF ;QUOTE
        DEFB   $D7, $D7, $01, $D7, $D7, $D7, $01, $D7, $D7 ;HASH
        DEFB   $EF, $83, $ED, $ED, $83, $6F, $6F, $83, $EF ;DOLLAR
        DEFB   $FF, $B3, $B3, $DF, $EF, $F7, $9B, $9B, $FF ;PERCENT
        DEFB   $E3, $DD, $EB, $F7, $EB, $5D, $BD, $5D, $63 ;AND
        DEFB   $FE, $FC, $FA, $F6, $EF, $F6, $FA, $FC, $FE ;MIPRO1
        DEFB   $DF, $EF, $F7, $F7, $F7, $F7, $F7, $EF, $DF ;OPEN PARENTHESIS
        DEFB   $F7, $EF, $DF, $DF, $DF, $DF, $DF, $EF, $F7 ;CLOSED PARENTHESIS
        DEFB   $FF, $EF, $AB, $C7, $01, $C7, $AB, $EF, $FF ;STAR
        DEFB   $FF, $EF, $EF, $EF, $01, $EF, $EF, $EF, $FF ;PLUS
        DEFB   $FF, $FF, $FF, $FF, $FF, $E7, $E7, $EF, $F7 ;COMMA
        DEFB   $FF, $FF, $FF, $FF, $01, $FF, $FF, $FF, $FF ;MINUS
        DEFB   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $E7, $E7 ;POINT
        DEFB   $7F, $7F, $BF, $DF, $EF, $F7, $FB, $FD, $FD ;/
        DEFB   $C7, $BB, $3D, $5D, $6D, $75, $79, $BB, $C7 ;0
        DEFB   $EF, $E7, $EF, $EF, $EF, $EF, $EF, $EF, $C7 ;1
        DEFB   $C7, $BB, $7D, $7F, $BF, $C7, $FB, $FD, $01 ;2
        DEFB   $C7, $BB, $BF, $CF, $BF, $7F, $7D, $BB, $C7 ;3
        DEFB   $BF, $DF, $EF, $F7, $BB, $BD, $01, $BF, $BF ;4
        DEFB   $01, $FD, $C5, $B9, $7D, $7F, $7D, $BB, $C7 ;5
        DEFB   $C7, $BB, $FD, $C5, $B9, $7D, $7D, $BB, $C7 ;6
        DEFB   $01, $7D, $BF, $DF, $EF, $EF, $F7, $F7, $F7 ;7
        DEFB   $C7, $BB, $BB, $C7, $BB, $7D, $7D, $BB, $C7 ;8
        DEFB   $C7, $BB, $7D, $7D, $3B, $47, $7F, $BF, $C3 ;9
        DEFB   $FF, $E7, $E7, $FF, $FF, $FF, $E7, $E7, $FF ;DOUBLE
        DEFB   $FF, $E7, $E7, $FF, $FF, $E7, $E7, $EF, $F7 ;Semicolon
        DEFB   $BF, $DF, $EF, $F7, $FB, $F7, $EF, $DF, $BF ;LESS
        DEFB   $FF, $FF, $FF, $01, $FF, $01, $FF, $FF, $FF ;EQUAL
        DEFB   $FB, $F7, $EF, $DF, $BF, $DF, $EF, $F7, $FB ;LARGER
        DEFB   $C7, $BB, $7D, $BF, $DF, $EF, $EF, $FF, $EF ;QUESTION
        DEFB   $DF, $EF, $F7, $03, $FF, $03, $F7, $EF, $DF ;MIPRO2
        DEFB   $C7, $BB, $7D, $7D, $7D, $01, $7D, $7D, $7D ;A
        DEFB   $C1, $BD, $7D, $BD, $C1, $BD, $7D, $7D, $81 ;B
        DEFB   $C7, $BB, $7D, $FD, $FD, $FD, $7D, $BB, $C7 ;C
        DEFB   $C1, $BD, $7D, $7D, $7D, $7D, $7D, $BD, $C1 ;D
        DEFB   $01, $FD, $FD, $FD, $C1, $FD, $FD, $FD, $01 ;E
        DEFB   $01, $FD, $FD, $FD, $C1, $FD, $FD, $FD, $FD ;F
        DEFB   $87, $7B, $FD, $FD, $0D, $7D, $7D, $7B, $87 ;G
        DEFB   $7D, $7D, $7D, $7D, $01, $7D, $7D, $7D, $7D ;H
        DEFB   $C7, $EF, $EF, $EF, $EF, $EF, $EF, $EF, $C7 ;I
        DEFB   $01, $7F, $7F, $7F, $7F, $7F, $7D, $BB, $C7 ;J
        DEFB   $BD, $DD, $ED, $F5, $F9, $F5, $ED, $DD, $BD ;K
        DEFB   $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD, $01 ;L
        DEFB   $7D, $39, $55, $6D, $7D, $7D, $7D, $7D, $7D ;M
        DEFB   $7D, $7D, $79, $75, $6D, $5D, $3D, $7D, $7D ;N
        DEFB   $C7, $BB, $7D, $7D, $7D, $7D, $7D, $BB, $C7 ;O
        DEFB   $81, $7D, $7D, $7D, $81, $FD, $FD, $FD, $FD ;P
        DEFB   $C7, $BB, $7D, $7D, $7D, $7D, $5D, $BB, $47 ;Q
        DEFB   $81, $7D, $7D, $7D, $81, $ED, $DD, $BD, $7D ;R
        DEFB   $C3, $BD, $FD, $C3, $BF, $7F, $7D, $BB, $C7 ;S
        DEFB   $01, $EF, $EF, $EF, $EF, $EF, $EF, $EF, $EF ;T
        DEFB   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $BB, $C7 ;U
        DEFB   $7D, $7D, $7D, $BB, $BB, $BB, $D7, $D7, $EF ;V
        DEFB   $7D, $7D, $7D, $6D, $6D, $6D, $6D, $55, $BB ;W
        DEFB   $7D, $7D, $BB, $D7, $EF, $D7, $BB, $7D, $7D ;X
        DEFB   $7D, $7D, $7D, $3B, $47, $7F, $7F, $BB, $C7 ;Y
        DEFB   $01, $7F, $BF, $DF, $EF, $F7, $FB, $FD, $01 ;Z
        DEFB   $01, $01, $01, $01, $01, $01, $01, $01, $01 ;CURSOR BLOCK
        DEFB   $00, $00, $10, $28, $44, $10, $10, $00, $00 ;ARROW UP
        DEFB   $00, $00, $10, $10, $44, $28, $10, $00, $00 ;DOWN ARROW
        DEFB   $00, $00, $10, $08, $64, $08, $10, $00, $00 ;LEFT ARROW
        DEFB   $00, $00, $10, $20, $4C, $20, $10, $00, $00 ;ARROW RIGHT
        DEFW $0C0C          ;text of the opening screen
        DEFB "     *** GALAKSIJA PLUS ***"          
        DEFW $DCDC          ;DC=down arrow - move to the next line
        DEFB 0              
        EX   (SP),HL        ;store HL, HL=return address - command link
        PUSH DE             ;basic pointer to stack
        LD   DE,$075B       ;recognition attempt orders
        RST  $10            
        POP  DE             ;DE=basic pointer
        JR   Z,$E815        ;order is
        LD   A,H            
        CP   $20            ;below $2000 ?
        JR   C,$E811        ;ROM-A/B command
        CP   $28            ;above $2800
        JR   NC,$E811       ;user command
        AND  $7             ;between - ROM-C command
        RLCA                ; correct address...
        RLCA                ;...to the right value
        OR   $E0            
        LD   H,A            
        EX   (SP),HL        ;return address to stack
        JP   $100F          ;next round of recognition
        EX   (SP), HL       
        LD   HL,$E81B       ;command table -1
        JP   $039A          ;recognize command
        
        DEFB "DRAW"         
        DEFB $A0            ;E0D8
        DEFB DRAW           
        DEFB "UNDRAW"       
        DEFB $A0            ;E0D5
        DEFB UNDRAW         
        DEFB "PLOT"         
        DEFB $A0            ;E0C6
        DEFB PLOT           
        DEFB "UNPLOT"       
        DEFB $A0            ;E0C3
        DEFB UNPLOT         
        DEFB "GRAPH"        
        DEFB $A0            ;E045
        DEFB GRAPH          
        DEFB "TEXT"         
        DEFB $A0            ;E0BA
        DEFB TEKST           
        DEFB "SOUND"        
        DEFB $A0            ;E0AE
        DEFB SOUND          
        DEFB "QSAVE"        
        DEFB $A3            ;EC18
        DEFB QSAVE          
        DEFB "QLOAD"        
        DEFB $A3            ;EC1B
        DEFB QLOAD          
        DEFB "VERIFY"       
        DEFB $A3            ;EC1E
        DEFB VERIFY         
        DEFB "FAST"         
        DEFB $A2            ;E8BC
        DEFB FAST           
        DEFB "SLOW"         
        DEFB $A2            ;E8BF
        DEFB SLOW           
        DEFB "LINE"         
        DEFB $A2            ;E8C5
        DEFB LINE           
        DEFB "KILL"         
        DEFB $A2            ;E8D9
        DEFB KILL           
        DEFB "DESTROY"      
        DEFB $A2            ;E8F8
        DEFB DESTROY        
        DEFB "CLEAR"        
        DEFB $A2            ;E8DB
        DEFB CLEAR          
        DEFB "HLOAD"        
        DEFB $A3            ;EC21
        DEFB HLOAD          
        DEFB "HDUMP"        
        DEFB $A3            ;EC24
        DEFB HDUMP          
        DEFB "HLDUMP"       
        DEFB $A3            ;EC27
        DEFB HLDUMP         
        DEFB "AUTO"         
        DEFB $A3            ;EC2A
        DEFB AUTO           
        DEFB "UP"           
        DEFB $A3            ;EC30
        DEFB UP             
        DEFB "DOWN"         
        DEFB $A3            ;EC33
        DEFB DOWN           
        DEFB "FILL"         
        DEFB $A3            ;EC2D
        DEFB FILL           
        DEFB "R2"           
        DEFB $A3           ;EC36
        DEFB R2D2           
        DEFB $10+$80        ;100F (ROM-B)
        DEFB $0F            
FAST_CMD:        
        POP  AF             ;FAST command
        DI                  ;disable interapt
        RST  $30            
SLOW_CMD:
        POP  AF             ;SLOW command
        EI                  ;enable interapt
        RST  $30            
        JP   $065A          ;print error message "HOW?"
LINE_CMD:        
        POP  AF             ;LINE command
        RST  $8             ;read parameter
        LD   A,L            
        CP   $D1            ;max. 208
        JR   NC,$E8C2       ;if greater, $error
        CP   $21            ;min. 33
        JR   C,$E8C2        ;if less, $error
        LD   HL,($2A6A)     
        LD   BC,$001C       
        ADD  HL,BC          ;HL=RAMTOP+28 (number of visible screen lines)
        LD   (HL),A         ;write the value
        RST  $30            ;resume basic
KILL_CMD:        
        JR   $E909          ;KILL command
CLEAR_CMD:        
        POP  AF             ;CLEAR command
        PUSH DE             ;save basic pointer
        PUSH IX             ;save arithmetic stack pointer
        LD   B,$1A          ;26 variables from A to Z
        LD   IX,$2A02       
        LD   DE,$0004       ;length of variable in bytes
        LD   (IX+$1),$40    ;characteristic is set...
        RES  $7,(IX)        ;...-128, $which represents the number 0
        ADD  IX, DE        
        DJNZ $E8E8          ;clears all variables
        POP  IX             ;return arithm. stack pointer
        POP  DE             ;return basic pointer
        RST  $30            ;return to basic
DESTROY_CMD:        
        POP  AF             ;DESTROY command
        RST  $8             ;read first parameter
        PUSH HL             ;store parameter on stack
        CALL $0005          ;read second parameter
        EX   DE,HL          ;DE=second parameter, HL=basic pointer
        EX   (SP),HL        ;HL=first parameter, $basic stack pointer
        EX   DE,HL          ;HL=second parameter, $DE=first parameter
        XOR  A              ;A=0
        LD   (DE),A         ;delete byte
        INC  DE             ;next byte
        RST  $10            ;compare DE with HL
        JR   NC,$E901       ;continue if DE is not greater
        POP  DE             ;return basic pointer
        RST  $30            ;return to basic
        LD   A,($2030)      ;continuation of KILL command
        BIT  $0,A           ;wait for key release...
        JR   Z,$E909        ;...ENTER
        LD   DE,$E929       ;message address "SURE ?"
        CALL $0937          ;print message
        LD   HL,$2037       ;check all keys
        BIT  $0,(HL)        
        JR   Z,$E922        ;if key pressed, $check which one
        DEC  L              
        JR   NZ,$E919       
        JR   $E916          ;if none pressed, $repeat all
        LD   A,L            
        CP   $19            ;if the key is not "Y"...
        JP   NZ,$0066       ;...only HARD BREAK
        RST  $0             ;if key is "Y", $RESET
        DEFB "SURE ?"       
        DEFB 13             ;new line
QSAVE_CMD:                
        POP  AF             ;QSAVE command
        CALL $EA39          ;initialize AY-3-8910 ()
        RST  $18            
        DEFB $22            ; does an apostrophe follow the command?
        DEFB $E940-$-1      ;if not, $error WHAT?
        LD   ($2B00),DE     ;record the address of the beginning of the name
        LD   B,$15          ;find the next apostrophe in the next 15 characters
        INC  DE             
        DJNZ $E943          
        JP   $078F          ; if there is no 2x" or the name is longer than 15. WHAT?
        RST  $18            
        DEFB $22            
        DEFB $E946-$-1      ;same continuation regardless of the result
        JR NZ,$E93D         ;if not "search further
        CALL $EA9C          ;is it followed by ENTER or . ? (are there parameters?)
        JR   Z,$E982        ;if ENTER or ., $no parameters. jump (it's basic)
        LD   HL,$EA62       ;HL=text address "LINE"
        PUSH DE             ;save basic pointer (byte address after name)
        CALL $EA6A          ; is the parameter LINE ?
        JR   Z,$E99A        ; if so, $read the LINE number (autostart line number)
        LD   HL,$EA66       ;if not, HL=address of text "CODE"
        POP  DE             ; return basic pointer (byte address after the name)
        CALL $EA6A          ;is the parameter CODE ?
        JR   NZ,$E940       ;if not, $WHAT?
        RST  $28            ;HL=0
        LD   ($2B02),HL     ; if CODE, $LINE address is 0
        RST  $8             ;get 1st parameter for CODE
        PUSH HL             
        CALL $0005          ;get 2nd parameter for CODE
        PUSH HL             
        RST  $18            ; any more parameters ?
        DEFB ","            ;(is the next character a comma?)
        DEFB $E96E-$-1      ; if not, $skip taking the 3rd parameter
        RST  $8             ; if yes, $take the 3rd parameter (relocation)
        DEFB $3E            ;false LD A,$EF if there is also a 3rd parameter
        RST  $28            ;HL=0 if there is no 3rd parameter
        LD   ($2B04),DE     ;save basic pointer
        LD   B,H            ;BC=3. parameter (reloc, $0 or value)
        LD   C,L            
        POP  HL             ;HL=2. parameter (end)
        LD   ($2B08),HL     
        ADD  HL,BC          ;HL=relocated end
        EX   DE,HL          ;DE=relocated end
        POP  HL             ;HL=1. parameter (start)
        LD   ($2B06),HL     
        ADD  HL,BC          ;HL=relocated start
        JR   $E9A6          ;record leader and header at 300bps
        RST  $28            
        LD   ($2B02),HL     ;LINE number for basic
        LD   HL,$2C36       ;HL=start of data block
        LD   ($2B04),DE     ;save basic pointer
        LD   DE,($2C38)     ;DE=end of data block
        LD   ($2B06),HL     
        LD   ($2B08),DE     
        JR   $E9A6          ;record leader and header at 300bps
        POP  AF             
        RST  $8             ;get LINE parameter (basic line number for autostart)
        LD   ($2B02),HL     ;remember it
        RST  $18            ;any more parameters?
        DEFB ","            ;(is there a comma?)
        DEFB $E9A4-$-1      ;if not, $just basic
        JR   $E963          ;if yes, $take other parameters (start, $end, $[reloc])
        JR   $E986          ;set header for "basic only"
        DI                  ;deny interapte - QSAVE 300bps header
        LD   B,$64          ;counter leader bytes
        XOR  A              ;leader bytes are zero
        CALL $0E68          ;record leader byte
        DJNZ $E9A9          ;...all 100
        LD   A,$A5          ;header ID (and base for CRC in B register)
        CALL $0E68          ;record header ID byte
        LD   A,$FF          ;indicator byte ??
        CALL $0E68          ;record indicator
        CALL $0E63          ;record HL
        EX   DE,HL          
        CALL $0E63          ;record DE
        LD   HL,($2B02)     
        CALL $0E63          ;record LINE number (autostart line)
        LD   DE,($2B00)     ;DE=beginning of name (first letter after the first ")
        LD   A, (DE)        
        CP   $22            ;is the character "
        JR   NZ,$E9D1       ;if not, $record it
        JR   $E9D7          ;if " , $jump
        CALL $0E68          ;write name letter
        INC  DE             ;next letter
        JR   $E9CA          ;check this sign too
        LD   A,$FF          ;indicator byte ??
        CALL $0E68          ;save indicator byte
        LD   A,B            ;A=CRC of bytes recorded so far
        CPL                 ;complement CRC byte
        CALL $0E68          ;record CRC byte
        LD   B,$0F          ;pause ~4 seconds
        LD   HL,$8000       
        DEC  HL             
        BIT  $7,H           
        JR   Z,$E9E6        
        DJNZ $E9E3          
        XOR  A              ;leader byte 0
        CALL $EBE5          ;record TURBO leader byte...
        DJNZ $E9ED          ;...256 times (initial B is 0 !)
        LD   A,$A5          ;header ID
        CALL $EBE5          ;record TURBO header ID
        XOR  A              ;indicator 0 ??
        CALL $EBE5          ;record TURBO indicator
        LD   HL,($2B06)     ;HL=start of data block
        LD   DE,($2B08)     ;DE=end of data block
        INC  DE             ;DE=end of data block +1 (for RST $10)
        LD   A,(HL)         ;read data byte
        INC  HL             ;next address
        CALL $EBE5          ;record TURBO data byte
        JR   C,$EA04        ;write all bytes to end
        LD   A,B            
        CPL                 ;complement CRC
        CALL $EBE5          ;record TURBO CRC BYTE (not WORD)
        LD   DE,($2B04)     ;restore basic pointer
        EI                  ; enable interapt
        CALL $EA52          ;mute AY sound
        RST  $30            ;continue basic
        DEFB "SEARCHING"    
        DEFB 13             
        LD   A,($2000)      ;A=state of port for tape recorder (WAITING FOR IMPULSE)
        RRCA                ;C=state of input port (bit 0)
        RET  NC             ;if Cf=0, $pulse detected, $return
        JR   $EA23          ;if there is no impulse, $wait for it further
        DEFB "FOUND "       
        DEFB 0              
        DEFB "LOADING"      
        DEFB 13             
        XOR  A              ;INITIALIZE AY SOUND
        OUT  ($0),A         ;R0
        OUT  ($1),A         ;channel A frequency (fine - 0)
        LD   A,$7           
        OUT  ($0),A         ;R7
        LD   A,$FE          
        OUT  ($1),A         ;tone on channel A only
        LD   A,$8           
        OUT  ($0),A         ;R8
        LD   A,$0F          
        OUT  ($1),A         ; volume on channel A is maximum (15)
        XOR  A              
        OUT  ($0),A         ;R0 prepared for further writing
        RET                 ;return with A=0
        LD   A,$8           ;SILENCE AY SOUND
        OUT  ($0),A         ;R8
        XOR  A              
        OUT  ($1),A         ;volume on channel A = 0 (none)
        LD   A,$7           
        OUT  ($0),A         ;R7
        LD   A,$FF          
        OUT  ($1),A         ;exclusion of all channels
        RET                 ;return with A = 255
        DEFB "LINE"         
        DEFB "CODE"         
        LD   B,$4           ;RECOGNITION OF "LINE" AND "CODE" WORDS
        CALL $0105          ;skip blanks
        LD   A,(DE)         ;get byte from BASIC
        CP   (HL)           ;compare with given text
        INC  HL             ;increase pointer
        INC  DE             
        RET  NZ             ;return with Zf=0 if they are not the same
        DJNZ $EA6F          ;if they are the same, $check all 4 letters
        RET                 ;return with Zf=1 if the words are the same
QLOAD_CMD:        
        POP  AF             ;forget return address - QLOAD command
        LD   ($2B00),DE     ;store basic pointer (address names)
        CALL $EA39          ;initialize AY sound (A=0 on return)
        INC  A              ;A=1 , $Zf=0
        PUSH AF             ;$XX01 onto stack (1=LOAD mode, $0=VERIFY mode)
        EI                  ;enable interapte (exit FAST mode to see messages)
        LD   A,$FF          
        PUSH AF             ;$XXFF onto stack (ie name not specified)
        RST  $18            
        DEFB $22            ; is the QLOAD command followed by a quotation mark ?
        DEFB $EAA3-$-1      ; if not, $jump to further checks
        EX   DE,HL          ;HL=address of the character after the first quotation mark (A=character of the first quotation mark)
        CP   (HL)           ; is the name given? (or just two quotes)
        EX   DE,HL          ;DE=basic pointer (points to second quote or first letter of name)
        JR   Z,$EAAB        ;if there is no name, $jump to check further parameters
        POP  AF             ;pop $XXFF off stack
        PUSH DE             ;start address of the name of the requested image on the stack
        XOR  A              
        PUSH AF             ;$XX00 onto stack (means name is specified)
        LD   B,$15          ;find another quote (from here QLOAD and VERIFY are the same)
        INC  DE             
        DJNZ $EA96          
        RST  $18            
        DEFB $22            
        DEFB $EAA9-$-1      ; if it is not a quote, $search further (to 15 places)
        DEC  DE             ;second quote found, $jump compensation (why?)
        JR   $EAAB          ;jump (why not JR $EAAC here without DEC DE ?)
        LD   A,(DE)         ;A=character text (basic) (Why is this pinched here ???)
        CP   $0D            ;is it ENTER ?
        RET  Z              ;if so, $return with Zf=1
        CP   $3A            ;is it a colon ?
        RET                 ;return with Zf=0 if none
        CALL $EA9C          ;no quotes after QLOAD, $is there . or ENTER ?
        RST  $28            ;HL=0
        JR   Z,$EAB3        ;if any, $jump
        JR   $EA93          ; if there is no . or ENTER, $search further for quotation marks (?)
        INC  DE             ;return the pointer to the end of the name
        RST  $28            ;HL=0 (RELOC parameter in case it is not specified)
        CALL $EA9C          ;is the name followed by . or ENTER ?
        JR   Z,$EAB3        ; if followed by . or ENTER, $skip reading the RELOC parameter
        RST  $8             ;HL=RELOC parameter
        LD   ($2B04),DE     ;save basic pointer (address of continuation of basic)
        PUSH HL             ;RELOC parameter to stack
        LD   DE,$EA19       ;message address "SEARCHING"
        CALL $0937          ;print message + new line
        CALL $EA23          ;wait for an impulse from the tape recorder
        DI                  ;pulse detected, $turn off image
        LD   B,$14          ;B=20 - WAITING FOR LEADER RECORD, $at least 20 consecutive zeros)
        PUSH BC             ;keep B counter on stack
        CALL $0EDD          ;load byte from cassette (300bps)
        LD   A,C            ;A=loaded byte
        POP  BC             ;return B counter from stack
        OR   A              ; is byte 0 (leader) loaded
        JR   NZ,$EAC2       ;if not, $reset the counter and wait for 20 leaders
        DJNZ $EAC4          ;detect 20 consecutive leader bytes
        CALL $0EDD          ;load next byte from cassette - WAIT FOR HEADER ID
        LD   A,C            
        CP   $A5            ; is byte header id ?
        JR   NZ,$EACF       ;if not, $wait for it further
        LD   B,A            ;B=$A5 (CRC basis)
        CALL $0EDD          ;load next BYTE
        LD   A,C            
        INC  A              ;is byte $FF (TURBO header indicator) ?
        JR   NZ,$EB55       ;if not, $jump (stack=RRRR[XX00XXXX]/[XXFFXX01] !!!)
        CALL $0ED9          ;if yes, $load start address (WORD)
        LD   H,C            
        EX   DE,HL          ;DE=start address
        CALL $0ED9          ;load end address (WORD)
        LD   H,C            ;HL=end address
        LD   A,B            ;A=CRC of loaded bytes (effectively only the last 5)
        POP  BC             ;BC=RELOC number from stack
        ADD  HL, BC         
        EX   DE,HL          ;DE=relocated end address of load data
        ADD  HL,BC          ;HL=relocated start address of load data
        LD   B,A            ;B=CRC again
        LD   ($2B06),HL     ;remembers actual initial and...
        LD   ($2B08),DE     ;...actual end address to load
        CALL $0ED9          ;load AUTOSTART line number (WORD)
        LD   H,C            
        LD   ($2B02),HL     ;remember AUTOSTART line number
        LD   DE,$EA2A       ;message address "FOUND "
        PUSH BC             ;store CRC on stack (PRINTSTR dirty BC)
        CALL $0937          ;print message "FOUND " (cursor remains in the same row)
        POP  BC             ;B=CRC from stack
        LD   HL,($2A68)     ;HL=cursor address (beginning of the name found on the screen)
        CALL $0EDD          ;load next byte (name letter)
        LD   A,C            ;A=letter of name
        INC  C              ;is byte $FF loaded (end of name)
        JR   Z,$EB11        ;if end of name jump to load CRC
        RST  $20            ;if letter, $print to screen
        JR   $EB07          ;load and print all letters of image name (if any)
        CALL $0EDD          ; load CRC BYTE header (B=calculated CRC + loaded CRC !)
        LD   A,$0D          
        RST  $20            ;goes to a new line on the screen
        INC  B              ;(CRC is recorded in complemented form) 
        JP   NZ,$078F       ;if CRC + loaded byte is not $FF , $WHAT? mistake
        LD   A,H            ;CRC OK, $A=higher byte of cursor address (FIND SCREEN NAME)
        CP   $28            ;does the name start at the top of the screen?
        JR   Z,$EB28        ;if in top half of screen, $jump to check name
        LD   A,L            
        CP   $E6            ;does the name start on line 16?
        JR   NZ,$EB28       ;if not, $jump (not in last row, $$0D didn't move it)
        SUB  $20            ;if in line 16, $address in line 15 of screen (due to $0D)
        LD   L,A            ;HL=address of screen name
        LD   A,$25          ;A=character %
        CP   (HL)           ;does name start with % (???)
        JR   NZ,$EB44       ;if not, $jump
        PUSH HL             ;if yes, $store name address on stack (I don't understand this part !!!)
        OR   $30            ;A=$55 (character U)
        LD   ($2C34),SP     ;store stack pointer at end of input buffer
        LD   SP,$2BAE       ;???
        INC  SP             ;StackPointer=$2BAF (system variable for clock start)
        RST  $28            ;HL=0
        LD   H,A            ;HL=$5500
        PUSH HL             ;START_RTC=$55, $VIDEO_LINK=$C39500 (CALL $0095 ????)
        LD   SP,($2C34)     ;restore StackPointer
        POP  HL             ;HL=address of found name
        LD   A,$20          
        LD   (HL),A         ;blank in place of the first letter (instead of % ?)
        INC  HL             ;HL=address of the second letter of the screen name
        POP  AF             ;A=name indicator from stack
        INC  A              ; if the name is not specified (indicator is $XXFF)...
        JR   Z,$EB62        ;...jump
        POP  DE             ; otherwise, $DE=address of the name of the requested image
        LD   A,(DE)         ;A=letter of the name of the requested image
        CP   $22            ;is there a quotation mark at the end of the name
        JR   Z,$EB62        ;if so, $jump
        CP   (HL)           ; compare the letter of the searched and found name
        INC  HL             ;next letter found (screen)
        INC  DE             ;next letter requested (stack pointer)
        JR   Z,$EB49        ;if the letters are the same, $compare further
        JR   $EB5B          ;if they are different, $it is not that shot - jump
        POP  AF             ;THE VIDEO IS NOT A TURBO HEADER !! (forget YYYY address)
        POP  AF             ;pop 4 bytes off stack (forget XX00 or XXFF)
        INC  A              ;(stack was RRRRXX00NNNN OR XXFFXX01)
        JR   Z,$EB5B        ;if the last one is not $XXFF (but NNNN)...
        POP  AF             ;...remove 2 more bytes (to leave only XX01)
        LD   DE,($2B00)     ;DE=saved basic pointer (pointer before the name)
        JP   $EA81          ;find the name of the requested recording again (and why ???)
        POP  AF             
        PUSH AF             ;A=load mode (1=LOAD, $0=VERIFY)
        JR   Z,$EB6C        ;if Zf=1, $jump to pause (requested clip not found)
        LD   DE,$EA31       ;if Zf=0, $the requested recording is found, $print...
        CALL $0937          ;...messages "LOADING"
        EI                  ;enable interapt (to see messages)
        LD   B,$5           ;pause ~1.3 seconds
        LD   HL,$8000       
        DEC  HL             
        BIT  $7,H           
        JR   Z,$EB72        
        DJNZ $EB6F          
        CALL $EA23          ;wait for an impulse from the tape recorder
        DI                  ;disable interapt (and image)
        LD   DE,($2B06)     ;DE=load start address
        LD   HL,($2B08)     ;HL=loading end address
        LD   B,$14          ;B=20 (WAITING FOR LEADER TURBO RECORD, $at least 20 zeros in a row)
        PUSH BC             ;keep counter
        CALL $EC3C          ;load TURBO byte in C (and change AY sound, $A on return $7A/$B7)
        LD   A,C            ;A=loaded byte
        POP  BC             ;return counter
        OR   A              ; is byte 0 ?
        JR   NZ,$EB84       ;if not 0, $reset counter and look for leader next
        DJNZ $EB86          ;if zero, $load all 20
        CALL $EC3C          ;load next byte into C
        LD   A,C            
        CP   $A5            ;is byte header ID loaded?
        JR   NZ,$EB91       ;if not, $load next byte
        LD   B,A            ;if so, $B=$A5 - basis for CRC
        CALL $EC3C          ;load next byte into C
        LD   A,C            
        OR   A              
        JR   NZ,$EBCC       ;if header ID does not follow byte 0, $report WHAT?
        EX   DE,HL          ;HL=start address, $DE=end
        CALL $EC3C          ;load data byte into C
        EX   AF,AF'         ;keep flag C (from comparing HL with DE)
        LD   A,C            ;A=loaded byte
        CP   (HL)           ;compare loaded byte with byte in memory (VERIFY ?)
        JR   Z,$EBAF        ;if same, $continue loading
        POP  AF             ;if not, $A=load mode from stack
        JR   Z,$EBCC        ;if VERIFY ($00), $report WHAT?
        PUSH AF             ;if LOAD ($01), $return A to stack
        LD   (HL),C         ;write loaded byte into memory
        INC  HL             ;next memory address
        EX   DE,HL          ;DE=start address, HL=end
        EX   AF,AF'         ;are all data bytes loaded?
        JR   C,$EBA1        ;if not yet, $continue loading
        CALL $EC3C          ;load TURBO CRC byte
        POP  AF             ;A=remove load mode from stack
        INC  B              ; is the loaded CRC equal to the calculated one?
        JR   NZ,$EBCC       ;if not, $state WHAT?
        EI                  ;enable interapt (include image)
        CALL $EA52          ;silence AY chip
        LD   DE,($2B04)     ;restore DE (basic pointer)
        LD   HL,($2B02)     ;HL=AUTOSTART line number
        LD   A,H            
        OR   L              ; if line number is not 0...
        JP   NZ,$040E       ;...RUN of loaded BASIC from line from HL
        RST  $30            ;if 0, $return to basic
        JP   $078F          ;jump to print message "WHAT?" (vector)
VERIFY_CMD:        
        POP  AF             ;forget return address - TURBO VERIFY command
        LD   ($2B00),DE     ;remember basic pointer (address before name - quotes)
        CALL $EA39          ;initialize AY sound
        XOR  A              ;A=$00 - loading mode (VERIFY - XX00)
        PUSH AF             ;stack load mode
        RST  $18            
        DEFB $22            ; is the command followed by a quotation mark ?
        DEFB $EBE2-$-1      ; if not, $report WHAT?
        PUSH DE             ;address of name on stack (NNNN)
        XOR  A              
        PUSH AF             ;name indicator on stack (XX00)
        JP   $EA91          ;continue as that QLOAD is a command
        JP   $078F          ;jump to print message "WHAT?" (vector)
        EXX                 ;TURBO BYTE RECORDING FROM A (with AY sound and patterns?)
        LD   HL,$2038       ;HL=cassette recorder output port
        LD   C,$8           
        RRCA                
        LD   (HL),$FC       
        LD   B,$1E          
        JR   C,$EBF4        
        LD   B,$64          
        DJNZ $EBF4          
        LD   (HL),$B8       
        LD   B,$1E          
        JR   C,$EBFE        
        LD   B,$64          
        DJNZ $EBFE          
        LD   (HL),$BC       
        DEC  C              
        JR   NZ,$EBEB       
        LD   B,$0           
        DJNZ $EC07          
        EXX                 
        ADD  A,B            ;add byte to CRC - COMMON CRC AND AY SOUND FOR QLOAD AND QSAVE
        LD   B,A            ;B=CRC
        LD   A,$7A          ;A=value for even CRC is 784Hz
        BIT  $0,B           ;basis for AY sound is CRC parity (bit 0)
        JR   Z,$EC14        ;if even, $sound is 784Hz
        LD   A,$B7          ;A=value for odd CRC is 523Hz
        OUT  ($1),A         ;write in R0 AY chip (frequency fine in Hz)
        RST  $10            
        RET                 
        JP   QSAVE_CMD      ;$E930 ;QSAVE (why were these 30 bytes consumed when already in the table...)
        JP   QLOAD_CMD      ;$EA77 ;QLOAD (...addresses from $E000 to $EFFF can be specified ???)
        JP   VERIFY_CMD     ;$EBCF ;VERIFY
        JP   HLOAD_CMD      ;$EEF4 ;HLOAD
        JP   HDUMP_CMD      ;$EEC0 ;HDUMP
        JP   HLDUMP_CMD     ;$EEBD ;HLDUMP
        JP   AUTO_CMD       ;$ECF4 ;AUTO
        JP   FILL_CMD       ;$EE02 ;FILL
        JP   UP_CMD         ;$EF93 ;UP
        JP   DOWN_CMD       ;$EFC8 ;DOWN
        CALL R2_CMD         ;$ECB5 ;hidden command "R2"
        JP   $0066 ;HARD-BREAK ("farm" - reset basic)
        EXX                 ;TURBO load byte into A
        LD   HL,$2000       
        LD   B,$55          
        BIT  $0,(HL)        
        JR   Z,$EC4C        
        DJNZ $EC42          
        EXX                 
        LD   A,C            
        JR   $EC0A          ;byte loaded into A, $jump to CRC and AY sound
        LD   A,$E4          
        INC  A              
        BIT  $0,(HL)        
        JR   Z,$EC4E        
        RLA                 
        EXX                 
        RR   C              
        EXX                 
        JR   $EC40          
        CP   H              
        JR   NZ,$EC5F       
        LD   H,$0           
        CP   L              
        JR   NZ,$EC64       
        LD   L,$0           
        DEC  E              
        JR   NZ,$EC72       ;key not pressed, $check next
        JR   $EC6F          ;no key pressed, $repeat the whole check
        EXX                 ;REPLACE FOR "KEY_0" IN SCREEN EDITOR
        LD   HL,($2AA5)     ;HL=sis. var. keyboard differentiator
        LD   C,$0E          ;C=14, $number of keys to check (from "STOP/LIST" to "7")
        LD   DE,$2034       ;DE=address of STOP/LIST key
        LD   A,(DE)         ;A=key state
        RRCA                ;Cf=key state
        LD   A,E            ;A=key number (address)
        JR   C,$EC5A        ;if the key is not pressed, $check if it has been pressed before
        CP   $32            ;is that the REPT key?
        JR   NZ,$EC84       ;if not, $jump
        DEC  C              ;next key
        JR   NZ,$EC5A       ;if it's not the last one, $check if it's already pressed before
        LD   A,($2BB4)      ;A=REPT status (contents of system register for REPT)
        JP   $0D54          ;end in ROM-A (to shorten the code by 2 bytes!)
        CP   H              
        JR   Z,$EC64        
        CP   L              
        JR   Z,$EC64        
        LD   B,$0           ;B=0 (counter 256) - DELAY FOR REPT (repetition rate)
        RST  $10            ;pause
        LD   A, (DE)        
        RRCA                ;is the key still pressed
        JR   C,$EC5A        ;if not, $continue with other keys
        DJNZ $EC8C          ;if pressed, $do pause
        LD   A,H            
        OR   A              
        JR   NZ,$EC9A       
        LD   H,E            
        JR   $EC9F          
        LD   A,L            
        OR   A              
        JR   NZ,$EC72       
        LD   L,E            
        LD   ($2AA5),HL     
        RST  $28            
        LD   A,E            
        CP   $34            
        JR   NZ,$ECAC       
        LD   A,$2           
        JR   $EC81          
        CP   $31            
        JP   NZ,$0D39       
        LD   A,$1           
        JR   $EC81
R2_CMD:                  
        LD   A,$0C          ;HIDDEN COMMAND "R2" TO RETURN TO MINUS MODE
        RST  $20            ;clear the screen
        IM   $1             ;interapt mode 1
        EXX                 
        CALL $1023          ;arrange links in ROM-B for ROM-A+B
        EXX                 
        RET                 ;go back, $and jump to the FARM !!!
        LD   L,C            
        PUSH BC             
        LD   A,B            
        CPL                 
        SUB  $30            
        LD   H,A            
        LD   A,L            
        AND  $7             
        LD   B,$3           
        SRL  H              
        RR   L              
        DJNZ $ECCC          
        PUSH HL             
        LD   H,B            
        LD   L,A            
        LD   BC,$E18D       
        ADD  HL,BC          
        LD   A,(HL)         
        LD   HL,($2A6A)     
        LD   BC,$0020       
        ADD  HL, BC         
        POP  BC             
        ADD  HL,BC          
        POP  BC             
        RET                 
        PUSH HL             
        CALL $ECC0          
        AND  (HL)           
        LD   (HL),A        
        POP  HL             
        RET                 
        PUSH HL             
        CALL $ECC0          
        AND  (HL)           
        POP  HL             
        RET                 
AUTO_CMD:        
        POP  AF             
        RST  $8             
        LD   ($2C34),HL     
        BIT  $7,H           
        JP   NZ,$078F       
        CALL $0005          
        LD   ($2C32),HL     
        BIT  $7,H           
        JR   NZ,$ECFB       
        CALL $ECB5          
        LD   HL,($2C34)     
        LD   ($2BB6),HL     
        CALL $07F2          
        JP   Z,$EDAF        
        CALL $08F3          
        LD   DE,$2BB8       
        CALL $EDE6          
        RST  $20            
        EXX                 
        LD   (HL),$5F       
        EXX                 
        LD   (DE), A        
        INC  DE             
        LD   A,D            
        CP   $2C            
        JR   NZ,$ED1D       
        LD   A,E            
        CP   $31            
        JR   NZ,$ED1D       
        CALL $EDE6          
        JR   $ED31          
        LD   A,D            
        CP   $2B            
        JR   NZ,$ED40       
        LD   A,E            
        CP   $B8            
        JR   Z,$ED1D        
        DEC  DE             
        LD   A,$1D          
        RST  $20            
        EXX                 
        LD   (HL),$5F       
        EXX                 
        JR   $ED1D          
        LD   (DE),A         
        RST  $20            
        INC  DE             
        LD   B,D            
        LD   C,E            
        LD   DE,$2BB6       
        LD   HL,($2C34)     
        PUSH BC             
        PUSH DE             
        LD   A,C            
        SUB  E              
        PUSH AF             
        CALL $07F2          
        PUSH DE             
        JR   NZ,$ED70       
        PUSH DE             
        CALL $0811          
        POP  BC             
        LD   HL,($2C38)     
        CALL $0944          
        LD   H,B            
        LD   L,C            
        LD   ($2C38),HL     
        POP  BC             
        LD   HL,($2C38)     
        POP  AF             
        PUSH HL             
        CP   $3             
        JR   Z,$ED92        
        LD   E,A            
        LD   D,$0           
        ADD  HL, DE        
        LD   DE,($2A6A)     
        RST  $10            
        JP   NC,$0153       
        LD   ($2C38),HL     
        POP  DE             
        CALL $094C          
        POP  DE             
        POP  HL             
        CALL $0944          
        LD   HL,($2C34)     
        LD   DE,($2C32)     
        ADD  HL, DE        
        BIT  $7,H           
        JP   NZ,$0153       
        LD   ($2C34),HL     
        JP   $ED0B          
        LD   D,A            
        LD   B,C            
        LD   D,D            
        LD   C,(HL)         
        LD   C,C            
        LD   C,(HL)         
        LD   B,A            
        JR   NZ,$EDCF       
        DEC  C              
        PUSH DE             
        CALL $EA39          
        LD   A,$C8          
        OUT  ($1),A         
        LD   DE,$EDA5       
        CALL $0937          
        POP  DE             
        CALL $0931          
        LD   B,$0           
        DJNZ $EDC3          
        CALL $EA52          
        CALL $EC69          
        CP   $1             
        JP   Z,$EF7F        
        CP   $2             
        JR   Z,$EDC8        
        CP   $0D            
        JR   Z,$ED92        
        LD   HL,($2C34)     
        PUSH AF             
        CALL $08F3          
        POP  AF             
        LD   DE,$2BB8       
        JP   $ED20          
        POP  HL             
        CALL $EC69          
        CP   $1             
        JP   Z,$EF7F        
        CP   $2             
        JR   Z,$EDE7        
        CP   $0D            
        JP   Z,$ED4A        
        CP   $1D            
        JP   Z,$ED36        
        CP   $20            
        JR   C,$EDE7        
        JP   (HL)           
FILL_CMD:
        POP  AF             
        RST  $8             
        LD   C,L            
        PUSH BC             
        CALL $0005          
        LD   A,($2BA8)      
        INC  A              
        POP  BC             
        JR   Z,$EE11        
        RST  $30            
        LD   B,L            
        PUSH DE             
        LD   ($2C32), SP    
        LD   HL,($2A6A)     
        LD   DE,($2A99)     
        BIT  $7,H           
        JR   Z,$EE25        
        ADD  HL,DE          
        JR   $EE28          
        XOR  A              
        SBC  HL, DE        
        DEC  HL             
        LD   A,$CF          
        SUB  B              
        JP   C,$065A        
        LD   SP,HL          
        EXX                 
        LD   HL,($2C38)     
        EXX                 
        LD   HL,$EE5C       
        PUSH HL             
        LD   H,$FF          
        DEC  SP             
        PUSH HL             
        CALL $EE74          
        POP  BC             
        DEC  SP             
        POP  DE             
        CALL $EE67          
        INC  B              
        RET  Z              
        LD   A,B            
        SUB  $D0            
        CALL C,$EE74        
        DEC  B              
        JR   Z,$EE56        
        DEC  B              
        CALL $EE74          
        INC  B              
        INC  C              
        DEC  D              
        JR   NZ,$EE46       
        JR   $EE40          
        LD   SP,($2C32)     
        POP  DE             
        RST  $30            
        LD   A,($2033)      
        RRCA                
        RET  C              
        LD   A,($2031)      
        RRCA                
        JR   C,$EE62        
        LD   SP,($2C32)     
        JP   $0305          
        LD   H,$0           
        CALL $EEAD          
        RET  NC             
        LD   E,C            
        LD   A,C            
        AND  A              
        JR   Z,$EE86        
        DEC  C              
        CALL $EEAD          
        JR   C,$EE7B        
        INC  C              
        LD   L,C            
        LD   C,E            
        INC  C              
        JR   Z,$EE90        
        CALL $EEAD          
        JR   C,$EE88        
        LD   C, L           
        EXX                 
        LD   ($2C34), SP    
        LD   DE,($2C34)     
        DEC  DE             
        DEC  DE             
        DEC  DE             
        RST  $10            
        JR   NC,$EEA6       
        EXX                 
        EX   (SP), HL       
        INC  SP             
        PUSH BC             
        LD   C,E            
        JP   (HL)           
        LD   SP,($2C32)     
        JP   $0153          
        PUSH HL             
        PUSH DE             
        CALL $ECC0          
        AND  (HL)           
        CP   (HL)           
        JR   Z,$EEB7        
        LD   (HL),A         
        POP  DE             
        POP  HL             
        RET  Z              
        INC  H              
        SCF                 
        RET
HLDUMP_CMD:                         
        CALL $1060          
HDUMP_CMD:        
        POP  AF             
        RST  $8             
        PUSH HL             
        CALL $0005          
        EX   DE, HL         
        EX   (SP), HL       
        LD   A,H            
        ADD  A,L            
        PUSH HL             
        LD   B,$8           
        ADD  A, (HL)        
        INC  HL             
        DJNZ $EECD          
        POP  HL             
        PUSH AF             
        CALL $134F          
        LD   B,$8           
        LD   A,$20          
        RST  $20
        LD   A,(HL)         
        CALL $135C          
        INC  HL             
        DJNZ $EED8          
        LD   A,$20          
        RST  $20            
        POP  AF             
        CALL $135C          
        CALL $02FF          
        LD   A,$0D          
        RST  $20            
        RST  $10            
        JR   C,$EEC8        
        POP  DE             
        RST  $30
HLOAD_CMD:                    
        POP  AF             ;HLOAD command
        RST  $8             ;get parameter (address of input start)
        CALL $ECB5          ;turn off ROM-C (back to (one)line editor !!!)
        PUSH HL             ;(BAG. in case of gross error ROM-C remains off !!!)
        PUSH HL             ;start address on stack 2x
        POP  HL             ;HL=address from stack
        CALL $134F          ; print HEX address
        PUSH HL             ;address back on stack
        LD   A,$20          ;A=ASCII blank
        LD   DE,$2BB6       ;DE=address of input buffer
        LD   (DE),A         ; the first character of the input buffer is blank
        INC  DE             ;DE=cursor address in input buffer
        RST  $20            ; on the screen after the address, $the same blank
        EXX                 
        LD   (HL),$5F       ;print cursor on screen (block) after blank
        EXX                 
        CALL $EC69          ;wait for key press (new KEY(0))
        CP   $1             ;is BRK pressed?
        JR   Z,$EF7F        ;end of entry, $jump to power on ROM-C
        CP   $2             ;is STOP/LIST pressed?\
        JR   Z,$EF0C        ;wait for next key /(unnecessary)
        CP   $1D            ;is the left arrow pressed (delete)?
        JR   Z,$EF2E        ;if so, $jump to delete processing
        CP   $0D            ;has ENTER been pressed?
        JR   Z,$EF38        ;if so, $jump to processing input
        CP   $20            ;is any other control key pressed?
        JR   C,$EF0C        ;if so, $wait for the next key
        EX   AF,AF'         ;save character code in A'
        LD   A,E            
        CP   $D1            ;is the cursor at the end of the line?
        JR   Z,$EF0C        ;if it is, $there is no printout, $wait for the key
        EX   AF,AF'         ;A=printable character
        LD   (DE),A         ;write a character into the input buffer
        INC  DE             ;DE=next location of input buffer
        JR   $EF07          ;jump to print character on screen and wait for key
        LD   A,E            ;delete processing
        CP   $B7            ; is the cursor in the buffer at the 2nd position (address+blank is not deleted)
        JR   Z,$EF0C        ;if so, $no deletion, $wait for another key
        DEC  DE             ;if not, $cursor in buffer one character back
        LD   A,$1D          ;A=erasure control code (left arrow - line editor !!)
        JR   $EF07          ;jump to print character on screen and wait for key
        LD   (DE),A         ; enter ENTER at the end of the buffer - processing the input
        RST  $20            ;print ENTER to screen (new line)
        LD   DE,$2BB6       ;DE=start of input buffer (entry)
        CALL $0105          ;skip blanks (A=first character in buffer)
        CP   $0D            ;is the sign ENTER?
        JR   Z,$EF4E        ;if yes, $jump to end of line processing
        CALL $18EE          ;read HEX number in HL (if not HEX number, $HOW? and ROM-C remains off)
        LD   A,L            ;A=number
        POP  HL             ;HL=address for number
        LD   (HL),A         ; entry of number to address
        INC  HL             ;next address
        PUSH HL             ;keep recording address still
        JR   $EF3D          ;process next HEX number (8 + CRC)
        POP  HL             ;forget the last entry address - end of line processing
        POP  HL             
        PUSH HL             ;HL=address of the first entry in the line
        LD   B,$8           ;B=number of entered HEX digits in the line (if there are less, $BAG?)
        LD   A,H            ;A=CRC basis (higher byte of starting address)
        ADD  A,L            ;CRC+lower byte of address
        ADD  A,(HL)         ;CRC+written byte
        INC  HL             ;address of next byte
        DJNZ $EF55          ;add all eight bytes
        CP   (HL)           ;is the CRC equal to the ninth written byte (again BAG !!!)
        JR   Z,$EF7B        ;if equal, $jump to next line entry
        POP  HL             ;set stack as...
        PUSH HL             ;...as at the beginning of the line
        PUSH HL             ;(will be repeated !!)
        LD   DE,$EF75       ;DE=address of error message "ERROR"
        CALL $0937          ;print error message
        CALL $EA39          ;initialize AY sound
        LD   A,$AA          ;A=frequency ~560Hz fine
        OUT  ($1),A         ;write to register R0 for channel A
        LD   B,$0           
        DJNZ $EF6E          ;short pause (from .1s to .21s)
        CALL $EA52          ;mute sound
        JR   $EEFB          ;expect the same line again
        DEFB "ERROR"        
        DEFB 13             
        POP  AF             ;forget line start address
        JP   $EEF9          ;expect next line
        DI                  ;disable interrupts - REFLASH ROM C
        CALL $E000          ;initialize ROM-C (and set 32 ​​system variables)
        LD   HL,($2A6A)     ;HL=new RAMTOP
        LD   DE,$0020       ;DE=number of system variables above RAMTOP
        ADD  HL,DE          ;HL=old RAMTOP (with old system variables)
        LD   ($2A6A),HL     ;set system variable RAMTOP
        LD   A,$0C          
        RST  $20            ;clear the screen
        JP   $0066          ;jump to HARD-BREAK ("farm")
UP_CMD:        
        POP  AF             ;COMMAND UP
        RST  $8             ;read the parameter (how many bytes to raise the basic up)
        PUSH DE             ;save basic pointer
        PUSH HL             ;save parameter
        BIT  $7,H           ; is the parameter greater than 32767 ?
        JR   NZ,$EFC5       ;if bigger HOW? (BUG. with ROM-D it will be stuck or RESET!!!)
        LD   DE,($2C38)     ;DE=end of basic +1
        PUSH DE             
        ADD  HL,DE          ;HL=new end of basic (end + parameter)
        LD   DE,($2A6A)     ;DE=RAMTOP
        RST  $10            ;is there room to move the base
        JP   NC,$0153       ;if none, $SORRY error message
        EX   (SP), HL       ; new end of basic to stack
        PUSH HL             ;HL=old end of basic, $and onto stack
        LD   DE,($2C36)     ;DE=start of basic
        CALL $EFEF          ;is there a basic at all?
        LDDR                ;if any, $move the base
        POP  DE             ;DE=saved parameter from stack
        LD   HL,($2C38)     ;HL=BASIC_END (end of BASIC system variable)
        ADD  HL,DE          ;HL=new end of basic
        LD   ($2C38),HL     ;update system variable
        LD   HL,($2C36)     ;HL=BASIC_START (basic start system variable)
        ADD  HL,DE          ;HL=new beginning of BASIC
        LD   ($2C36),HL     ;update system variable
        POP  DE             ;DE=saved basic pointer
        RST  $30            ;continue basic (after changing the address ??? but it works!)
        JP   $065A          ;print message "HOW?"
DOWN_CMD:        
        POP  AF             ;COMMAND DOWN
        RST  $8             ;read the parameter (how many bytes to lower the basic down)
        PUSH DE             ;save basic pointer
        BIT  $7,H           ;is the parameter greater than 32767?
        JR   NZ,$EFC5       ;if greater, $HOW? (BUG. with ROM-D it will be stuck or RESET!!!)
        EX   DE,HL          ;DE=parameter
        RST  $28            ;HL=0
        XOR  A              ;Cf=0
        SBC  HL,DE          ;HL= negative parameter
        PUSH HL             ;negative parameter on stack
        LD   DE,($2C36)     ;DE=BASIC_START (start of basic)
        PUSH DE             ;start of basic on stack
        ADD  HL,DE          ;HL=new start of basic (practical. start of basic - shift)
        LD   DE,$2C3A       ;DE=start of BASIC RAM
        RST  $10            ;is the new start of basic still in RAM?
        JP   C,$0153        ;if not, $error message SORRY
        POP  DE             ;DE=old beginning of BASIC
        PUSH HL             ;new start of BASIC on stack
        PUSH DE             ;old start of BASIC on stack
        LD   HL,($2C38)     ;HL=old end of basic
        CALL $EFEF          ;is there a basic at all?
        LDIR                ;if there is, $put it down
        JR   $EFB4          ;update system variables BASIC_START and BASIC_END
        RST  $10            ;are the beginning of the basic and the end of the basic the same? (SUBROUTINE !)
        JP   Z,$078F        ;if they are (nothing to move), $report WHAT?
        XOR  A              ;Cf=0
        SBC  HL,DE          ;HL=base length
        LD   B,H            
        LD   C,L            
        INC  BC             ;BC=length of base +1
        POP  AF             ;AF=return address
        POP  HL             ;HL=old end of basic
        POP  DE             ;DE=new end of basic
        PUSH AF             ;return address on stack
        RET                 ;return
        DEFB "G+"           ;(free space in ROM. smartly filled !)

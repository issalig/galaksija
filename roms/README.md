# ROM listings
There a 4 for ROMS, from A to D or 1 to 4.

Here I provide asm files for roms A, B, and C. For D only some info from a magazine is included.

I have used the rom files available at https://github.com/mejs/galaksija/blob/master/roms/ and they are located in the folder original.

local folder is used to assemble the .asm files

Using make_roms.sh will assemble roms A, B and C.

## ROM A
ROM A listing has been downloaded from https://github.com/mejs/galaksija/tree/master/roms and comes from avian site https://web.archive.org/web/20221228104534/https://www.tablix.org/~avian/galaksija/rom/rom1.html 

Assembled ROM A is the same as  https://github.com/mejs/galaksija/blob/master/roms/ROM%20A/ROM_A_without_ROM_B_init_ver_28.bin

ROM A may be patched for ROM B autostart by doing two changes. One is cosmetic and increases version number to 29. The second change initializes ROM B at start-up to make its commands accessible. If there is no initialization patch, ROM B has to be initialized at startup by typing A=USR(&1000)  

Differences between ROM_A_without_ROM_B_init_ver_28.bin and ROM_A_with_ROM_B_init_ver_29.bin are just:

```
46c46
< 	db 28			;0037
---
> 	db 29			;0037
734,735c734
< 	ld a,00ch		;03f9
< 	rst 20h			;03fb
---
> 	call 01000h		;03f9
```

To check with version of ROMS you have you can try from BASIC
```basic
DUMP &0037, 1
```
1C means version 28
1D means version 29

```basic
DUMP &03F9, 1
```

```CD D3 0C``` is for non ROM B init
```CD 00 10``` is for ROM B init (call 01000h)

The following table shows the BASIC commands and their descriptions for ROM A.

| Command | Description |
|---------|-------------|
| `!...` | Like other BASICs REM - begins comment |
| `#...` | Like other BASICs DATA & Use as prefix before number if it is written in hex |
| `ARR$(x)` | Allocates array of strings. Can only allocate array A$ - with exactly this name |
| `BYTE` | Universal PEEK/POKE tool. PEEK is like `PRINT BYTE(&33F9)`, POKE is like `BYTE &33F9,&C4` |
| `CALL n` | Like other BASICs GOSUB. Allows to use variables for line numbers |
| `CHR$(n)` | ASCII code to character |
| `DOT x, y` | When used as command, draws dot at x,y (X in 0..63, Y in 0..47). Used as function- checks if there is a dot |
| `DOT * ?` | Not specified |
| `EDIT n` | Edit specified BASIC line |
| `ELSE` | For IF |
| `EQ` | Compare strings |
| `FOR` | A typical FOR loop |
| `GOTO` | A standard GOTO |
| `HOME` | Clear screen. Optional argument (HOME x) preserves x characters |
| `IF` | An IF, but there is no THEN! |
| `INPUT` | Make user enter variable |
| `INT(x)` | Return largest integer <=x |
| `KEY(x)` | Is x key pressed? |
| `LIST` | LISTs program. Optional argument specifies from which line |
| `MEM` | How much memory is used? |
| `NEW` | Clears program. Optional argument (NEW x) changes start of BASIC area for potential user data/code |
| `OLD` | Load from tape. Optional argument loads to address (OLD x) |
| `PTR` | Address of variable |
| `PRINT` | Prints expression |
| `RETURN` | Return from GOSUB |
| `RND` | Returns a random float between 0 and 1 |
| `RUN` | Runs a program |
| `SAVE` | Save program to tape. Optional arguments: memory range to be saved (e.g. for data) |
| `STEP` | For FOR |
| `STOP` | Stops running of BASIC program |
| `TAKE` | If the parameter is variable name, reads it. If number - clears data under pointer |
| `UNDOT` | Inverse to DOT |
| `UNDOT * ?` | Not specified |
| `USR` | Calls user routine from memory |
| `WORD` | Double byte PEEK/POKE (see BYTE) |



# ROM B
ROM B listing has been downloaded from https://www.voja.rs/galaksija/ROM%20B%20Listing%20Scans/ROM_B_listing.htm, then it has been converted to text using and LLM. Of course an intense manual work has been necessary to polish ocr results.

I have used this prompt in order to avoid short or uncomplete answers:
```
'I have a listing of z80 assembler. The typical line contains the address, the code of the instruction 
   in hexadecimal, the number of line, a label, a mnemonic of the instruction, the parameters of the 
   instruction and the comments. I want to convert it to text and translate into English the comments that
   are the end of the lines. Also put a ";" before the comment if it does not have it. please provide the 
   full listing and do not miss any column'
```

There are different vesions of ROM B and the difference resides in byte 0x1024 
| ROM name | Byte value |
|----------|------------|
|ROM_B_monitor_value_13.bin | 13 (0xD) |
|ROM_B.bin                  | 12 (0xC) |
|ROM_B_monitor_fix.bin      | 11 (0xB) |

It is possible to generate these different versions by changing MONITOR value in https://github.com/issalig/galaksija/blob/c4fe2ca97ec3fee1fa63ec4eee6fe38ad49fcf26/roms/rom_b.asm#L63

ROM B includes mathematical functions, machine code utils and some BASIC extensions. The table shows the list of available functions.

| Command | Description |
|---------|-------------|
| `SQR(x)` | Square root |
| `POW(x,y)` | Power, values non-zero |
| `PI` | 3.141... |
| `EXP(x)` | e^x |
| `LN(x)` | Logarithm |
| `SIN/COS/TG` | Trigonometric functions |
| `SIND/COSD/TGD` | Trigonometry for degree measure |
| `ARCTG(x)` | Arctg |
| `ABS(x)` | Absolute value |
| `DEL x, y` | Delete BASIC lines x..y |
| `REN x` | Renumber every X lines (e.g. REN 5 renames 5, 10, 15), but does not touch labels! |
| `"-operator` | A = 10 + "X" - ASCII value of "X". Generally, first character in ""-string |
| `PRINT% "x"` | Value of X in 4-character hex (&0058). PRINT% converts result to 4-digit hex value |
| `DUMP x, y` | Display memory content from X, for Y rows (1 row: 8 bytes) |
| `/word` | Search and show all program lines containing word |
| `INP(x)` | Get content of x port |
| `OUT(x, y)` | Emit byte y to port x. x,y 0..255, port 255 is Centronics expansion |
| `L...` | LPRINT, LLIST, LDUMP - commands to Centronics printer expansion |

Note: ROM B can be started with USR routine `X=USR(&1000)`. In some ROM versions it starts automatically.

# ROM C
ROM C is targeted to Galaksija Plus which is an improved version of Galaksija, with 256x208 monochrome graphics mode, 3-voice sound based on AY-3-8910 and 48 KiB RAM. 
This rom listing has been obtained from https://github.com/mejs/galaksija/blob/master/roms/ROM%20C/ROM%20C%20listing.pdf

It is worth to mention that it differs from https://github.com/mejs/galaksija/blob/master/roms/ROM%20C/ROM_C.bin

However the asm file includes an optional patch to match the original ROM_C.bin

```assembly
...
ROM_C_PATCH EQU 1 
...
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
```

# Other links

 - General info https://github.com/mejs/galaksija/blob/master/roms/

 - ROM B info https://www.dejanristanovic.com/refer/galrom2.htm

 - ROM files https://8bitchip.info/galaksija/rom.zip

 - More ROM files https://oldcomputer.info/8bit/galaksija/ROM.7z

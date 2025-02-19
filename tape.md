# Galaksija Computer Tape File Format (GTP)

## Overview

The Galaksija computer tape file format (.GTP) is used for storing programs and data on cassette tapes. The format consists of blocks, each containing metadata and program data.

## File Structure

A typical Galaksija tape file consists of one or more blocks (name, standard or turbo). 

### Name block

| Size (Bytes) | Description              |
| ------------ | ------------------------ |
| 1            | `10`                     |
| 2            | Data Length              |
| 2            | '00 00' Separator        |
| Variable     | File Name + `\0`         |


### Standard block

| Size (Bytes) | Description              |
| ------------ | ------------------------ |
| 1            | `00`                     |
| 2            | Data Length from (A5 to CRC) |
| 2            | `0000`                   |
| 1            | `A5` Magic Byte          |
| 2            | Start Address (typically 2C36)     |
| 2            | End Address + 1 (Start + Data Length)|
| 2            | BASIC (Start + 4)|
| 2            | End Address (Start + Data Length)    |
| Variable     | Program Data             |
| 1            | Checksum (CRC)           |

BASIC lines in the program data are coded as 
   - Line number
   - `00`
   - Text of the line
   - `0D`

### Checksum Calculation (CRC)

The CRC is computed as follows:
- It is the sum of all bytes from the **magic byte (`A5`) to the last data byte**, modulo 256.
- The result is then **two's complemented** to obtain the final CRC value.

### Turbo mode

It uses 0x01 as the first byte in the block. For more info look for "TURBO" in roms/rom_c.asm

## Example Breakdown
Tip: You can use GALe emulator (https://galaksija.net/) to write your programs and save them as GTP (without the the header). Just use "SAVE" command from BASIC and press Tape button at the bottom of the screen.

The following bytes correspond to this HELLO WORLD! program.
```basic
10 PRINT "HELLO WORLD!"
```
```
10 06 00 00 00 48 45 4c 4c 4f 00 00 21 00 00 00 a5 36 2c 51 2c 3a 2c 51 2c
0a 00 50 52 49 4e 54 20 22 48 45 4c 4c 4f 20 57 4f 52 4c 44 21 22 0d 53
```
First block contain name (this block is **optional** and this bytes are ignored until a5 in standard block is found.)
- `10` -  Name Block
- `06 00` - Length ( strlen("HELLO\0")=6)
- `00 00` - Separator
- `48 45 4c 4c 4f 00` - String terminated with \0 (HELLO)

Second block is a standard block with a program
- `00` - Standard Block
- `21 00` - Length (33 bytes from a5 to CRC)
- `00 00` - Separator
- `a5` - Magic byte
- `36 2c` - Start data address 0x2c36 for BASIC
- `51 2c` - End data address 0x2c51 (**next byte after program**)
- `3a 2c` - Start of code (0x2c36 + 0x04 (2 words = 4 bytes))
- `51 2c` - End of code 0x2c36 + (0x21 - 0x06)
- `0a` - Line number in decimal (10)
- `00 50 52 49 4e 54 20 22 48 45 4c 4c 4f 20 57 4f 52 4c 44 21 22 0d` - String (begins with \0 and ends with CR)
   - `   P  R  I  N  T     "  H  E  L  L  O     W  O  R  L  D  !  "`
- `53` - CRC

Load it with OLD and type DUMP &2C36,4. This will dump 4*8 bytes starting at the given address and we can check if everything is correct.
```basic
OLD
DUMP &2C36,4
&2C36:  3A 2C 51 2C 0A 00 50 52
&2C3E:  49 4E 54 20 22 48 45 4C
&2C46:  4C 4F 20 57 4F 52 4C 44
&2C4E:  21 22 00 00 00 00 00 00
```
The previous dump confirms that BASIC start and end pointers are correctly set.

|address | content |
|-------|------|
|2C36   | 2C3A |
|2C38   | 2C51 (**next byte after program**) |
|2C3A .. 2C50 | 0A 00 .. 0D |

Some operation tell us 0x2C51 - 0x2C3A =  0x17 -> 23 which is the program length
```asm
0A 00 50 52 49 4E 54 20 22 48 45 4C 4C 4F 20 57 4F 52 4C 44 21 22 00
```
I compiled this information from several sources:
 - https://github.com/z88dk/z88dk/blob/master/src/appmake/galaksija.c
 - https://github.com/mamedev/mame/blob/master/src/lib/formats/gtp_cas.cpp
 - https://oldcomputer.info/8bit/galaksija/buildlog.htm
 - https://fahrplan.events.ccc.de/congress/2012/Fahrplan/attachments/2250_prezentacija.pdf
 - gtpwav

OLD (Output LoaD?) is the command for loading data. Thus, looking at the roms, "OLD" function code is found in ROM A https://github.com/issalig/galaksija/blob/ea546a2fea61937e64ce2bfd1ef2ee66332b27ea/roms/rom_a.asm#L5473 and it reads the data from the cassette that is mapped/wire to address 0x2000 https://github.com/issalig/galaksija/blob/ea546a2fea61937e64ce2bfd1ef2ee66332b27ea/roms/rom_a.asm#L5611
```asm
;; LOAD_WAIT_PULSE
l0ee2h:
	add a,b		;0ee2	4	Add B' to A
	ld hl,02000h	;0ee3	10	Load cassette port address into HL'
 ```
## Tape Data Storage
This text is a translation of Tomaž Šolc thesis (page 55) and explains how data is recorded on the cassete.

Simple pulse modulation is used for storing data on the tape. The time diagram of the signal is shown in Figure 30, the information on the time intervals in Table 11, and the logical meaning of the individual stored bytes in Table 12.

A data transfer rate of approximately 330 bit/s is typically achieved. The choice of a simple modulation and low transfer rate is most likely due to the limited space for modulation and demodulation routines in the EPROM memory, as microcomputers with the same hardware and larger ROM memory achieve significantly higher transfer rates (for example, Sinclair Spectrum typically 1500 bit/s).

![imagen](https://github.com/user-attachments/assets/c14e8397-1778-408f-98d6-d34391841abf)

**Figure 30**: Timing diagram of the modulation used for storing data on magnetic tape

### Table 11: Values of symbols (for Figure 30)

| Symbol  | Comment | Min | Typical | Max | Unit |
|---------|---------|-----|---------|-----|------|
| tpos    | Duration of positive pulse | 140 | 650 | - | T us |
|         | | 45 | 210 | - | T us |
| tneg    | Duration of negative pulse | 650 | - | T us |
|         | | 210 | - | T us |
| tbase   | Duration of recording one bit | 7800 | 9200 | 16000 | T ms |
|         | | 2.5 | 3.0 | 5.2 | ms |
| tone    | Delay between 1st and 2nd pulse | 4400 | 4600 | 7400 | T ms |
|         | | 1.4 | 1.5 | 2.4 | ms |
| tbyte   | Duration of recording one byte | - | 74000 | - | T ms |
|         | | - | 24.0 | - | ms |
| tinterbyte | Delay between 2 bytes | 8200 | 13000 | - | T ms |
|         | | 2.7 | 4.3 | - | ms |

### Table 12: Meaning of individual bytes in the data record for storage on tape recorder

| Offset | Length | Comment |
|--------|--------|---------|
| 0x00   | 0x01   | Start byte (0xa5) (1010 0101) |
| 0x01   | 0x02   | Address of the first data byte (lowest address byte first) |
| 0x03   | 0x02   | Address of the last data byte + 1 (lowest address byte first) |
| 0x05   | N      | Data bytes |
| 0x05+N | 0x01   | Checksum (the number that needs to be added to the sum of previous bytes modulo 256 to get 0xff) |

### Table 13: Data part of the record when storing a BASIC program on tape recorder

| Address | Length | Content | Comment |
|---------|--------|---------|---------|
| 0x2c36  | 0x02   | 0x2c3a  | Address of the first byte of the BASIC program (lowest address byte first) |
| 0x2c38  | 0x02   | 0x2c3a+N | Address of the last byte of the BASIC program + 1 (lowest address byte first) |
| 0x2c3a  | N      | -       | BASIC program |

The operating system does not distinguish between storing data, machine code, and BASIC programs. The data structure in Table 12 only allows storing the contents of any part of the microprocessor's address space.

In the case of storing a BASIC program, the operating system stores data from address 0x2c36 to the end of the BASIC program on the tape recorder. When later loading the stored data, the system variables BASIC START and BASIC END at addresses 0x2c36 and 0x2c38 are overwritten, which allows the operating system to locate the loaded program.

## Notes:

### Working with a tape recorder

Galaksija is connected to the tape recorder with a transmission speed of 280 baud (280 bits are written to the tape every second). This speed guarantees reliability even though it is lower than that offered by some commercial models.

As an illustration of the reliability/speed problem, let a quote from the instruction manual of the BBC computer, which is advertised as one of the most complete and powerful desktop computers on the market: "the recording speed is 1300 baud, but we suggest that, when recording an important program, you enter the next command and thus reduce the speed to 300 baud...".

The basic memory of the Galaksija computer is not large, so recording on a cassette does not take too long, and the verification of the recording eliminates all other potential problems.

---
# ******************************
# YOU ARE ENTERING A WIP AREA!!!
# ******************************

TO-DO: Load from TZX (rcmolina maxduino, etc, ...
https://galaksija.net/
https://github.com/rcmolina/Elektronika-Galaksija


https://web.archive.org/web/20221228104534/https://www.tablix.org/~avian/galaksija/rom/rom1.html

---
### System Addresses of ROM 2

The following table presents a map of system variables for the "Galaksija" operating system, BASIC interpreter, and ROM 2. 

(see https://dejanristanovic.com/refer/galrom2.htm)

| Address | Bytes | Initially | Contents |
|---------|------|-----------|----------|
| 2800    | 512  | 20        | Video memory |
| 2A00    | 104  | 00        | Numeric variables A-Z |
| 2A68    | 2    | 2800      | Cursor position in memory |
| 2A6A    | 2    | 3800      | End of memory |
| 2A6C    | 2    | 00        | Number of HOME-protected bytes of video memory |
| 2A6E    | 2    | 00        | Exit criteria for FOR-NEXT |
| 2A70    | 16   | 00        | X$ |
| 2A80    | 16   | 00        | Y$ |
| 2A91    | 2    | 00        | Stack for the current loop |
| 2A93    | 2    | 00        | Current line position (during FOR-NEXT) |
| 2A95    | 2    | 00        | BASIC pointer (during CALL and FOR-NEXT) |
| 2A97    | 2    | 00        | Location to DUMP from |
| 2A99    | 2    | 00        | 16*ARR$+16 |
| 2A9B    | 2    | 00        | Address of NEXT variable |
| 2A9D    | 2    | 2C3C      | TAKE pointer |
| 2A9F    | 2    | 00        | Current line position |
| 2AA1    | 2    | 00        | Register for active FOR-NEXT |
| 2AA3    | 2    | 00        | Temporary SP, during CALL |
| 2AA5    | 2    | 00        | Keyboard differentiator |
| 2AA7    | 3    | 00        | Seed for RND |
| 2AAA    | 1    | 00        | Which pass through assembler (1 or 2) |
| 2AAC    | 1    | 00        | ČĆŠŽ become CCSZ in print code for bit7=0 |
| 2AAC    | 124  | 00        | Arithmetic accumulators (IX) |
| 2BA8    | 1    | 0C        | Horizontal text position |
| 2BA9    | 3    | C9        | Command link |
| 2BAC    | 3    | C9        | Video link |
| 2BAF    | 1    | 00        | If bit 7=1, the clock is running |
| 2BB0    | 1    | 00        | Image scroll counter |
| 2BB1    | 1    | 00        | Image scroll flag |
| 2BB2    | 1    | 00        | How many rows to DUMP |
| 2BB3    | 1    | 00        | OPT during assembly |
| 2BB4    | 1    | 00        | REPT register |
| 2BB5    | 1    | 00        | Printer flag |
| 2BB6    | 125  | 00        | Buffer |
| 2C36    | 2    | 2C3A      | BASIC start pointer |
| 2C38    | 2    | 2C3A      | End of BASIC pointer |
| 2C3A    | ??   | 00        | Program |

---

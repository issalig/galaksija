# New Galaksija

## 3.2.5 Tape Interface (p40)

The analog output of the tape interface is similar to that of the original Galaksija, using a simple digital-to-analog converter. The output voltages are dependent on resistors R25, R26, and R28.

Figure 22 shows a recording of the output signal (in this case, one synchronization byte) made with an analog-to-digital converter with a sampling rate of 44100 kHz.

The analog input consists of a pulse amplifier that acts as a simple analog-to-digital converter. The circuit topology is the same as that of the original Galaksija circuit, but the component values have been recalculated (see Appendix, page 65) since there was an error in the original design.

An example of the input and output signal of the amplifier for a single input pulse is shown in Figure 23.

**Figure 22**: Tape Interface Output Signal (Measurement)

**Figure 23**: Pulse Amplifier Input and Output Signal (SPICE Simulation)

## 5.6 Tape Data Storage (p55)

Simple pulse modulation is used for storing data on the tape. The time diagram of the signal is shown in Figure 30, the information on the time intervals in Table 11, and the logical meaning of the individual stored bytes in Table 12.

A data transfer rate of approximately 330 bit/s is typically achieved. The choice of a simple modulation and low transfer rate is most likely due to the limited space for modulation and demodulation routines in the EPROM memory, as microcomputers with the same hardware and larger ROM memory achieve significantly higher transfer rates (for example, Sinclair Spectrum typically 1500 bit/s).

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


### 
You can use GALe emulator to write your own programs and save them as GTP
00A5 362C 4C2C 3A2C 4C2C 0A00 5052494E5420225A445241564F21220D A3 FF

## Format
# Galaksija Computer Tape File Format

## Overview

The Galaksija computer tape file format (.GTP) is used for storing programs and data on cassette tapes. The format consists of blocks, each containing metadata and program data.

## File Structure

A typical Galaksija tape file consists of one or more blocks. 

### Name block

| Size (Bytes) | Description              |
| ------------ | ------------------------ |
| 1            | `10`                     |
| 2            | Block Length             |
| Variable     | File Name + `\0`         |


### Standard block

| Size (Bytes) | Description              |
| ------------ | ------------------------ |
| 1            | `00`                     |
| 2            | Data Length              |
| Variable     | Padding                  |
| 1            | Start Byte Marker (`A5`) |
| 2            | Start Address            |
| 2            | End Address (Start address + Data Length)|
| 2            | BASIC (Start address + len + 4)|
| 2            | End Address (Start + Data Length)    |
| Variable     | Program Data             |
| 1            | Checksum (CRC)           |

(see https://github.com/z88dk/z88dk/blob/master/src/appmake/galaksija.c)

### Turbo mode

Uses 0x01 value but I do not have more info.

### Checksum Calculation (CRC)

The CRC is computed as follows:
- It is the sum of all bytes from the **start address byte (`A5`) to the last data byte**, modulo 256.
- The result is then **two's complemented** to obtain the final CRC value.


10 06 00 00 00 48 45 4c 4c 4f 00 00 21 00 00 00 a5 36 2c 51 2c 3a 2c 51 2c 0a 00 50 52 49 4e 54 20 22 48 45 4c 4c 4f 20 57 4f 52 4c 44 21 22 0d 53

10 Name Block
06 00 Length (6)
00 00 Separator
48 45 4c 4c 4f 00 Name string terminated with \0 (HELLO)

00 Standard Block
21 00 Length (33)
00 00 Separator
a5 Magic byte
36 2c //
51 2c 
3a 2c 
51 2c 
0a Line number in decimal (10)
00 50 52 49 4e 54 20 22 48 45 4c 4c 4f 20 57 4f 52 4c 44 21 22 0d   \0 P  R  I  N  T     "  H  E  L  L  O  " CR
53 CRC


A5
2C36 //ORG address
2C36 + datalen //block end location
2C36 + 4+len //basic start
2C36 + datalen //block end location


## Example Breakdown


```
00 A5 36 2C 5E 2C 3A 2C 5E 2C 0A 00 50 52 49 4E 54 20 22 48 45 4C 4C 4F 22 0D 14 00 50 52 49 4E 54 20 22 47 41 4C 41 4B 53 49 4A 41 22 0D 69 2C
                              10    P  R  I  N  T     "  H  E  L  L  O  "     20    P  R  I  N  T     "  G  A  L  A  K  S  I  J  A  "  
```
- `00` - Block Type (Standard Data)
- `A5` - Start Byte Marker
- `36 2C` - Start Address (`0x2C36`)
- `4C 2C` - End Address (`0x2C4C`)
- `3A 2C` - Additional data separator
- `4C 2C` - Additional marker
- `0A 00` - Line Number (`10` in decimal), separator byte
- `50 52 49 4E 54 20 22 5A 44 52 41 56 4F 21 22` - Program Code (`PRINT "HELLO"` in ASCII)
- `14 00` - Line Number (`20` in decimal), separator byte
- `50 52 49 4E 54 20 22 47 41 4C 41 4B 53 49 4A 41 22` (`PRINT "GALAKSIJA"`in ASCII)
- `0D` - Carriage Return (End of Line)
- `A3` - Computed CRC Checksum
- `FF` - Possible additional padding or marker

### BASIC Program Explanation

The program contained in this example block is a simple **Galaksija BASIC** program:

```basic
10 PRINT "ZRAVO!"
```

- **10**: Line number of the BASIC program.
- **PRINT "ZRAVO!"**: Outputs the text "ZRAVO!" to the screen.
- **0D (Carriage Return)**: Marks the end of the line in the BASIC program.

## Additional Notes

- Some files may include an initial block containing metadata, such as a program name.
- The checksum (CRC) verification method follows a known pattern and can be computed manually for validation.
- Blocks may vary in size depending on the content.

## COMMANDS

OLD
SAVE


---

This document provides a foundation for understanding the Galaksija tape format. Further analysis is needed for full documentation.









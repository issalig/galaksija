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


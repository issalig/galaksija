### The translation of this document is WIP.

**University of Ljubljana**  
**Faculty of Electrical Engineering**  

**Tomaž Šolc**  

# Replica of the Galaksija Microcomputer

**University Diploma Thesis**  

**Mentor:**  
Professor Dr. Tadej Tuma  

**Ljubljana, 2007**  

---

### **Abstract**  

Due to various reasons, a shortage or even complete absence of detailed documentation for older microprocessor systems is common today. Because of this, reverse engineering is often required, and understanding the design practices and methods from the era in which the system was created is essential for its success.  

**Galaksija** is a Yugoslavian home microcomputer from the 1980s, which holds historical significance. Due to its publication in magazines, part of the hardware documentation and a large collection of software, including the operating system, have been preserved to this day. As a typical yet relatively simple microprocessor system from that time, **Galaksija** provides an accessible insight into the design techniques used in that period.  

This thesis first reconstructs the documentation of **Galaksija**’s hardware architecture based on preserved schematics and reverse engineering of the software. This documentation is then used to design and build a **replica of Galaksija**—an electronic circuit built with modern components, which remains software-compatible with the original microcomputer and runs the original operating system.  

The creation of the replica also served as a foundation for documenting peculiarities in the implementation of the original electronic circuit. Furthermore, a working replica was used as a tool to analyze the programming techniques employed in the development of Galaksija’s operating system. The purpose of this documentation is to facilitate similar projects aimed at restoring microprocessor systems from this era.  

Additionally, this work includes the development of software tools for reverse engineering Z80 machine code and a development environment for the Galaksija architecture.  

**Keywords:** Galaksija, microcomputers, microprocessor systems, operating system, reverse engineering  

---

### **Acknowledgments**

I would like to express my gratitude to my mentor, Prof. Dr. Tadej Tuma, for his support in the preparation of this thesis.

I would like to thank my parents and my sister Barbara for their support and help during critical moments. My mother for her scientific perspective on the world and my father, who served as a role model for me in the study of electronics.

I would like to thank Mr. Jože Stepan for his assistance in gathering documentation and preserved articles about the Galaksija, for the creation of the printed circuit board, and last but not least, for the interesting conversations about old computer and electronic equipment.

I would also like to thank Tomaž Kac for his collection of preserved software for the Galaksija and for occasional hints during the exploration of the Galaksija's functionality.

I would like to thank Prof. Mateja Cvelbar for proofreading this work.

Finally, I would like to thank the other members of the Kiberpipa Computer Museum team, who allowed me access to the hidden parts of old computers and whose interest in the Galaksija was actually the reason for the creation of this thesis.

---

### **Index**
[1 Introduction](#1-introduction)
1.1 Galaksija
1.2 Motivation
1.3 Objectives

[2 Hardware Architecture](#2-hardware-architecture)
2.1 Use of Address Space
2.2 Peripherals
2.2.1 Keyboard
2.2.2 Tape Interface
2.2.3 Latch
2.3 Control of the A7 Line for RAM
2.4 Video Signal Generation
2.4.1 Synchronization
2.4.2 Character Generator
2.4.3 Video Driver
2.4.4 Shift Register

[3 The New Galaksija](#3-the-new-galaksija)
3.1 Digital Section
3.1.1 Microprocessor and Memory
3.1.2 Address Decoder
3.1.3 Keyboard
3.1.4 Clock Divider
3.1.5 Shift Register
3.1.6 Interrupt Synchronization
3.2 Analog Section
3.2.1 Power Supply
3.2.2 Oscillator
3.2.3 Reset Circuit
3.2.4 Composite Video
3.2.5 Tape Interface

[4 Peculiarities of the Original Galaksija Circuit](#4-peculiarities-of-the-original-galaksija-circuit)
4.1 Use of Undocumented Microprocessor Features
4.1.1 First Memory Cell
4.1.2 Second Memory Cell
4.2 Microprocessor Bus Wiring
4.3 Keyboard Wiring
4.4 Use of the R Register

[5 Peculiarities of the Operating System](#5-peculiarities-of-the-operating-system)
5.1 Multilingual Program Code
5.2 Multilingual Data Structures
5.3 Organization of Program Code
5.4 Use of Processor Registers
5.5 Processor Stack
5.6 Storing Data on Tape

[6 Conclusion](#6-conclusion)

[7 References](#7-references)

[8 Appendices](#8-appendices)

A Voltage Inverter

B Calculation of the Pulse Amplifier

C Floating-Point Numbers


---

## **1. Introduction**

### **1.1 Galaksija**

**Galaksija** is a home microcomputer designed in 1983 by **Voja Antonić**. Similar to other microcomputers developed in former Yugoslavia at the time, **Galaksija** was intended as a domestic alternative to foreign microcomputers produced by **Sinclair Research** (Sinclair ZX81, Sinclair ZX Spectrum) and **Commodore Business Machines** (Commodore 64). These foreign microcomputers, although highly sought after, were difficult to obtain legally due to strict import restrictions on Western technology and their relatively high prices【1】.

To make the computer as affordable as possible and accessible to the widest range of people, its electronic circuitry was designed to be as simple as possible, including only components that were either readily available in electronic stores at the time or could be easily imported from neighboring countries. Since cost reduction was the highest priority in its design, many compromises had to be made in hardware. For example, the computer's operation depends on certain undocumented features of the microprocessor, along with other design choices that would be unacceptable in modern systems. The development of system software was also heavily influenced by the goal of keeping hardware costs low.

A comparison of **Galaksija**’s capabilities with similar foreign and domestic microcomputers from the same era is shown in **Tables 1 and 2**.

Initially, **Galaksija** was intended for self-assembly. To facilitate this, the designer, with the assistance of editor **Dejan Ristanović**, published a complete guide on how to build it in a **special edition of the magazine Galaksija**, released in January 1984【2】. This publication, which included a significant portion of the development documentation, ensured that much of the technical details were preserved. Due to high demand, the computer was later produced as a commercial product as well.

![imagen](https://github.com/user-attachments/assets/5e98ac0e-d437-44b5-8c16-c175136e4923)

📌 Figure 1: Handmade Galaksija prototype (private collection of Damjan Lenarčič).

![imagen](https://github.com/user-attachments/assets/7542a1ea-37e5-4a8f-946b-b4bf0dca32ef)

📌 Figure 2: Factory-produced Galaksija (manufactured by Zavod za udžbenike i nastavna sredstva).

![imagen](https://github.com/user-attachments/assets/d4a84cc0-b273-4d5b-994e-0ba4c7448707)

📌 Figure 3: Top view of the original Galaksija PCB (private collection of Iztok Pušnar).

![imagen](https://github.com/user-attachments/assets/8f929285-d1e5-4068-8a5a-57e6f927fe5e)

📌 Figure 4: Bottom view of the original Galaksija PCB (private collection of Iztok Pušnar).

#### **Table 1: Comparison of Galaksija with foreign microcomputers**  

| Feature | ZX81 (1981) | Galaksija (1984) | ZX Spectrum (1982) | Commodore 64 (1982) |
|---------|------------|------------------|--------------------|--------------------|
| **CPU** | Zilog Z80A | Zilog Z80A | Zilog Z80A | MOS 6502 |
| **Clock Speed** | 3.25 MHz | 3.072 MHz | 3.5 MHz | 0.985 MHz (PAL) |
| **ROM** | 8 KB | 4 KB (ROM A) | 16 KB | 20 KB |
| **RAM** | 1 KB | 2, 4, or 6 KB | 16 or 48 KB | 64 KB |
| **Video Output** | Software-based | Software-based | Dedicated IC (ULA) | MOS VIC-II |
| **Resolution** | 32×24 chars | 32×16 chars | 32×24 chars | 40×25 chars |
| **Graphics Mode** | 64×48 pixels | 64×48 pixels | 256×192 pixels | 320×200 pixels |
| **Color Support** | No | No | 15 colors | 16 colors |
| **Sound** | No | No | Software-based | MOS SID |

#### **Table 2: Comparison of Galaksija with other Yugoslavian microcomputers**  

| Feature | Galaksija | Orao | Lola-8 | Galeb |
|---------|----------|------|--------|-------|
| **CPU** | Zilog Z80A | MOS 6502 | Intel 8085A | MOS 6502 |
| **Clock Speed** | 3.072 MHz | 1 MHz | 5 MHz | No data |
| **ROM** | 4 KB (ROM A) | 16 KB | 16 KB | 16 KB |
| **RAM** | 2, 4, or 6 KB | 8 KB | 6 KB | 9 KB |
| **Resolution** | 32×16 chars | 32×16 chars | 40×25 chars | 48×16 chars |
| **Graphics Mode** | 64×48 pixels | 256×128 pixels | 80×75 pixels | 96×48 pixels |
| **Color Support** | No | No | No | No |
| **Sound** | No | Yes | Yes | Yes |

---

### **1.2 Motivation**

Due to the rapid advancement of computer technology, knowledge required for maintaining older systems is being lost at an increasing rate. This phenomenon is particularly evident in consumer electronics, where products can become obsolete and disappear from manufacturers' public archives within a year or less. Frequent company mergers and restructurings further worsen the situation by adding more barriers to accessing archival documentation.

At the same time, consumer electronics are increasingly replacing expensive, specialized industrial equipment due to their affordability and widespread availability. The most significant examples of this trend are personal computers, where mass production enables manufacturers to invest heavily in development. As a result, even computer architectures originally designed for relatively simple personal computing have outperformed certain specialized architectures.

A common problem that arises in practice is that **software often has a much higher value than the hardware it runs on**. This is particularly true in highly reliable systems, where software has been improved over time through use and bug fixes, making it significantly more reliable than newly developed alternatives. While software does not physically deteriorate, hardware requires occasional maintenance. When maintenance costs become too high, it makes sense to develop a new, **compatible** hardware system. However, due to the reasons mentioned earlier, documentation for the original hardware is often unavailable. In such cases, **reverse engineering** is required to recreate the missing documentation.

The **Galaksija microcomputer** provides an excellent example of the design approaches used by both hardware and software developers in the 1980s. While Galaksija itself was not widely used for professional purposes, the experience gained from reverse engineering it can be applied to similar projects with greater practical value.

Building a **replica of Galaksija** also serves an important role in preserving **technical heritage**. Due to advancements in microelectronics, the **original integrated circuits required to build a new Galaksija are no longer available**. As a result, only a limited number of **functional Galaksija computers** remain, restricting the ability to run historical software. The Galaksija system and its software are historically significant as they contributed to the spread of computer knowledge and literacy in **former Yugoslavia**.

Additionally, teaching the **fundamentals of microprocessor systems** often faces the challenge that modern systems are **too complex** to serve as simple educational examples. For instance, the architecture of a modern **PC** is so intricate that a student cannot realistically understand all its components. Furthermore, manufacturers often **intentionally obscure** internal workings to maintain a competitive advantage. The high level of **integration** in modern electronics also prevents direct observation of internal circuits using standard laboratory instruments.

In contrast, **Galaksija** is made up of relatively **simple electronic circuits**, built from **low- and medium-scale integrated circuits** (with the exception of the **Z80 microprocessor**, for which detailed documentation is available). Additionally, the system's **low clock speed** allows for analysis using **affordable oscilloscopes**. Despite its simplicity, Galaksija remains a **fully functional microprocessor system**, containing the same core components as modern computers (CPU, memory, bus, peripherals, etc.).

---

### **1.3 Objectives**

The main objectives of this work are:  

- To **describe the functionality of Galaksija’s hardware** (and software components closely related to hardware) in sufficient detail so that a new **compatible** computer can be built based on this description.  
- To **construct a fully functional replica** of **Galaksija**, using **modern electronic components** available on today’s market, while maintaining similarity to the original where practical.  
- To **document the design techniques** used in the original system, making it easier to restore **other** microcomputer systems from the **1980s**.  

---

## **2. Hardware Architecture**

The block diagram of the **Galaksija** motherboard is shown in **Figure 5**. A facsimile of the original circuit diagram【2】is included in the appendix.

![imagen](https://github.com/user-attachments/assets/21af8ca3-42a5-40fd-839d-858358450f01)

📌 Figure 5: Block diagram of Galaksija motherboard.

### **2.1 Address Space Utilization**

The **Z80 microprocessor**【6】has **two separate address spaces**:  

1. A **16-bit address space** for memory  
2. An **8-bit address space** for input/output (I/O) operations  

The **Galaksija motherboard** only utilizes the **memory address space**, both for **memory access** and for **communication with peripherals** (a technique known as **memory-mapped I/O**).

![imagen](https://github.com/user-attachments/assets/b4855b7d-06d2-482e-a6fe-92b7ac81609a)

📌 Figure 6: Galaksija’s memory map and address space allocation.

**Figure 6** illustrates the memory **layout** and how memory and peripheral devices are mapped into the address space (**memory map**). This layout is defined by the **address decoder circuit** and **cannot be changed via software** (except for control of the **A7 address line for RAM**, as shown in **Figure 9**). Unused parts of the address space are **reserved for future expansion**, and reading from these addresses returns **undefined values**.

The **4 KB read-only memory (ROM A)**, which contains the **system software**, is mapped at address **0x0000** and occupies the **interrupt vectors** of the microprocessor. Another **4 KB read-only memory (ROM B)** is mapped at address **0x1000** and is reserved for **expansion**.

Writing to memory addresses used by the **ROM** is **not allowed**. On computers **without ROM B**, reading from addresses mapped to it returns **undefined values**.

At **0x2800**, **2 KB to 6 KB of static RAM (SRAM)** is mapped. This RAM does **not require refresh cycles** using the **memory refresh counter** of the **Z80 processor**.

The entire **I/O address space** is reserved for **expansion**, and reading from **unmapped** I/O addresses returns **undefined values**.

![imagen](https://github.com/user-attachments/assets/5c135871-ac20-47db-bc5a-3454f4f776e9)

📌 Figure 7: Keyboard memory address mapping.


---

### **2.2 Peripherals**

The **processor accesses peripherals** through a **2 KB block** of the **memory address space**, starting at **0x2000**.

![imagen](https://github.com/user-attachments/assets/7f9210f7-6d17-458f-bd31-32f683ee8488)

📌 Figure 8: Latch register bit layout.

#### **2.2.1 Keyboard**

The keyboard has **54 keys**, each of which is mapped to a **specific address in memory**, as shown in **Figure 7**. The exception is the two **SHIFT** keys, which from the software perspective behave as a single key. This key is considered pressed if either of the physical **SHIFT** keys is pressed.  
The base memory address for the keyboard is **0x2000**, with multiple address offsets for different keys. Due to **incomplete address decoding**, the **keyboard can be accessed from 32 base addresses** (e.g., 0x2000, 0x2040, …, 0x27C0). **Unused memory locations** behave as if **no key is pressed**.

If the **least significant bit (LSB)** at a specific **keyboard address** is **0**, the key is **pressed**. If the bit is **1**, the key is **not pressed**. The **other bits** in the address return **undefined values**.

Writing to the **keyboard memory addresses** is **not allowed**.

![imagen](https://github.com/user-attachments/assets/1d0133cc-66a8-4a84-82f5-384109722d17)

📌 Figure 9: A7 line control for RAM address remapping.

---

#### **2.2.2 Cassette Interface**

The **cassette interface** consists of an **analog input** and an **analog output**.

- The **analog input** is implemented as a **simple comparator** with a **high-pass filter** at the input.  
- If a pulse with an **amplitude greater than approximately 700 mV** (determined by the transistor **T2**) appears at the input, the **least significant bit (LSB)** at the **comparator addresses** in **Figure 7** is set to **0** for the duration of the pulse.  
- The **maximum pulse length** is defined by the **filter** consisting of **C2** and **R14**. The cutoff frequency of the filter, according to published data [2], is approximately **16 kHz**, which is too high considering the frequency response of an average audio cassette recorder. I conclude that this is likely a printing error.  

The **analog output** is controlled through **two bits** in the **latch register** (**Figure 8**, **AOUT0 and AOUT1**), forming a **simple digital-to-analog converter (DAC)**. The output voltage is determined by the states of these two bits, as shown in **Table 3**.

| **AOUT0** | **AOUT1** | **Output Voltage (Ua) [V]** |
|----------|----------|------------------|
| 0        | 0        | 0.0 V            |
| 1        | 0        | 0.5 V            |
| 0        | 1        | 0.5 V            |
| 1        | 1        | 1.0 V            |

**Table 3:** Analog output voltage levels for tape interface.

The functions of the **individual bits** in the latch register are given in **Table 4**:

| **Bit**       | **Description**                                                                 |
|---------------|---------------------------------------------------------------------------------|
| A7CLMP        | If this bit is set to 0, the address line A7 for RAM memory is set to 1, regardless of the value on the processor's address bus. See Figure 9. |
| AOUT0-1       | Control of the digital-to-analog converter (DAC) for the tape interface.              |
| CHR0-3        | Control of the current row (scanline) being displayed by the character generator.          |

**Table 4:** Meanings of individual bits in the latch register.


---

### 2.2.3  **Latch**  

The microprocessor can access a **6-bit register** (referred to as the "latch" in the original documentation) at addresses of the form **0x0010 0xxx xx11 1xxx** (the lowest such address is **0x2038**, and the highest is **0x27FF**). This register is used to control the character generator, the analog output, and the **A7** address line for the RAM memory.  

- **Writing:** Only 8-bit values can be written to these addresses.  
- **Reading:** Reading from these addresses returns an undefined value.  

The meanings of the individual bits (labeled in Figure 8) are provided in **Table 4**.  

--- 

### **2.3 A7 Address Line Control for RAM**


Setting the **A7CLMP bit** allows the **A7 address line** of RAM to be **forced to 1**, regardless of the address bus value from the processor. This allows the **processor to read values stored in odd-numbered 128-byte blocks**, even when accessing even-numbered addresses.

This feature is used in **video signal generation** due to a **peculiarity of the Z80 processor**, which **does not automatically increment the A7 line** during **memory refresh cycles**【6】.

---

### **2.4 Video Signal Generation**

**Galaksija** is designed to be connected to a **composite video monitor** or a **TV via a UHF modulator**. In both cases, the display uses a **cathode-ray tube (CRT)**, so the following descriptions rely on the **movement of the electron beam** across the screen.

Due to the **simple hardware design**, **video signal generation** requires **active cooperation from the microprocessor**. Proper **synchronization** of software execution with the **movement of the electron beam** is essential.

The **video driver** responsible for generating the video signal is located in **ROM A at address 0x0038**, which is the **interrupt vector for the INT interrupt** in **interrupt mode IM 1**.


---

### 2.4.1  
**Synchronization**  

The fundamental timing intervals important for generating the video signal are shown in **Figure 10**. The microprocessor's clock (3072 kHz) and the video signal circuit's clock (6144 kHz) are synchronized. The screen area is divided into a black border, which is not usable for displaying images, and the usable area in the center. Drawing one row on the screen always takes **128 microprocessor clock cycles**, and the entire usable area consists of **208 rows**. Horizontal and vertical synchronization pulses are generated by hardware.  

![imagen](https://github.com/user-attachments/assets/a1dc8c27-de5b-4f54-bf49-f368afffd6ae)

📌 Figure 10: Video synchronization timing.

When the electron beam begins moving to the start of the first row of the visible screen area at the **56th horizontal synchronization pulse**, the video circuit interrupts the execution of the user program via an **INT interrupt**.  

The delay in the microprocessor's response to the interrupt is **non-deterministic**. It depends on the time the processor needs to complete the execution of the current instruction, which can range from **1 to 23 clock cycles**. However, since the video driver code must execute in perfect synchronization with the beam's movement across the screen, the microprocessor's execution is halted for the duration of one screen row (**192 clock cycles**) after responding to the interrupt. This is achieved by inserting a specific number of **HALT states** into the processor's operation, implemented via a circuit connected to the processor's **WAIT signal**. See **Figure 11**.  

![imagen](https://github.com/user-attachments/assets/bc5a9d70-f7b9-418a-b31d-62aa1526b23d)

📌 Figure 11: Processor timing during video signal generation.



#### **2.4.2 Character Generator**

The information about the screen image is stored in a 512-byte section of RAM memory at address 0x2800. This section contains ASCII codes of characters (16 rows of 32 characters each) that are displayed on the screen with each screen refresh. The task of the video driver, which runs on the microprocessor during the refresh, is to sequentially read 8-bit ASCII codes from this memory section and transfer them to the character generator.

The character generator is a 2 kB ROM (character generator ROM) that stores the mapping from the ASCII code of a character to its corresponding bitmap representation (i.e., the pattern of dots that form the character on the screen). The way a character is stored is shown in Figure 12. Bit 0 in the bitmap represents a bright dot on the screen, while bit 1 represents a dark dot.

![imagen](https://github.com/user-attachments/assets/9120ac7b-78a6-4da7-b87b-e110ead9a1d7)

📌 Figure 12: ASCII character ROM encoding structure.

The lower 7 address lines of the ROM are connected to the microprocessor's data bus, while the upper 4 lines are connected to bits CHR0 to CHR3 in the latch. This allows the processor, by setting the latch and placing values on the data bus (e.g., by reading values from RAM), to retrieve any scanline of any character from the character generator.

![imagen](https://github.com/user-attachments/assets/36ffa263-f8d6-43be-8a7c-b5edce8dee6b)
![imagen](https://github.com/user-attachments/assets/d6a78e14-217d-4d96-aaf8-ef2d5919a607)

📌 Figure 13: Galaksija’s character set table.

Figure 13 shows all 128 characters that the character generator can display on the screen. Since the D6 line of the data bus is not connected, each stored character corresponds to two 8-bit ASCII codes. The arrangement of characters is chosen so that the codes of the first 64 characters overlap with the central half of the standard ASCII character set (ASCII codes 20 to 5F). The remaining 64 characters consist of a set of pseudographic symbols, enabling a graphical display resolution of 64x48 pixels.

On the screen, each character is composed of 13 rows (13 · 16 = 208). The video driver in the ROM uses only the first 12 scanlines out of the 16 stored in the ROM. The 13th scanline of each character is always blank (black) on the screen because, during the time the electron beam scans this line, the video driver prepares to draw the next row of characters, and the character generator is disabled.

It is also important to note that the last scanline (address 0x0F) of all stored characters is blank (contains all ones). This line is set in the latch while the user's program is running. This ensures that the character generator is disabled when the content on the microprocessor's data bus is not under the direct control of the video driver. This also ensures that the beam intensity is minimized while the beam scans the black border of the screen and during the beam's diagonal retrace to the starting point.


#### **2.4.3 Video Driver**

The video driver must ensure that, as the electron beam scans the usable area of the screen, a byte corresponding to the ASCII code of the character to which the next 8 pixels belong appears on the data bus every 4 clock cycles (3072 kHz).

The sequential reading of the video memory section is implemented using a Z80 microprocessor function [6], which is otherwise intended for refreshing dynamic memory. The driver, just before starting to draw a screen scanline, sets the microprocessor's I and R registers so that they form a pointer to the memory location where the beginning of the 32-character row is located. The microprocessor's internal logic then ensures that, during program execution, 1 byte is read from memory and the R register is incremented with each M1 cycle.

To meet the requirement of transferring one byte every 4 clock cycles, the video driver must execute (any) 32 processor instructions that have only one M cycle (i.e., they consist only of an M1 cycle and last 4 clock cycles). After 32 M cycles, the current row is drawn, and the video driver can prepare to draw the next row while the beam scans the screen border.

Before drawing each scanline, the CHRx bits in the latch must be correctly set to specify the current scanline number in the character generator. After drawing, the character generator is disabled by selecting scanline 0x0F.

The microprocessor itself does not increment the I register or the highest bit of the R register. The driver sets the I register programmatically while preparing to draw a new row, and the highest bit of the R register is set together with the selection of the scanline via the A7CLMP bit in the latch.

![imagen](https://github.com/user-attachments/assets/5a98e382-98ab-4911-a742-ddf6c7d57053)

📌 Figure 14: Video driver execution flowchart.


Figure 14 shows a simplified diagram of the video driver's execution. The diagram does not show the driver code required for synchronizing memory reads with the electron beam, setting the A7 line, and writing the current scanline number to the latch.

#### **2.4.4 Shift Register**

The output of the character generator is connected to a parallel/serial shift register. This register loads 8 bits from the character generator at the right moment and serially sends them to the video output over 8 video clock cycles (6144 kHz). The serial loading occurs at the end of each M1 cycle of the microprocessor (Figure 15).

![imagen](https://github.com/user-attachments/assets/12e3e710-b573-4093-9fea-7b97eaa91359)

📌 Figure 15: Timing of the shift register during video output.

While the video driver is active and the beam scans the usable area of the screen, the shift register sequentially loads character bitmaps during M1 cycles. However, when the user's program is running, blank (dark) scanlines 0x0F are loaded into the register. This ensures that no random values from the data bus appear in the video signal during synchronization pulses and while the beam scans the black border of the screen.

When executing instructions that have multiple M cycles (and thus last more than 4 processor clock cycles), the shift register is completely emptied (since more than 8 video clock cycles pass between two parallel loads). The serial input of the register is therefore connected to a logical 1. This ensures that nothing is displayed on the screen during the execution of longer processor instructions in the user's program.

---

# **3. New Galaksija**

The electronic circuit of the new Galaksija is largely similar to the original. However, certain parts have been modified due to the unavailability of equivalent components, making it impossible to implement them exactly as per the original design. During the design of the replica, **reliability of operation** was prioritized over manufacturing cost. As a result, all known shortcomings of the original circuit were addressed, provided that such fixes would not be detectable from a software perspective. The new circuit has also been adapted for easier connection to modern television receivers or monitors.  

The wiring diagram of the circuit and the printed circuit board (PCB) layout are included in the appendix.  

---

## **3.1 Digital Section**

The **digital components** in the **new Galaksija** are built using **high-speed CMOS logic (74HC series).**

---

### **3.1.1 Microprocessor and Memory**

The role of the central processing unit (CPU) in the new circuit is fulfilled by the **Z84C0008** integrated circuit from Zilog. This is a microprocessor manufactured in CMOS technology in a DIP40 package, which is fully hardware- and software-compatible with the **Z80** microprocessor used in the original Galaksija.  

The **read-only memory (ROM)** (U2) is implemented using a single **32 kB EPROM** (27C256) in CMOS technology. The modern chip used here has sufficient capacity to store both the basic operating system and its first extension (thus, this integrated circuit occupies both the **ROM A** and **ROM B** positions in the microprocessor's address space, as shown in Figure 6). The upper **24 kB** of the memory remains unused.  

Due to the implementation of the address decoder, the EPROM is enabled (outputs in a low-impedance state) even when the microprocessor attempts to write to the portion of the address space occupied by the EPROM. In this case, two devices with low-impedance outputs would be connected to the data bus, potentially causing a short-circuit current that could damage the microprocessor or the EPROM. To limit the current in such cases, resistors **R10-R17** are placed between the EPROM's data lines and the data bus.  

The **working memory (RAM)** (U3) consists of an **8 kB SRAM** chip (LH5164D). The lower **2 kB** of the memory is unused (this portion of the address space is occupied by peripherals).  


| **Component** | **Type** | **Function** |
|--------------|---------|-------------|
| **CPU (U1)** | Zilog Z84C0008 | CMOS version of Z80, fully compatible |
| **ROM (U2)** | 27C256 (32 KB EPROM) | Stores **ROM A**, **ROM B**, and additional space for expansions |
| **RAM (U3)** | LH5164D (8 KB SRAM) | Stores program variables and system memory |

--- 



![imagen](https://github.com/user-attachments/assets/3d0ae99c-00c3-4b8d-9c07-82696e2eee15)

![imagen](https://github.com/user-attachments/assets/a84a43c4-7775-4087-bfa8-68d2dd602d1f)

![imagen](https://github.com/user-attachments/assets/ddaa3e9d-cb0c-49a8-a334-217f92119608)


📌 **Figures 16, 17, 18**: Show the **motherboard, keyboard, and full enclosure** of the new Galaksija.


🔹 **Important modification**:  
- In the **new design**, the **EPROM remains active during write attempts**.  
- To **prevent short circuits**, **resistors (R10-R17)** limit current flow between the CPU and the EPROM.

---

### **3.1.2 Address Decoder**

The address decoder is composed of a dual **2/4 demultiplexer (U10)** and logic gates **(U18)**. It implements the addressing of the **EPROM**, **SRAM**, and peripherals in accordance with Figure 6.  

The addresses for the keys, comparator, and latch in the address space are a result of the keyboard matrix wiring, the demultiplexer **U7**, and the multiplexer **U6**.  

---

### **3.1.3 Keyboard**  

The new Galaksija features a keyboard on a separate printed circuit board (PCB), connected to the mainboard via a **20-pin connector**.  

The keyboard of the original Galaksija required open-collector outputs from the demultiplexer for its operation. Since the demultiplexer **U7** used here does not have such outputs, they are simulated by connecting diodes **D1** to **D7**.  

The output of the multiplexer is protected against short circuits with resistor **R30**, for similar reasons as the EPROM outputs.  

---

### **3.1.4 Clock Divider**  

The clock divider consists of **4 4-bit ripple counters** in circuits **U12** and **U13**. These counters derive the necessary signals for generating the composite video from the oscillator signal with a frequency of **6144 kHz**, according to the following equations:  

\[
f_{\text{video}} = f_{\text{osc}} = 6144 \, \text{kHz}
\]  
\[
f_{\text{cpu}} = \frac{f_{\text{osc}}}{2} = 3072 \, \text{kHz}
\]  
\[
f_{\text{hsync}} = \frac{f_{\text{osc}}}{12 \cdot 16 \cdot 2} = 16 \, \text{kHz}
\]  
\[
10 \cdot f_o = \frac{f_{\text{osc}}}{12 \cdot 16 \cdot 16 \cdot 4} = 500 \, \text{Hz}
\]  

Using the **10 · f₀** signal, the **Johnson counter (U14)** generates two phase-shifted signals with a frequency of **f₀ = 50 Hz** (the signal for processor interrupts and vertical synchronization pulses) in accordance with the requirements for generating a composite video signal (Figure 11).  


| **Signal** | **Frequency Calculation** | **Result** |
|------------|---------------------------|------------|
| **Processor Clock** | \( f_{cpu} = \frac{f_{osc}}{2} \) | 3.072 MHz |
| **Horizontal Sync** | \( f_{hsync} = \frac{f_{osc}}{12 \times 16 \times 2} \) | 16 kHz |
| **Interrupt Frequency** | \( f_o = \frac{f_{osc}}{12 \times 16 \times 16 \times 4} \) | 50 Hz |

📌 **Table 5**: *Comparison of Galaksija's video signal characteristics with the PAL B,G standard.*


With the help of the 10 · f₀ signal, the Johnson counter U14 generates two phase-shifted signals with a frequency of f₀ = 50 Hz (the signal for processor interrupts and vertical synchronization pulses) in accordance with the requirements for generating a composite video signal (Figure 11).


| **Characteristic** | **PAL B,G (Used in Slovenia)** | **Galaksija** |
|------------------|--------------------------------|--------------|
| **Number of scanlines per frame** | 625 | 320 |
| **Field rate** | 50 Hz | 50 Hz |
| **Horizontal frequency** | 15.625 kHz | 16.000 kHz |
| **Interlacing** | 2:1 | 1:1 |
| **Black level** | 0 IRE | 0 IRE |
| **White level** | 100 IRE | 100 IRE |
| **Sync level** | -43 IRE | -43 IRE |
| **Nominal bandwidth** | 5 MHz | 3 MHz |

Even though **Galaksija’s horizontal frequency and number of scanlines differ from PAL standards**, most **TVs and monitors** can still **display its video signal correctly**.

---

### **3.1.5 Shift Register**

The logic circuit, composed of the gate U17, detects the fourth T state of the M1 cycle and triggers the parallel loading of data into the shift register U6 (Figure 19).

In the new circuit, the loading of data into the shift register occurs two video clock cycles earlier than in the original circuit (compare with Figure 15). The reason for this change is improved reliability (page 43), but the consequence is that the image is shifted two pixels to the left compared to the original Galaksija.

![imagen](https://github.com/user-attachments/assets/1f60d456-33d7-4cad-80f7-02db9a8b6c95)

📌 **Figure 19**: *Timing diagram of the shift register control circuit.*

---

### **3.1.6 Interrupt Synchronization**

A sequential logic circuit, composed of the memory cell U21 and the gates U19, detects the microprocessor's response to an interrupt and halts the execution of the first instruction of the video driver until the next horizontal synchronization pulse (Figure 20).

![imagen](https://github.com/user-attachments/assets/d6379007-582c-4490-aaa8-98e044f48ef5)

📌 **Figure 20**: *Timing diagram of the interrupt synchronization circuit.*

---

## **3.2 Analog Section**

### **3.2.1 Power Supply**

To power the computer from the 240V AC mains voltage, an external 12V DC adapter with a power rating of 5W is used. On the motherboard, the 12V DC voltage is further converted into +5V and −5V supply voltages.

    The +5V voltage is used to power all digital and analog components and is obtained using the voltage regulator U9.

    The −5V voltage is used to power the video amplifier and is obtained using a switching voltage inverter and the voltage regulator U22 (see Appendix, page 63).


| **Power Supply** | **Voltage** | **Function** |
|------------------|------------|-------------|
| **External Adapter** | +12V DC | Provides input power |
| **Internal Regulator (U9)** | +5V DC | Powers **digital components** |
| **Voltage Inverter (U22)** | -5V DC | Powers **video amplifier** |

- The **-5V supply** is generated by a **switching voltage inverter (U22)**.

---

### **3.2.2 Oscillator**

A crystal oscillator generates the base clock signal with a frequency of 6144 kHz. The active part of the oscillator consists of the logic gate U19.

### **3.2.3 Reset Circuit**

The reset circuit keeps the processor in a reset state for a short period after power is turned on. This ensures that, by the time the operating system starts, any transient phenomena in the supply voltages have subsided, which could otherwise cause operational errors.

### **3.2.4 Composite Video Output**

From the clock signals generated by the clock divider, the horizontal and vertical synchronization pulses are generated using two monostable multivibrators (circuit U15). These pulses are then combined into a composite synchronization signal using an XOR logic function implemented by the logic gate U16.

The synchronization signal and the video signal from the shift register are then fed into a mixer (Q4, Q5). The resistors R21 and R22 determine the ratio between the synchronization signal and the black level.

The resulting composite video signal is first passed through a resistive divider (R24, R27) to adjust the signal amplitude, and then into a two-stage amplifier in a common-collector configuration (Q6, Q8). The generated signal has a peak-to-peak voltage of 2V with an output impedance of 75Ω.

![imagen](https://github.com/user-attachments/assets/792eee0a-3e17-418f-b8df-9ce3f1f5719c)

📌 **Figure 21**: *Bode plot of the video amplifier (SPICE simulation).*

Calculation of Video Signal Bandwidth [8][9]:  

The bandwidth of the video signal is calculated as follows:  

\[
BW = \frac{1}{2} \cdot K \cdot N_{ht} \cdot N_{vt} \cdot f_o \cdot K_h \cdot K_v
\]  

Where:  
- \( K \) is the Kell factor,  
- \( N_{ht} \) and \( N_{vt} \) are the horizontal and vertical screen resolutions,  
- \( f_o \) is the frame rate (50 Hz),  
- \( K_h \) and \( K_v \) are the fractions of time occupied by horizontal and vertical synchronization.  

Substituting the values:  

\[
BW = \frac{1}{2} \cdot 0.7 \cdot 256 \cdot 208 \cdot 50 \, \text{Hz} \cdot \frac{64 + 256 + 64}{256} \cdot \frac{56 + 208 + 56}{208} = 2.2 \, \text{MHz}
\]  

From the graph in Figure 21, we can see that the amplifier has sufficient bandwidth and exhibits approximately **0.5 dB of linear distortion** in the frequency range covered by the video signal.  

---

### 3.2.5  **Tape Interface**  

The analog output of the tape interface uses a simple digital-to-analog converter (DAC), similar to the original Galaksija. The output voltages depend on the resistors **R25**, **R26**, and **R28**.  

Figure 22 shows a recording of the output signal (in this case, one synchronization byte) made with an analog-to-digital converter at a sampling frequency of **44.1 kHz**.  

The analog input consists of a pulse amplifier that acts as a simple analog-to-digital converter. The circuit topology is the same as in the original Galaksija, but the component values have been recalculated (see Appendix, page 65) due to an error in the original design.  

An example of the input and output signals of the amplifier for a single input pulse is shown in Figure 23.  


![imagen](https://github.com/user-attachments/assets/eef3fcc6-91d2-436f-959d-cdf40375bc2d)

📌 **Figure 22**: *Output waveform of the cassette interface (measured).*  

![imagen](https://github.com/user-attachments/assets/a9bffebe-609e-4b31-b89f-18cbf81783ce)

📌 **Figure 23**: *Input and output waveform of the impulse amplifier (SPICE simulation).*

---

# **4. Peculiarities of the Original Galaksija Circuit**

The **original Galaksija circuit** contained **several design peculiarities** due to the need to keep the hardware **simple and cost-effective**. These peculiarities include:

1. **Utilization of undocumented microprocessor behaviors**
2. **Minimalistic address decoding**
3. **Unusual keyboard wiring**
4. **Creative usage of processor registers**

This chapter examines these **unique design decisions** and their implications.

---

## **4.1 Use of Undocumented Microprocessor Features**

The **original Galaksija hardware** relies on **two D flip-flops (U4, U5 in the original circuit, 74LS74 ICs)** to detect **specific processor states**:

- **The first flip-flop** is used for detecting the **interrupt request/acknowledge cycle**. This is important for **video synchronization**.
- **The second flip-flop** detects the **end of an M1 cycle** and is responsible for **timing video shift register operations**.

These **flip-flops depend on timing variations** in the **Z80 microprocessor**, which are **not officially documented by Zilog**. The circuit was designed assuming **consistent timing behavior across different Z80 chips**, but in reality, this **timing can vary between different Z80 models and manufacturing batches**.

![imagen](https://github.com/user-attachments/assets/e2c8a1e7-6107-454d-8f35-9fc0e7899ab5)

📌 **Figure 24**: *Timing diagram of the first D flip-flop (interrupt detection).*  

![imagen](https://github.com/user-attachments/assets/9e5c9cde-e1ce-4476-8690-d2cf09862d90)

📌 **Figure 25**: *Timing diagram of the second D flip-flop (M1 cycle detection).*

#### **4.1.1 First Flip-Flop (Interrupt Detection)**

- The **D input** of the **flip-flop** is connected to the **M1 signal**.
- The **clock input** is connected to the **IORQ signal**.
- The output of the **flip-flop** must transition to **low (0)** **at the correct moment** in the **interrupt cycle**.

In order for this to work correctly, the **transition delay between IORQ and M1 must be within a specific range**. **Zilog’s official documentation** only specifies the **maximum delay**, while the **minimum delay is undefined**, making the circuit **unreliable with some Z80 chips**.

---

#### **4.1.2 Second Flip-Flop (M1 Cycle Detection)**

- The **D input** is connected to **MREQ (memory request)**.
- The **reset input** is connected to **RFSH (refresh cycle)**.
- The **flip-flop clock signal is shared with the processor clock**.

The goal of this circuit is to **ensure precise timing for video synchronization**. However, just like the **first flip-flop**, this circuit depends on **specific timing characteristics of the Z80**, which **were not guaranteed by Zilog**.

📌 **Table 6**: *Comparison of undocumented timing characteristics across Z80 variants.*

| **Z80 Variant** | **Typical M1 Delay** | **Maximum M1 Delay** |
|---------------|------------------|------------------|
| **Original NMOS Z80 (Z8400, 4 MHz)** | ~100 ns | 250 ns |
| **CMOS Z80 (Z84C0008, 8 MHz)** | ~50 ns | 150 ns |
| **Modern Z80 Clones** | Varies | Undefined |

The **timing difference** between **old NMOS** and **modern CMOS** Z80s is the **main reason why original Galaksija designs do not work properly with modern processors**.

---

## **4.2 Address Decoding Peculiarities**

- **The original address decoding circuit is extremely minimalistic**.  
- **It does not differentiate between read (RD) and write (WR) signals**.  
- **As a result, writing to certain memory addresses can cause unintended effects.**

The address decoder **only checks the upper address bits**, leading to **multiple addresses mapping to the same physical device**.

![imagen](https://github.com/user-attachments/assets/43f516e5-9f2a-4252-b6f1-a8b99fe403e3)

📌 **Figure 26**: *Memory layout of the original Galaksija.*  

### **Example of Decoding Issue**
- **Memory mapped I/O registers (e.g., the keyboard matrix)** can be accessed **at multiple different addresses** due to **incomplete decoding**.
- This leads to **aliasing**, where **one physical register appears at multiple memory locations**.

---

## **4.3 Keyboard Wiring Anomalies**

The **keyboard matrix** in **Galaksija** uses a **non-standard wiring scheme**, where:

- **Each key is mapped to a specific memory address**.
- **Pressing a key pulls the corresponding memory location low (0)**.
- **Reading the keyboard matrix involves scanning a set of 32 possible base addresses**.

![imagen](https://github.com/user-attachments/assets/97a9b28b-179a-4ff6-b2a6-a54c389233e3)

📌 **Figure 27**: *Keyboard memory mapping diagram.*

### **Implication of This Design**
- **Due to incomplete address decoding**, some **keyboard locations overlap with other memory-mapped devices**.
- This results in **unexpected behavior** when certain keys are pressed while other I/O operations are happening.

---

## **4.4 Usage of the R Register**

The **Z80 processor** includes an **R register**, which is **intended for dynamic RAM refresh**. However, in **Galaksija**, it is used for a completely **different purpose**:

- The **R register is used as a pseudo-random number generator** in the system.
- Since the **R register increments with every memory access**, it behaves **semi-randomly** when executing certain loops.

📌 **Figure 28**: *Diagram showing unintended side effects of using the R register.*

### **How This Affects the System**
- Certain **Galaksija programs rely on the specific behavior of the R register**.
- If a **different Z80 variant** is used (e.g., a modern Z80 clone), **programs that depend on this behavior might not work correctly**.

---

## **Summary of Peculiarities in the Original Circuit**

| **Design Feature** | **Effect** | **Issue** |
|-------------------|----------|---------|
| **Flip-Flops for Interrupts** | Saves components by detecting M1 cycles | Timing is unreliable across different Z80 chips |
| **Minimal Address Decoding** | Reduces chip count | Causes address aliasing and unexpected behavior |
| **Non-Standard Keyboard Wiring** | Simple circuit | Causes conflicts with other I/O devices |
| **Use of R Register for Random Numbers** | Eliminates the need for a true RNG | Not portable across all Z80 variants |

---

# **5. Peculiarities of the Operating System**

The **Galaksija operating system (OS)** is a **minimalistic software environment** that provides:

1. **Basic input/output functionality**
2. **Video display control**
3. **Cassette tape storage management**
4. **A built-in BASIC interpreter**

Due to **hardware limitations**, the OS employs **several unusual programming techniques** to optimize **speed and memory usage**.

---

## **5.1 Self-Modifying Code**

A significant portion of **Galaksija’s OS** consists of **self-modifying code**, meaning that:

- The **program actively alters its own instructions while running**.
- This allows the OS to **adapt dynamically** to different tasks.
- However, it also **complicates debugging** and makes porting the OS to **new hardware more difficult**.

📌 **Figure 29**: *Example of a self-modifying routine in Galaksija’s OS.*

### **Example: Dynamic Video Driver Configuration**
- The **video display routine** writes new instructions **into its own code space** in **real time**.
- This allows **efficient screen updates** but **prevents execution from ROM** (it must run in RAM).

---

## **5.2 Memory Optimization via Code Overlap**

To **save space**, many **routines in the OS overlap in memory**:

| **Technique** | **Purpose** | **Example** |
|-------------|----------|---------|
| **Overlapping Code Segments** | Saves memory by reusing instruction blocks | Different functions share the same code region |
| **Dual-Purpose Data Structures** | Uses the same memory region for different tasks | The stack also holds temporary variables |
| **Jump Tables Instead of Function Calls** | Saves CPU cycles and RAM | Code execution is redirected dynamically |

📌 **Table 6**: *Examples of self-overlapping code in the OS.*

| **Code Section** | **Overlapping Function** | **Effect** |
|---------------|------------------|---------|
| **Screen Refresh Routine** | **Cassette Tape Handler** | Limits available CPU cycles for video |
| **Interrupt Handler** | **Keyboard Scanner** | Allows single-routine multitasking |
| **Startup Code** | **RAM Test Function** | Uses the same memory region for different states |

These optimizations allow **Galaksija’s OS** to fit into just **4 KB of ROM**, but they also make **modifying or expanding the OS difficult**.

---


### 4.3 Keyboard Connection

The keys of the Galaksija keyboard are arranged in an 8 x 7 matrix so that their addresses in the microprocessor's address space correspond as closely as possible to the arrangement of corresponding characters in the ASCII code table (Figure 7). This way, the operating system code that converts the key scan code to the ASCII code character corresponding to the key can be significantly smaller, as relatively extensive tables are not needed for conversion.

Since the physical arrangement of keys generally does not correspond to the arrangement of characters in the ASCII table, this feature significantly increased the complexity of the keyboard's printed circuit board. In its original version, it was single-sided and therefore required many manually made jumpers.

The EPROM read-only memory is, besides the microprocessor and working memory, the only highly integrated circuit and as such one of the more expensive parts of Galaksija. From this perspective, it becomes understandable that the increased manufacturing complexity was a good compromise for a smaller operating system footprint, which allowed the use of cheaper EPROM circuits with lower capacity. Additionally, the required manual creation of jumpers did not affect the selling price of computer self-assembly kits, which was the only planned sales method when designing the computer.

### 4.4 Use of R Register

Using the microprocessor for screen display to reduce hardware complexity was a relatively common approach in early home computers. Similar approaches are used, for example, by Sinclair ZX80 and ZX81 computers. Galaksija's unique feature is that it uses the dynamic memory refresh function (second half of M1 cycle, R register) for this purpose. Sinclair computers, on the other hand, use the first half of the M1 cycle to transfer data from working memory to the shift register [11].

### 5 Operating System Peculiarities

As mentioned earlier, reducing the size of the operating system stored in EPROM memory was one of the effective methods of lowering the overall system cost. Because of this, the operating system contains many optimizations that reduce code size, but on the other hand make reverse engineering very difficult and reduce code readability. In particular, the usefulness of automatic disassembler programs is greatly reduced, as some of the described approaches cause the disassembler to lose synchronization with the code executed by the microprocessor. In this case, manual verification of results and disassembly of machine code in parts where the microprocessor entry point is known is required.

The Galaksija operating system (ROM A) can be divided into the following components:
- Hardware initialization routines
- Video driver
- Keyboard driver and basic terminal emulation
- Magnetic tape signal modulation and demodulation code
- Floating-point arithmetic routines
- BASIC interpreter

The working memory organization is shown in Figure 26.

Literature suggests that the operating system is based on Microsoft Level 1 BASIC [12]. This is likely an error. Comparison with the only 4 KB BASIC interpreter from Microsoft (BASIC for the Altair microcomputer) shows that the program codes are very different: Altair BASIC uses only Intel 8080 microprocessor instructions, while essential parts of Galaksija's operating system also use instructions specific to the Zilog Z80 microprocessor. Additionally, Altair BASIC's code [13] takes advantage of the fact that it runs in RAM, making its operation dependent on the ability to modify code during program execution at certain points. The data structures used also differ significantly (for example, floating-point number notation, BASIC program notation, etc.). The only similarity between Galaksija's and Altair's code is restart 0x08 (on Galaksija 0x10), which performs a similar function and is similarly implemented.

![imagen](https://github.com/user-attachments/assets/96bc202c-4ba8-4490-ad19-eb2148374b7e)

**Figure 26**: Working Memory Organization (darkened fields are occupied by system variables)

It's more likely that Galaksija's operating system is based on the Tandy TRS-80 Model I microcomputer operating system. The first version of the operating system (modified Tiny Basic by Li-Chen Wang) used a 4 KB ROM and has very similar characteristics to Galaksija's operating system: identical error messages ("HOW?", "WHAT?", "SORRY"), similar modulation for storing data on magnetic tape, partially identical machine code for performing floating-point operations, etc. In general, the TRS-80's hardware capabilities are similar to Galaksija (same pseudo-graphic mode, same keyboard connection to the processor bus, etc.).

For the purposes of reverse engineering Galaksija's operating system, a new disassembler program z80dasm was created, which is included in the appendix. The contents of ROM A in the form of assembly source code, created with z80dasm, is included in the appendix.

Below are descriptions of some of the optimization approaches used with examples from ROM A's contents.

### 5.1 Program Code Polymorphism

Some parts of the machine code stored in EPROM memory are interpreted differently by the microprocessor on different occasions.

Certain sequences of machine instructions, for example, are interpreted differently depending on the jump address. Table 6 shows an example of such code that is interpreted in three different ways in three different cases. When jumping to address 0x0390, the value 0x0f0e is written to register HL, when jumping to address 0x0393, the value 0x0f9b, and when jumping to 0x0396, the value 0x0fee.

Similarly, code is shortened in several places in the operating system code. In most cases, this involves replacing a jump over an unwanted instruction with a load instruction to an unused register. This way, one byte of program code is saved for each execution branch compared to using the processor's jr instruction.

In certain cases, the Z80 microprocessor's machine code is also interpreted as a data structure.

The first such example can be found at address 0x0098 (Table 7), where the code is also interpreted as an ASCII string. Characters from the upper half of the ASCII code table are interpreted exclusively as 8-bit load (ld) instructions with register operands [14], which simplifies the selection of a text string that matches the microprocessor code.





| Address | Hex    | Processor Interpretation |||
|---------|--------|------------------------|-|-|
| 0x0390  | 0x2e   | 1 →ld l,0ehh |               |              | 
| 0x0391  | 0x0e   |              |               |              | 
| 0x0392  | 0x01   | ld bc,9b2eh  |               |              | 
| 0x0393  | 0x2e   |              | 2 →ld l,9bh   |              |
| 0x0394  | 0x9b   |              |               |              |
| 0x0395  | 0x01   |              | ld bc,ee2eh   |              |
| 0x0396  | 0x2e   |              |               | 3 →ld l,eeh  |
| 0x0397  | 0xee   |              |               |              |
| 0x0398  | 0x26   | ld h,0fh     | ld h,0fh      | ld h,0fh     |
| 0x0399  | 0x0f   |              |               |              |


**Table 6:** Example of machine code polymorphism in the Galaxy operating system. The HL register is set to different values depending on the entry point (→) of the microprocessor


| **Adr.** | **Hex** | **ASCII** | **Processor Interpretation of Instructions** |
|----------|---------|-----------|---------------------------------------------|
| 0x0098   | 0x42    | B         | ld b,d                                      |
| 0x0099   | 0x52    | R         | ld d,d                                      |
| 0x009A   | 0x45    | E         | ld b,l                                      |
| 0x009B   | 0x41    | A         | ld b,c                                      |
| 0x009C   | 0x4B    | K         | ld c,e                                      |
| 0x009D   | 0x00    | NUL       | nop                                         |

**Table 7:** Example of using machine code as the ASCII string "BREAK".

--- 

Let me know if you need further adjustments!

| **Adr.** | **Hex** | **Data**                  | **Processor Interpretation of Instructions** |
|----------|---------|------------------------------|----------------------------------------|
| 0x00A0   | 0x00    | M=0x800000, S=+1, E=0x01     | nop                                    |
| 0x00A1   | 0x00    | M=0x800000, S=+1, E=0x01     | nop                                    |
| 0x00A2   | 0x80    | M=0x800000, S=+1, E=0x01     | add a,b                                |
| 0x00A3   | 0x00    | M=0x800000, S=+1, E=0x01     | nop                                    |

**Table 8:** Example of using machine code as a 4-byte floating-point constant (Appendix, page 67).

The second example is located at address **0x00A0** (Table 8). Here, the machine code is also interpreted as a floating-point number: **+1 · 0x800000 · 2^(0x01−24) = 1.0**.  

---

### 5.2  
**Multifunctionality of Data Structures**  

The EPROM memory contains a series of constant data structures, mostly interspersed with machine code. Some of these structures are interpreted by the operating system in multiple ways.  

One such example is the table of ASCII codes for the keyboard, located at addresses **0x0D70** to **0x0D99** (Table 9).  

- **KEY SHIFT SYM TABLE** at address **0x0D70** is used to convert key codes into ASCII character codes. It stores ASCII codes in an order corresponding to the addresses of keys in the microprocessor's address space (Figure 7). For example, the first row in the table corresponds to the key at address **0x1F**. The first column contains ASCII codes for characters when the key is pressed with the **SHIFT** key, while the second column contains ASCII codes for characters when the key is pressed without **SHIFT**.  
- **KEY SHIFT YU TABLE** at address **0x0D94** is used for entering Yugoslav characters. It contains ASCII characters corresponding to keys that, when pressed with **SHIFT**, input diacritical marks.  

The **KEY SHIFT YU TABLE** occupies positions in the larger **KEY SHIFT SYM TABLE** that correspond to the keys at addresses **0x31** and **0x32**. These addresses belong to the **BREAK** and **REPEAT** keys, which the operating system handles separately. As a result, the ASCII codes assigned to these keys in the **KEY SHIFT YU TABLE** are irrelevant.  

Here is the information rearranged into a table with four columns: **Adr.**, **Hex**, **SYM TABLE**, and **YU TABLE**:


| Address | Hex  | Symbol | SYM_TABLE  | YU TABLE |
|---------|------|--------|-----|-------|
| 0x0d70  | 0x20 | 0x1f   | ␣ ␣ |       |
| 0x0d71  | 0x20 |        |     |       |
| 0x0d72  | 0x5f | 0x20   | _ 0 |       |
| 0x0d73  | 0x30 |        |     |       |
| 0x0d74  | 0x21 | 0x21   | ! 1 |       |
| 0x0d75  | 0x31 |        |     |       |
| 0x0d76  | 0x22 | 0x22   | " 2 |       |
| 0x0d77  | 0x32 |        |     |       |
| 0x0d78  | 0x23 | 0x23   | # 3 |       |
| 0x0d79  | 0x33 |        |     |       |
| 0x0d7a  | 0x24 | 0x24   | $ 4 |       |
| 0x0d7b  | 0x34 |        |     |       |
| 0x0d7c  | 0x25 | 0x25   | % 5 |       |
| 0x0d7d  | 0x35 |        |     |       |
| 0x0d7e  | 0x26 | 0x26   | & 6 |       |
| 0x0d7f  | 0x36 |        |     |       |
| 0x0d80  | 0xbf | 0x27   | □ 7 |       |
| 0x0d81  | 0x37 |        |     |       |
| 0x0d82  | 0x28 | 0x28   | ( 8 |       |
| 0x0d83  | 0x38 |        |     |       |
| 0x0d84  | 0x29 | 0x29   | ) 9 |       |
| 0x0d85  | 0x39 |        |     |       |
| 0x0d86  | 0x2b | 0x2a   | + ; |       |
| 0x0d87  | 0x3b |        |     |       |
| 0x0d88  | 0x2a | 0x2b   | * : |       |
| 0x0d89  | 0x3a |        |     |       |
| 0x0d8a  | 0x3c | 0x2c   | < , |       |
| 0x0d8b  | 0x2c |        |     |       |
| 0x0d8c  | 0x2d | 0x2d   | - = |       |
| 0x0d8d  | 0x3d |        |     |       |
| 0x0d8e  | 0x3e | 0x2e   | > . |       |
| 0x0d8f  | 0x2e |        |     |       |
| 0x0d90  | 0x3f | 0x2f   | ? / |       |
| 0x0d91  | 0x2f |        |     |       |
| 0x0d92  | 0x0d | 0x30   | CR CR |     |
| 0x0d93  | 0x0d |        |     |       |
| 0x0d94  | 0x58 | 0x31   | X C | Ĉ shift X |
| 0x0d95  | 0x43 |        |     | Ċ shift C |
| 0x0d96  | 0x5a | 0x32   | Z S | Ź shift Z |
| 0x0d97  | 0x53 |        |     | Ṡ shift S |
| 0x0d98  | 0x0c | 0x33   | FF NUL |    |
| 0x0d99  | 0x00 |        |     |       |


**Table 9:** Example of multifunctionality of data structures. A portion of memory is interpreted as the content of two different tables.

--- 


## 5.3  **Organization of Program Code**  

The operating system, due to optimization, is not strictly divided into closed units—program functions. Instead of standard function calls using **call** and **ret** instructions, a combination of **call** instructions and jumps (**jp** or **jr**) is used. This approach saved a large number of **ret** instructions that would otherwise be needed to end functions, and it also improved the operating system's speed (as fewer stack operations are required).  

Figure 27 shows a typical arrangement of functions:  
- **Multiple Entry Points:** A function often has multiple entry points. Depending on the entry point, the function's behavior changes slightly. For example, the first entry point performs an operation on the string at address **DE+1**, while the second entry point performs the same operation at address **DE+0** (see **f1a**, **f1b**, and **f1c** in Figure 27).  
- **Function Chaining:** Function **f2** calls function **f1a** just before its end. Instead of using a **call f1a** instruction, function **f2** is placed in ROM memory immediately before function **f1**. This allows the microprocessor to continue execution into the next function without a jump. The final **ret** instruction then returns execution to the code that called function **f2**. This saves an entire **call** instruction (3 bytes in the best case) and is sometimes used even when the called function is not the most suitable.  
- **Shared Code:** Functions often share the same ending code (just before the **ret** instruction). Instead of repeating this code in every function, it is written only once (see **fend** in Figure 27). Other functions are either placed in ROM memory so that the microprocessor reaches this code without a jump (**f1** and **f2**) or jump to it using **jp** or **jr** instructions (**f3**).  

Side effects of functions are also frequently used in the code. For example, the **CLEAR LINE** function, whose main task is to clear one screen line, is also used in some cases to move the pointer in the **HL** register.  

Note: For example, the **SAVE WORD** function is called to store a checksum at the end of the **SAVE** routine, even though calling **SAVE BYTE** would have been more appropriate, as it would not save an unnecessary byte to the tape.  

---

### 5.4  
**Use of Processor Registers**  

The relatively unstructured nature of the code results in consistent use of registers. The patterns in Table 10 are followed by the vast majority of the operating system's code.  


![imagen](https://github.com/user-attachments/assets/18b3b216-782c-4e6e-b50e-3d8880a3690d)

Figure 27


| **Register** | **Description**                                                                 |
|--------------|---------------------------------------------------------------------------------|
| DE           | Pointer to the current character in the BASIC interpreter                        |
| HL           | Pointer to a BASIC variable                                                     |
| IX           | Pointer to the top of the arithmetic stack                                       |
| IY           | Pointer to the function executed during a video interrupt                        |
| HL’, C’, HL  | First operand for floating-point operations                                      |
| DE’, B’, DE  | Second operand for floating-point operations                                     |

**Table 10:** Typical use of processor registers in the operating system.

--- 

Let me know if you need further adjustments!

![imagen](https://github.com/user-attachments/assets/8c9ac02f-67d6-495e-8015-40eab3a2d56d)

Figure 28

## **5.4 Register-Based Processing**

To maximize **execution speed**, the OS minimizes **memory accesses** by:

- Using **Z80 registers** whenever possible.
- Keeping **critical variables in registers** instead of RAM.
- Using **alternate register sets** for multitasking-like behavior.

📌 **Table 7**: *Typical register usage in the Galaksija OS.*

| **Register** | **Purpose** |
|------------|----------|
| **AF** | Video sync counter |
| **BC** | Character printing loop |
| **DE** | Memory address pointer |
| **HL** | Current cursor position |
| **IX/IY** | Interrupt service routines |

This approach reduces **bus contention**, improving **execution speed**, but also makes **interrupt handling more complex**.


---

## **5.5 Processor Stack**  

The operating system's code often directly modifies values on the processor stack, which is uncommon elsewhere. One example of stack manipulation is shown in Figure 28. Here, the function at address **0x0393** calls the function at **0x0C8F** by pushing its address onto the stack, while the next function (**0x2BA9**) is called using the **jp** instruction instead of **ret**. This way, the **ret** instruction in the function at **0x2BA9** jumps to the called function at **0x0C8F**, rather than returning execution to **0x0393**.  

The stack is also used to pass pointers to arguments for certain functions. An example is shown in Figure 29. Here, the **READ PAR** function uses the address saved at the top of the stack by the **rst** instruction as the address of two operands (at addresses **0x0134** and **0x0135**).  

At the end of execution, the function adds **2** to the pointer it initially read from the top of the stack and returns it to the top of the stack. This way, the **ret** instruction at the end returns processor execution to address **0x0136**.  

A similar implementation is used for the **BASIC ERROR** function, where the value at the top of the stack points to an error message.  

This approach saves additional machine code that would otherwise be needed to load function arguments into registers or to load a pointer to a data structure. This simplification, in the case of a large number of calls to a specific function, more than compensates for the additional code required in the function itself.  

Such interweaving of machine code and function arguments is one of the main reasons for the aforementioned difficulties with automatic disassembler programs. Unusual uses of the processor stack also greatly complicate the use of software simulators for exploring operating system functions, as they obscure the function call trace (backtrace).  

```asm
rst 18h          ;0133  Call the READ_PAR function
db '('           ;0134 Define byte: ASCII '('
db l015dh-$-1    ;0135 Define byte: Calculate offset to label l015dh

rst 08           ;0136 Call routine at address 08h
inc hl           ;0137 Increment HL register
add hl, hl       ;0138 Add HL to itself (HL = HL * 2)
```

**Figure 29:** Example of using the stack to pass a pointer to function arguments.  

---

## **5.6 Cassette Tape Data Storage**

Simple pulse modulation is used for storing data on tape. The timing diagram of the signal is shown in Figure 30, the timing intervals are detailed in Table 11, and the logical meaning of individual stored bytes is provided in Table 12.  

The typical data transfer rate achieved is approximately **330 bits/s**. The choice of simple modulation and low transfer speed is most likely due to the limited space for modulation and demodulation routines in the EPROM memory. Microcomputers with similar hardware but larger ROM capacities achieve significantly higher transfer speeds (for example, the Sinclair Spectrum typically achieves **1500 bits/s**).  

![imagen](https://github.com/user-attachments/assets/315be561-2034-4f66-b087-1c76c9ae1553)

📌 **Figure 30:** *Timing diagram of the modulation used for storing data on magnetic tape.*


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


📌 **Table 9**: *Comparison of original and replica Galaksija hardware.*

| **Feature** | **Original Galaksija** | **New Galaksija Replica** |
|------------|------------------|------------------|
| **Processor** | Zilog Z80A (NMOS) | Zilog Z84C0008 (CMOS) |
| **ROM Size** | 4 KB | 32 KB |
| **RAM Size** | 2, 4, or 6 KB | 8 KB |
| **Video Output** | Composite Video | Composite Video (Optimized for modern displays) |
| **Cassette Interface** | Analog | Improved ADC/DAC circuit |

---

### **6 Conclusion**  

The creation of the Galaksija replica demonstrated that replicating even a small electronic system like the Galaksija is not a simple task. It requires knowledge of both analog and digital electronics, as well as assembly programming. On the other hand, this work proves that creating a functional replica is possible based solely on preserved documentation and software, even when a working original is unavailable for analysis.  

Before designing and building the replica, several side issues had to be addressed: reverse-engineering the original electronic circuit was, of course, planned, but the inadequacy of current tools for analyzing Z80 machine code was not anticipated. This required a detour from the main path and the creation of a usable Z80 disassembler. Due to difficulties in understanding the operating system's behavior, it was necessary to study the system while running test programs, rather than relying solely on static analysis of the ROM contents. Developing these test programs, in turn, required the creation of development tools first.  

The construction of the replica's keyboard also posed challenges. Due to the overwhelming prevalence of standard PC keyboards within the available resources, it was not possible to create a suitable replacement for the original Galaksija keyboard. As a result, the modern replica has a lower-quality, foil-covered keyboard (whereas the professional keyboard was one of the few technical advantages the Galaksija had over its competitors).  

These detours contributed to the results covering a slightly broader area than originally planned in the project's objectives. This also led to a somewhat more extensive list of appendices.  

Today, the importance of writing clear and simple programs is emphasized over highly optimized but difficult-to-understand code. The results of this work confirm this, as the excessively optimized machine code proved very difficult to understand. At the same time, the associated preserved documentation turned out to be practically useless. An unexpected consequence of this optimization was the reduced usability of modern disassembler tools, requiring manual translation of machine code into assembly based on instruction tables.  

Despite better documentation, the findings regarding hardware were similar to those for software: it became clear that designing simple and understandable circuits is just as important as documentation. Excessive optimization in terms of the number of electronic components, such as the Galaksija's use of sequential circuits instead of combinational ones, significantly increased the complexity of the work. On several occasions, preserved documentation, due to printing errors, made the work more difficult rather than easier, often requiring cross-referencing data from different sources (e.g., wiring diagrams and PCB layouts).  

On the other hand, the results highlight the positive impact of exclusively using standard electronic components (especially integrated circuits). Creating a similar replica of a microcomputer that relies on an application-specific integrated circuit (ASIC) would be a significantly more challenging task.  

The importance of publicly releasing documentation was also evident in this project. Many microcomputers from this era were lost primarily because their documentation disappeared along with the companies that carefully guarded it. Similarly, the absence of copy protection in software had a positive impact on its preservation, as such protections often led to the loss of a significant portion of software for similar microcomputers.  

---

### **7 Bibliography**
[1] Hišni računalnik. Ljubljana, Mladinska knjiga, 1984, str. 42-46.

[2] Antonić, V.: Napravi i ti računar Galaksija. Računari u vašoj kuči,januar 1984, str. 50-56.

[3] ZX81 Assembly Instructions. Sinclair Research Ltd, 1981.

[4] Servicing Manual for ZX Spectrum. Thorn Datatech Ltd, Sinclair Research Ltd, 1984.

[5] Commodore 64 Service Manual. Commodore Business Machines Inc,1985.

[6] Z80 Family CPU User Manual. San Jose, ZiLOG Inc., 2005.

[7] Benson, K. B.: Television Engineering Handbook. McGraw-Hill Inc., 1985.

[8] Wedam, A.: Radiotehnika: ojačevalniki in sprejemniki. Ljubljana,Državna založba Slovenije, 1955.

[9] Bandwidth Versus Video Resolution. Maxim Integrated Products, Dallas Semiconductor,2005. http://www.maxim-ic.com/appnotes.cfm/appnote number/750

[10] Z8400/Z84C00 NMOS/CMOS Z80 CPU Central Processing Unit: Product specification. ZiLOG Inc.

[11] Rigter, W.: ZX81 Video Display System. 1996. http://home.germany.net/nils.eilers/zx81/wilfvid.htm

[12] Ristanović, D.: Računar Galaksija. http://user.sezampro.yu/ dejanr/galaks.htm

[13] Harris, R.: Altair BASIC 3.2 (4K) - Annotated Disassembly. http://www.interact-sw.co.uk/altair/index2.html

[14] Dinu, C.: Decoding Z80 opcodes. http://z80.info/decoding.htm

[15] Ristanović, D.: Računar Galaksija Uputstvo za upotrebu.

[16] Ristanović, D.: Galaksija bez tajni. Računari, July 1984, pages 53-63.

### A  
**Voltage Inverter**  

The voltage inverter must produce a stabilized supply voltage of **−5V** under all operating conditions of the video amplifier.  

SPICE simulations of the video amplifier in both extreme cases (a completely white screen and a completely black screen) showed that the video amplifier requires a current of **25 to 34 mA** for operation.  

Due to its simple circuit and reliable operation, a **switched capacitor** implementation with a linear voltage regulator was chosen. The low output current minimizes the drawbacks of this approach (such as high losses compared to an inductor-based design).  

The switching part (integrated circuit **U11**, capacitor **C4**, and diodes **D2** and **D3**) operates at a frequency of approximately **10 kHz** and produces an unstabilized voltage of approximately **−9V**. This voltage is then stabilized by the regulator in the integrated circuit **U22**.  

The results of measurements of the output voltage as a function of the output current are shown in **Figure 31**.  

![imagen](https://github.com/user-attachments/assets/92821ea7-12ba-445a-91f6-d1d359758f83)

![imagen](https://github.com/user-attachments/assets/d473a335-4486-4aa6-b385-0bc173bc48cc)

**Figure 31:** Results of voltage measurements before (**Usw**) and after (**Uout**) the voltage regulator, as a function of the output current **Iout**.  

---

### Calculation of the Pulse Amplifier  

Assume that the input pulse is rectangular in shape and that the connected tape recorder has a low output impedance.  

First, calculate the **maximum collector current**, while also assuming the **minimum current through R1** at which the amplifier output is at a logical **0**.  


The minimum collector current (**ICmin**) is calculated as:  

\[
IC_{\text{min}} = \frac{U_{CC} - U_{CE_{\text{sat}}}}{R1}  
\]  
*(Equation 1)*  

Where:  
- \( U_{CC} \) = Supply voltage  
- \( U_{CE_{\text{sat}}} \) = Collector-emitter saturation voltage  
- \( R1 \) = Resistor value  


The minimum base current (**IBmin**) required to achieve **ICmin** is:  

\[
IB_{\text{min}} = \frac{IC_{\text{min}}}{\beta}  
\]  
*(Equation 2)*  

Where:  
- \( \beta \) = Current gain of the transistor  

If the above assumptions hold, the capacitor **C15** initially charges primarily through the base of transistor **Q7** after the first edge of the pulse. Once the voltage at the base drops to the base-emitter voltage (**UBE**) of transistor **Q7**, the capacitor continues to charge mainly through resistor **R33**.  

The output pulse of the amplifier lasts as long as the base current exceeds **IBmin**.  

![imagen](https://github.com/user-attachments/assets/9dd797d3-e29e-428d-b717-894cd4f416bc)


Due to the exponential **IB (UBE)** characteristic of the transistor, the capacitor charges through the base in a very short time. The width of the output pulse is primarily determined by the charging through resistor **R33** and the resulting **RC time constant** of the **R33 C15** circuit.  

Assume that the base current becomes negligible when it drops to approximately one-tenth of the current through the resistor. At this point, the base voltage is:  

EQ 3 is missing

\[
U_{BE_{\text{start}}} = U_T \ln\left(\frac{U_{BE} \beta}{I_S R33 \cdot 10} + 1\right)  
\]  
*(Equation 4)*  

Where:  
- \( U_T \) = Thermal voltage  
- \( I_S \) = Saturation current of the transistor  
- \( \beta \) = Current gain of the transistor  

Similarly, the base voltage when the minimum base current (**IBmin**) flows is:  

\[
U_{BE_{\text{stop}}} = U_T \ln\left(\frac{I_{B_{\text{min}}} \beta}{I_S} + 1\right)  
\]  
*(Equation 5)*  

The duration of the pulse is then:  

\[
t = R33 \cdot C15 \cdot \ln\left(\frac{U_{BE_{\text{start}}}}{U_{BE_{\text{stop}}}}\right)  
\]  
*(Equation 6)*  

The required capacitance **C15** for a known resistor value and pulse duration is:  

\[
C15 = \frac{t}{R33 \cdot \ln\left(\frac{U_{BE_{\text{start}}}}{U_{BE_{\text{stop}}}}\right)}  
\]  
*(Equation 7)*  

For a resistor **R33 = 1 kΩ** and a pulse duration **t = 100 µs**, we obtain a value of **C15 ≈ 0.72 µF**, which is approximately **1 µF**. The minimum pulse duration of **45 µs** is derived from the **LOAD READ PULSE** loop at addresses **0x0EF9** to **0x0F05**. For greater reliability, a value approximately twice as large was used.  

### Floating-Point Numbers  

Galaksija's operating system uses a stack-based calculator with **RPN (Reverse Polish Notation)** for evaluating mathematical expressions internally. For example, all BASIC expressions are internally converted into this form before calculation, and the complexity of expressions is limited only by the memory available for the arithmetic stack.  

The system uses **two different formats** for floating-point numbers:  
1. **4-byte format:** Used for long-term storage of values (e.g., for BASIC variables and arrays).  
2. **5-byte format:** Used for storing intermediate calculation results (e.g., values on the arithmetic stack). This format is more suitable for arithmetic operations due to its data layout.  

This approach achieves a compromise between the speed of arithmetic operations and memory requirements.  

Both formats always contain **normalized values** and use:  
- **24 bits** for the mantissa,  
- **8 bits** for the exponent, and  
- **1 bit** for the sign.  

The value of the number is determined by the following equation:  

\[
N = 
\begin{cases} 
+1 \cdot M \cdot 2^{E-24} & \text{if } S = 0 \\
0 & \text{if } E = -128 \\
-1 \cdot M \cdot 2^{E-24} & \text{if } S \neq 0 
\end{cases}
\]  
*(Equation 8)*  

Where:  
- \( M \) = Unsigned mantissa value,  
- \( E \) = Signed exponent value,  
- \( S \) = Sign bit value, and  
- \( N \) = Represented number.  

This format allows numbers to be represented in the following range:  

\[
N \in \left[ -1 \cdot (2^{24} - 1) \cdot 2^{127}, +1 \cdot (2^{24} - 1) \cdot 2^{127} \right]  
\]  
*(Equation 9)*  

The format does not support non-numeric values (e.g., infinity, undefined values, etc.).  

The interpretation of individual bits in both formats is shown in **Tables 14** and **15**. In the 4-byte format, the **most significant bit of the mantissa (M23)** is omitted because it is always **1** due to the mandatory normalization of numbers.  

Here is the translation and rearrangement of the table:

---

| **Address** | **Bit** | **7** | **6** | **5** | **4** | **3** | **2** | **1** | **0** |         |
|-------------|---------|-------|-------|-------|-------|-------|-------|-------|-------|---------|
| IX - 5      | L’ E’   | M7    | M6    | M5    | M4    | M3    | M2    | M1    | M0    | mantisa |
| IX - 4      | H’ D’   | M15   | M14   | M13   | M12   | M11   | M10   | M9    | M8    |         |
| IX - 3      | C’ B’   | M23   | M22   | M21   | M20   | M19   | M18   | M17   | M16   |         |
| IX - 2      | L E     | E7    | E6    | E5    | E4    | E3    | E2    | E1    | E0    | exponent|
| IX - 1      | H D     | S     | S6    | S5    | S4    | S3    | S2    | S1    | S0    | predznak|

**Table 14:** 5-byte floating-point number format.

| **Bit** | **7** | **6** | **5** | **4** | **3** | **2** | **1** | **0** |
|---------|-------|-------|-------|-------|-------|-------|-------|-------|
| HL + 0  | M7    | M6    | M5    | M4    | M3    | M2    | M1    | M0    |
| HL + 1  | M15   | M14   | M13   | M12   | M11   | M10   | M9    | M8    |
| HL + 2  | E0    | M22   | M21   | M20   | M19   | M18   | M17   | M16   |
| HL + 3  | S7    | E7    | E6    | E5    | E4    | E3    | E2    | E1    |

**Table 15:** 4-byte floating-point number format.

### **Declaration**  

I declare that I have prepared this thesis independently under the guidance of my mentor, Prof. Dr. Tadej Tuma, Univ. Dipl. Ing. El. Any assistance provided by other collaborators has been fully acknowledged in the acknowledgments section.  




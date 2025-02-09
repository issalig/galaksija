### **University of Ljubljana**  
**Faculty of Electrical Engineering**  

**Tomaž Šolc**  

**Replica of the Galaksija Microcomputer**  

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

## **1. Introduction**

### **1.1 Galaksija**

**Galaksija** is a home microcomputer designed in 1983 by **Voja Antonić**. Similar to other microcomputers developed in former Yugoslavia at the time, **Galaksija** was intended as a domestic alternative to foreign microcomputers produced by **Sinclair Research** (Sinclair ZX81, Sinclair ZX Spectrum) and **Commodore Business Machines** (Commodore 64). These foreign microcomputers, although highly sought after, were difficult to obtain legally due to strict import restrictions on Western technology and their relatively high prices【1】.

To make the computer as affordable as possible and accessible to the widest range of people, its electronic circuitry was designed to be as simple as possible, including only components that were either readily available in electronic stores at the time or could be easily imported from neighboring countries. Since cost reduction was the highest priority in its design, many compromises had to be made in hardware. For example, the computer's operation depends on certain undocumented features of the microprocessor, along with other design choices that would be unacceptable in modern systems. The development of system software was also heavily influenced by the goal of keeping hardware costs low.

A comparison of **Galaksija**’s capabilities with similar foreign and domestic microcomputers from the same era is shown in **Tables 1 and 2**.

Initially, **Galaksija** was intended for self-assembly. To facilitate this, the designer, with the assistance of editor **Dejan Ristanović**, published a complete guide on how to build it in a **special edition of the magazine Galaksija**, released in January 1984【2】. This publication, which included a significant portion of the development documentation, ensured that much of the technical details were preserved. Due to high demand, the computer was later produced as a commercial product as well.

📌 Figure 1: Handmade Galaksija prototype (private collection of Damjan Lenarčič).
📌 Figure 2: Factory-produced Galaksija (manufactured by Zavod za udžbenike i nastavna sredstva).
📌 Figure 3: Top view of the original Galaksija PCB (private collection of Iztok Pušnar).
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

#### **Table 2: Comparison of Galaksija with domestic microcomputers**  

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

### **2.1 Address Space Utilization**

The **Z80 microprocessor**【6】has **two separate address spaces**:  

1. A **16-bit address space** for memory  
2. An **8-bit address space** for input/output (I/O) operations  

The **Galaksija motherboard** only utilizes the **memory address space**, both for **memory access** and for **communication with peripherals** (a technique known as **memory-mapped I/O**).

📌 Figure 6: Galaksija’s memory map and address space allocation.
**Figure 6** illustrates the memory **layout** and how memory and peripheral devices are mapped into the address space (**memory map**). This layout is defined by the **address decoder circuit** and **cannot be changed via software** (except for control of the **A7 address line for RAM**, as shown in **Figure 9**). Unused parts of the address space are **reserved for future expansion**, and reading from these addresses returns **undefined values**.

The **4 KB read-only memory (ROM A)**, which contains the **system software**, is mapped at address **0x0000** and occupies the **interrupt vectors** of the microprocessor. Another **4 KB read-only memory (ROM B)** is mapped at address **0x1000** and is reserved for **expansion**.

Writing to memory addresses used by the **ROM** is **not allowed**. On computers **without ROM B**, reading from addresses mapped to it returns **undefined values**.

At **0x2800**, **2 KB to 6 KB of static RAM (SRAM)** is mapped. This RAM does **not require refresh cycles** using the **memory refresh counter** of the **Z80 processor**.

The entire **I/O address space** is reserved for **expansion**, and reading from **unmapped** I/O addresses returns **undefined values**.

📌 Figure 7: Keyboard memory address mapping.
📌 Table 1: Comparison of Galaksija with similar foreign computers.
📌 Table 2: Comparison of Galaksija with other Yugoslavian microcomputers.

---

### **2.2 Peripherals**

The **processor accesses peripherals** through a **2 KB block** of the **memory address space**, starting at **0x2000**.
📌 Figure 8: Latch register bit layout.

#### **2.2.1 Keyboard**

The keyboard has **54 keys**, each of which is mapped to a **specific address in memory**, as shown in **Figure 7**. The base memory address for the keyboard is **0x2000**, with multiple address offsets for different keys. Due to **incomplete address decoding**, the **keyboard can be accessed from 32 base addresses** (e.g., 0x2000, 0x2040, …, 0x27C0). **Unused memory locations** behave as if **no key is pressed**.

If the **least significant bit (LSB)** at a specific **keyboard address** is **0**, the key is **pressed**. If the bit is **1**, the key is **not pressed**. The **other bits** in the address return **undefined values**.

Writing to the **keyboard memory addresses** is **not allowed**.
📌 Figure 9: A7 line control for RAM address remapping.
---

#### **2.2.2 Cassette Interface**

The **cassette interface** consists of an **analog input** and an **analog output**.

- The **analog input** is implemented as a **simple comparator** with a **high-pass filter** at the input.  
- If a pulse with an **amplitude greater than approximately 700 mV** (determined by the transistor **T2**) appears at the input, the **least significant bit (LSB)** at the **comparator addresses** in **Figure 7** is set to **0** for the duration of the pulse.  
- The **maximum pulse length** is defined by the **filter** consisting of **C2** and **R14**【2】.

The **analog output** is controlled through **two bits** in the **latch register** (**Figure 8**, **AOUT0 and AOUT1**), forming a **simple digital-to-analog converter (DAC)**. The output voltage is determined by the states of these two bits, as shown in **Table 3**.

📌 Table 3: Analog output voltage levels for tape interface.
| **AOUT0** | **AOUT1** | **Output Voltage (Ua) [V]** |
|----------|----------|------------------|
| 0        | 0        | 0.0 V            |
| 1        | 0        | 0.5 V            |
| 0        | 1        | 0.5 V            |
| 1        | 1        | 1.0 V            |

---

#### **2.2.3 Latch Register**

The **processor** can access a **6-bit latch register** at **addresses in the range 0x2038 to 0x27FF**. The **latch register** is used for:  
- **Character generator control**  
- **Analog output control**  
- **A7 address line control for RAM**  

The **processor can only write** 8-bit values to these addresses. **Reading from them returns undefined values**.

The functions of the **individual bits** in the latch register are given in **Table 4**:

| **Bit Name** | **Function** |
|-------------|-------------|
| **A7CLMP** | If set to **0**, forces the **A7 address line** of RAM to **1**, regardless of the processor’s address bus (**Figure 9**). |
| **AOUT0–AOUT1** | Controls the **cassette interface’s digital-to-analog converter (DAC)**. |
| **CHR0–CHR3** | Controls the **current scanline** being processed by the **character generator**. |

---

### **2.3 A7 Address Line Control for RAM**
📌 Figure 10: Video synchronization timing.
📌 Figure 11: Processor timing during video signal generation.
Setting the **A7CLMP bit** allows the **A7 address line** of RAM to be **forced to 1**, regardless of the address bus value from the processor. This allows the **processor to read values stored in odd-numbered 128-byte blocks**, even when accessing even-numbered addresses.

This feature is used in **video signal generation** due to a **peculiarity of the Z80 processor**, which **does not automatically increment the A7 line** during **memory refresh cycles**【6】.

---

### **2.4 Video Signal Generation**

**Galaksija** is designed to be connected to a **composite video monitor** or a **TV via a UHF modulator**. In both cases, the display uses a **cathode-ray tube (CRT)**, so the following descriptions rely on the **movement of the electron beam** across the screen.

Due to the **simple hardware design**, **video signal generation** requires **active cooperation from the microprocessor**. Proper **synchronization** of software execution with the **movement of the electron beam** is essential.

The **video driver** responsible for generating the video signal is located in **ROM A at address 0x0038**, which is the **interrupt vector for the INT interrupt** in **interrupt mode IM 1**.
📌 Figure 12: ASCII character ROM encoding structure.
📌 Figure 13: Galaksija’s character set table.
---

#### **2.4.1 Synchronization**

The **key timing intervals** required for **video signal generation** are shown in **Figure 10**. The **clock signals** for the processor (**3.072 MHz**) and the **video circuitry** (**6.144 MHz**) are synchronized.  

The **visible screen area** consists of **208 lines**, with a **black border** surrounding it. **Each horizontal scanline** takes **128 processor clock cycles**, and the **horizontal and vertical sync pulses** are **generated by hardware**.

At the **56th horizontal sync pulse**, the **electron beam** begins moving to the **first visible scanline** of the screen. At this moment, the **video hardware triggers an interrupt (INT)** to **pause user program execution** and start video processing.

Since the **processor’s response time** to an **interrupt** is **variable** (1–23 clock cycles), the **processor is paused** for **one full scanline (192 cycles)** using the **WAIT signal**. This ensures that **video processing remains perfectly synchronized** with the **electron beam**.
📌 Figure 14: Video driver execution flowchart.
📌 Figure 15: Timing of the shift register during video output.
---

# **3. The New Galaksija**

The **new Galaksija** retains the **main features** of the original design while incorporating **modern components** where necessary. The **primary objective** was to maintain **software compatibility** while improving **hardware reliability** and **ease of use** with modern displays.

The **circuit schematic** and **PCB layout** are provided in the **appendix**.

---

## **3.1 Digital Section**

The **digital components** in the **new Galaksija** are built using **high-speed CMOS logic (74HC series).**

---

### **3.1.1 Microprocessor and Memory**

| **Component** | **Type** | **Function** |
|--------------|---------|-------------|
| **CPU (U1)** | Zilog Z84C0008 | CMOS version of Z80, fully compatible |
| **ROM (U2)** | 27C256 (32 KB EPROM) | Stores **ROM A**, **ROM B**, and additional space for expansions |
| **RAM (U3)** | LH5164D (8 KB SRAM) | Stores program variables and system memory |

📌 **Figures 16, 17, 18**: Show the **motherboard, keyboard, and full enclosure** of the new Galaksija.

🔹 **Important modification**:  
- In the **new design**, the **EPROM remains active during write attempts**.  
- To **prevent short circuits**, **resistors (R10-R17)** limit current flow between the CPU and the EPROM.

---

### **3.1.2 Address Decoder**

The **address decoder** consists of:

- **Demultiplexers (U10)**
- **Logic gates (U18)**

These components ensure proper **memory mapping** between ROM, RAM, and **peripherals**.

---

### **3.1.3 Keyboard**

- The **new keyboard** is built on a **separate PCB** and connects to the **mainboard** via a **20-pin connector**.
- The **original Galaksija keyboard required open-collector outputs**, which the **U7 demultiplexer** does not provide.
  - To solve this, **diodes (D1-D7)** simulate **open-collector behavior**.
- A **resistor (R30)** protects the output **multiplexer** from **short circuits**.

---

### **3.1.4 Clock Divider**

The **clock divider** consists of **four 4-bit ripple counters (U12, U13)** that derive various **timing signals** from the **6.144 MHz system clock**:

| **Signal** | **Frequency Calculation** | **Result** |
|------------|---------------------------|------------|
| **Processor Clock** | \( f_{cpu} = \frac{f_{osc}}{2} \) | 3.072 MHz |
| **Horizontal Sync** | \( f_{hsync} = \frac{f_{osc}}{12 \times 16 \times 2} \) | 16 kHz |
| **Interrupt Frequency** | \( f_o = \frac{f_{osc}}{12 \times 16 \times 16 \times 4} \) | 50 Hz |

📌 **Table 5**: *Comparison of Galaksija's video signal characteristics with the PAL B,G standard.*

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

- The **video shift register (U6)** receives **parallel data** from the **character generator** and outputs it serially to create the **video signal**.
- **Logic gates (U17)** detect the **fourth T-state of each machine cycle (M1)** and trigger **parallel data loading** into the shift register.

📌 **Figure 19**: *Timing diagram of the shift register control circuit.*

---

### **3.1.6 Interrupt Synchronization**

- A **sequential logic circuit** consisting of:
  - **Memory cell (U21)**
  - **Logic gates (U19)**
- This circuit **detects the processor's response** to an **interrupt** and **synchronizes video execution** with the **horizontal sync pulse**.

📌 **Figure 20**: *Timing diagram of the interrupt synchronization circuit.*

---

## **3.2 Analog Section**

### **3.2.1 Power Supply**

| **Power Supply** | **Voltage** | **Function** |
|------------------|------------|-------------|
| **External Adapter** | +12V DC | Provides input power |
| **Internal Regulator (U9)** | +5V DC | Powers **digital components** |
| **Voltage Inverter (U22)** | -5V DC | Powers **video amplifier** |

- The **-5V supply** is generated by a **switching voltage inverter (U22)**.

---

### **3.2.2 Oscillator**

- The **system clock (6.144 MHz)** is generated by a **crystal oscillator**, using **logic gates (U19)**.

---

### **3.2.3 Reset Circuit**

- Ensures that the **CPU remains in reset mode** briefly after power-on, preventing **unwanted startup errors**.

---

### **3.2.4 Composite Video Output**

- **Video sync signals** are generated using:
  - **Two monostable multivibrators (U15)**
  - **Logic gates (U16)**
- These signals are **combined** to form a **composite sync signal**.

📌 **Figure 21**: *Bode plot of the video amplifier (SPICE simulation).*

---

### **3.2.5 Cassette Interface**

- The **cassette output** is generated by a **simple digital-to-analog converter (DAC)** using **resistors (R25, R26, R28)**.
- The **cassette input** consists of:
  - **An impulse amplifier**
  - **A simple analog-to-digital converter (ADC)**
- The **values of the circuit components** were recalculated due to **errors in the original Galaksija design**.

📌 **Figure 22**: *Output waveform of the cassette interface (measured).*  
📌 **Figure 23**: *Input and output waveform of the impulse amplifier (SPICE simulation).*

---

### **Cassette Interface Voltage Table**

| **AOUT0** | **AOUT1** | **Output Voltage (Ua) [V]** |
|----------|----------|------------------|
| 0        | 0        | 0.0 V            |
| 1        | 0        | 0.5 V            |
| 0        | 1        | 0.5 V            |
| 1        | 1        | 1.0 V            |

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

📌 **Figure 24**: *Timing diagram of the first D flip-flop (interrupt detection).*  
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

I will now proceed with **Chapter 4: Peculiarities of the Original Galaksija Circuit**, including references to **figures and tables**.

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

📌 **Figure 24**: *Timing diagram of the first D flip-flop (interrupt detection).*  
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

## **5.3 Use of Uninitialized Memory**

The OS **assumes certain RAM regions contain valid data at startup**, without explicitly initializing them.

- Some variables are **"randomly" set** at boot, leading to **unpredictable behavior**.
- Programs sometimes **work differently on different Galaksija units**, depending on **RAM contents at startup**.

📌 **Figure 30**: *Diagram illustrating unpredictable behavior caused by uninitialized memory.*

---

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

## **5.5 Stack Manipulation Tricks**

The OS frequently **manipulates the stack pointer directly**, using **non-standard calling conventions**.

📌 **Figure 31**: *Example of direct stack pointer manipulation.*

### **Example: Custom Return Address Handling**
- The **OS dynamically modifies return addresses** in function calls.
- This allows **multiple execution paths from a single function**, but also **breaks standard debugging tools**.

---

## **5.6 Cassette Tape Data Storage**

The **Galaksija OS** uses a **custom data encoding method** for storing programs on **cassette tapes**.

📌 **Figure 32**: *Cassette tape waveform modulation.*

### **Encoding Process**
- Each **bit** is stored as a **specific tone frequency**.
- The system **modulates audio signals** in a way that reduces **dropout errors**.

📌 **Table 8**: *Cassette tape byte structure.*

| **Byte Component** | **Bit Pattern** | **Function** |
|------------------|--------------|-----------|
| **Start Marker** | `10101010` | Synchronization signal |
| **Data Byte** | Variable | Encoded program data |
| **Checksum** | Computed value | Ensures data integrity |

This method allows **reliable data storage on standard audio cassette recorders**, but it is **sensitive to tape speed variations**.

---

# **6. Conclusion**

The **Galaksija microcomputer** was an **innovative product** for its time, designed to be **affordable and accessible** to a wide audience in **former Yugoslavia**. Despite its **hardware limitations**, it demonstrated **clever design strategies** that allowed it to function **efficiently** with **minimal resources**.

The **main findings of this research** are:

### **6.1 Hardware Reconstruction**
- A **fully functional replica** of **Galaksija** was designed using **modern electronic components**.
- The **new Galaksija** maintains **full software compatibility** with the original, allowing it to run **historical programs**.

📌 **Figure 33**: *Final assembled replica of Galaksija.*

---

### **6.2 Challenges in Reverse Engineering**
- **Lack of documentation** made it necessary to perform **reverse engineering** on both **hardware and software**.
- **Undocumented behaviors of the Z80 processor** posed challenges in reproducing the original system.
- **Address decoding limitations** in the original circuit had to be resolved for modern reliability.

📌 **Table 9**: *Comparison of original and replica Galaksija hardware.*

| **Feature** | **Original Galaksija** | **New Galaksija Replica** |
|------------|------------------|------------------|
| **Processor** | Zilog Z80A (NMOS) | Zilog Z84C0008 (CMOS) |
| **ROM Size** | 4 KB | 32 KB |
| **RAM Size** | 2, 4, or 6 KB | 8 KB |
| **Video Output** | Composite Video | Composite Video (Optimized for modern displays) |
| **Cassette Interface** | Analog | Improved ADC/DAC circuit |

---

### **6.3 Future Applications**
- The **replica can be used for educational purposes**, helping students understand **early microcomputer design**.
- The **reverse engineering methodology** developed in this project can be applied to **other historical microcomputers**.
- The **reconstructed documentation** can aid enthusiasts in preserving **Galaksija’s legacy**.

📌 **Figure 34**: *Diagram showing potential improvements in a future Galaksija redesign.*

---

### **6.4 Final Thoughts**
The **Galaksija microcomputer** represents a **unique moment in history**, where **technological ingenuity** overcame **economic and political limitations**. 

Through **reverse engineering**, **hardware replication**, and **software analysis**, this project successfully **revived an important piece of computing history**.

---


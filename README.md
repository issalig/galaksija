# galaksija
My recontrstrucion of Galaksija computer

- Case [(link)](https://github.com/issalig/galaksija/tree/main/case)
  - It contains scad files for the enclosure and the keys.
  - The enclosure can be printed in 4 parts in order to fit in normal printers (aka Ender3)
  - Keys include also an stabilizer for space bar.
  ![galaksija scad](case/galaksija_case.png)
  ![galaksija scad](case/galaksija_keys.png)
  ![galaksija front](case/photos/galaksija_front.jpg)
  
- HW  [(link)](https://github.com/issalig/galaksija/tree/main/hw)
  - In order to build it follow instructions from https://github.com/mejs/galaksija
  - I have used 27C512 for the ROMs in a Manhattan style.
    - You just need add some wires like in the diagram
    ![adapter](hw/2732_to_27c512.png)
    ![pcb](case/photos/galaksija_pcb.jpg)
    - Plan b: Get an adapter such as https://www.ukvac.com/forum/threads/2708-2716-2732-adapter-to-27512-eeprom.67258/
  - Source authentic ICs or you will have problems and a lot of "fun".
  - I have wired BRK, NMI and Reset and connected to buttons on the back side.
    ![pcb2](case/photos/galaksija_pcb2.jpg)
  - Audio connections go to KI and KM
  - C2 is 1 uF (105)
  - Capacitor next to Z80 is 3.3 nF (332)
  
- SW (TO-DO)
  - To load SW I got best results with a laptop. Mobile phone seem to have lower signal voltage and did not work.

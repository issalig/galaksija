# ROM listings
There a 4 for ROMS, from A to D or 1 to 4, i. e., A corresponds to 1 and so on.

Here I provide asm files for roms A, B, and C. For D only some info from a magazine is included.

I have used the rom files available at https://github.com/mejs/galaksija/blob/master/roms/ and they are located in the folder original.

local folder is used to assemble the .asm files

Using make_roms.sh will assemble roms A, B and C.

## ROM A
ROM A has been downloaded from https://github.com/mejs/galaksija/tree/master/roms and comes from avian site https://web.archive.org/web/20221228104534/https://www.tablix.org/~avian/galaksija/rom/rom1.html 

Assembled ROM A is the same as ROM_A_without_ROM_B_init_ver_28.bin

ROM A may be patched by doing two changes. One is cosmetic and is increasing version number. The second change initializes ROM B at start-up to make its commands accessible. If there is no initialization patch, ROM B has to be inisialized at startup by typing A=USR(&1000)  

Differences between ROM_A_without_ROM_B_init_ver_28.bin and ROM_A_with_ROM_B_init_ver_29.bin is just:

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

# ROM B
ROM B has been downloaded from https://www.voja.rs/galaksija/ROM%20B%20Listing%20Scans/ROM_B_listing.htm, then it has been converted to text using and LLM. Of course an intense manual work has been necessary to polish ocr results.

I have used this prompt in order to avoid short or uncomplete answers:
```
'I have a listing of z80 assembler. The typical line contains the address, the code of the instruction 
   in hexadecimal, the number of line, a label, a mnemonic of the instruction, the parameters of the 
   instruction and the comments. I want to convert it to text and translate into English the comments that
   are the end of the lines. Also put a ";" before the comment if it does not have it. please provide the 
   full listing and do not miss any column'
```

There are some differences in byte #1023 
ROM_B_monitor_value_13.bin byte is 13(D)  
ROM_B.bin is 12(C)
ROM_B_monitor_fix.bin 11 (B)

I have added this to the .asm to change it if you want ```MONITOR  EQU     0CH```

# ROM C
This rom is converted from https://github.com/mejs/galaksija/blob/master/roms/ROM%20C/ROM%20C%20listing.pdf
It includes an optional patch to match the original ROM_C.bin

```assembly
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

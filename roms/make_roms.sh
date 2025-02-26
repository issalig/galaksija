# make_roms script
# author: issalig
# date: 25/02/2025

# set -x # verbose

outfile_a="rom_a"
outfile_b="rom_b"
outfile_c="rom_c"

# Paths
SRC="./"
LOCAL="./local"
ORIGINAL="./original"

# Create directories
mkdir -p ${SRC}
mkdir -p ${LOCAL}
mkdir -p ${ORIGINAL}

# Clean local
rm ${LOCAL}/*

# ROM A
sjasmplus --lst=${LOCAL}/${outfile_a}_sjasm.lst --raw=${LOCAL}/${outfile_a}.bin ${SRC}/${outfile_a}.asm 2> /dev/null
diff ${ORIGINAL}/ROM_A_without_ROM_B_init_ver_28.bin ${LOCAL}/${outfile_a}.bin  && echo "ROM A 28 no autostart binary files are the same :)"

sjasmplus -DROM_A_VERSION=29 -DROM_B_AUTOSTART=1 --lst=${LOCAL}/${outfile_a}_sjasm.lst --raw=${LOCAL}/${outfile_a}_29_auto.bin ${SRC}/${outfile_a}.asm 2> /dev/null
diff ${ORIGINAL}/ROM_A_with_ROM_B_init_ver_29.bin ${LOCAL}/${outfile_a}_29_auto.bin  && echo "ROM A 29 autostart binary files are the same :)"


# ROM B
sjasmplus --lst=${LOCAL}/${outfile_b}_sjasm.lst --raw=${LOCAL}/${outfile_b}.bin ${SRC}/${outfile_b}.asm 2> /dev/null
diff ${LOCAL}/${outfile_b}.bin ${ORIGINAL}/ROM_B.bin && echo "ROM B binary files are the same :)"

sjasmplus -DMONITOR_FIX=13 --lst=${LOCAL}/${outfile_b}_13_sjasm.lst --raw=${LOCAL}/${outfile_b}_13.bin ${SRC}/${outfile_b}.asm 2> /dev/null
diff ${LOCAL}/${outfile_b}_13.bin ${ORIGINAL}/ROM_B_monitor_value_13.bin && echo "ROM B fix 13 binary files are the same :)"

sjasmplus -DMONITOR_FIX=11 --lst=${LOCAL}/${outfile_b}_11_sjasm.lst --raw=${LOCAL}/${outfile_b}_11.bin ${SRC}/${outfile_b}.asm 2> /dev/null
diff ${LOCAL}/${outfile_b}_11.bin ${ORIGINAL}/ROM_B_monitor_fix.bin && echo "ROM B fix 11 binary files are the same :)"

# ROM C
sjasmplus --lst=${LOCAL}/${outfile_c}_sjasm.lst --raw=${LOCAL}/${outfile_c}.bin ${SRC}/${outfile_c}.asm 2> /dev/null
diff ${LOCAL}/${outfile_c}.bin ${ORIGINAL}/ROM_C.bin && echo "ROM C binary files are the same :)"

echo "Results are in ${LOCAL} directory"

# Useful commands
# z80asm -i ${SRC}/rom_a.asm -o ${LOCAL}/${outfile_a}.bin
# z80dasm ${LOCAL}/${outfile_a}.bin -l -g 0x0000 -a > ${LOCAL}/${outfile_a}_z80dasm.asm 2> /dev/null
# z80dasm ${LOCAL}/${outfile_c}.bin -l -g 0x1000 -a > ${LOCAL}/${outfile_b}_z80dasm.asm 2> /dev/null
# z80dasm ${LOCAL}/${outfile_c}.bin -l -g 0xe000 -a > ${LOCAL}/${outfile_c}_z80dasm.asm 2> /dev/null
# pasmo -v ${outfile_b}.asm ${outfile_b}.bin 
# pasmo --alocal ${outfile_b}.asm ${outfile_b}.bin ${outfile_b}.lst

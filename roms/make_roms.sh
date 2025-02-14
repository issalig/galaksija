# out files
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
#z80asm -i ${SRC}/rom_a.asm -o ${LOCAL}/${outfile_a}.bin
sjasmplus --raw=${LOCAL}/${outfile_a}.bin ${SRC}/${outfile_a}.asm 2> /dev/null
sjasmplus --lst=${LOCAL}/${outfile_a}_sjasm.lst ${SRC}/${outfile_a}.asm 2> /dev/null
z80dasm ${LOCAL}/${outfile_a}.bin -l -g 0x0000 -a > ${LOCAL}/${outfile_a}_z80dasm.asm 2> /dev/null

diff ${ORIGINAL}/ROM_A_without_ROM_B_init_ver_28.bin ${LOCAL}/${outfile_a}.bin  && echo "ROM A binary files are the same :)"

# ROM B
# Remove unwanted lines or fields
#python listing2asm.py -i ${SRC}/${outfile_b}.lst -o ${SRC}/${outfile_b}.asm

# Assemble local file and generate listing file
sjasmplus --raw=${LOCAL}/${outfile_b}.bin ${SRC}/${outfile_b}.asm 2> /dev/null
sjasmplus --lst=${LOCAL}/${outfile_b}_sjasm.lst ${SRC}/${outfile_b}.asm 2> /dev/null

# Pasmo (commented out)
# pasmo -v ${outfile_b}.asm ${outfile_b}.bin 
# pasmo --alocal ${outfile_b}.asm ${outfile_b}.bin ${outfile_b}.lst

# Disassemble local file for further comparison
#z80dasm ${LOCAL}/${outfile_b}.bin -l -g 0x1000 -a > ${LOCAL}/${outfile_b}_z80dasm.asm 2> /dev/null
# Disassemble ROM_B.bin
#z80dasm ${ORIGINAL}/ROM_B.bin -l -g 0x1000 -a > ${ORIGINAL}/ROM_B_z80dasm.asm 2> /dev/null
#diff  ${LOCAL}/${outfile_b}_z80dasm.asm ${ORIGINAL}/ROM_B_z80dasm.asm

diff ${LOCAL}/${outfile_b}.bin ${ORIGINAL}/ROM_B.bin && echo "ROM B binary files are the same :)"

# ROM C

# Assemble listing file
sjasmplus --raw=${LOCAL}/${outfile_c}.bin ${SRC}/${outfile_c}.asm 2> /dev/null
sjasmplus --lst=${LOCAL}/${outfile_c}_sjasm.lst ${SRC}/${outfile_c}.asm 2> /dev/null

# Disassemble listing file
#z80dasm ${LOCAL}/${outfile_c}.bin -l -g 0xe000 -a > ${LOCAL}/${outfile_c}_z80dasm.asm 2> /dev/null
# Disassemble ROM_C.bin
#z80dasm ${ORIGINAL}/ROM_C.bin -l -g 0xe000 -a > ${ORIGINAL}/ROM_C_z80dasm.asm 2> /dev/null
#diff  ${LOCAL}/${outfile_c}_z80dasm.asm ${ORIGINAL}/ROM_C_z80dasm.asm

diff ${LOCAL}/${outfile_c}.bin ${ORIGINAL}/ROM_C.bin && echo "ROM C binary files are the same :)"

echo "Results are in ${LOCAL} directory"
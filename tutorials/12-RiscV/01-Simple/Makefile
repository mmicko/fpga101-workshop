RISCV_TOOLS_PREFIX = riscv64-unknown-elf-
CXX = $(RISCV_TOOLS_PREFIX)g++
CC = $(RISCV_TOOLS_PREFIX)gcc
AS = $(RISCV_TOOLS_PREFIX)gcc
ICEPROG = iceprog

all: firmware.bin

# ---- iCE40 UP5k Breakout Board ----

upload: firmware.bin
	$(ICEPROG) -o 1M firmware.bin

# ---- Example Firmware ----
firmware.elf: sections.lds start.s firmware.c sections.c
	$(CC) -O3 -nostartfiles -mabi=ilp32 -march=rv32ic -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -o firmware.elf start.s sections.c firmware.c -lgcc

firmware.bin: firmware.elf
	$(RISCV_TOOLS_PREFIX)objcopy  -O binary firmware.elf firmware.bin

# ---- Clean ----

clean:
	rm -f firmware.elf firmware.bin

.PHONY: upload clean


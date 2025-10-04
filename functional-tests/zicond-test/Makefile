RISCV_PREFIX ?= riscv64-unknown-elf
CC = $(RISCV_PREFIX)-gcc
LD = $(RISCV_PREFIX)-gcc
OBJCOPY = $(RISCV_PREFIX)-objcopy

%.elf: %.s
	$(CC) -mabi=ilp32 -march=rv32im_zicsr_zicond -c -o $@ $<
	$(CC) -mabi=ilp32 -march=rv32im_zicsr_zicond -ffreestanding -nostdlib -T ../tests.ld -o $@ $<

%.ihex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

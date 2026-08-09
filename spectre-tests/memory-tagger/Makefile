CC = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
CFLAGS = -mabi=ilp32 -march=rv32im_zicsr -ffreestanding -nostdlib
LDFLAGS = -T tests.ld

SOURCES = $(wildcard *.s)

BINS = $(SOURCES:.s=.bin)
TAGS = $(SOURCES:.s=_tags.bin)

all: $(BINS) $(TAGS)

%.elf: %.s tests.ld
	$(CC) -mabi=ilp32 -march=rv32im_zicsr -c -o $@ $<
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary -j .text -j .data $< $@

%_tags.bin: %.elf
	$(OBJCOPY) -O binary -j .tags $< $@

sim: $(BINS) $(TAGS)
	@if [ -z "$(INSECURE)" ] || [ -z "$(SECURE)" ]; then \
		echo "Pass a secure and insecure version of Proteus using the SECURE and INSECURE flags"; \
		exit 1; \
	fi
	./eval.py $(INSECURE) $(SECURE)

clean:
	rm -f *.elf *.bin *.fst *.vcd

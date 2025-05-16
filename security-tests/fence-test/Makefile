TOOLCHAIN=riscv32-unknown-elf

%.elf: %.s
	$(TOOLCHAIN)-gcc -mabi=ilp32 -march=rv32im_zicsr -c -o $@ $<
	$(TOOLCHAIN)-gcc -mabi=ilp32 -march=rv32im_zicsr -ffreestanding -nostdlib -T ../tests.ld -o $@ $<

%.ihex: %.elf
	$(TOOLCHAIN)-objcopy -O ihex $< $@

%.bin: %.elf
	$(TOOLCHAIN)-objcopy -O binary $< $@

%.objdump: %.elf
	$(TOOLCHAIN)-objdump -s --section=.data $< > $@
	$(TOOLCHAIN)-objdump -d $< >> $@


clean:
	rm -f *.bin *.ihex *.elf *.vcd *.objdump

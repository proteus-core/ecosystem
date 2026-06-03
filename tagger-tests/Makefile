CC = riscv32-unknown-elf-gcc
OBJCOPY = riscv32-unknown-elf-objcopy
CFLAGS = -nostdlib
LDFLAGS = -T link.ld -Wl,--no-warn-rwx-segments

OUT_DIR = output_$(GRAN)
TEST_DIR = tests_$(GRAN)

SOURCES = $(wildcard $(TEST_DIR)/*.S)

TESTS = $(notdir $(SOURCES:.S=))

BINS = $(TESTS:%=%.bin)
TAGS = $(TESTS:%=%_tags.bin)
SIM_TARGETS = $(TESTS:%=sim-%)

all: $(BINS) $(TAGS)

sim-all: $(SIM_TARGETS)

%.elf: $(TEST_DIR)/%.S link.ld
	@$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

%.bin: %.elf
	@$(OBJCOPY) -O binary -j .text -j .data $< $@

%_tags.bin: %.elf
	@$(OBJCOPY) -O binary -j .tags $< $@

sim-%: %.bin %_tags.bin
	@if [ -z "$(SIM)" ]; then \
		echo "SIM undefined. Exiting"; \
		exit 1; \
	fi
	@$(SIM) --dump-fst $(OUT_DIR)/$*_sim.fst \
	        --dump-mem $(OUT_DIR)/$*_mem.bin \
	        --dump-tags $(OUT_DIR)/$*_tags.bin \
	        --csv-stores $(OUT_DIR)/$*_stores.csv \
	        --tag-file $*_tags.bin $*.bin > /dev/null
	@uv run tags --test $* \
	             --signals $(OUT_DIR)/$*_sim.fst \
	             --expStores expected_$(GRAN)/$*_stores.csv \
	             --actStores $(OUT_DIR)/$*_stores.csv \
	             --sourceTags $*_tags.bin \
	             --actTags $(OUT_DIR)/$*_tags.bin \
	             --output $(OUT_DIR)/$*_output.csv \
				 --granularity $(GRAN)

clean:
	rm -f *.elf *.bin *_tags.bin
	rm -rf $(OUT_DIR)
	mkdir -p $(OUT_DIR)

.PHONY: all clean sim-all

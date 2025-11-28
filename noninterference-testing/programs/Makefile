include Makefile.include
BUILD_DIR = build
VCD_DIR = vcd
BOOT = 0
LDFLAGS += -T layout.lds

PROGRAMS := pht-test1 pht-test2 ssb-test1 psf-test1
FENCE_VALUES := FULLFENCE NOFENCE
LEAK_VALUES := LEAKLOAD LEAKSTORE LEAKBR LEAKJMP LEAKDIV
EXP_NUMBER := EXP1 EXP0

# Generate all combinations of targets
TARGETS := $(foreach P,$(PROGRAMS), $(foreach Z,$(EXP_NUMBER), $(foreach X,$(FENCE_VALUES),$(foreach Y,$(LEAK_VALUES),$(P)_$(X)_$(Y)_$(Z)))))

ELF_TARGETS := $(addsuffix .elf, $(TARGETS))
BIN_TARGETS := $(addsuffix .bin, $(TARGETS))
VCD_TARGETS := $(addsuffix .vcd, $(TARGETS))
OBJDUMP_TARGETS := $(addsuffix .objdump, $(TARGETS))

.PHONY: all build elf bin vcd objdump ssb

# Default target
all: elf bin

dirs:
	@mkdir -p $(BUILD_DIR)

elf: dirs $(ELF_TARGETS)
bin: dirs $(BIN_TARGETS)
vcd: dirs $(VCD_TARGETS)
objdump: dirs $(OBJDUMP_TARGETS)

include Makefile.include
BUILD_DIR = build
MODULES =
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

# Default target
all: elf bin

elf: $(ELF_TARGETS)
bin: $(BIN_TARGETS)
vcd: $(VCD_TARGETS)
objdump: $(OBJDUMP_TARGETS)


SSB_TARGETS := $(foreach Z,$(EXP_NUMBER), $(foreach X,$(FENCE_VALUES),$(foreach Y,$(LEAK_VALUES),ssb-test1_$(X)_$(Y)_$(Z))))
ssb: $(addsuffix .vcd, $(SSB_TARGETS)) $(addsuffix .objdump, $(SSB_TARGETS))

CORE ?= riscv.CoreExtMem

# Only applicable for CORE=riscv.CoreExtMem:
PIPELINE ?= Static
ISA ?= RV32I
# To instead build with a custom config file, define CONFIG=<path>

BASE_DIR ?= ../core
BUILD_DIR = build
TOPLEVEL_MODULE = Core
VERILOG_FILE_NAME = $(TOPLEVEL_MODULE).v
VERILOG_INPUT = $(BUILD_DIR)/$(VERILOG_FILE_NAME)
VERILATOR_NAME = V$(TOPLEVEL_MODULE)
EXE_NAME ?= sim
EXE_FILE = $(BUILD_DIR)/$(EXE_NAME)

CFLAGS = -O3 -std=c++20
CFLAGS += $(EXTRA_CFLAGS)

all: $(EXE_FILE)

$(EXE_FILE): $(BUILD_DIR)/$(VERILATOR_NAME).mk main.cpp
	make -C $(BUILD_DIR) -f $(VERILATOR_NAME).mk $(EXE_NAME)

$(BUILD_DIR)/$(VERILATOR_NAME).mk: $(VERILOG_INPUT)
	verilator --cc --exe --trace-fst -O3 -CFLAGS "$(CFLAGS)" -Wno-WIDTH -Wno-UNOPTFLAT -Wno-CMPCONST -Wno-UNSIGNED -Mdir $(BUILD_DIR) $(VERILOG_INPUT) main.cpp -o $(EXE_NAME)

$(VERILOG_INPUT): $(BASE_DIR)/$(VERILOG_FILE_NAME)
	mkdir -p $(@D)
	cp $< $@

$(BASE_DIR)/$(VERILOG_FILE_NAME): FORCE
ifeq ($(CORE),riscv.CoreExtMem)
ifdef CONFIG
	cd $(BASE_DIR); sbt "runMain $(CORE) $(abspath $(CONFIG))"
else
	cd $(BASE_DIR); sbt "runMain $(CORE) $(PIPELINE) $(ISA)"
endif
else
	cd $(BASE_DIR); sbt "runMain $(CORE)"
endif

FORCE:

clean:
	rm -rf $(BUILD_DIR)

#!/bin/bash

set -ex

git clone --recurse-submodules --branch main https://github.com/proteus-core/proteus.git core
make -C simulation CORE=riscv.CoreExtMem PIPELINE=Static ISA=RV32I && cp simulation/build/sim simulation/build/sim-32-i
make -C simulation CORE=riscv.CoreExtMem PIPELINE=Dynamic ISA=RV32I && cp simulation/build/sim simulation/build/sim-32-o
make -C simulation CORE=riscv.CoreExtMem PIPELINE=Static ISA=RV64I && cp simulation/build/sim simulation/build/sim-64-i
make -C simulation CORE=riscv.CoreExtMem PIPELINE=Dynamic ISA=RV64I && cp simulation/build/sim simulation/build/sim-64-o

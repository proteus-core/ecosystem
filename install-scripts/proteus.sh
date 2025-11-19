#!/bin/bash

set -ex

git clone --recurse-submodules --branch main https://github.com/proteus-core/proteus.git core
make -C simulation CORE=riscv.CoreExtMem32 && cp simulation/build/sim simulation/build/sim-32-i
make -C simulation CORE=riscv.CoreDynamicExtMem32 && cp simulation/build/sim simulation/build/sim-32-o
make -C simulation CORE=riscv.CoreExtMem64 && cp simulation/build/sim simulation/build/sim-64-i
make -C simulation CORE=riscv.CoreDynamicExtMem64 && cp simulation/build/sim simulation/build/sim-64-o

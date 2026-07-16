#!/bin/bash

set -ex

################################################################################
# Install GNU RISC-V toolchain
################################################################################

ROOT_DIR="$(pwd)"
SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"

$SUDO apt-get -yqq install git autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build

mkdir -p toolchain-tmp && cd toolchain-tmp
git clone --branch 2026.05.06 --depth 1 --shallow-submodules https://github.com/riscv/riscv-gnu-toolchain .
./configure --prefix="${ROOT_DIR}/gnu" --with-cmodel=medany --with-multilib-generator="rv32im_zicsr_zifencei_zicond-ilp32--;rv64im_zicsr_zifencei_zicond-lp64--" --enable-debug-info && make -j$(nproc) && make clean
echo "PATH=\"${ROOT_DIR}/gnu/bin:\$PATH\"" >> ~/.bashrc
cd .. && rm -rf toolchain-tmp

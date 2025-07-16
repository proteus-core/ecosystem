FROM ubuntu:24.04

# Set to noninteractive mode
ARG DEBIAN_FRONTEND=noninteractive

ARG INSTALL_TOOLCHAIN
ARG INSTALL_EVAL_HD
ARG INSTALL_PROTEUS
RUN echo "Install RISC-V toolchain: ${INSTALL_TOOLCHAIN}"
RUN echo "Install EVAL-HD: ${INSTALL_EVAL_HD}"
RUN echo "Setup Proteus core: ${INSTALL_PROTEUS}"

################################################################################
# Basic dependencies
################################################################################

RUN apt-get update && apt-get -yqq install build-essential git openjdk-17-jdk verilator libz-dev gcc-riscv64-unknown-elf python3-pip python3-venv

WORKDIR /ecosystem
COPY . .

RUN ./install-scripts/sbt.sh

WORKDIR /ecosystem/waveform-analysis
RUN python3 -m venv .venv && .venv/bin/pip install -r requirements.txt

WORKDIR /ecosystem
RUN if [ "${INSTALL_TOOLCHAIN}" = "true" ] ; then ./install-scripts/toolchain.sh ; else echo Skipping RISC-V toolchain... ; fi
RUN if [ "${INSTALL_EVAL_HD}" = "true" ] ; then ./install-scripts/eval-hd.sh ; else echo Skipping EVAL-HD setup... ; fi
RUN if [ "${INSTALL_PROTEUS}" = "true" ] ; then ./install-scripts/proteus.sh ; else echo Skipping Proteus core setup... ; fi

CMD /bin/bash

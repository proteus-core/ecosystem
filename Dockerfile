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

RUN apt-get update && apt-get -yqq install build-essential git openjdk-17-jdk verilator libz-dev gcc-riscv64-unknown-elf python3-pip python3-venv gtkwave scons

WORKDIR /ecosystem
COPY ./benchmarks ./benchmarks
COPY ./cpu-interfaces ./cpu-interfaces
COPY ./formal-verification ./formal-verification
COPY ./functional-tests ./functional-tests
COPY ./install-scripts ./install-scripts
COPY ./newlib-bsp ./newlib-bsp
COPY ./noninterference-testing ./noninterference-testing
COPY ./simulation ./simulation
COPY ./synthesis ./synthesis
COPY ./waveform-analysis ./waveform-analysis

RUN ./install-scripts/sbt.sh
RUN ./install-scripts/python-modules.sh

WORKDIR /ecosystem
RUN if [ "${INSTALL_TOOLCHAIN}" = "true" ] ; then ./install-scripts/toolchain.sh ; else echo Skipping RISC-V toolchain... ; fi
RUN if [ "${INSTALL_EVAL_HD}" = "true" ] ; then ./install-scripts/eval-hd.sh ; else echo Skipping EVAL-HD setup... ; fi
RUN if [ "${INSTALL_PROTEUS}" = "true" ] ; then ./install-scripts/proteus.sh ; else echo Skipping Proteus core setup... ; fi

# add RISC-V toolchain to path if it was installed (https://stackoverflow.com/a/51264575)
ENV TOOLCHAIN_PATH=${INSTALL_TOOLCHAIN:+/opt/riscv/bin:}
ENV TOOLCHAIN_PATH=${TOOLCHAIN_PATH:-}

ENV PATH=${TOOLCHAIN_PATH}${PATH}

CMD /bin/bash

FROM ghcr.io/proteus-core/riscv-toolchain:latest

ARG DEBIAN_FRONTEND=noninteractive

ARG INSTALL_EVAL_HD=false
ARG INSTALL_PROTEUS=false
ARG INSTALL_RISCV_FORMAL=false
RUN echo "Install EVAL-HD: ${INSTALL_EVAL_HD}"
RUN echo "Setup Proteus core: ${INSTALL_PROTEUS}"
RUN echo "Install riscv-formal: ${INSTALL_RISCV_FORMAL}"

RUN apt-get update && apt-get -yqq install openjdk-17-jdk verilator libz-dev python3-pip python3-venv gtkwave scons

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

RUN if [ "${INSTALL_EVAL_HD}" = "true" ] ; then ./install-scripts/eval-hd.sh ; else echo Skipping EVAL-HD setup... ; fi
RUN if [ "${INSTALL_PROTEUS}" = "true" ] ; then ./install-scripts/proteus.sh ; else echo Skipping Proteus core setup... ; fi
RUN if [ "${INSTALL_RISCV_FORMAL}" = "true" ] ; then ./install-scripts/riscv-formal.sh ; else echo Skipping riscv-formal setup... ; fi

CMD ["/bin/bash"]

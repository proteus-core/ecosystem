FROM ubuntu:24.04

# Set to noninteractive mode
ARG DEBIAN_FRONTEND=noninteractive

################################################################################
# Basic dependencies
################################################################################

RUN apt-get update && apt-get -yqq install build-essential git openjdk-17-jdk verilator libz-dev gcc-riscv64-unknown-elf python3-pip python3-venv

################################################################################
# Install scala and sbt (https://www.scala-sbt.org/)
################################################################################

RUN apt-get update
RUN apt-get install apt-transport-https curl gnupg -yqq
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
RUN chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
RUN apt-get update
RUN apt-get install sbt

################################################################################
# Build dynamic pipeline and run RISC-V tests
################################################################################

WORKDIR /proteus
COPY . .
RUN git clone https://github.com/proteus-core/proteus.git core
RUN make -C simulation clean
RUN make -C simulation CORE=riscv.CoreDynamicExtMem
RUN make -C functional-tests CORE=riscv.CoreDynamicExtMem BUILD_CORE=0 RISCV_PREFIX=riscv64-unknown-elf  # currently BUILD_CORE=0 seems to not have an effect

WORKDIR /proteus/waveform-analysis
RUN python3 -m venv .venv && .venv/bin/pip install -r requirements.txt

CMD /bin/bash

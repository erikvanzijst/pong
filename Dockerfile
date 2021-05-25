# Container used to run tests and build iCE40 bitstream in CI

FROM ubuntu:20.04

LABEL description="Container for synthesizing FPGA and ASIC designs"
LABEL maintainer="erik.van.zijst@gmail.com"

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
    clang pkg-config cmake libreadline-dev flex bison tcl tcl-dev \
    libboost-all-dev libeigen3-dev curl wget git libftdi-dev python3 \
    python3-dev python3-pip apt-utils gperf gtkwave apt-transport-https

RUN pip3 install cocotb

# Install verible:
WORKDIR /usr
RUN curl -sL https://github.com/google/verible/releases/download/v0.0-1203-ge56b205/verible-v0.0-1203-ge56b205-Ubuntu-20.04-focal-x86_64.tar.gz | \
    tar zxv --strip-components=1

# Install yosys, icestorm, arachepnr and nextpnr:
WORKDIR /tmp
RUN (wget https://raw.githubusercontent.com/esden/WTFpga/master/summon-fpga-tools.sh && \
    chmod +x summon-fpga-tools.sh && \
    ./summon-fpga-tools.sh PREFIX=/usr/local/ )

# Install iverilog:
RUN curl -sL https://github.com/steveicarus/iverilog/archive/refs/tags/v11_0.tar.gz | tar zxv && \
    cd iverilog-11_0 && \
    autoconf && ./configure && make && make install

# Install RISC-V compiler toolchain:
RUN mkdir /riscv
WORKDIR /riscv
RUN curl -sL https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14.tar.gz | \
    tar zxv --strip-components=1

WORKDIR /
ENV PATH="${PATH}:/riscv/bin"

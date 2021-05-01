FROM ubuntu:20.04

LABEL description="Container for synthesizing FPGA and ASIC designs"
LABEL maintainer="erik.van.zijst@gmail.com"

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
    clang pkg-config cmake libreadline-dev flex bison tcl tcl-dev \
    libboost-all-dev libeigen3-dev curl wget git libftdi-dev python3 \
    python3-dev apt-utils gperf

WORKDIR /tmp
RUN (wget https://raw.githubusercontent.com/esden/WTFpga/master/summon-fpga-tools.sh && \
    chmod +x summon-fpga-tools.sh && \
    ./summon-fpga-tools.sh PREFIX=/usr/local/ )

RUN curl -sL https://github.com/steveicarus/iverilog/archive/refs/tags/v11_0.tar.gz | tar zxv && \
    cd iverilog-11_0 && \
    autoconf && ./configure && make && make install

ENTRYPOINT ["echo $GITHUB_SHA"]

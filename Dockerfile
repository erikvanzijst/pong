FROM ubuntu:20.04

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential \
    clang pkg-config cmake libreadline-dev flex bison tcl tcl-dev \
    libboost-all-dev libeigen3-dev curl wget git libftdi-dev python3 \
    python3-dev apt-utils

RUN curl -s https://raw.githubusercontent.com/esden/WTFpga/master/summon-fpga-tools.sh | bash

ENTRYPOINT ["echo $GITHUB_SHA"]

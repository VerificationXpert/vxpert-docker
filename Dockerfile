# Docker container for RTL simulation and design verification tools
#
# Copyright (c) 2024 VerificationXpert
# This code is licensed under Apache License 2.0 (see LICENSE for details)

FROM python:3.11

# basic setup, including Python, Node.js installations
# (Node.js is needed for some GitHub Actions)
RUN \
apt update -y && \
apt install -y curl unzip git libsystemc libsystemc-dev && \
python3 -m pip install --upgrade pip && \
curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && \
apt install -y nodejs && \
apt clean && \
rm -rf /var/lib/apt/lists/*

# install Verilator
# https://verilator.org/guide/latest/install.html#git-quick-install
RUN \
apt update -y && \
apt install -y git help2man perl python3 make autoconf g++ flex bison \
    ccache libgoogle-perftools-dev numactl perl-doc && \
apt install -y libfl2 && \
apt install -y libfl-dev && \
git clone https://github.com/verilator/verilator && \
cd verilator && \
git pull && \
git checkout v5.028 && \
autoconf && \
./configure && \
make -j `nproc` && \
make install && \
cd .. && \
rm -rf verilator && \
apt clean && \
rm -rf /var/lib/apt/lists/*

# install Icarus Verilog
# https://iverilog.fandom.com/wiki/Installation_Guide#Obtaining_Source_From_git
RUN \
apt update -y && \
apt install -y autoconf gperf && \
git clone https://github.com/steveicarus/iverilog.git && \
cd iverilog && \
git pull && \
git checkout v12_0 && \
sh autoconf.sh && \
./configure && \
make -j `nproc` && \
make install && \
cd .. && \
rm -rf iverilog && \
apt clean && \
rm -rf /var/lib/apt/lists/*

# Install Cocotb, pytest, and other Python tools for verification
RUN \
python3 -m pip install --upgrade pip && \
pip install cocotb cocotbext-axi cocotbext-spi cocotbext-uart pytest pytest-cov && \
pip install cocotb-test && \
pip install cookiecutter

# Install Corsair register tool
RUN \
python3 -m pip install --upgrade pip && \
pip install corsair



# Set environment variables
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LD_LIBRARY_PATH=/usr/local/lib

# Clean up unnecessary files to reduce image size
RUN apt clean && \
rm -rf /var/lib/apt/lists/*

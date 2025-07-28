#!/bin/bash

###########################################################################
# Script: compiletools.sh
# Purpose: 
#   Installs essential development tools and dependencies for benchmarking
#   and performance testing on Debian/Ubuntu and RHEL-based systems.
#   It builds and installs common tools like FIO, iPerf, SockPerf, and
#   Elbencho (with optional S3 support), and prepares a `labuser` environment.
#
# Logs:
#   - /tmp/compiletools-out.log: Full stdout/stderr from execution.
#   - /tmp/cloud-init-out.txt: Summary of key status messages.
#
# Requirements:
#   - Must be run as root.
#   - Internet access required for package installation and git cloning.
#
# Author: Karl Vietmeier
# Updated: July 2025
###########################################################################

exec > >(tee -a /tmp/compiletools-out.log) 2>&1
echo "compiletools.sh started at $(date)"

LOG_FILE="/tmp/cloud-init-out.txt"

log_and_continue() {
  echo "$1" >> "$LOG_FILE"
  if [ $? -ne 0 ]; then
    echo "Warning: $1 failed!" >> "$LOG_FILE"
  fi
}

# Install dependencies
if [ -f /etc/debian_version ]; then
  apt-get update -y
  chmod -x /etc/update-motd.d/*
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    debhelper \
    libboost-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libssl-dev \
    libncurses-dev \
    libnuma-dev \
    libaio-dev \
    librdmacm1 \
    bpfcc-tools \
    man-db \
    chrony \
    dnsutils \
    nfs-common \
    cmake \
    dkms \
    autoconf \
    libcurl4-openssl-dev \
    uuid-dev \
    zlib1g-dev

elif [ -f /etc/redhat-release ]; then
  dnf groupinstall -y "Development Tools"
  dnf install -y \
    epel-release \
    numactl-devel \
    libaio-devel \
    boost-devel \
    boost-program-options \
    boost-system \
    boost-thread \
    ncurses-devel \
    openssl-devel \
    bcc-tools \
    man-db \
    chrony \
    bind-utils \
    nfs-utils \
    cmake \
    rdma-core \
    libcurl4-openssl-dev \
    libcurl-devel \
    libuuid-devel \
    zlib \
    zlib-devel \
    libarchive
fi

cd /root
mkdir -p .local/bin git
cd git

# DOOL
git clone https://github.com/scottchiefbaker/dool.git
cd dool
./install.py
cd ..

# FIO
git clone https://github.com/axboe/fio.git
cd fio
./configure
make
make install
cd ..

# iPerf
git clone https://github.com/esnet/iperf.git
cd iperf
./configure
make
make install
cd ..
echo "/usr/local/lib" > /etc/ld.so.conf.d/iperf.conf && log_and_continue "Added /usr/local/lib to ld.so.conf.d"
ldconfig && log_and_continue "Ran ldconfig to refresh library links"

# SockPerf
git clone https://github.com/mellanox/sockperf
cd sockperf
./autogen.sh
./configure
make
make install
cd ..

# Elbencho
git clone https://github.com/breuner/elbencho.git
cd elbencho
make S3_SUPPORT=1 -j "$(nproc)"

if [ -f /etc/redhat-release ]; then
  make rpm && dnf install -y ./packaging/RPMS/x86_64/elbencho*.rpm
elif [ -f /etc/debian_version ]; then
  make install
fi

cd /root

# Setup labuser
mkdir -p /home/labuser/output
chown -R labuser:labuser /home/labuser/output
cd /home/labuser
git clone https://github.com/kvietmeier/scripts.git
chown -R labuser:labuser /home/labuser/scripts

# Enable and restart chrony
if [ -f /etc/debian_version ]; then
  systemctl enable chrony
  systemctl restart chrony
elif [ -f /etc/redhat-release ]; then
  systemctl enable chronyd
  systemctl restart chronyd
fi

echo "compiletools.sh completed at $(date)" >> "$LOG_FILE"

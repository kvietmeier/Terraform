#!/bin/bash
# Run as root

exec > >(tee -a /tmp/compiletools-out.log) 2>&1
echo "compiletools_full.sh started at $(date)"

LOG_FILE="/tmp/cloud-init-out.txt"
log_and_continue() {
    echo "$1" >> "$LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "Warning: $1 failed!" >> "$LOG_FILE"
    fi
}

# -------------------------------
# Ensure labuser exists
# -------------------------------
if ! id -u labuser >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo labuser
    echo "labuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/labuser
fi

LABUSER_HOME="/home/labuser"
mkdir -p "$LABUSER_HOME/output"
mkdir -p "$LABUSER_HOME/git"
chown -R labuser:labuser "$LABUSER_HOME"

# -------------------------------
# Labuser bashrc
# -------------------------------
cat <<'EOF' >> "$LABUSER_HOME/.bashrc"
alias la="ls -Av"
alias ls="ls -hF --color=auto"
alias l="ls -CFv"
alias ll='ls -lhvF --group-directories-first'
alias lla='ls -alhvF --group-directories-first'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias cdb='cd -'
alias cdu='cd ..'
alias df='df -kh'
alias du='du -h'
set -o vi
bind 'set bell-style none'
EOF
chown labuser:labuser "$LABUSER_HOME/.bashrc"
chmod 644 "$LABUSER_HOME/.bashrc"

# -------------------------------
# Root bashrc
# -------------------------------
cat <<'EOF' >> /root/.bashrc
alias ls="ls -hFv --color=auto"
alias l="ls -CFv"
alias la="ls -Av"
alias ll='ls -lhvF --group-directories-first'
alias lla='ls -alhvF --group-directories-first'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias cdb='cd -'
alias cdu='cd ..'
alias df='df -kh'
alias du='du -h'
set -o vi
bind 'set bell-style none'
EOF

# -------------------------------
# OS detection & packages
# -------------------------------
if [ -f /etc/debian_version ]; then
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential debhelper libboost-dev libboost-program-options-dev \
        libboost-system-dev libboost-thread-dev libssl-dev libncurses-dev \
        libnuma-dev libaio-dev librdmacm1 bpfcc-tools man-db chrony dnsutils \
        docker nfs-common cmake dkms autoconf libcurl4-openssl-dev uuid-dev \
        zlib1g-dev

    # Disable unattended-upgrades
    echo 'APT::Periodic::Update-Package-Lists "0";' > /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "0";' >> /etc/apt/apt.conf.d/20auto-upgrades
    systemctl stop unattended-upgrades || true
    systemctl disable unattended-upgrades || true
    systemctl stop apt-daily.timer apt-daily-upgrade.timer || true
    systemctl disable apt-daily.timer apt-daily-upgrade.timer || true
    systemctl mask apt-daily.service apt-daily-upgrade.service || true

elif [ -f /etc/redhat-release ]; then
    dnf groupinstall -y "Development Tools"
    dnf install -y epel-release numactl-devel libaio-devel boost-devel \
        boost-program-options boost-system boost-thread ncurses-devel \
        openssl-devel docker bcc-tools man-db chrony bind-utils nfs-utils \
        cmake rdma-core libcurl-devel libuuid-devel zlib zlib-devel libarchive
fi

# -------------------------------
# Chrony cloud-agnostic
# -------------------------------
CHRONY_CONF="/etc/chrony/chrony.conf"
if curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/ >/dev/null 2>&1; then
    echo "server 169.254.169.123 prefer iburst" > $CHRONY_CONF
elif curl -s --connect-timeout 1 -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/ >/dev/null 2>&1; then
    echo "server metadata.google.internal iburst" > $CHRONY_CONF
elif curl -s --connect-timeout 1 http://169.254.169.254/metadata/instance?api-version=2021-02-01 -H "Metadata:true" >/dev/null 2>&1; then
    echo "server time.windows.com iburst" > $CHRONY_CONF
else
    echo "pool pool.ntp.org iburst" > $CHRONY_CONF
fi

cat <<EOF >> $CHRONY_CONF
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
allow 0.0.0.0/0
bindcmdaddress 127.0.0.1
bindcmdaddress ::1
EOF

if [ -f /etc/debian_version ]; then
    systemctl enable chrony
    systemctl restart chrony
elif [ -f /etc/redhat-release ]; then
    systemctl enable chronyd
    systemctl restart chronyd
fi

# -------------------------------
# Compile tools (FIO, DOOL, iPerf, SockPerf, Elbencho)
# -------------------------------
cd /root
mkdir -p .local/bin
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
echo "/usr/local/lib" > /etc/ld.so.conf.d/iperf.conf
ldconfig

# SockPerf
git clone https://github.com/mellanox/sockperf
cd sockperf
./autogen.sh
./configure
make
make install
cd ..

# Elbencho with S3 support
git clone https://github.com/breuner/elbencho.git
cd elbencho
make S3_SUPPORT=1 -j "$(nproc)"
if [ -f /etc/redhat-release ]; then
    make rpm && dnf install -y ./packaging/RPMS/x86_64/elbencho*.rpm
elif [ -f /etc/debian_version ]; then
    make install
fi
cd /root

echo "compiletools_full.sh completed at $(date)" >> /tmp/cloud-init-out.txt

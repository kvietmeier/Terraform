#!/bin/bash
###=============================================================================###
# lab_bootstrap.sh — single source of truth for multi-cloud lab VM bootstrap
#
# Invoked by cloud-init (see cloud-init-universal.yaml). Safe to run standalone
# as root for debugging:  sudo bash lab_bootstrap.sh
#
# Covers: AWS, Azure, GCP (and OCI NTP if present) on Debian/Ubuntu and
# RHEL/Rocky/CentOS/Azure Linux.
#
# Env knobs:
#   INSTALL_BENCH_TOOLS=true|false   Compile fio/iperf/dool/sockperf/elbencho
#                                    (default: true for benchmark lab images)
#   CLONE_LAB_SCRIPTS=true|false     Clone kvietmeier/scripts into labuser home
#                                    (default: true)
#   CLONE_TOOLS_REPOS=true|false     Clone sys-perf-tools + system-tools into
#                                    /home/labuser/tools (default: true)
#
# Author: Karl Vietmeier
# License: Apache 2.0
###=============================================================================###

set -u
# Do NOT use set -e globally — bench compiles must not fail the whole bootstrap.

INSTALL_BENCH_TOOLS="${INSTALL_BENCH_TOOLS:-true}"
CLONE_LAB_SCRIPTS="${CLONE_LAB_SCRIPTS:-true}"
CLONE_TOOLS_REPOS="${CLONE_TOOLS_REPOS:-true}"

LOG_FILE="/tmp/cloud-init-out.txt"
BOOT_LOG="/tmp/lab_bootstrap-out.log"

exec > >(tee -a "$BOOT_LOG") 2>&1
echo "lab_bootstrap.sh started at $(date)"
echo "INSTALL_BENCH_TOOLS=${INSTALL_BENCH_TOOLS} CLONE_LAB_SCRIPTS=${CLONE_LAB_SCRIPTS} CLONE_TOOLS_REPOS=${CLONE_TOOLS_REPOS}"

log() { echo "$*" | tee -a "$LOG_FILE"; }

log_and_continue() {
    local desc="$1"
    shift
    log ">> $desc"
    if "$@"; then
        log "OK: $desc"
        return 0
    fi
    log "WARN: $desc failed (continuing)"
    return 0
}

wait_for_locks() {
    echo "Waiting for package/user locks..."
    local i=0
    if command -v fuser >/dev/null 2>&1; then
        while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock \
              /var/cache/dnf/metadata_lock.pid >/dev/null 2>&1; do
            sleep 5
            i=$((i + 1))
            [[ $i -gt 60 ]] && break
        done
    fi
    while [[ -f /etc/passwd.lock || -f /etc/group.lock || -f /etc/ptmp || -f /etc/gtmp ]]; do
        sleep 2
        i=$((i + 1))
        [[ $i -gt 60 ]] && break
    done
}

is_debian() { [[ -f /etc/debian_version ]]; }
is_rhel() {
    [[ -f /etc/redhat-release || -f /etc/azurelinux-release || -f /etc/mariner-release ]]
}

###-----------------------------------------------------------------------------###
### Disable auto-updates / host firewalls (bench stability)
###-----------------------------------------------------------------------------###
disable_noise() {
    if is_debian; then
        cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
        systemctl stop unattended-upgrades apt-daily.timer apt-daily-upgrade.timer 2>/dev/null || true
        systemctl disable unattended-upgrades apt-daily.timer apt-daily-upgrade.timer 2>/dev/null || true
        systemctl mask unattended-upgrades apt-daily.service apt-daily-upgrade.service 2>/dev/null || true
        command -v ufw >/dev/null 2>&1 && ufw disable || true
    elif is_rhel; then
        systemctl stop dnf-automatic.timer firewalld nftables 2>/dev/null || true
        systemctl disable dnf-automatic.timer firewalld nftables 2>/dev/null || true
    fi
}

###-----------------------------------------------------------------------------###
### Copy the cloud key pair onto labuser (Ansible uses labuser, not ubuntu)
### AWS/Azure/GCP inject the key into the image default user only.
###-----------------------------------------------------------------------------###
prepare_ansible_ssh() {
    local home="$1"
    local src=""
    local candidate line

    for candidate in \
        /home/ubuntu/.ssh/authorized_keys \
        /home/ec2-user/.ssh/authorized_keys \
        /home/azureuser/.ssh/authorized_keys \
        /home/opc/.ssh/authorized_keys \
        /root/.ssh/authorized_keys
    do
        if [[ -s "$candidate" ]]; then
            src="$candidate"
            break
        fi
    done

    if [[ -z "$src" ]]; then
        log "WARN: no cloud SSH key found; labuser is not yet reachable by Ansible"
        return 0
    fi

    mkdir -p "$home/.ssh"
    touch "$home/.ssh/authorized_keys"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        grep -qxF "$line" "$home/.ssh/authorized_keys" || echo "$line" >> "$home/.ssh/authorized_keys"
    done < "$src"
    chmod 700 "$home/.ssh"
    chmod 600 "$home/.ssh/authorized_keys"
    chown -R labuser:labuser "$home/.ssh"
    log "OK: copied SSH key from $src to labuser"
}

###-----------------------------------------------------------------------------###
### labuser + shell defaults
###-----------------------------------------------------------------------------###
ensure_labuser() {
    wait_for_locks
    if ! id -u labuser >/dev/null 2>&1; then
        local grp="wheel"
        is_debian && grp="sudo"
        useradd -m -s /bin/bash -G "$grp" labuser
        echo "labuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/labuser
        chmod 440 /etc/sudoers.d/labuser
    fi

    local home="/home/labuser"
    mkdir -p "$home/output" "$home/git" "$home/tools" /root/git

    # Append once (idempotent marker)
    local marker="# >>> lab_bootstrap aliases >>>"
    local aliases
    aliases=$(cat <<'EOF'
# >>> lab_bootstrap aliases >>>
alias la="ls -Av"
alias ls="ls -hF --color=auto"
alias l="ls -CFv"
alias ll='ls -lhvF --group-directories-first'
alias lla='ls -alhvF --group-directories-first'
alias grep='grep --color=auto'
alias cdb='cd -'
alias cdu='cd ..'
alias df='df -kh'
alias du='du -h'
set -o vi
bind 'set bell-style none' 2>/dev/null || true
# <<< lab_bootstrap aliases <<<
EOF
)

    for rc in "$home/.bashrc" /root/.bashrc; do
        touch "$rc"
        if ! grep -qF "$marker" "$rc" 2>/dev/null; then
            printf '\n%s\n' "$aliases" >> "$rc"
        fi
    done
    chown -R labuser:labuser "$home"
    prepare_ansible_ssh "$home"
}

###-----------------------------------------------------------------------------###
### Build dependencies (only when compiling bench tools)
###-----------------------------------------------------------------------------###
install_build_deps() {
    wait_for_locks
    if is_debian; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y \
            build-essential debhelper cmake autoconf pkg-config libtool \
            libboost-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev \
            libssl-dev libncurses-dev libnuma-dev libaio-dev librdmacm1 \
            libcurl4-openssl-dev uuid-dev zlib1g-dev libarchive-dev \
            git python3-dev chrony psmisc curl
    elif is_rhel; then
        dnf groupinstall -y "Development Tools" || true
        dnf install -y epel-release || true
        dnf install -y \
            cmake autoconf libtool pkgconf-pkg-config \
            numactl-devel libaio-devel boost-devel ncurses-devel \
            openssl-devel rdma-core libcurl-devel libuuid-devel \
            zlib zlib-devel libarchive-devel \
            git python3-devel chrony psmisc curl
    else
        log "WARN: unknown distro; skipping build deps"
    fi
}

###-----------------------------------------------------------------------------###
### Cloud-aware chrony (AWS / Azure / GCP / OCI)
###-----------------------------------------------------------------------------###
configure_chrony() {
    local conf
    if is_debian; then
        conf="/etc/chrony/chrony.conf"
        mkdir -p /etc/chrony
    else
        conf="/etc/chrony.conf"
    fi

    local server_line="pool pool.ntp.org iburst"

    # Order matters: probe cloud metadata endpoints
    if curl -s --connect-timeout 1 -H "Metadata-Flavor: Google" \
        http://169.254.169.254/computeMetadata/v1/ >/dev/null 2>&1; then
        server_line="server metadata.google.internal iburst"          # GCP
    elif curl -s --connect-timeout 1 -H "Metadata:true" \
        "http://169.254.169.254/metadata/instance?api-version=2021-02-01" >/dev/null 2>&1; then
        server_line="server 169.254.169.254 prefer iburst"            # Azure
    elif curl -s --connect-timeout 1 http://169.254.169.254/opc/v1/instance/ >/dev/null 2>&1; then
        server_line="server 169.254.169.254 iburst"                   # OCI
    elif curl -s --connect-timeout 1 http://169.254.169.254/latest/meta-data/ >/dev/null 2>&1; then
        server_line="server 169.254.169.123 prefer iburst"            # AWS
    fi

    cat > "$conf" <<EOF
# Managed by lab_bootstrap.sh
$server_line
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF

    systemctl enable --now chronyd 2>/dev/null || systemctl enable --now chrony 2>/dev/null || true
    log "chrony: $server_line"
}

###-----------------------------------------------------------------------------###
### Bench tool compiles (soft-fail per tool)
###-----------------------------------------------------------------------------###
smart_build() {
    local url="$1" dir="$2" cmd="$3"
    mkdir -p /root/git
    cd /root/git || return 0
    if [[ -d "$dir" ]]; then
        log "skip $dir (already present)"
        return 0
    fi
    log_and_continue "clone $dir" git clone "$url" "$dir"
    if [[ ! -d "$dir" ]]; then
        return 0
    fi
    (
        cd "/root/git/$dir" || exit 1
        eval "$cmd"
    ) && log "OK: build $dir" || log "WARN: build $dir failed"
}

install_bench_tools() {
    smart_build "https://github.com/scottchiefbaker/dool.git" "dool" \
        "./install.py"

    smart_build "https://github.com/axboe/fio.git" "fio" \
        "./configure && make -j\$(nproc) && make install"

    smart_build "https://github.com/esnet/iperf.git" "iperf" \
        "./configure && make -j\$(nproc) && make install && echo /usr/local/lib > /etc/ld.so.conf.d/iperf.conf && ldconfig"

    smart_build "https://github.com/mellanox/sockperf" "sockperf" \
        "./autogen.sh && ./configure && make -j\$(nproc) && make install"

    local el_cmd
    if is_rhel; then
        el_cmd="find . -name CMakeCache.txt -delete; \
            export OPENSSL_ROOT_DIR=/usr OPENSSL_LIBRARIES=/usr/lib64 OPENSSL_INCLUDE_DIR=/usr/include; \
            make S3_SUPPORT=1 -j\$(nproc) && make rpm && dnf install -y ./packaging/RPMS/x86_64/elbencho*.rpm"
    else
        el_cmd="make S3_SUPPORT=1 -j\$(nproc) && make install"
    fi
    smart_build "https://github.com/breuner/elbencho.git" "elbencho" "$el_cmd"
}

clone_lab_scripts() {
    local home="/home/labuser"
    cd "$home" || return 0
    if [[ -d "$home/scripts/.git" ]]; then
        log "lab scripts already cloned"
    else
        log_and_continue "clone lab scripts" \
            git clone https://github.com/kvietmeier/scripts.git "$home/scripts"
    fi
    chown -R labuser:labuser "$home/scripts" 2>/dev/null || true
}

# Clone personal tool repos for labuser (Ubuntu + CentOS/RHEL-family alike).
# Layout: /home/labuser/tools/{sys-perf-tools,system-tools}
clone_tools_repos() {
    local home="/home/labuser"
    local tools="$home/tools"
    local name url dest

    mkdir -p "$tools"

    # name|url
    for entry in \
        "sys-perf-tools|https://github.com/kvietmeier/sys-perf-tools.git" \
        "system-tools|https://github.com/kvietmeier/system-tools.git"
    do
        name="${entry%%|*}"
        url="${entry##*|}"
        dest="$tools/$name"
        if [[ -d "$dest/.git" ]]; then
            log "tools/$name already cloned"
            continue
        fi
        log_and_continue "clone tools/$name" git clone "$url" "$dest"
    done

    chown -R labuser:labuser "$tools" 2>/dev/null || true
}

###-----------------------------------------------------------------------------###
### Main
###-----------------------------------------------------------------------------###
main() {
    disable_noise
    ensure_labuser
    configure_chrony

    if [[ "$INSTALL_BENCH_TOOLS" == "true" ]]; then
        install_build_deps
        install_bench_tools
    else
        log "Skipping bench tool compile (INSTALL_BENCH_TOOLS=false)"
    fi

    if [[ "$CLONE_LAB_SCRIPTS" == "true" ]]; then
        clone_lab_scripts
    fi

    if [[ "$CLONE_TOOLS_REPOS" == "true" ]]; then
        clone_tools_repos
    fi

    log "lab_bootstrap.sh completed at $(date)"
    echo "lab_bootstrap.sh completed at $(date)" > /root/CONFIGURED_BY_LAB_BOOTSTRAP
}

main "$@"

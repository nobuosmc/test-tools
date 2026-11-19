#!/bin/bash
# Multi-node install of Open MPI, Slurm, and OSU Micro-Benchmarks 7.5.2
# Targeted at Ubuntu 24.04
# Reads node list from host.txt (one IP/hostname per line)

set -euo pipefail

# ======================== Configuration ========================
HOST_FILE="host.txt"
REMOTE_USER="${USER}"                 # Change if needed
VERSION="7.5.2"
PREFIX="/opt/osu-micro-benchmarks"
TARBALL="osu-micro-benchmarks-${VERSION}.tar.gz"
URL="https://mvapich.cse.ohio-state.edu/download/mvapich/${TARBALL}"
# ===============================================================

log() { echo -e "\n=== $* ==="; }

# Read nodes from host.txt
if [[ ! -f "$HOST_FILE" ]]; then
    echo "Error: $HOST_FILE not found."
    echo "Create it with one IP or hostname per line."
    exit 1
fi

mapfile -t NODES < <(grep -vE '^\s*($|#)' "$HOST_FILE" | sed 's/[[:space:]]//g')

if [[ ${#NODES[@]} -eq 0 ]]; then
    echo "Error: No valid hosts found in $HOST_FILE"
    exit 1
fi

CONTROLLER="${NODES[0]}"
echo "Loaded ${#NODES[@]} nodes from $HOST_FILE"
echo "Controller: $CONTROLLER"
echo "All nodes: ${NODES[*]}"
echo

remote() {
    local host=$1
    shift
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes "${REMOTE_USER}@${host}" "$@"
}

remote_sudo() {
    local host=$1
    shift
    remote "$host" "sudo bash -c '$*'"
}

# ------------------------------------------------------------------
log "Verifying Ubuntu 24.04 on all nodes"
for node in "${NODES[@]}"; do
    echo "--> Checking $node"
    VERSION_ID=$(remote "$node" "grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '\"'")
    if [[ "$VERSION_ID" != "24.04" ]]; then
        echo "Error: $node is running Ubuntu $VERSION_ID (expected 24.04)"
        exit 1
    fi
    echo "    OK: Ubuntu 24.04"
done

# ------------------------------------------------------------------
log "Installing packages on all nodes (Ubuntu 24.04)"
for node in "${NODES[@]}"; do
    echo "--> $node"
    remote_sudo "$node" "
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            build-essential wget tar pkg-config \
            openmpi-bin libopenmpi-dev \
            munge libmunge-dev \
            slurm-wlm slurmctld slurmd slurm-client
    "
done

# ------------------------------------------------------------------
log "Setting up Munge authentication"
remote_sudo "$CONTROLLER" "
    if [[ ! -f /etc/munge/munge.key ]]; then
        create-munge-key
    fi
    chown munge:munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
"

KEY_TMP=$(mktemp)
scp -o StrictHostKeyChecking=no "${REMOTE_USER}@${CONTROLLER}:/etc/munge/munge.key" "$KEY_TMP" 2>/dev/null || \
    remote_sudo "$CONTROLLER" "cat /etc/munge/munge.key" > "$KEY_TMP"

for node in "${NODES[@]}"; do
    [[ "$node" == "$CONTROLLER" ]] && continue
    echo "Copying munge key to $node"
    scp -o StrictHostKeyChecking=no "$KEY_TMP" "${REMOTE_USER}@${node}:/tmp/munge.key"
    remote_sudo "$node" "
        mv /tmp/munge.key /etc/munge/munge.key
        chown munge:munge /etc/munge/munge.key
        chmod 400 /etc/munge/munge.key
    "
done
rm -f "$KEY_TMP"

for node in "${NODES[@]}"; do
    remote_sudo "$node" "systemctl enable --now munge"
done

# ------------------------------------------------------------------
log "Creating multi-node slurm.conf"
NODE_LINES=""
for node in "${NODES[@]}"; do
    CPUS=$(remote "$node" "nproc")
    MEM=$(remote "$node" "free -m | awk '/^Mem:/{print int(\$2*0.9)}'")
    NODE_LINES+="NodeName=${node} CPUs=${CPUS} RealMemory=${MEM} State=UNKNOWN\n"
done

NODE_LIST=$(IFS=,; echo "${NODES[*]}")

SLURM_CONF=$(cat << EOF
ClusterName=osucluster
SlurmctldHost=${CONTROLLER}
MpiDefault=none
ProctrackType=proctrack/linuxproc
ReturnToService=2
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
StateSaveLocation=/var/spool/slurmctld
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log
SlurmUser=slurm
TaskPlugin=task/affinity
AuthType=auth/munge
CryptoType=crypto/munge
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_CPU_Memory

$(echo -e "$NODE_LINES")
PartitionName=debug Nodes=${NODE_LIST} Default=YES MaxTime=INFINITE State=UP
EOF
)

for node in "${NODES[@]}"; do
    echo "--> Configuring $node"
    echo "$SLURM_CONF" | remote_sudo "$node" "cat > /etc/slurm/slurm.conf"
    remote_sudo "$node" "
        mkdir -p /var/spool/slurmctld /var/spool/slurmd /var/log/slurm
        chown -R slurm:slurm /var/spool/slurmctld /var/spool/slurmd /var/log/slurm
    "
done

remote_sudo "$CONTROLLER" "systemctl enable --now slurmctld"
for node in "${NODES[@]}"; do
    remote_sudo "$node" "systemctl enable --now slurmd"
done

# ------------------------------------------------------------------
log "Installing OSU Micro-Benchmarks on all nodes"
for node in "${NODES[@]}"; do
    echo "--> Building OSU on $node"
    remote_sudo "$node" "
        set -e
        rm -rf /tmp/osu-build
        mkdir -p /tmp/osu-build
        cd /tmp/osu-build
        wget -q --show-progress '$URL'
        tar -xzf '$TARBALL'
        cd osu-micro-benchmarks-${VERSION}
        ./configure CC=mpicc CXX=mpicxx --prefix='${PREFIX}'
        make -j\$(nproc)
        make install
        cd /
        rm -rf /tmp/osu-build
    "
done

# ------------------------------------------------------------------
log "Installation finished"
echo ""
echo "Controller : ${CONTROLLER}"
echo "Nodes      : ${NODES[*]}"
echo ""
echo "Verify:"
echo "  ssh ${REMOTE_USER}@${CONTROLLER} sinfo"
echo "  ssh ${REMOTE_USER}@${CONTROLLER} srun -N 2 hostname"
echo ""
echo "Run OSU benchmark:"
echo "  ssh ${REMOTE_USER}@${CONTROLLER} srun -N 2 -n 2 ${PREFIX}/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency"
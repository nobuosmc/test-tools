#!/bin/bash

# /home/smc/amd/ompi/ompi/bin/mpirun -np 16 -x LD_LIBRARY_PATH=/home/smc/amd/ompi/ompi/lib:$LD_LIBRARY_PATH -H amd300node3:8,amd300node4:8 -mca pml ucx -gmca btl_tcp_if_include ens50f0 -gmca oob_tcp_if_include ens50f0 -x UCX_IB_GID_INDEX=3 -x NCCL_IB_DISABLE=0 -x NCCL_IB_HCA=bnxt_re0:1,bnxt_re1:1,bnxt_re2:1,bnxt_re3:1,bnxt_re4:1,bnxt_re5:1,bnxt_re6:1,bnxt_re7:1 -x NCCL_SOCKET_IFNAME=ens50f0 -x NCCL_IB_GID_INDEX=3 -x NCCL_DEBUG=VERSION ./all_reduce_perf -b 8 -e 16G -f 2 -g 1


export LD_LIBRARY_PATH=/home/smc/amd/ompi/ompi/lib:$LD_LIBRARY_PATH
MPIRUN="${HOME}/amd/ompi/ompi/bin/mpirun "
MPIFLAGS=""

# ulimit -c unlimited
NODES=4
PPN=8
NP=$(($NODES * $PPN))

MPIFLAGS+="-np $NP "
MPIFLAGS+="-x LD_LIBRARY_PATH "
MPIFLAGS+="-H amd300node1:${PPN},amd300node2:${PPN},amd300node3:${PPN},amd300node4:${PPN} "
MPIFLAGS+="-mca pml ucx "
MPIFLAGS+="-gmca btl_tcp_if_include ens50f0 "
MPIFLAGS+="-gmca oob_tcp_if_include ens50f0 "
MPIFLAGS+="-x UCX_IB_GID_INDEX=3 "
MPIFLAGS+="-x NCCL_IB_DISABLE=0 "
MPIFLAGS+="-x NCCL_IB_HCA=bnxt_re0:1,bnxt_re1:1,bnxt_re2:1,bnxt_re3:1,bnxt_re4:1,bnxt_re5:1,bnxt_re6:1,bnxt_re7:1 "
MPIFLAGS+="-x NCCL_SOCKET_IFNAME=ens50f0 "
MPIFLAGS+="-x NCCL_IB_GID_INDEX=3 "
MPIFLAGS+="-x NCCL_DEBUG=VERSION "


for coll in all_reduce all_gather
#for coll in reduce_scatter
# for coll in all_reduce all_gather alltoall alltoallv broadcast gather reduce reduce_scatter scatter sendrecv
do
    EXE="./${coll}_perf -b 8 -e 16g -f 2 -g 1 -w 75 -n 100"
    CMD="$MPIRUN $MPIFLAGS $EXE"
    echo $CMD
    # $CMD
    $CMD 2>&1 | tee results/${NODES}nodes_across_${coll}.log
    sleep 10
done


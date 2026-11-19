#!/bin/bash

MC_INTF=`ifconfig | grep -B1 10.10 | grep flags | awk '{print$1}' | cut -f1 -d:`
NODE_NUM=`cat hosts.txt | wc -l`
GPU_NUM=$((NODE_NUM * 4))
TEST_ITEMS=("alltoall_perf" "all_reduce_perf" "all_gather_perf")
export PATH=/usr/local/cuda/bin:/usr:/usr/mpi/gcc/openmpi-4.1.7rc1/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/mpi/gcc/openmpi-4.1.7rc1/lib:/usr/lib/aarch64-linux-gnu/ucx:$LD_LIBRARY_PATH
#export NCCL_P2P_DISABLE=1

#export NCCL_NET_GDR_LEVEL=1
#export NCCL_P2P_LEVEL=NVL
#export NCCL_MNNVL_ENABLE=1
#export NCCL_DEBUG=INFO
export OMPI_MCA_coll=^hcoll
export NCCL_SOCKET_IFNAME=$MC_INTF

for test_item in ${TEST_ITEMS[@]};do
      for i in {1..2};do
        mpirun -np $GPU_NUM --allow-run-as-root --map-by ppr:4:node --bind-to core --report-bindings --mca btl_tcp_if_include $MC_INTF -x UCX_NET_DEVICES=$MC_INTF -x NCCL_MNNVL_ENABLE=1 -x NCCL_NET_GDR_LEVEL=1 -x NCCL_P2P_LEVEL=NVL -x PATH=$PATH -x LD_LIBRARY_PATH=$LD_LIBRARY_PATH --hostfile hosts.txt ./build/${test_item} -b 8 -e 32G -f 2 -g 1 | tee log/18-nodes-nvidia-nccl-test_${test_item}_loop${i}.txt 2>&1
        sleep 3
      done
done


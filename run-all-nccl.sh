#!/bin/bash

ncclPerfFile="/home/test/nccl-tests/ncclPerf-$(date +"%Y%m%d-%H%M%S").txt"
[[ -e ncclPerfFile ]] && rm $ncclPerfFile

for file in ./build/*_perf; do
    echo "$file"
    #b=8
    #e='128M'
    #f=2
    #g=8
    np=8
    b=8
    e=32G
    f=2
    #g=8
    g=8
    printf "RUN==>%s" $file
    #mpirun -np $np --allow-run-as-root  NCCL_DEBUG=INFO $file -b $b -e $e -f $f -g $g | tee -a $ncclPerfFile
    $file -b $b -e $e -f $f -g $g | tee -a $ncclPerfFile
done

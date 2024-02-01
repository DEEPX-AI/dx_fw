#!/bin/bash

if [[ $# -eq 0 ]]; then
    DEV_NUM=1
else
    DEV_NUM=$1
fi

for ((idx=0 ; idx < $DEV_NUM ; idx++));
do
    echo /dev/dx_dma"$idx"_c2h_0
    ./update_pcie.sh -d /dev/dx_dma"$idx"_c2h_0 -f map_qspi.txt -t fwboot
    ./update_pcie.sh -d /dev/dx_dma"$idx"_c2h_0 -f map_qspi.txt -t spl0 spl1 spl2 spl3
    ./update_pcie.sh -d /dev/dx_dma"$idx"_c2h_0 -f map_qspi.txt -t fwboot_r0 fwboot_r1
done

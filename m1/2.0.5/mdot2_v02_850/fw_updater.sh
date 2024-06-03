#!/bin/bash

./update_pcie.sh -d /dev/dx_dma0_c2h_0 -f map_qspi.txt -t spl0 spl1 spl2 spl3
./update_pcie.sh -d /dev/dx_dma0_c2h_0 -f map_qspi.txt -t fwboot -r

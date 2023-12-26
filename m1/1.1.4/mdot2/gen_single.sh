#!/bin/bash

SINGLE_IMAGE=deepx_image.bin
TOTAL_SIZE=8

boot2nd_image=fw_2ndboot_qspi.bin
fw_image=fw-boot.bin


function check_prev_cmd() {
    local exit_status="$1"
    local msg="$2"

    if [ "$exit_status" -ne 0 ]; then
        echo "An error occurred during $msg process. Exiting the script."
        exit 1
    fi
}

function CMD_n_CHK() {
    local command="$1"
    local message="$2"

	$(eval "$command")
    exit_status=$?

    check_prev_cmd "$exit_status" "$message"
}


# 0xff base
CMD_n_CHK "dd if=/dev/zero bs=1M count=${TOTAL_SIZE} status=none | tr '\000' '\377' > ${SINGLE_IMAGE}" "ff-ed base"

# copies 2ndboot
CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x0)) status=none" "2ndboot #0"
CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x20000)) status=none" "2ndboot #1"
CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x40000)) status=none" "2ndboot #2"
CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x60000)) status=none" "2ndboot #3"

# copies dx_fw
CMD_n_CHK "dd conv=notrunc if=${fw_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x380000)) status=none" "fw"
CMD_n_CHK "dd conv=notrunc if=${fw_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x600000)) status=none" "fw r0"
CMD_n_CHK "dd conv=notrunc if=${fw_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x700000)) status=none" "fw r1"

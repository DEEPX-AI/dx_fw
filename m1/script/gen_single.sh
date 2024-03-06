#!/bin/bash

SINGLE_IMAGE=deepx_image.bin
DEFAULT_TOTAL_SIZE="8M"
TOTAL_SIZE=${2:-$DEFAULT_TOTAL_SIZE}

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






hex_to_octal() {
    hex_value=$1
    octal_value=$(printf "%o" "$((16#${hex_value}))")
    echo "$octal_value"
}

function make_base() {
	if [ "$#" -ne 3 ]; then
		echo "error: make base image not enough argumnet"
	fi

	local output_file="$1"
	local image_size="$2"
	local hex_pattern="$3"

	dd if=/dev/zero bs=$image_size count=1 status=none | tr '\000' "$(printf "\\%o" "${hex_pattern}")" > "$output_file"
}

function overwrite_on_base() {
	# copies 2ndboot
	CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x0)) status=none" "2ndboot #0"
	CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x20000)) status=none" "2ndboot #1"
	CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x40000)) status=none" "2ndboot #2"
	CMD_n_CHK "dd conv=notrunc if=${boot2nd_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x60000)) status=none" "2ndboot #3"

	# copies dx_fw
	CMD_n_CHK "dd conv=notrunc if=${fw_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x380000)) status=none" "fw"
	CMD_n_CHK "dd conv=notrunc if=${fw_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x600000)) status=none" "fw r0"
	CMD_n_CHK "dd conv=notrunc if=${fw_image} of=${SINGLE_IMAGE} bs=1 seek=$((0x700000)) status=none" "fw r1"
}


release_dir="$1"

if [ -d "$release_dir" ]; then
	pushd $release_dir > /dev/null
else
	echo "USAGE: ./gen_single.sh DIRECTORY_PATH"
	echo "  e.g. ./gen_single.sh ../1.1.4/mdot2"
	exit 1
fi

# single_image_name image_size patten_on_hex
make_base ${SINGLE_IMAGE} ${TOTAL_SIZE} 0xff

overwrite_on_base map_qspi.txt

popd > /dev/null

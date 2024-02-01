#!/bin/bash

# Copyright (C) 2023  DeepX Co., Ltd.

GEN_CMD=./m1_gen.sh
REL_TARGET=UNKNOWN
REL_VER=
proj_dir=$(realpath ../../..)
flashByPcieH1.sh

script_path="$(realpath $0)"
script_directory="$(dirname $script_path)"

function prepare_release() {
	\rm -f ${proj_dir}/rt_fw/firmware/build.log
	get_release_ver
}

function copy_outputs() {
	OUTDIR=${proj_dir}/outputs

	fw_boot=$OUTDIR/fw-boot.bin
	fw_mini=$OUTDIR/fw-mini.bin
	fw_2ndqspi=$OUTDIR/fw_2ndboot_qspi.bin
	fw_2nduart=$OUTDIR/fw_2ndboot_uart.bin
	fw_updater=$OUTDIR/fw_updater.sh
	tool_pcie=../../dx_rt/driver/DX_M1/pcie/script/pcie_rescan.sh
	tool_map=$OUTDIR/map_qspi.txt
	tool_upcie=$OUTDIR/update_pcie
	tool_upcie_arm=$OUTDIR/update_pcie_arm
	tool_shupcie=$OUTDIR/update_pcie.sh
	_tool_shupcie=$(basename $tool_shupcie)

	if [ ! -f $fw_boot ] || [ ! -f $fw_mini ] || [ ! -f $fw_2ndqspi ] || [ ! -f $fw_2nduart ] || [ ! -f $fw_updater ] \
		|| [ ! -f $tool_pcie ] || [ ! -f $tool_map ] || [ ! -f $tool_upcie ] || [ ! -f $tool_upcie_arm ] || [ ! -f $tool_shupcie ]; then
		echo "file not exist"
		return -1
	fi

	rel_dir_target=../../fw_release/$REL_VER/$1
	mkdir -p $rel_dir_target
	rel_dir=$(realpath $rel_dir_target)
	\cp -f $script_directory/m1_release.sh $rel_dir
	\cp -f $fw_boot $fw_mini $fw_2ndqspi $fw_2nduart $fw_updater $tool_pcie $tool_map $tool_upcie $tool_upcie_arm $tool_shupcie $rel_dir

	sed -i "s/^do_pcie_rescan/#&/" "$rel_dir/$_tool_shupcie"

	return 0
}

function do_build_upcie() {
	make clean && make
}

function do_build() {
	cfg=
	case $1 in
		mdot2)
			REL_TARGET=MDOT2
			cfg="m1_m.2.cfg"
			;;
		som_lp4)
			REL_TARGET=SOM_LP4
			cfg="m1_som_lpddr4.cfg"
			;;
		som_lp5)
			REL_TARGET=SOM_LP5
			cfg="m1_som_lpddr5.cfg"
			;;
		som_v03_lp5)
			REL_TARGET=SOM_V03_LP5
			cfg="m1_som_v03_lpddr5.cfg"
			;;
		h1)
			REL_TARGET=H1
			cfg="h1.cfg"
			;;
		*)
			echo "unknown target"
			return -1
			;;
	esac

	#echo "Build Target : $REL_TARGET"
	$GEN_CMD -b boards/build_config/$cfg 1>>build.log

	result=$(copy_outputs $1)
	if [[ $result -ne 0 ]]; then
		return -1
	fi

	return 0
}

function get_release_ver() {
	file_path="m1_gen.sh"
	REL_VER=$(awk -F '"' '/fw_version=/{print $2}' "$file_path")
}

function do_exit() {
	echo "error occurred"
	popd
	exit 1
}

cd ${proj_dir}/rt_fw/tool/update
do_build_upcie


##################################################
# BUILD FW
##################################################

cd ${proj_dir}/rt_fw/firmware

# checkout main branch
git checkout -f main

prepare_release

result=$(do_build mdot2)
if [[ $result -ne 0 ]]; then
	do_exit
fi

result=$(do_build som_lp4)
if [[ $result -ne 0 ]]; then
	do_exit
fi

result=$(do_build som_lp5)
if [[ $result -ne 0 ]]; then
	do_exit
fi

result=$(do_build som_v03_lp5)
if [[ $result -ne 0 ]]; then
	do_exit
fi

result=$(do_build h1)
if [[ $result -ne 0 ]]; then
	do_exit
fi



##################################################
# BUILD 2ndboot & bingen
##################################################

cd ${proj_dir}/rt_u-boot-deepx
git checkout -f main

eval "./uboot.run"
if [ $? -ne 0 ]; then
       do_exit
fi


cd ${proj_dir}/rt_bingen
git checkout -f main

eval "./bingen.run"
if [ $? -ne 0 ]; then
       do_exit
fi



##################################################
# Release file packing
##################################################

cd ${proj_dir}/fw_release
tar -czf ${proj_dir}/fw_release/fw_$REL_VER.tar.gz $REL_VER

if [ -e ${proj_dir}/fw_release/fw_$REL_VER.tar.gz ]; then
	echo "release $REL_VER success"
else
	echo "release $REL_VER failed"
fi

\cp -rf $REL_VER fw_$REL_VER.tar.gz ~/DEEPX-AI/dx_fw/m1

cd ~/DEEPX-AI/dx_fw/m1

git pull --rebase

git add $REL_VER fw_$REL_VER.tar.gz
if [ $? -ne 0 ]; then
       do_exit
fi
git commit -m "release: fw v$REL_VER"
if [ $? -ne 0 ]; then
       do_exit
fi

git push
if [ $? -ne 0 ]; then
       do_exit
fi


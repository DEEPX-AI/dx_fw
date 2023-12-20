#!/bin/bash

# __base_dir is script's realpath
__base_dir=$(realpath $(dirname $(realpath "$BASH_SOURCE")))
__update_dir="${__base_dir}"
__update_exe="update_pcie"
__update_app=
__update_devnode="/dev/dx_dma0_c2h_0"

function env_setup () {
	ARCH=$(uname -m)

	if [ "$ARCH" == "aarch64" ]; then
		__update_exe="update_pcie_arm64"
	elif [ "$ARCH" == "x86_64" ]; then
		__update_exe="update_pcie"
	else
		echo "architecture $ARCH not supported"
		exit 1
	fi
	__update_app="${__base_dir}/${__update_exe}"
}

function logerr () { echo -e "\033[0;31m$*\033[0m"; }
function logmsg () { echo -e "\033[0;33m$*\033[0m"; }
function logext () { echo -e "\033[0;31m$*\033[0m"; exit -1; }

function usage () {
	echo -e " usage:"
	echo -e "\t$(basename "${0}") -f <map> [options]"
	echo ""
	echo -e " options"
	echo -e "\t-t : select update targets"
	echo -e "\t-l : show update list"
	echo -e "\t-i : show update list info"
	echo -e "\t-d : PCIe device node : '${__update_devnode}'"
	echo -e "\t-p : update image search path, default: '${__update_dir}'"
	echo -e "\t-j : jump to addr after end of update"
	echo -e "\t-r : reboot after end of update"
	echo -e "\t-x : exit of update"
	echo -e "\t-n : skip verify (CRC32)"
	echo -e "\t-v : verbose"
	echo -e "\t-e : edit map file"
	echo -e ""
	echo -e " note> This script is a script that runs '${__update_exe}' program"
	echo -e "       Check the detailed options in the program."
	echo -e ""
	echo -e " map struct:"
	echo -e "\t<name>:<device>,<device no>:<offs(hex)>,<addr(hex)>:<length(hex)>:<file>"
	echo -e "\t\t- <name>\t= used to select the update target. (-t option)"
	echo -e "\t\t- <device>\t= 0: memory, 1: sflash"
	echo -e "\t\t- <device no>\t= current not used"
	echo -e "\t\t- <offs(hex)>\t= the device address to write the file."
	echo -e "\t\t\t\t  note> If the <device> is 0(memory),"
	echo -e "\t\t\t\t        this value will be ignored"
	echo -e "\t\t- <addr(hex)>\t= the memory address to load the file."
	echo -e "\t\t- <length(hex)>\t= the device erase length."
	echo -e "\t\t- <file>\t= The file name to write to the device."
	echo -e "\t\t\t\t  note> The file must exist in the directory"
	echo -e "\t\t\t\t        where the script is located or"
	echo -e "\t\t\t\t        in the directory specified with '-p'."
	echo ""
	exit 1;
}

__update_elems=()
__update_target=()

function do_pcie_rescan() {
	local script_dir="$(realpath "${__base_dir}/../dx_rt/driver/DX_M1/pcie/script")"
	local pcie_rescan="${script_dir}/pcie_rescan.sh"

	logmsg " PCIe Rescan  : ${pcie_rescan}"
	if [[ ! -f ${pcie_rescan} ]];then
		logerr "Not found : ${pcie_rescan}"
		return
	fi

	sudo bash -c "${pcie_rescan} ${__debug_verbose}"

	[[ $? -ne 0 ]] && logext "FAILE PCIe Rescan"
	logmsg " PCIe Done\n"
}

function do_update () {
	local target=()

	if [[ ! -c ${__update_devnode} ]]; then
		logerr " Not such device node: ${__update_devnode}";
		usage;
	fi

	logmsg " Update Start :"
	if [[ -z ${__update_target[@]} ]]; then
		for i in "${__update_elems[@]}"; do
			__update_target+=( "$(echo $i| cut -d':' -f 1)" )
		done
	fi

	for i in "${__update_elems[@]}"; do
		local t="$(echo ${i} | cut -d ':' -f 1)"
		for n in "${__update_target[@]}"; do
			if [[ ${n} == ${t} ]]; then
				file="$(echo $(echo ${i} | cut -d':' -f 6)| cut -d';' -f 1)"
				[[ -z ${file} ]] && continue;
				file="$(realpath ${__update_dir}/${file})"
				if [[ ! -f "${file}" ]]; then
					logerr " Not found '${n}': ${file}\033[0m"
					continue
				fi

				node="-d ${__update_devnode}"
				file="-i $(realpath ${file})"
				dev="-t $(echo ${i} | cut -d':' -f 2 | cut -d',' -f 1)"
				offs="$(echo ${i} | cut -d':' -f 3)"
				[[ -n ${offs} ]] && offs="-o ${offs}";
				addr="-a $(echo ${i} | cut -d':' -f 4)"
				len=$(echo ${i} | cut -d':' -f 5)
				[[ -n ${len} ]] && len="-l ${len}";
				opts="${node} ${file} ${dev} ${offs} ${addr} ${len} ${__skip_verify}"

				target+=( "${opts}" );
				break;
			fi
		done
	done

	for args in "${target[@]::${#target[@]}-1}"; do
		logmsg " $ ${__update_app} ${args}"
		sudo bash -c "${__update_app} ${args} ${__debug_verbose}"
		[[ $? -ne 0 ]] && logext " Update FAIL !!!";
	done

	# last command to reset
	args="${target[@]: -1:1}"
	[[ ${__jump_entry} != "NULL" ]] && args="${args} -j ${__jump_entry}"
	[[ ${__do_reboot} == true ]] && args="${args} -r"
	[[ ${__do_exit} == true ]] && args="${args} -x"
	logmsg " $ ${__update_app} ${args}"
	sudo bash -c "${__update_app} ${args} ${__debug_verbose}"
	[[ $? -ne 0 ]] && logext " Update FAIL !!!";
	logmsg " Update Done"
}

__update_map=""
__skip_verify=""
__jump_entry="NULL"
__do_reboot=false
__do_exit=false
__show_update_info=false
__show_update_list=false
__edit_map=false
__debug_verbose=">> /dev/null 2>&1"

function parse_args () {
	while getopts "f:t:d:p:j:lirxnevh" opt; do
	case ${opt} in
		f )	__update_map=$(realpath "${OPTARG}");;
		t )	__update_target=("${OPTARG}")
			until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [[ -z "$(eval "echo \${$OPTIND}")" ]]; do
				__update_target+=("$(eval "echo \${$OPTIND}")")
				OPTIND=$((OPTIND + 1))
			done
			;;
		d )	__update_devnode=$(realpath "${OPTARG}");;
		p )	__update_dir=$(realpath "${OPTARG}");;
		l )	__show_update_list=true;;
		i ) __show_update_info=true;;
		j )	__jump_entry="${OPTARG}";;
		r )	__do_reboot=true;;
		x )	__do_exit=true;;
		n )	__skip_verify='-n';;
		v )	__debug_verbose="";;
		e )	__edit_map=true;;
		h )	usage ;;
	    * )	exit 1;;
	esac
	done
}


### routine
env_setup
parse_args "${@}"

if [[ ! -f ${__update_map} ]]; then
	logerr " Not such map file: ${__update_map}";
	usage;
fi

if [[ ${__edit_map} == true ]]; then
	vim "${__update_map}"
	exit 0;
fi

while read line; do
	[[ ${line} == *"#"* ]] || [[ -z ${line} ]] && continue;
	__update_elems+=( "$(echo "${line}" | sed 's/[[:space:]]//g')" )
done < ${__update_map}

if [[ ${__show_update_list} == true ]]; then
	logmsg " Update List :"
	for i in "${__update_elems[@]}"; do
		logmsg " - $(echo $i| cut -d':' -f 1) "
	done
	exit 0;
fi

if [[ ${__show_update_info} == true ]]; then
	logmsg " Update Info :"
	for i in "${__update_elems[@]}"; do
		logmsg " - ${i}"
	done
	exit 0;
fi	

#do_pcie_rescan
do_update

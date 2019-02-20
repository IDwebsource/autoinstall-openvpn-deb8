#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# Pi-hole: A black hole for Internet advertisements
# (c) 2017 Pi-hole, LLC (https://pi-hole.net)
# Network-wide ad blocking via your own hardware.
#
# Calculates stats and displays to an LCD
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.a
#LC_ALL=C
#LC_NUMERIC=C

# Retrieve stats from FTL engine


# Print spaces to align right-side additional text
printFunc() {
    local text_last

    title="$1"
    title_len="${#title}"

    text_main="$2"
    text_main_nocol="$text_main"
    if [[ "${text_main:0:1}" == "" ]]; then
        text_main_nocol=$(sed 's/\[[0-9;]\{1,5\}m//g' <<< "$text_main")
    fi
    text_main_len="${#text_main_nocol}"

    text_addn="$3"
    if [[ "$text_addn" == "last" ]]; then
        text_addn=""
        text_last="true"
    fi

    # If there is additional text, define max length of text_main
    if [[ -n "$text_addn" ]]; then
        case "$scr_cols" in
            [0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-4]) text_main_max_len="9";;
            4[5-9]) text_main_max_len="14";;
            *) text_main_max_len="19";;
        esac
    fi

    [[ -z "$text_addn" ]] && text_main_max_len="$(( scr_cols - title_len ))"

    # Remove excess characters from main text
    if [[ "$text_main_len" -gt "$text_main_max_len" ]]; then
        # Trim text without colours
        text_main_trim="${text_main_nocol:0:$text_main_max_len}"
        # Replace with trimmed text
        text_main="${text_main/$text_main_nocol/$text_main_trim}"
    fi

    # Determine amount of spaces for each line
    if [[ -n "$text_last" ]]; then
        # Move cursor to end of screen
        spc_num=$(( scr_cols - ( title_len + text_main_len ) ))
    else
        spc_num=$(( text_main_max_len - text_main_len ))
    fi

    [[ "$spc_num" -le 0 ]] && spc_num="0"
    spc=$(printf "%${spc_num}s")
    #spc="${spc// /.}" # Debug: Visualise spaces

    printf "%s%s$spc" "$title" "$text_main"

    if [[ -n "$text_addn" ]]; then
        printf "%s(%s)%s\\n" "$COL_NC$COL_DARK_GRAY" "$text_addn" "$COL_NC"
    else
        # Do not print trailing newline on final line
        [[ -z "$text_last" ]] && printf "%s\\n" "$COL_NC"
    fi
}

# Perform on first Chrono run (not for JSON formatted string)
get_init_stats() {
    calcFunc(){ awk "BEGIN {print $*}" 2> /dev/null; }

    # Convert bytes to human-readable format
    hrBytes() {
        awk '{
            num=$1;
            if(num==0) {
                print "0 B"
            } else {
                xxx=(num<0?-num:num)
                sss=(num<0?-1:1)
                split("B KB MB GB TB PB",type)
                for(i=5;yyy < 1;i--) {
                    yyy=xxx / (2^(10*i))
                }
            printf "%.0f " type[i+2], yyy*sss
            }
        }' <<< "$1";
    }


    # Set Colour Codes
        COL_NC="[0m"
        COL_DARK_GRAY="[1;30m"
        COL_LIGHT_GREEN="[1;32m"
        COL_LIGHT_BLUE="[1;34m"
        COL_LIGHT_RED="[1;31m"
        COL_YELLOW="[1;33m"
        COL_LIGHT_RED="[1;31m"
        COL_URG_RED="[39;41m"



}

get_sys_stats() {
    local ph_ver_raw
    local cpu_raw
    local ram_raw
    local disk_raw
	# Get Version
    source "/etc/os-release"
    CODENAME=$(sed 's/[()]//g' <<< "${VERSION/* /}")
	kernel="$(uname -r)"
    sys_type="${NAME/ */} $VERSION_ID (${CODENAME^}) $(uname -m)"

    # Get core count
    sys_cores=$(grep -c "^processor" /proc/cpuinfo)
    sys_modelname=$(sed -n 's/^model name[ \t]*: *//p' /proc/cpuinfo | uniq)
    cpu_mhz=$(sed -n 's/^cpu MHz[ \t]*: *//p' /proc/cpuinfo | uniq)
    count_process=$(ps aux | grep -vE "^USER|grep" | wc -l)
    
	
	# Update every 12 refreshes (Def: every 60s)
    count=$((count+1))
    if [[ "$count" == "1" ]] || (( "$count" % 12 == 0 )); then
        # Do not source setupVars if file does not exist
        [[ -n "$setupVars" ]] && source "$setupVars"
	fi	
		
        sys_name=$(hostname)
        sys_name2=$(hostname -d)
		MYIP=$(wget -qO- ipv4.icanhazip.com)

        # Get storage stats for partition mounted on /
        read -r -a disk_raw <<< "$(df -B1 / 2> /dev/null | awk 'END{ print $3,$2,$5 }')"
        disk_used="${disk_raw[0]}"
        disk_total="${disk_raw[1]}"
        disk_perc="${disk_raw[2]}"

        net_gateway=$(ip route | grep default | cut -d ' ' -f 3 | head -n 1)
        #net_gateway=$(hostname -I)

    # Get screen size
    read -r -a scr_size <<< "$(stty size 2>/dev/null || echo 24 80)"
    scr_lines="${scr_size[0]}"
    scr_cols="${scr_size[1]}"

    # Determine Chronometer size behaviour
    if [[ "$scr_cols" -ge 58 ]]; then
        chrono_width="large"
    elif [[ "$scr_cols" -gt 40 ]]; then
        chrono_width="medium"
    else
        chrono_width="small"
    fi

    #sys_uptime=$(hrSecs "$(cut -d. -f1 /proc/uptime)")
    sys_uptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
    sys_loadavg=$(cut -d " " -f1,2,3 /proc/loadavg)

    # Get CPU usage, only counting processes over 1% as active
    # shellcheck disable=SC2009
    cpu_raw=$(ps -eo pcpu,rss --no-headers | grep -E -v "    0")
    cpu_tasks=$(wc -l <<< "$cpu_raw")
    cpu_taskact=$(sed -r "/(^ 0.)/d" <<< "$cpu_raw" | wc -l)
    cpu_perc=$(awk '{sum+=$1} END {printf "%.0f\n", sum/'"$sys_cores"'}' <<< "$cpu_raw")
	
	# RAM USAGE
    read -r -a ram_raw <<< "$(awk '/MemTotal:/{total=$2} /MemFree:/{free=$2} /Buffers:/{buffers=$2} /^Cached:/{cached=$2} END {printf "%.0f %.0f %.0f", (total-free-buffers-cached)*100/total, (total-free-buffers-cached)*1024, total*1024}' /proc/meminfo)"
    ram_perc="${ram_raw[0]}"
    ram_used="${ram_raw[1]}"
    ram_total="${ram_raw[2]}"

	#APP STATUS 
	#dropbear
	if [[ "$(pidof dropbear 2> /dev/null)" != "" ]]; then 
		dropbear_status="${COL_LIGHT_GREEN}Active${COL_NC}"
	else
		dropbear_status="${COL_LIGHT_RED}Offline${COL_NC}"
	fi
	
	#squid
	if [[ "$(pidof squid3 2> /dev/null)" != "" ]]; then 
		squid_status="${COL_LIGHT_GREEN}Active${COL_NC}"
	else
		squid_status="${COL_LIGHT_RED}Offline${COL_NC}"
	fi
	#openvpn
	if [[ "$(pidof openvpn 2> /dev/null)" != "" ]]; then 
		openvpn_status="${COL_LIGHT_GREEN}Active${COL_NC}"
	else
		openvpn_status="${COL_LIGHT_RED}Offline${COL_NC}"
	fi
	#ssh
	if [[ "$(pidof sshd 2> /dev/null)" != "" ]]; then 
		ssh_status="${COL_LIGHT_GREEN}Active${COL_NC}"
	else
		ssh_status="${COL_LIGHT_RED}Offline${COL_NC}"
	fi
	
	#Internet status
    if ping -c 1 google.com &> /dev/null; then
        internet_status="${COL_LIGHT_GREEN}Connected${COL_NC}"
    else
        internet_status="${COL_LIGHT_RED}Disconnected${COL_NC}"
    fi

}


get_strings() {
    host_info="$sys_type"
    sys_info="$sys_throttle"
    sys_info2="Active: $cpu_taskact of $cpu_tasks tasks"
    used_str="Used: "
    leased_str="Leased: "
    sys_proc="$count_process Running Proccess"
    sys_kernel="$kernel"
    
    [[ "$sys_cores" -ne 1 ]] && sys_cores_txt="${sys_cores}x "
    cpu_info="Core: $sys_cores_txt $cpu_mhz MHz"
    ram_info="$used_str$(hrBytes "$ram_used") of $(hrBytes "$ram_total")"
    disk_info="$used_str$(hrBytes "$disk_used") of $(hrBytes "$disk_total")"
    lan_info="Gateway: $net_gateway"
}

chronoFunc() {
    get_init_stats

    for (( ; ; )); do
        get_sys_stats
        get_strings

        # Get refresh number
        if [[ "$*" == *"-r"* ]]; then
            num="$*"
            num="${num/*-r /}"
            num="${num/ */}"
            num_str="Refresh set for every $num seconds"
        else
            num_str=""
        fi

        clear

        # Remove exit message heading on third refresh
		
echo -e "[1;31m        _                          _   _ _____ _____	$COL_NC"
echo -e "[1;32m  __ _ (_)_   _ _ __ _ __   __ _  | \ | | ____|_   _|	$COL_NC"
echo -e "[1;33m / _  || | | | | '__| '_ \ / _  | |  \| |  _|   | |	$COL_NC"
echo -e "[1;34m| (_| || | |_| | |  | | | | (_| |_| |\  | |___  | |	$COL_NC"
echo -e "[1;35m \__,_|/ |\__,_|_|  |_| |_|\__,_(_)_| \_|_____| |_|	$COL_NC"
echo -e "[1;36m     |__/												$COL_NC"
        if [[ "$count" -le 2 ]] && [[ "$*" != *"-e"* ]]; then
            echo -e "$num_str ${COL_LIGHT_RED}Press Ctrl-C to exit${COL_NC}"
        else
echo -e "${COL_LIGHT_GREEN}Info server - mod from Pi-hole Chronometer${COL_NC}"
        fi
echo -e "$COL_DARK_GRAY=======================================================$COL_NC"

        printFunc "       CPU: " "$sys_modelname" 
        printFunc "        OS: " "$host_info"
        printFunc "    Kernel: " "$sys_kernel"
        printFunc "  Hostname: " "$sys_name" "$sys_name2"
        printFunc "    Uptime: " "$sys_uptime" "$sys_proc"
        printFunc " Task Load: " "$sys_loadavg" "$sys_info2"
        printFunc " CPU usage: " "$cpu_perc%" "$cpu_info"
        printFunc " RAM usage: " "$ram_perc%" "$ram_info"
        printFunc " HDD usage: " "$disk_perc" "$disk_info"
		printFunc "   IP addr: " "$MYIP" "$lan_info"
		printFunc "  Internet: " "$internet_status"  
		printFunc "  Dropbear: " "$dropbear_status"
		printFunc "    Squid3: " "$squid_status"
		printFunc "   OpenVPN: " "$openvpn_status"  
		printFunc "       SSH: " "$ssh_status" "last"
		#printFunc "" "" "last"		


        # Handle exit/refresh options
        if [[ "$*" == *"-e"* ]]; then
            exit 0
        else
            if [[ "$*" == *"-r"* ]]; then
                sleep "$num"
            else
                sleep 5
            fi
        fi

    done
}



helpFunc() {
    if [[ "$1" == "?" ]]; then
        echo "Unknown option. Please view 'info --help' for more information"
    else
        echo "Usage: info -e [options]
Example: 'info -r 5'
Calculates stats and displays to an LCD
Options:
  -r, --refresh       Set update frequency (in seconds)
  -e, --exit          Output stats and exit witout refreshing
  -h, --help          Display this help text"
  fi

  exit 0
}

if [[ $# = 0 ]]; then
    chronoFunc
fi

for var in "$@"; do
    case "$var" in
        "-h" | "--help"    ) helpFunc;;
        "-r" | "--refresh" ) chronoFunc "$@";;
        "-e" | "--exit"    ) chronoFunc "$@";;
        *                  ) helpFunc "?";;
    esac
done

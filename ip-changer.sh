#!/bin/bash

CONFIG_FILE="./ip-changer.conf"
source "$CONFIG_FILE"

PATH=$PATH:/usr/games

[[ "$UID" -ne 0 ]] && {
    echo "Script must be run as root."
    exit 1
}

install_packages() {
    local distro
    distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    distro=${distro//\"/}
    
    case "$distro" in
        *"Ubuntu"* | *"Debian"*)
            apt-get update
            apt-get install -y curl tor lolcat
            ;;
        *"Fedora"* | *"CentOS"* | *"Red Hat"* | *"Amazon Linux"*)
            yum update
            yum install -y curl tor
            ;;
        *"Arch"*)
            pacman -S --noconfirm curl tor
            ;;
        *)
            echo "Unsupported distribution: $distro. Please install curl, tor and lolcat manually."
            exit 1
            ;;
    esac
}

if ! command -v curl &> /dev/null || ! command -v tor &> /dev/null || ! command -v lolcat &> /dev/null; then
    echo "Installing required packages..."
    install_packages
fi

if ! systemctl --quiet is-active tor.service; then
    dololcat "Starting tor service"
    systemctl start tor.service
fi

get_ip() {
    local url get_ip ip
    url="https://checkip.amazonaws.com"
    get_ip=$(curl -s -x socks5h://127.0.0.1:9050 "$url")
    ip=$(echo "$get_ip" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
    echo "$ip"
}

dololcat() {
        if [[ "$lolcat" -eq "1" ]]; then
                echo -e "$@" | lolcat
        else
                echo "$@"
        fi
}

change_ip() {
    dololcat "Reloading tor service"
    systemctl reload tor.service
    dololcat -e "\033[34mNew IP address: $(get_ip)\033[0m"
}

LOGO_FILE="./logo.txt"
entry() {
	clear
	if [[ -f "$LOGO_FILE" ]]; then
		dololcat "$(cat "$LOGO_FILE")"
	fi
}
entry

getvalues() {
    	read -rp $'\033[34mEnter time interval in seconds (type 0 for infinite IP changes) [Default: 3]: \033[0m' _interval
    	read -rp $'\033[34mEnter number of times to change IP address (type 0 for infinite IP changes) [Default: 0]: \033[0m' _times
    	read -rp $'\033[34mEnable lolcat? (0: off / 1: on) [Default: 1] \033[0m' _lolcat
	actual_lolcat=${_lolcat:-99}
	actual_interval=${_interval:-3}
	actual_times=${_times:-0}
	if [[ "$_lolcat" != 0 && "$_lolcat" != 1 ]]; then	
		actual_lolcat=1
	fi
	sed -i "s/^interval=.*/interval=${actual_interval}/" "$CONFIG_FILE" 
	sed -i "s/^times=.*/times=${actual_times}/" "$CONFIG_FILE"
	sed -i "s/^lolcat=.*/lolcat=${actual_lolcat}/" "$CONFIG_FILE"
}

verify_parameters() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		echo -e "interval=3\ntimes=0\nlolcat=1" > "$CONFIG_FILE"
	fi
	if [[ -z "$interval" || -z "$times" || -z "$lolcat" || ( "$lolcat" != 0 && "$lolcat" != 1 ) ]]; then
		getvalues
	fi 
	source "$CONFIG_FILE"
	entry
}

while true; do
    verify_parameters
    if [[ "$interval" -eq "0" || "$times" -eq "0" ]]; then
        dololcat "Starting infinite IP changes"
        while true; do
            change_ip
            interval=$(shuf -i 10-20 -n 1)
            sleep "$interval"
        done
    else
        for ((i=0; i< times; i++)); do
            change_ip
            sleep "$interval"
        done
    fi
done

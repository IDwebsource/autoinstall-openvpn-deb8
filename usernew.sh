#!/bin/bash
#Script auto create user SSH

read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=`dig +short myip.opendns.com @resolver1.opendns.com`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "====Informasi SSH Account====" | lolcat
echo -e "Host: $IP"
echo -e "Username: $Login "
echo -e "Password: $Pass" 
echo -e "Port Dropbear: 143,3128"
echo -e "Port Squid: 3121"
echo -e "Config OpenVPN (UDP 1194): http://$IP:81/client.ovpn"
echo -e "-----------------------------" | lolcat
echo -e "Aktif Sampai: $exp"
echo -e "=============================" | lolcat
echo -e "Mod by Bustami Arifin"
echo -e "Upgrade by Umar Ajurna"
echo -e ""
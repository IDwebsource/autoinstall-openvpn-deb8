#!/bin/bash
#
# Original script by fornesia, rzengineer and fawzya
# Mod by Bustami Arifin
# Upgrade by Umar Ajurna
# ==================================================

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

#cek kvm atau openvz
GATEWAY=$(ip route | grep default | cut -d ' ' -f 3 | head -n 1);
		if [[ $GATEWAY == "venet0" ]]; then 
			lan_gateway="venet0"
		else		
			lan_gateway="eth0"
		fi
		
#detail nama perusahaan
country=ID
state=Jakarta
locality=Tebet
organization=Cendrawasih
organizationalunit=IT
commonname=ajurna.net
email=me@ajurna.net

# go to root
cd

# merampingkan
apt-get purge apache* samba* bind9* sasl* sendmail* exim* nscd* ntp
apt-get clean
apt-get autoremove --purge

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/sources.list.debian9"
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg

# update
apt-get update

# install webserver
apt-get -y install nginx

# install essential package
apt-get -y install nano iptables dnsutils openvpn screen whois ngrep unzip unrar

echo "clear" >> .bashrc
echo 'echo -e "Selamat datang di server $HOSTNAME" | lolcat' >> .bashrc
echo 'echo -e " [1;31m        _                          _   _ _____ _____	[0m"' >> .bashrc
echo 'echo -e " [1;32m  __ _ (_)_   _ _ __ _ __   __ _  | \ | | ____|_   _|[0m"' >> .bashrc
echo 'echo -e " [1;33m / _  || | | | | ^__| ^_ \ / _  | |  \| |  _|   | |	[0m"' >> .bashrc
echo 'echo -e " [1;34m| (_| || | |_| | |  | | | | (_| |_| |\  | |___  | |	[0m"' >> .bashrc
echo 'echo -e " [1;35m \__,_|/ |\__,_|_|  |_| |_|\__,_(_)_| \_|_____| |_|	[0m"' >> .bashrc
echo 'echo -e " [1;36m     |__/											[0m"' >> .bashrc
echo 'echo -e " Script by Fornesia,Rzengineer,Fawzya,Bustami Arifin"' >> .bashrc
echo 'echo -e "         [1;32mModified by Umar Ajurna[0m             "' >> .bashrc
echo 'echo -e ""' >> .bashrc
echo 'echo -e "Ketik menu untuk menampilkan daftar perintah"' >> .bashrc
echo 'echo -e ""' >> .bashrc

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Umar Ajurna</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/vps.conf"
/etc/init.d/nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/server.conf "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/serverdeb9.conf"
/etc/init.d/openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -o $lan_gateway -j MASQUERADE
iptables-save > /etc/iptables_yg_baru_dibikin.conf
wget -O /etc/network/if-up.d/iptables "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/iptables"
chmod +x /etc/network/if-up.d/iptables
mkdir -p /etc/openvpn/logs
touch /etc/openvpn/logs/{openvpn,status}.log
systemctl restart openvpn@server.service
#/etc/init.d/openvpn restart

# konfigurasi openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/clientdeb9.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
cp client.ovpn /home/vps/public_html/

# teks berwarna
apt-get -y install ruby
gem install lolcat

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/menu.sh"
wget -O usernew "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/trial.sh"
wget -O hapus "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/user-vpn.sh"
wget -O member "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/user-list.sh"
wget -O resvis "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/resvis.sh"
wget -O speedtest "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/speedtest.py"
wget -O info "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/info.sh"
wget -O about "https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/about.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x usernew
chmod +x trial
chmod +x hapus
chmod +x cek
chmod +x member
chmod +x resvis
chmod +x speedtest
chmod +x info
chmod +x about

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "menu (Menampilkan daftar perintah yang tersedia)"  | tee -a log-install.txt
echo "usernew (Membuat Akun SSH)"  | tee -a log-install.txt
echo "trial (Membuat Akun Trial)"  | tee -a log-install.txt
echo "hapus (Menghapus Akun SSH)"  | tee -a log-install.txt
echo "member (Cek Member SSH)"  | tee -a log-install.txt
echo "resvis (Restart Service squid3, openvpn dan ssh)"  | tee -a log-install.txt
echo "reboot (Reboot VPS)"  | tee -a log-install.txt
echo "speedtest (Speedtest VPS)"  | tee -a log-install.txt
echo "info (Menampilkan Informasi Sistem)"  | tee -a log-install.txt
echo "about (Informasi tentang script auto install)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Original Script by Fornesia, Rzengineer & Fawzya"  | tee -a log-install.txt
echo "Modified by Umar Ajurna"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "VPS AUTO REBOOT TIAP JAM 12 MALAM"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd
rm -f /root/ovpndeb9.sh

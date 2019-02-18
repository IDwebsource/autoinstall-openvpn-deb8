#!/bin/bash
#
# Original script by fornesia, rzengineer and fawzya
# Mod by Bustami Arifin
# ==================================================

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
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
email=ajurna.net

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# merampingkan
apt-get purge apache* samba* bind9* sasl* sendmail* exim* nscd* ntp
apt-get clean
apt-get autoremove --purge

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# set repo
wget -O /etc/apt/sources.list "http://repo.ajurna.net/sources.list.debian8"
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
#sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
#wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

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
wget -O /etc/nginx/nginx.conf "http://repo.ajurna.net/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by Umar Ajurna</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "http://repo.ajurna.net/vps.conf"
/etc/init.d/nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "http://repo.ajurna.net/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/server.conf "http://repo.ajurna.net/server.conf"
/etc/init.d/openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o $lan_gateway -j MASQUERADE
iptables-save > /etc/iptables_yg_baru_dibikin.conf
wget -O /etc/network/if-up.d/iptables "http://repo.ajurna.net/iptables"
chmod +x /etc/network/if-up.d/iptables
mkdir -p /etc/openvpn/logs
touch /etc/openvpn/logs/{openvpn,status}.log
systemctl restart openvpn@server.service
#/etc/init.d/openvpn restart


# konfigurasi openvpn
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn "http://repo.ajurna.net/client.conf"
sed -i $MYIP2 /etc/openvpn/client.ovpn;
cp client.ovpn /home/vps/public_html/



# setting port ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 444' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=3128/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 143"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "http://repo.ajurna.net/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
/etc/init.d/squid3 restart


# teks berwarna
apt-get -y install ruby
gem install lolcat

# download script
cd /usr/bin
wget -O menu "http://repo.ajurna.net/menu.sh"
wget -O usernew "http://repo.ajurna.net/usernew.sh"
wget -O trial "http://repo.ajurna.net/trial.sh"
wget -O hapus "http://repo.ajurna.net/hapus.sh"
wget -O cek "http://repo.ajurna.net/user-vpn.sh"
wget -O member "http://repo.ajurna.net/user-list.sh"
wget -O resvis "http://repo.ajurna.net/resvis.sh"
wget -O speedtest "http://repo.ajurna.net/speedtest.py"
wget -O info "http://repo.ajurna.net/info.sh"
wget -O about "http://repo.ajurna.net/about.sh"

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
/etc/init.d/dropbear restart
/etc/init.d/squid3 restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# install neofetch
#echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | tee -a /etc/apt/sources.list
#curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray"| apt-key add -
#apt-get update
#apt-get install neofetch

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenSSH  : 22, 444"  | tee -a log-install.txt
echo "Dropbear : 143, 3128"  | tee -a log-install.txt
echo "Squid3   : 3121 (limit to IP SSH)"  | tee -a log-install.txt
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
echo "resvis (Restart Service dropbear, squid3, openvpn dan ssh)"  | tee -a log-install.txt
echo "reboot (Reboot VPS)"  | tee -a log-install.txt
echo "speedtest (Speedtest VPS)"  | tee -a log-install.txt
echo "info (Menampilkan Informasi Sistem)"  | tee -a log-install.txt
echo "about (Informasi tentang script auto install)"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
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
rm -f /root/ovpndeb8.sh

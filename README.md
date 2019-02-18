

# ovpndeb8
Auto Install OpenVPN, Squid3, Dropbear, and SSH for debian 8 64 bit

Original script by :
* Fornesia
* Rzengineer
  https://github.com/rzengineer/Auto-Installer-VPS
* Fawzya
+ for debian 7
+ Mod by Bustami Arifin
  https://www.kangarif.net/2017/10/script-auto-install-ssh-openvpn-untuk.html


Upgrade and mod by Umar Ajurna
+ for debian 8 64 bit

Install OpenVPN and Squid3
--------------------------
1. wget https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/ovpndeb8.sh
   <br/><br/>
   If problem "ERROR: The certificate of 'raw.githubusercontent.com' is not trusted"
  
   <br/>The solution simple install:
   apt-get install ca-certificates
  
2. chmod +x ovpndeb8.sh
3. ./ovpndeb8.sh
4. Done
   <br/>Status Server is UP, "info -e" for command 
    <br/><a href="https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/ovpndeb8.png" rel="nofollow"><img src="https://raw.githubusercontent.com/IDwebsource/autoinstall-openvpn-deb8/master/ovpndeb8.png" alt=""></a>

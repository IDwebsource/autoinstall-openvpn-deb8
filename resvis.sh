#!/bin/bash
# Script restart service dropbear, webmin, squid3, openvpn, openssh
# Created by Bustami Arifin
/etc/init.d/dropbear restart
/etc/init.d/nginx restart
/etc/init.d/squid3 restart
/etc/init.d/openvpn restart
/etc/init.d/ssh restart


#!/bin/bash
# VeePeeNee 1.0
# http://www.top-hat-sec.com
# By: d4rkcat & R4v3N
# We couldnt think of a good name for this script! lulz 8===D
# Please be responsible!

fgetcerts()
{
	# download certs
	rm *.*
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip -O euro1.zip
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro2.zip -O euro2.zip
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-UK1.zip -O uk1.zip
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-US1.zip -O us1.zip
	for ITEM in $(ls /root/VPN/VPNBOOK/ | grep .zip);do unzip $ITEM;done
	for ITEM in $(ls /root/VPN/VPNBOOK/);do echo -e '\nauth-user-pass "creds"' >> $ITEM;done
	fgetcreds
	rm *.zip
}

fgetcreds()
{
	# mkdir & get the creds
	mkdir -p /root/VPN/
	mkdir -p /root/VPN/VPNBOOK/
	cd /root/VPN/VPNBOOK
	echo vpnbook > creds && curl -s www.vpnbook.com | grep Password | tr -d ' ' | head -n 1 | cut -d '>' -f 3 | cut -d ':' -f 2 | cut -d '<' -f 1 >> creds
}

fdnsmake()
{
		if [ ! -f /etc/resolv.conf.bak ] 2> /dev/null
		then
				mv /etc/resolv.conf /etc/resolv.conf.bak
		fi

		read -p ''' [>] Please select the DNS provider:

 [1] Google
 [2] Chaos Computer Club (GERMANY)

 >''' DNSPROVIDER

echo -e '\n [*] Changeing DNS provider.'

		if [ $DNSPROVIDER = '1' ] 2> /dev/null
		then
			echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf
		else
			echo -e 'nameserver 213.73.91.35\nnameserver 194.150.168.168' > /etc/resolv.conf
		fi
}

fsetupvpn()
{
		read -p '''
 [>] Please select the vpn country:

 [1] USA
 [2] UK
 [3] EU

 >''' COUNTRY
		read -p '''
 [>] Please select the vpn port:

 [1] TCP 80
 [2] TCP 443
 [3] UDP 25000

 >''' PORT
		if [ $COUNTRY = '1' ] 2> /dev/null
		then
			COUNTRY='USA'
			if [ $PORT = '1' ] 2> /dev/null
			then
				terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-us1-tcp80.ovpn" 2> /dev/null&
			elif [ $PORT = '2' ] 2> /dev/null
			then
				terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-us1-tcp443.ovpn" 2> /dev/null&
			elif [ $PORT = '3' ] 2> /dev/null
			then
				terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-us1-upd25000.ovpn" 2> /dev/null&
			fi
		elif [ $COUNTRY = '2' ] 2> /dev/null
		then
				COUNTRY='UK'
				if [ $PORT = '1' ] 2> /dev/null
				then
					terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-uk1-tcp80.ovpn" 2> /dev/null&
				elif [ $PORT = '2' ] 2> /dev/null
				then
					terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-uk1-tcp443.ovpn" 2> /dev/null&
				elif [ $PORT = '3' ] 2> /dev/null
				then
					terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-uk1-upd25000.ovpn" 2> /dev/null&
				fi
		else
				COUNTRY='EU'
				if [ $PORT = '1' ] 2> /dev/null
				then
						terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-euro2-tcp80.ovpn" 2> /dev/null&
				elif [ $PORT = '2' ] 2> /dev/null
				then
						terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-euro2-tcp443.ovpn" 2> /dev/null&
				elif [ $PORT = '3' ] 2> /dev/null
				then
					terminator -e "openvpn /root/VPN/VPNBOOK/vpnbook-euro2-upd25000.ovpn" 2> /dev/null&
				fi
		fi
	echo -e "\n [*] VPN setup complete, Welcome to the $COUNTRY"
}


fgetdeps()
{
	if [ $(which terminator) -z ] 2> /dev/null || [ $(which openvpn) -z ] 2> /dev/null
	then
		read -p ' [>] terminator or openvpn was not found on this system, install now? [Y/n]
	 >' INSTALL
		case $INSTALL in
			"y") ANS3=1;;
			"Y") ANS3=1;;
			"") ANS3=1
		esac
		if [ $ANS3 = '1' ] 2> /dev/null
		then
			sudo apt-get install terminator openvpn
		fi
	fi
}

if [ $(whoami) = 'root' ]
then
	fgetdeps
else
	echo ' [X] This script must be run as root.'
	exit
fi

fgetcreds

# Download files?
read -p ''' [>] Download and install vpnbook certs? [Y/n]
 >' CERTS

case $CERTS in
		"y") ANS2=1;;
		"Y") ANS2=1;;
		"") ANS2=1
esac

if [ $ANS2 = 1 ] 2> /dev/null
then
		fgetcerts
else
		echo " [*] Skipping..."
fi

# change dns?
read -p '''
 [>] Do you want to change your DNS? [Y/n]
 >' CHANGEDNS

case $CHANGEDNS in
		"Y") ANS=1;; 
		"y") ANS=1;;
		"") ANS=1
esac

if [ $ANS = 1 ] 2> /dev/null
then
		fdnsmake
else
		echo " [*] Skipping..."
fi

fsetupvpn

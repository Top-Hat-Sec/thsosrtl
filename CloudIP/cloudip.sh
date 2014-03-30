#!/bin/bash
# cloudIP 1.0
# Revised 11/2013
# By: R4v3N & TAPE
# http://www.top-hat-sec.com

# [ cloudIP was originally thought of for attempting to resolve the true IP address of targets running through cloudflare. ]
# [ It was then obvious that this could not only be used for cloudflare, but for any other service doing the same thing.   ]
# [ It invokes nslookup and whois records on the specified target so you must have these installed on your linux box.      ]
# [ cloudIP can also be used for recon to get an idea of what services and if multiple servers are being used.             ]
# [ It is always possible that cloudIP will not be able to determine the true IP address depending on the targets config.  ]

#
# teh colorz
STD=$(echo -e "\e[0;0;0m")  #Revert fonts to standard colour/format
RED=$(echo -e "\e[1;31m")  #Alter fonts to red bold
REDN=$(echo -e "\e[0;31m")  #Alter fonts to red normal
GRN=$(echo -e "\e[1;32m")  #Alter fonts to green bold
GRNN=$(echo -e "\e[0;32m")  #Alter fonts to green normal
BLU=$(echo -e "\e[1;36m")  #Alter fonts to blue bold
BLUN=$(echo -e "\e[0;36m")  #Alter fonts to blue normal
#
# header
f_header() {
# http://patorjk.com/software/taag/#p=display&f=Big&t=cloudIP
echo $BLUN"       _                 _ _____ _____  
      | |               | |_   _|  __ \\ 
   ___| | ___  _   _  __| | | | | |__) |
  / __| |/ _ \| | | |/ _\` | | | |  ___/ 
 | (__| | (_) | |_| | (_| |_| |_| |     
  \___|_|\___/ \__,_|\__,_|_____|_|
   By: R4v3N & TAPE | TOP-HAT-SEC
"$STD
}
#
# Internet connection check
f_netcheck() {
echo
echo $GRN">$STD Checking connectivity.."
wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
 if [ ! -s /tmp/index.google ];then
 echo $RED">$STD No internet connection found..$STD"
 echo "Please check connection and restart script"
 exit
 else
 echo $GRN">$STD Internet connection found..proceding$STD"
 fi
}
#
# start script
clear
f_header
f_netcheck
echo -n $GRN">$STD Enter Domain Name$RED without$STD the www. [top-hat-sec.com] : "$BLU
read lookup
if [ "$lookup" == "" ] ; then 
echo $RED">$STD Input error, missing input" 
echo
exit
fi
clear
f_header
echo $STD
echo $GRN"> $BLU$lookup$STD selected"
sleep 1.5
###################################################################################
# Initial nslookup
echo "Attempting to check IPs with nslookup.."
NS=$(nslookup $lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
MAXNR=$(echo $NS | sed 's/ /\n/' | wc -l)
for i in $(seq 1 $MAXNR) ; do 
IP=$(echo $NS | sed 's/ /\n/' | sed -n "$i"p)
IP_NETNAME=$(whois $IP | grep -i netname | awk '{print $2}')
echo "$GRNN$IP$STD --> $GRNN$IP_NETNAME$STD" 
done
sleep 1.5
echo $STD
###################################################################################
# nslookup with ftp
FAIL="Failed to resolve"
#
FTP_RESULT=$(nslookup ftp.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$FTP_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 1 of 7$BLUN [$STD FTP$BLUN ]$RED -----> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 1 of 7$BLUN [$STD FTP$BLUN ]$GRNN -----> $STD$FTP_RESULT"
FTP_NETNAME=$(whois $FTP_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of$GRNN$FTP_RESULT$STD --> $GRNN$FTP_NETNAME"
fi
sleep 1.5
echo $STD
####################################################################################
# nslookup with cpanel
CPANEL_RESULT=$(nslookup cpanel.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$CPANEL_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 2 of 7$BLUN [$STD Cpanel$BLUN ]$RED --> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 2 of 7$BLUN [$STD Cpanel$BLUN ]$GRNN --> $STD$CPANEL_RESULT"
CPANEL_NETNAME=$(whois $CPANEL_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of $GRNN$CPANEL_RESULT$STD --> $GRNN$CPANEL_NETNAME"
fi
sleep 1.5
echo $STD
#####################################################################################
# nslookup with mail
MAIL_RESULT=$(nslookup mail.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$MAIL_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 3 of 7$BLUN [$STD Mail$BLUN ]$RED ----> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 3 of 7$BLUN [$STD Mail$BLUN ]$GRNN ----> $STD$MAIL_RESULT"
MAIL_NETNAME=$(whois $MAIL_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of$GRNN$MAIL_RESULT$STD --> $GRNN$MAIL_NETNAME"
fi
sleep 1.5
echo $STD""
#####################################################################################
# nslookup with direct
DIRECT_RESULT=$(nslookup direct.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$DIRECT_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 4 of 7$BLUN [$STD Direct$BLUN ]$RED --> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 4 of 7$BLUN [$STD Direct$BLUN ]$GRNN --> $STD$DIRECT_RESULT"
DIRECT_NETNAME=$(whois $DIRECT_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of$GRNN$DIRECT_RESULT$STD --> $GRNN$DIRECT_NETNAME"
fi
sleep 1.5
echo $STD""
#####################################################################################
# nslookup with direct-connect
DIRECT_RESULTC=$(nslookup direct-connect.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$DIRECTC_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 5 of 7$BLUN [$STD Direct-Connect$BLUN ]$RED --> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 5 of 7$BLUN [$STD Direct-Connect$BLUN ]$GRNN --> $STD$DIRECTC_RESUL$"
DIRECT_NETNAME=$(whois $DIRECTC_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of$GRNN$DIRECTC_RESULT$STD --> $GRNN$DIRECTC_NETNAME"
fi
sleep 1.5
echo $STD""
######################################################################################
# nslookup with webmail
WEBMAIL_RESULT=$(nslookup webmail.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$WEBMAIL_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 6 of 7$BLUN [$STD Webmail$BLUN ]$RED --> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 6 of 7$BLUN [$STD Webmail$BLUN ]$GRNN --> $STD$WEBMAIL_RESUL$"
WEBMAIL_NETNAME=$(whois $WEBMAIL_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of$GRNN$WEBMAIL_RESULT$STD --> $GRNN$WEBMAIL_NETNAME"
fi
sleep 1.5
echo $STD""
#######################################################################################
# nslookup with portal
PORTAL_RESULT=$(nslookup portal.$lookup | sed '0,/Non-authoritative/d' | grep -i Address | sed 's/Address://')
if [ "$PORTAL_RESULT" == "" ] ; then 
echo $GRN">$STD Resolve Attempt 7 of 7$BLUN [$STD Portal$BLUN ]$RED --> $STD$FAIL"
else
echo $GRN">$STD Resolve Attempt 7 of 7$BLUN [$STD Portal$BLUN ]$GRNN --> $STD$PORTAL_RESUL$"
PORTAL_NETNAME=$(whois $PORTAL_RESULT | grep -i netname | awk '{print $2}')
echo "NetName of$GRNN$PORTAL_RESULT$STD --> $GRNN$PORTAL_NETNAME"
fi
sleep 1.5
echo $STD""
#
# finished
echo $REDN">$STD Resolve Attempts Exhausted$REDN <$STD"
echo $STD"  Please Review Data Above$STD :)"
echo $STD"  Press Enter To Continue.."
read enter
echo $STD""
./cloudIP



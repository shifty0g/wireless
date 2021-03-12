wireless
=========================
set for functions for pentesting wifi networks
mainly uses aircrack suite 


Features
--------------
* Turn Monitor Mode on or off
* Enable Manage Mode
* Connect to Wireless AP
* Dump wireless data fron an AP
* Deauth Attack
* Site Survey
* Crack a Cap file using Aircrack

Install
-----------
git clone the repo
make sure you have aircrack suite installed

Useage
---------
```console
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
```

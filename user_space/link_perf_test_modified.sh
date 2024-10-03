#!/bin/bash



cd /root/openwifi
./wgd.sh
./monitor_ch.sh sdr0 1
./sdrctl dev sdr0 set reg xpu 1 1
 insmod side_ch.ko iq_len_init=4095
 
 
 

 
 #Start receive
./side_ch_ctl_src/side_ch_ctl_modified wh11d2000 
#pre-trigger length = 2000
./side_ch_ctl_src/side_ch_ctl_modified wh8d1
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10


#Start transmit
COUNT=100
RATE=( 0 )
SIZE=50 # paload size in bytes

ERR_COUNT=0

	for (( j = 0 ; j < ${#RATE[@]} ; j++ )) do
	for (( i = 0 ; i < $COUNT ; i++ )) do
		inject_80211 -m 'n' -n 1  -r ${RATE[$j]} -s "sdr0"
		output=$(./side_ch_ctl_src/side_ch_ctl_modified g)
		ERR_COUNT=$((ERR_COUNT+$output))
	done
	done

#!/bin/bash



cd /root/openwifi
./wgd.sh
./monitor_ch.sh sdr0 1
./sdrctl dev sdr0 set reg xpu 1 1
 insmod side_ch.ko iq_len_init=4095
 
 
 

 
 #Start receive
./side_ch_ctl_src/side_ch_ctl wh11d2000 
#pre-trigger length = 2000
./side_ch_ctl_src/side_ch_ctl wh8d1
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10
./side_ch_ctl_src/side_ch_ctl g &

#Start transmit
HW_MODE='n'
DELAY=1000
COUNT=100
RATE=( 0  )
SIZE=( $(seq -s' ' 50) ) # paload size in bytes
IF="sdr0"


for (( i = 0 ; i < ${#PAYLOAD[@]} ; i++ )) do
	for (( j = 0 ; j < ${#RATE[@]} ; j++ )) do
		inject_80211 -m $HW_MODE -n $COUNT -d $DELAY -r ${RATE[$j]} -s ${SIZE[$i]} $IF
		 #Start Receive
		 errcnt=expr $(python side_ch_ctl_src/iq_capture_modified 4095)
		sleep 1
	done
done

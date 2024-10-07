#!/bin/bash


 
 #Start receive
./side_ch_ctl_modified wh11d2000 
#pre-trigger length = 2000
./side_ch_ctl_modified wh8d1
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10


#Start transmit
COUNT=100
RATE=( 0 )
SIZE=50 # paload size in bytes



	for (( j = 0 ; j < ${#RATE[@]} ; j++ )) do
	ERR_COUNT=0
	for (( i = 0 ; i < $COUNT ; i++ )) do
		./inject_80211/inject_80211 -m n -n 1  -r ${RATE[$j]} -s $SIZE sdr0 > /dev/null
		output=$(./side_ch_ctl_modified g)
		ERR_COUNT=$((ERR_COUNT+$output))
		echo Packet $i of $COUNT : $output
	done
	    printf "Packet Error for  ${RATE[$j]} = %.2f\n"  $(bc <<<"scale=4;1-$ERR_COUNT/$COUNT")
	done

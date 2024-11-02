#!/bin/bash

ssh root@192.168.10.122 <<'ENDSSH'
cd openwifi
rm result_perf_rvr.csv
 #Start receive
./side_ch_ctl wh11d500 > /dev/null  
#pre-trigger length = 500 seems to be good to capture rssi
./side_ch_ctl wh8d1 > /dev/null
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10
cd ..

echo "Starting"

cd openwifi/inject_80211/
make
cd ..

#Start transmit
COUNT=10
RATE=(0 4 7)
SIZE=128 # paload size in bytes
BO=(20 18 16 14 12 10 8 6 4 2 0)
PER=(0 0 0)

OUT="RSSI"


 for (( i = 1 ; i <= ${#BO[@]} ; i++ )) do
./sdrctl dev sdr0 set reg rf 0 $((${BO[$i-1]}*1000)) > /dev/null
./inject_80211/inject_80211 -m n -d 0 -n 1 -r 0 -s $SIZE sdr0 > /dev/null
rssi=$(./side_ch_ctl_src/side_ch_ctl_rssi g0)
				echo RSSI is $rssi for BO ${BO[$i-1]}
   OUT="${OUT},$rssi"
done

echo ${OUT}  >> result_perf_rvr.csv

			for (( j = 1 ; j <= ${#RATE[@]} ; j++ )) do
			PREV_ERR=1
				#Check SNR

			 	OUT="MCS${RATE[$j-1]}" 
 				for (( k = 1 ; k <= ${#BO[@]} ; k++ )) do	
		 		./sdrctl dev sdr0 set reg rf 0 $((${BO[$k-1]}*1000)) > /dev/null
				ERR=0
				if [[ $PREV_ERR != 0 ]]; then
					for (( i = 1 ; i <= $COUNT ; i++ )) do
						./inject_80211/inject_80211 -m n -d 0 -n 1 -r ${RATE[$j-1]} -s $SIZE sdr0 > /dev/null
						output=$(./side_ch_ctl_src/side_ch_ctl_decode g0)
						if [[ $output == 0 ]]; then
							outputString="Success"
						else
							outputString="Failed"
						fi
						ERR=$((ERR+$output))
						echo RATE = ${RATE[$j-1]} : Power BO = ${BO[$k-1]} :  Packet $i of $COUNT : Result = $outputString
						if [[ $ERR == 10 ]]; then
						echo $ERR  errors reached at count $i
							break
						fi
					done
				fi
				OUT="$OUT,$(bc <<<"scale=4;$ERR/$i")"
  				PREV_ERR=$ERR
				done
			
			printf "\n"
			echo $OUT >> result_perf_rvr.csv
			done
			
			cat result_perf_rvr.csv
			
ENDSSH

scp root@192.168.10.122:openwifi/result_perf_rvr.csv ./
python3 plot_result.py



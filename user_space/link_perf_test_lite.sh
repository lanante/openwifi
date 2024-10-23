#!/bin/bash


rm result_perf_lite.csv
 #Start receive
./side_ch_ctl_lite wh11d2000 > /dev/null
#pre-trigger length = 2000
./side_ch_ctl_lite wh8d1 > /dev/null
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10


#Start transmit
COUNT=100
RATE=(0 4 7)
SIZE=128 # paload size in bytes
BO=(20 18 16 14 12 10 8 6 4 2 0)


OUT="Power Backoff"
PREV_ERR=1

 for (( i = 1 ; i <= ${#BO[@]} ; i++ )) do
   OUT="${OUT},${BO[$i-1]}"
done


  
echo ${OUT}  >> result_perf_lite.csv

			for (( j = 1 ; j <= ${#RATE[@]} ; j++ )) do
			 	OUT="MCS${RATE[$j-1]}" 
 				for (( k = 1 ; k <= ${#BO[@]} ; k++ )) do	
		 		./sdrctl dev sdr0 set reg rf 0 $((${BO[$k-1]}*1000)) > /dev/null
				ERR=0
				if [[ $PREV_ERR != 0 ]]; then
					for (( i = 1 ; i <= $COUNT ; i++ )) do
						./inject_80211/inject_80211 -m n -d 0 -n 1 -r ${RATE[$j-1]} -s $SIZE sdr0 > /dev/null
						output=$(./side_ch_ctl_src/side_ch_ctl_lite g)
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
			echo $OUT >> result_perf_lite.csv
			done


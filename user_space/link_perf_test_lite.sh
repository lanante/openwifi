#!/bin/bash


 rm result_perf_lite.csv
 #Start receive
./side_ch_ctl_modified wh11d2000 > /dev/null
#pre-trigger length = 2000
./side_ch_ctl_modified wh8d1 > /dev/null
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10


#Start transmit
COUNT=100
RATE=( 7)
SIZE=128 # paload size in bytes
BO=(20 18 16 14 12 10 8 6 4 2 0)



OUT="Power Backoff,"


 for (( i = 0 ; i < ${#RATE[@]} ; i++ )) do
  if [[ $((i+1)) == ${#RATE[@]} ]]; then
    OUT="${OUT}MCS${RATE[$i]}"
  else
   OUT="${OUT}MCS${RATE[$i]},"
  fi
done

  
  
echo ${OUT}  >> result_perf_lite.csv


	 for (( k = 0 ; k < ${#BO[@]} ; k++ )) do
	 	OUT="${BO[$k]}" 
			for (( j = 0 ; j < ${#RATE[@]} ; j++ )) do
		 		./sdrctl dev sdr0 set reg rf 0 $((${BO[$k]}*1000)) > /dev/null
				ERR=0
				for (( i = 1 ; i <= $COUNT ; i++ )) do
					./inject_80211/inject_80211 -m n -d 0 -n 1 -r ${RATE[$j]} -s $SIZE sdr0 > /dev/null
					output=$(./side_ch_ctl_lite g)
					if [[ $output == 0 ]]; then
						outputString="Success"
					else
						outputString="Failed"
					fi
					ERR=$((ERR+$output))
					echo Power BO = ${BO[$k]} : RATE = ${RATE[$j]} : Packet $i of $COUNT : Result = $outputString
					if [[ $ERR == 10 ]]; then
			#			echo $ERR  errors reached at count $i
						break
					fi
				
				done
				  if [[ $((j+1)) == ${#RATE[@]} ]]; then
    					OUT="$OUT$(bc <<<"scale=4;$ERR/$i")"
 				  else
  					OUT="$OUT,$(bc <<<"scale=4;$ERR/$i")"
  				  fi

			done
			printf "\n"
			echo $OUT,$(bc <<<"scale=4;$ERR/$i")>> result_perf_lite.csv
	done


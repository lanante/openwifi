#!/bin/bash


 rm result_perf_lite.csv
 #Start receive
#./side_ch_ctl_modified wh11d2000 > /dev/null
#pre-trigger length = 2000
#./side_ch_ctl_modified wh8d1 > /dev/null
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
# receiver gives short preamble detected=9, RSSI (half dB uncalibrated) goes above the threshold=10


#Start transmit
COUNT=10
RATE=( 0 1 2 3 4 7)
SIZE=128 # paload size in bytes
BO=(0 2 4 6 8 10 12 14 16 18 20)



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
			for (( j = 0 ; j < ${#RATE[@]}-1 ; j++ )) do
		 		#./sdrctl dev sdr0 set reg rf 0 $((${BO[$k]}*1000)) > /dev/null
				SUCC=0
				for (( i = 0 ; i < $COUNT ; i++ )) do
					#./inject_80211/inject_80211 -m n -n 1  -r ${RATE[$j]} -s $SIZE sdr0 > /dev/null
					#output=$(./side_ch_ctl_lite g)
					#SUCC=$((SUCC+$output))
					output=1
					echo Power BO = ${BO[$k]} : RATE = ${RATE[$j]} : Packet $i of $COUNT : Result = $output
				done
				  if [[ $((j+1)) == ${#RATE[@]} ]]; then
    					OUT="$OUT$(bc <<<"scale=4;1-$SUCC/$COUNT")"
 				  else
  					OUT="$OUT,$(bc <<<"scale=4;1-$SUCC/$COUNT")"
  				  fi

			done
				echo $OUT,$(bc <<<"scale=4;1-$SUCC/$COUNT")>> result_perf_lite.csv
	done


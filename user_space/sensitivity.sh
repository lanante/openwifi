#!/bin/bash

cd /root/openwifi
./wgd.sh
./monitor_ch.sh sdr0 11
./sdrctl dev sdr0 set reg xpu 1 1
 insmod side_ch.ko iq_len_init=4095
./side_ch_ctl wh11d2000
./side_ch_ctl wh8d8
./inject_80211/inject_80211 -d 10000 -r 0 -t d -e 0 -b 5a -n 99999999 -s 1000 sdr0 &
 ./side_ch_ctl g &






## Start
- Power on the SDR board.
- Connect the TX port to the RX port of the SDR board with a wire. Put **ENOUGH ATTENUATION** to protect your board.
- Connect a computer to the SDR board via Ethernet cable. The computer should have static IP 192.168.10.1. Open a terminal on the computer, and then in the terminal:
  ```
  ssh root@192.168.10.122
  # (password: openwifi)
  cd /root/openwifi
  ./wgd.sh
  # (Wait for the script completed)
  ./monitor_ch.sh sdr0 11
  # (Monitor on channel 11. You can change 11 to other channel that is busy)
  ./sdrctl dev sdr0 set reg xpu 1 1
  # (Above unmute the baseband self-receiving to receive openwifi own TX signal/packet)
    insmod side_ch.ko iq_len_init=4095
  # (for smaller FPGA (7Z020), iq_len_init should be <4096, like 4095, instead of 8187)
  ./side_ch_ctl wh11d2000
  ./side_ch_ctl wh8d8
  ./side_ch_ctl g &
  
	N=10
	S=0
## Transmit
for i in $(seq 1 $N); 
do   
./inject_80211/inject_80211 -d 10000 -r 0 -t d -e 0 -b 5a -n 1 -s 1000 sdr0; 
result=python3 decode.py 
if [ "$result" == "Success" ]; then
S=$((S+1))
fi
done


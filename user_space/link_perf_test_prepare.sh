#!/bin/bash



cd /root/openwifi
./wgd.sh
./monitor_ch.sh sdr0 1
./sdrctl dev sdr0 set reg xpu 1 1
insmod side_ch.ko iq_len_init=4095
 

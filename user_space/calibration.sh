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


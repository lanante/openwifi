#!/bin/bash

ssh root@192.168.10.122 <<'ENDSSH'
cd /root/openwifi
./wgd.sh
./monitor_ch.sh sdr0 1
./sdrctl dev sdr0 set reg xpu 1 1
insmod side_ch.ko iq_len_init=4095

#./side_ch_ctl wh5h0 #manual loopback
./side_ch_ctl wh5h4  #internal loopback
./sdrctl dev sdr0 set reg rx 5 768 #internal loopback

ENDSSH



scp  ./side_ch_ctl_src/side_ch_ctl.c  root@192.168.10.122:openwifi/side_ch_ctl_src
scp  ./side_ch_ctl_src/side_ch_ctl_decode.c  root@192.168.10.122:openwifi/side_ch_ctl_src
scp  ./side_ch_ctl_src/side_ch_ctl_rssi.c  root@192.168.10.122:openwifi/side_ch_ctl_src
ssh root@192.168.10.122 <<'ENDSSH'
cd openwifi
cd side_ch_ctl_src
gcc -o side_ch_ctl side_ch_ctl.c
gcc -o side_ch_ctl_rssi side_ch_ctl_rssi.c
gcc -o side_ch_ctl_decode side_ch_ctl_decode.c
cd ..

ENDSSH


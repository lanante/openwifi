scp link_perf_test_lite.sh  root@192.168.10.122:openwifi/
scp  ./side_ch_ctl_src/side_ch_ctl_lite.c  root@192.168.10.122:openwifi/side_ch_ctl_src


scp link_perf_test_lite_temp.sh  root@192.168.10.122:openwifi/
ssh root@192.168.10.122 <<'ENDSSH'
cd openwifi
cd side_ch_ctl_src
gcc -o side_ch_ctl_lite side_ch_ctl_lite.c
cd ..
./link_perf_test_lite_temp.sh 

ENDSSH


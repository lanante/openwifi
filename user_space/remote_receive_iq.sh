

# ssh into the SDR board, password: openwifi
ssh root@192.168.10.122 <<'ENDSSH'
cd openwifi/side_ch_ctl_src
# Relay the FPGA IQ capture to the host computer that will show the captured IQ later on)

./side_ch_ctl wh11d500 
#pre-trigger length

./side_ch_ctl wh8d1
# checksum pass= 1,  receiver gives SIGNAL field checksum result. pass = 4,  receiver gives long preamble detected=8, 
./side_ch_ctl_rssi g0


ENDSSH

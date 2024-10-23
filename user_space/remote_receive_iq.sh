

# ssh into the SDR board, password: openwifi
ssh root@192.168.10.122 <<'ENDSSH'
cd openwifi
# Relay the FPGA IQ capture to the host computer that will show the captured IQ later on)
./side_ch_ctl g0


ENDSSH

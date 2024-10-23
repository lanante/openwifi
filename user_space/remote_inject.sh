

ssh root@192.168.10.122 <<'ENDSSH'
cd openwifi/inject_80211/
make
# Build our example packet injection program
./inject_80211 -m n -r 5 -n 1 sdr0
# Inject one packet to openwifi sdr0 NIC
ENDSSH


#
# openwifi side info receive and display program
# Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be
#
import os
import sys
import socket
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('GTK3Agg')

def rssi_correction_lookup_table(freq_mhz):
    if freq_mhz < 2412 or freq_mhz <= 2484 or freq_mhz < 5160:
        return 153
    else:
        return 145


def rssi_half_db_to_rssi_dbm(rssi_hdb, rssi_correction):
    rssi_db = (rssi_hdb >> 1)
    rssi_dbm = rssi_db - rssi_correction
    rssi_dbm = [max(x, -128)  for x in rssi_dbm] # Ensure rssi_dbm is not less than -128

    return rssi_dbm

def display_iq(iq_capture, agc_gain, rssi):


    fig_iq_capture = plt.figure(0)
    fig_iq_capture.clf()
    plt.xlabel("sample")
    plt.ylabel("I/Q")
    plt.title("I (blue) and Q (red) capture")
    plt.plot(iq_capture.real, 'b')
    plt.plot(iq_capture.imag, 'r')
    plt.ylim(-32767, 32767)
    fig_iq_capture.canvas.flush_events()

    agc_gain_lock = np.copy(agc_gain)
    agc_gain_lock[agc_gain>127] = 80 # agc lock
    agc_gain_lock[agc_gain<=127] = 0 # agc not lock

    agc_gain_value = np.copy(agc_gain)
    agc_gain_value[agc_gain>127] = agc_gain[agc_gain>127] - 128

    fig_agc_gain = plt.figure(1)
    fig_agc_gain.clf()
    plt.xlabel("sample")
    plt.ylabel("gain/lock")
    plt.title("AGC gain (blue) and lock status (red)")
    plt.plot(agc_gain_value, 'b')
    plt.plot(agc_gain_lock, 'r')
    plt.ylim(0, 82)
    fig_agc_gain.canvas.flush_events()

    fig_rssi = plt.figure(2)
    fig_rssi.clf()
    plt.xlabel("sample")
    plt.ylabel("dBm")
    plt.title("RSSI  (calibrated)")
    plt.plot(rssi)
    plt.ylim(-100, 10)
    fig_rssi.canvas.flush_events()


def parse_iq(iq, iq_len):
    # print(len(iq), iq_len)
    num_dma_symbol_per_trans = 1 + iq_len
    num_int16_per_trans = num_dma_symbol_per_trans*4 # 64bit per dma symbol
    num_trans = round(len(iq)/num_int16_per_trans)
    # print(len(iq), iq.dtype, num_trans)
    iq = np.int64(iq.reshape([num_trans, num_int16_per_trans]))
    
    timestamp = iq[:,0] + pow(2,16)*iq[:,1] + pow(2,32)*iq[:,2] + pow(2,48)*iq[:,3]
    iq_capture = np.int16(iq[:,4::4]) + np.int16(iq[:,5::4])*1j
    agc_gain = iq[:,6::4]
    rssi_half_db = iq[:,7::4]
    # print(num_trans, iq_len, iq_capture.shape, agc_gain.shape, rssi_half_db.shape)

    iq_capture = iq_capture.reshape([num_trans*iq_len,])
    agc_gain = agc_gain.reshape([num_trans*iq_len,])
    rssi_half_db = rssi_half_db.reshape([num_trans*iq_len,])

    return timestamp, iq_capture, agc_gain, rssi_half_db

UDP_IP = "192.168.10.1" #Local IP to listen
UDP_PORT = 4000         #Local port to listen

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 464) # for low latency. 464 is the minimum udp length in our case (CSI only)

# align with side_ch_control.v and all related user space, remote files
MAX_NUM_DMA_SYMBOL = 8192

if len(sys.argv)<2:
    print("Assume iq_len = 8187! (Max UDP 65507 bytes; (65507/8)-1 = 8187)")
    iq_len = 4095
else:
    iq_len = int(sys.argv[1])
    print(iq_len)
    # print(type(num_eq))

if iq_len>8187:
    iq_len = 8187
    print('Limit iq_len to 8187! (Max UDP 65507 bytes; (65507/8)-1 = 8187)')

num_dma_symbol_per_trans = 1 + iq_len
num_byte_per_trans = 8*num_dma_symbol_per_trans

if os.path.exists("iq.txt"):
    os.remove("iq.txt")
iq_fd=open('iq.txt','a')

plt.ion()

while True:
    try:
        data, addr = sock.recvfrom(MAX_NUM_DMA_SYMBOL*8) # buffer size
        # print(addr)
        test_residual = len(data)%num_byte_per_trans
        print(len(data)/8, num_dma_symbol_per_trans, test_residual)
        if (test_residual != 0):
            print("Abnormal length")

        iq = np.frombuffer(data, dtype='uint16')
        np.savetxt(iq_fd, iq)

        timestamp, iq_capture, agc_gain, rssi_half_db = parse_iq(iq, iq_len)
        rssi=rssi_half_db_to_rssi_dbm(rssi_half_db,rssi_correction_lookup_table(2400))

        print(timestamp,rssi[0],rssi_half_db )
        print(data[:20])

        display_iq(iq_capture, agc_gain, rssi)
        plt.show()
        
    except KeyboardInterrupt:
        print('User quit')
        break

print('close()')
iq_fd.close()
sock.close()

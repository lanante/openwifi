#
# openwifi side info receive and display program
# Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be
#
import sys
import socket
import numpy as np


def parse_side_info(side_info, num_eq, CSI_LEN, EQUALIZER_LEN, HEADER_LEN):
    # print(len(side_info), num_eq, CSI_LEN, EQUALIZER_LEN, HEADER_LEN)
    CSI_LEN_HALF = round(CSI_LEN/2)
    num_dma_symbol_per_trans = HEADER_LEN + CSI_LEN + num_eq*EQUALIZER_LEN
    num_int16_per_trans = num_dma_symbol_per_trans*4 # 64bit per dma symbol
    num_trans = round(len(side_info)/num_int16_per_trans)
    # print(len(side_info), side_info.dtype, num_trans)
    side_info = np.int64(side_info.reshape([num_trans, num_int16_per_trans]))
    
    timestamp = side_info[:,0] + pow(2,16)*side_info[:,1] + pow(2,32)*side_info[:,2] + pow(2,48)*side_info[:,3]

    
    freq_offset = (20e6*np.int16(side_info[:,4])/512)/(2*3.14159265358979323846)

    csi = np.zeros((num_trans, CSI_LEN), dtype='int16')
    csi = csi + csi*1j
    
    equalizer = np.zeros((0,0), dtype='int16')
    if num_eq>0:
        equalizer = np.zeros((num_trans, num_eq*EQUALIZER_LEN), dtype='int16')
        equalizer = equalizer + equalizer*1j
    
    for i in range(num_trans):
        tmp_vec_i = np.int16(side_info[i,8:(num_int16_per_trans-1):4])
        tmp_vec_q = np.int16(side_info[i,9:(num_int16_per_trans-1):4])
        tmp_vec = tmp_vec_i + tmp_vec_q*1j
        # csi[i,:] = tmp_vec[0:CSI_LEN]
        csi[i,:CSI_LEN_HALF] = tmp_vec[CSI_LEN_HALF:CSI_LEN]
        csi[i,CSI_LEN_HALF:] = tmp_vec[0:CSI_LEN_HALF]
        if num_eq>0:
            equalizer[i,:] = tmp_vec[CSI_LEN:(CSI_LEN+num_eq*EQUALIZER_LEN)]
        # print(i, len(tmp_vec), len(tmp_vec[0:CSI_LEN]), len(tmp_vec[CSI_LEN:(CSI_LEN+num_eq*EQUALIZER_LEN)]))

    return timestamp, freq_offset, csi, equalizer

UDP_IP = "192.168.10.1" #Local IP to listen
UDP_PORT = 4000         #Local port to listen

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 464) # for low latency. 464 is the minimum udp length in our case (CSI only)

# align with side_ch_control.v and all related user space, remote files
MAX_NUM_DMA_SYMBOL = 8192
CSI_LEN = 56 # length of single CSI
EQUALIZER_LEN = (56-4) # for non HT, four {32767,32767} will be padded to achieve 52 (non HT should have 48)
HEADER_LEN = 2 # timestamp and frequency offset





num_dma_symbol_per_trans = HEADER_LEN + CSI_LEN + 0*EQUALIZER_LEN
num_byte_per_trans = 8*num_dma_symbol_per_trans


data, addr = sock.recvfrom(MAX_NUM_DMA_SYMBOL*8) # buffer size
test_residual = len(data)%num_byte_per_trans
sock.close()

if (test_residual > 0):
    print ('Success')
else:
    print ('Error')

sys.exit(0)


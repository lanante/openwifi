#
# openwifi side info receive and display program
# Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be
#
import sys
import socket
#import matplotlib.pyplot as plt



UDP_IP = "192.168.10.1" #Local IP to listen
UDP_PORT = 4000         #Local port to listen

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))
sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 464) # for low latency. 464 is the minimum udp length in our case (CSI only)

# align with side_ch_control.v and all related user space, remote files
MAX_NUM_DMA_SYMBOL = 8192

if len(sys.argv)<2:
    print("Assume iq_len = 8187! (Max UDP 65507 bytes; (65507/8)-1 = 8187), Assume N=1")
    iq_len = 8187
    N=1
elif len(sys.argv)<2:
    iq_len = int(sys.argv[1])
    N=1
    print("Assume N=1")
    # print(type(num_eq))
else:
    iq_len = int(sys.argv[1])
    N=int(sys.argv[2])

if iq_len>8187:
    iq_len = 8187
    print('Limit iq_len to 8187! (Max UDP 65507 bytes; (65507/8)-1 = 8187)')

    
    
num_dma_symbol_per_trans = 1 + iq_len
num_byte_per_trans = 8*num_dma_symbol_per_trans

#if os.path.exists("iq.txt"):
#    os.remove("iq.txt")
#iq_fd=open('iq.txt','a')

#plt.ion()


data, addr = sock.recvfrom(MAX_NUM_DMA_SYMBOL*8) # buffer size
test_residual = len(data)%num_byte_per_trans
if test_residual!=0 & test_residual > 0:
    print('0')
else:
    print('1')
#iq_fd.close()
sock.close()

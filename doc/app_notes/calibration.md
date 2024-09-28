<!--
Author: Leonardo Lanante
SPDX-FileCopyrightText: 2024 Leonardo Lanante
SPDX-License-Identifier: ISC
-->

<!--
Author: Xianjun jiao
SPDX-FileCopyrightText: 2019 UGent
SPDX-License-Identifier: AGPL-3.0-or-later
-->

We use the 

##We implement the **IQ sample capture** with interesting extensions: many **trigger conditions**; **RSSI**, RF chip **AGC** **status (lock/unlock)** and **gain**.

##(By default, openwifi Rx baseband is muted during self Tx, to unmute Rx baseband and capture self Tx signal you need to run "./sdrctl dev sdr0 set reg xpu 1 1" after the test running)

## Quick start
- Power on the SDR board.
- Connect a computer to the SDR board via Ethernet cable. The computer should have static IP 192.168.10.1. Open a terminal on the computer, and then in the terminal:
  ```
  ssh root@192.168.10.122
  # (password: openwifi)
  cd /root/openwifi
  ./wgd.sh
  # (Wait for the script completed)
  ./monitor_ch.sh sdr0 11
  # (Monitor on channel 11. You can change 11 to other channel that is busy)
  ./sdrctl dev sdr0 set reg xpu 1 1
  # (Above unmute the baseband self-receiving to receive openwifi own TX signal/packet)
    insmod side_ch.ko iq_len_init=4095
  # (for smaller FPGA (7Z020), iq_len_init should be <4096, like 4095, instead of 8187)
  ./side_ch_ctl wh11d2000
  ./side_ch_ctl wh8d8
  ./inject_80211/inject_80211 -d 10000 -r 0 -t d -e 0 -b 5a -n 99999999 -s 1000 sdr0
  ```

- Open another terminal and ssh on the board.
  ```
  cd /root/openwifi
  # (Above command is needed only when you run with zed, adrv9364z7020, zc702 board)
   ./side_ch_ctl g
  ```
  You should see on board outputs like:
  ```
  loop 64 side info count 61
  loop 128 side info count 99
  ...
  ```
  If the second number (side info count 61, 99, ...) keeps increasing, that means the trigger condition is met from time to time and the IQ sample is going to the computer smoothly.
  
- Open another terminal on the computer, and run:
  ```
  cd openwifi/user_space/side_ch_ctl_src
  python3 iq_capture.py 4095
  (for zed, adrv9364z7020, zc702 board, add argument that euqals to iq_len_init, like 4095)
  ```


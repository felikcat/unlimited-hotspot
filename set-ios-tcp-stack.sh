#!/bin/sh
SYSCTL="$(where sysctl)"

# Act like more of an iPhone, and less of a macOS device.
## Note: These are all divided by 2, compared to macOS defaults.
$SYSCTL -w net.inet.tcp.sendspace=65536 # Default: iOS * 2 -> 131072 (macOS)
$SYSCTL -w net.inet.tcp.recvspace=65536 # iOS * 2
$SYSCTL -w kern.ipc.maxsockbuf=4194304 # iOS * 2

$SYSCTL -w net.inet.tcp.win_scale_factor=6 # 9 is closer to Android.
$SYSCTL -w net.inet.ipsec.dfbit=1          # Might be IPSec exclusive, but just in case.

exit 0

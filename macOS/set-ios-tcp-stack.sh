#!/bin/bash
SYSCTL="$(whereis sysctl | awk '{print $2}')"

# Set TCP buffers and TCP window scaling to an iPhone 13 Mini running iOS 17.
${SYSCTL} -w net.inet.tcp.sendspace=65536     # macOS default: iOS * 2
${SYSCTL} -w net.inet.tcp.recvspace=65536     # macOS default: iOS * 2
${SYSCTL} -w kern.ipc.maxsockbuf=4194304      # macOS default: iOS * 2
${SYSCTL} -w net.inet.tcp.win_scale_factor=6  # macOS default: 9
# For creating a local hotspot on macOS, which is required for unlimited hotspot from iOS and iPadOS devices.
${SYSCTL} -w net.inet.ip.forwarding=1         # macOS default: 1
exit 0

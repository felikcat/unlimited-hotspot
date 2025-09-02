#!/bin/bash
SYSCTL="$(whereis sysctl | awk '{print $2}')"

# Set TCP buffers and TCP window scaling to an iPhone 16 Pro Max running iOS 26.
${SYSCTL} -w net.inet.tcp.sendspace=65536     # macOS default: typically 131072
${SYSCTL} -w net.inet.tcp.recvspace=65536     # macOS default: typically 131072
${SYSCTL} -w kern.ipc.maxsockbuf=4194304      # macOS default: typically 8388608
${SYSCTL} -w net.inet.tcp.win_scale_factor=6  # macOS default: 3
${SYSCTL} -w net.inet.tcp.autorcvbufmax=4194304  # macOS default: typically 4194304; caps auto-tuning to iOS levels
${SYSCTL} -w net.inet.tcp.autosndbufmax=4194304  # macOS default: typically 4194304; caps auto-tuning to iOS levels
${SYSCTL} -w net.inet.tcp.mssdflt=1448        # macOS default: 512; aligns with iOS MSS for RFC1323-enabled connections
${SYSCTL} -w net.inet.tcp.rfc1323=1           # macOS default: 1; enables timestamps and window scaling, as in iOS
${SYSCTL} -w net.inet.tcp.delayed_ack=3       # macOS default: 3; matches iOS delayed ACK behavior
# TTL adjustments to mimic iOS packet lifetimes and avoid detection in tethered setups.
${SYSCTL} -w net.inet.ip.ttl=65               # macOS default: 64
${SYSCTL} -w net.inet6.ip6.hlim=65            # macOS default: 64
# For creating a local hotspot on macOS, which is required for unlimited hotspot from iOS and iPadOS devices.
${SYSCTL} -w net.inet.ip.forwarding=1         # macOS default: 0
exit 0

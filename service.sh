#!/system/bin/sh

# Notes:
## resetprop (without -n) = deletes a property then modifies it, this forces property_service to update that property immediately.
## Avoid changing props that can be important to a niche group of users, such as "persist.traced.enable".

# 'dun' persistently tells the telecom that tethering was used.
# Only a reboot can remove the 'dun' APN flag; but here we disable setting 'dun' in the first place.
resetprop tether_dun_required 0

# Don't tell the telecom to check if tethering is even allowed for your data plan.
resetprop net.tethering.noprovisioning true
resetprop tether_entitlement_check_state 0

# Fully shut-down the device to prevent connection issues; never hibernate on "Power off".
resetprop persist.sys.shutdown.mode 
resetprop persist.ro.config.hw_quickpoweron false
resetprop persist.ro.warmboot.capability 0


#== Performance tweaks ==
sysctl -w kernel.sched_schedstats=0
echo off > /proc/sys/kernel/printk_devkmsg
for disks in /sys/block/*/queue; do
    # Don't log I/O statistics.
    echo 0 > "$disks/iostats" 
done
# Use "Explicit Congestion Notification" for both incoming and outgoing packets.
sysctl -w net.ipv4.tcp_ecn=1
# Consume more battery while semi-idle to have more stable internet.
## For some devices with old Linux kernels, this lessens CPU interrupts and thus saves battery.
sysctl -w kernel.timer_migration=0

# Use the best available TCP congestion algorithm.
sysctl -w net.ipv4.tcp_congestion_control=cubic
sysctl -w net.ipv4.tcp_congestion_control=bbr
sysctl -w net.ipv4.tcp_congestion_control=bbr2
sysctl -w net.ipv4.tcp_congestion_control=bbr3
#== END ==


# Don't apply iptables rules until Android has fully booted.
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 1s
done

# Also bypass TTL/HL detections for other devices that connect to this device.
# Notes:
## Routers (as the client) require their own TTL/HL increment script.
## Tethering interfaces -> rndis0: USB, wlan1: Wi-Fi, bt-pan: Bluetooth.
## -A: last rule in chain, -I: "head"/first rule in chain (by default).
for INTERFACE in "rndis0" "wlan1" "bt-pan"; do
    iptables -t mangle -A PREROUTING -i $INTERFACE -j TTL --ttl-inc 1
    iptables -t mangle -I POSTROUTING -o $INTERFACE -j TTL --ttl-inc 1
    ip6tables -t mangle -A PREROUTING ! -p icmpv6 -i $INTERFACE -j HL --hl-inc 1
    ip6tables -t mangle -I POSTROUTING ! -p icmpv6 -o $INTERFACE -j HL --hl-inc 1
done

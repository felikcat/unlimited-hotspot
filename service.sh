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
resetprop -p persist.ro.config.hw_quickpoweron false
resetprop -p persist.ro.warmboot.capability 0


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

# Dynamically select the best available TCP congestion algorithm.
AVAILABLE_CONGESTION=$(sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null)
if echo "$AVAILABLE_CONGESTION" | grep -q bbr3; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr3
elif echo "$AVAILABLE_CONGESTION" | grep -q bbr2; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr2
elif echo "$AVAILABLE_CONGESTION" | grep -q bbr; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr
else
    sysctl -w net.ipv4.tcp_congestion_control=cubic
fi
#== END ==


# Don't apply iptables rules or WiFi country code until Android has fully booted.
until [ "$(getprop sys.boot_completed)" = 1 ]; do
    sleep 1
done

# Allow 6GHz WiFi tethering in any country.
cmd wifi force-country-code enabled BR

# Also bypass TTL/HL detections for other devices that connect to this device.
# Notes:
## Routers (as the client) require their own TTL/HL increment script.
## Tethering interfaces -> rndis0: USB, wlan1: Wi-Fi, bt-pan: Bluetooth.
## -A: append rule to chain (last position), -I: insert rule at beginning of chain.
for INTERFACE in "rndis0" "wlan0" "wlan1" "ap0" "bt-pan"; do
    # Skip if interface does not exist to avoid errors.
    if [ -d "/sys/class/net/$INTERFACE" ]; then
        iptables -t mangle -A PREROUTING -i "$INTERFACE" -j TTL --ttl-inc 1
        iptables -t mangle -I POSTROUTING -o "$INTERFACE" -j TTL --ttl-inc 1
        ip6tables -t mangle -A PREROUTING ! -p icmpv6 -i "$INTERFACE" -j HL --hl-inc 1
        ip6tables -t mangle -I POSTROUTING ! -p icmpv6 -o "$INTERFACE" -j HL --hl-inc 1
    fi
done

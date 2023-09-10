#!/system/bin/sh

resetprop -d tether_dun_required
resetprop -d net.tethering.noprovisioning
resetprop -d tether_entitlement_check_state
resetprop -p -d persist.ro.config.hw_quickpoweron
resetprop -p -d persist.ro.warmboot.capability

# Specific to Unlimited Hotspot v5 only:
resetprop -p -d persist.logcat.live
resetprop -p -d persist.vendor.sys.modem.diag.mdlog
resetprop -p -d persist.vendor.verbose_logging_enabled
resetprop -p -d persist.traced.enable

#!/system/bin/sh

resetprop --delete tether_dun_required
resetprop --delete net.tethering.noprovisioning
resetprop --delete tether_entitlement_check_state
resetprop -p --delete persist.ro.config.hw_quickpoweron
resetprop -p --delete persist.ro.warmboot.capability

# Specific to changes Unlimited Hotspot v5 did:
resetprop -p --delete persist.logcat.live
resetprop -p --delete persist.vendor.sys.modem.diag.mdlog
resetprop -p --delete persist.vendor.verbose_logging_enabled
resetprop -p --delete persist.traced.enable

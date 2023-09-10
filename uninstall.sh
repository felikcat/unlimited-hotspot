#!/system/bin/sh

resetprop -d tether_dun_required
resetprop -d net.tethering.noprovisioning
resetprop -d tether_entitlement_check_state
resetprop -p -d persist.ro.config.hw_quickpoweron
resetprop -p -d persist.ro.warmboot.capability
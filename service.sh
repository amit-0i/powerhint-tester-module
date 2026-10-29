#!/system/bin/sh
MODDIR=${0%/*}
# Let Android finish booting and allow KernelSU's systemless mount to settle.
waited=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ "$waited" -lt 180 ]; do
    sleep 2
    waited=$((waited + 2))
done
sh "$MODDIR/restart-powerhal.sh"

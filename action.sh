#!/system/bin/sh
MODDIR=${0%/*}
echo "PowerHint Tester"
echo "Checking systemless overlay and requesting a Power HAL reload..."
sh "$MODDIR/restart-powerhal.sh"
echo "Log: /data/adb/powerhint-tester.log"

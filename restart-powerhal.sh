#!/system/bin/sh
MODDIR=${0%/*}
LOG=/data/adb/powerhint-tester.log
log() {
    /system/bin/toybox date '+%Y-%m-%d %H:%M:%S' 2>/dev/null | while IFS= read -r ts; do
        echo "[$ts] $*" >> "$LOG"
    done
}

EXPECTED="$MODDIR/system/vendor/etc/powerhint.json"
LIVE="/vendor/etc/powerhint.json"

if [ ! -f "$EXPECTED" ]; then
    log "ERROR: module config missing: $EXPECTED"
    exit 1
fi
if [ ! -f "$LIVE" ]; then
    log "ERROR: live config path not found: $LIVE; this ROM may use a different config path."
    exit 1
fi
if ! cmp -s "$EXPECTED" "$LIVE"; then
    log "WARNING: /vendor/etc/powerhint.json does not match the module config; overlay not confirmed. Skipping HAL restart."
    exit 1
fi

# The uploaded power-libperfmgr init rc declares this service name.
SVC="vendor.power-hal-aidl"
STATE="$(getprop "init.svc.$SVC")"
if [ -z "$STATE" ]; then
    log "WARNING: init service '$SVC' was not found. Config is overlaid, but this ROM may use a differently named Power HAL."
    exit 0
fi

log "Config overlay confirmed. Restarting $SVC (state=$STATE) to reload powerhint.json."
setprop ctl.restart "$SVC"
sleep 3
log "Restart request sent for $SVC; current state=$(getprop "init.svc.$SVC"). Check logcat for parser or service errors."
exit 0

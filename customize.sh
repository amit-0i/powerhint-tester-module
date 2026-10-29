ui_print "- PowerHint Tester"
ui_print "- Replaces /vendor/etc/powerhint.json systemlessly."
ui_print "- Requires KernelSU system-file overlay support (a compatible metamodule)."
if [ -f /vendor/etc/powerhint.json ]; then
    ui_print "- Existing /vendor/etc/powerhint.json detected."
else
    ui_print "! WARNING: /vendor/etc/powerhint.json not found before reboot."
    ui_print "! Verify your ROM's actual libperfmgr config path before relying on this module."
fi

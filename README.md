# PowerHint Tester (KernelSU)

A systemless overlay for testing the supplied `powerhint.json` without rebuilding a ROM.

## What it does

- Overlays `system/vendor/etc/powerhint.json` onto `/vendor/etc/powerhint.json`.
- Does not write to or modify the physical vendor partition.
- On boot completion, checks that the live file matches the module file and asks the `vendor.power-hal-aidl` service to restart so it can reread the JSON.
- The KernelSU Manager **Action** button performs the same verification/restart check.
- Logs checks and restart requests to `/data/adb/powerhint-tester.log`.

## Requirements and limitations

- A rooted device running KernelSU.
- KernelSU system-file overlay support supplied by a compatible metamodule (for example, meta-overlayfs). Current KernelSU builds delegate system-file mounting to a metamodule.
- A ROM whose Power HAL is libperfmgr-compatible and reads `/vendor/etc/powerhint.json`.
- The sysfs paths in the JSON must exist and accept the specified values on your kernel. This ZIP cannot verify hardware-node access on the phone.
- This is not intended to be flashed in custom recovery; install it from the KernelSU app.

## Install

1. Copy `PowerhintTester.zip` to the phone.
2. Open KernelSU Manager → Modules → Install from storage and choose the ZIP.
3. Reboot the phone. The module needs a boot with the systemless vendor overlay active.
4. Check the log with a root shell: `cat /data/adb/powerhint-tester.log`.
5. Confirm the live config matches the packaged config with a root shell:
   `cmp /data/adb/modules/powerhint_tester/system/vendor/etc/powerhint.json /vendor/etc/powerhint.json`\
   if it returns nothing, the flash was successfull

## Trying a new JSON revision

Edit the module's `system/vendor/etc/powerhint.json`, package/reinstall the updated module ZIP, and reboot. The Power HAL reads its config at service startup; merely changing the file on disk is not a guaranteed hot reload. The Action button restarts the service only when the live mounted config matches the module copy.

## Rollback

Disable the module in KernelSU Manager and reboot, or uninstall it and reboot. The original vendor file was never overwritten. If Android becomes unstable, use KernelSU's module-disable/rescue path; from a root shell, `touch /data/adb/modules/powerhint_tester/disable` followed by a reboot disables this module.

## Troubleshooting

- If the log says the live file does not match, the overlay may not be mounted, or this ROM may use another config path. Do not assume the tuning is active until this is resolved.
- If the service name is not found, inspect `getprop | grep init.svc` and the device's Power HAL init `.rc` file. Do not blindly restart unrelated services.
- Inspect Power HAL logs after installation, e.g. `logcat -b all -d | grep -iE 'powerhal|perfmgr|powerhint|hintmanager'`.

### Bootloop Recovery & Safety

**If your device bootloops or the Power HAL becomes unstable after installing this module, disable the module before attempting further changes. A ROM rebuild is normally not required.**

#### Method 1: KernelSU Safe Mode
1. Restart the device.
2. During boot, quickly press and release **Volume Down more than three times** to attempt to trigger KernelSU Safe Mode. This depends on your KernelSU build.
3. If Safe Mode is triggered, open KernelSU Manager and disable or uninstall **PowerHint Tester**.
4. Reboot normally.

#### Method 2: Recovery
If Safe Mode does not work, boot into a compatible custom recovery that can access and decrypt `/data`.

Create an empty file named `disable` inside the module directory:

```sh
touch /data/adb/modules/powerhint_tester/disable
```

Reboot the device. KernelSU should skip the disabled module.

### Method 3: ADB
If Android boots sufficiently and ADB access is available:

```sh
adb shell su -c 'touch /data/adb/modules/powerhint_tester/disable'
adb reboot
```

**Warning:** Do not format `/data` to recover from a module-related bootloop. If recovery cannot decrypt `/data`, use a compatible recovery environment or another supported KernelSU recovery method. Recovery behavior depends on the device, ROM, and KernelSU version.


## For developers
- replace the `system/vendor/etc/powerhint.json` for your device and package the module.
- make sure to change the powerhint path if your device uses anything other than `vendor/etc/powerhint.json`
- after doing the above zip this repository and flash from KernelSU Manager

### Before Testing Modified Configurations
- Back up the original ROM configuration before installing the module.
- Validate JSON syntax before each installation:

  ```sh
  python -m json.tool powerhint.json > /dev/null
  ```

- Remember that valid JSON does not guarantee that every node, value, or hint is supported by your ROM or kernel.
- Test changes incrementally and keep a recovery method available.
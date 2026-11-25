# LOQ fwupd remote (unofficial)

Update the BIOS of supported Lenovo LOQ laptops from Linux with plain
`fwupdmgr update`, without Windows.

> **Unofficial and not Lenovo-approved.** This is a community remote. Lenovo
> does not publish LOQ firmware on LVFS
> ([fwupd/firmware-lenovo#461](https://github.com/fwupd/firmware-lenovo/issues/461)).
> Firmware updates can brick a laptop. **Prepare a crisis recovery USB first:
> see [RECOVERY.md](RECOVERY.md).** You use this at your own risk.

## What it ships

The CABs contain Lenovo's BIOS image **unchanged**: the `.ROM` extracted
from Lenovo's own Windows `.exe`, byte-for-byte, with its Lenovo signature.
The UEFI firmware verifies that signature itself when it applies the
update. This project only adds fwupd metadata and signs the metadata and
the CABs with its own community key.

fwupd only offers a CAB to a machine whose ESRT firmware GUID **and**
full hardware ID (manufacturer, family, product, SKU, baseboard) match the
model, so a CAB is never offered to the wrong laptop.

## Supported models

| Model | Machine type | BIOS | Status |
|---|---|---|---|
| LOQ 15AHP10 | 83JG | R8CN26WW | Same-version reinstall **through this remote** succeeded on one unit (2026-11-25, fwupd 2.1.10); Fn+R recovery confirmed |
| LOQ 15AHP9 | 83DX | NZCN42WW | This payload upgrade-tested (NZCN28WW → NZCN42WW) on one unit via fwupd by [Firi0n](https://github.com/Firi0n); install through this remote not yet tested |

Check your machine type with `cat /sys/class/dmi/id/product_name`.
Updating resets BIOS settings to defaults (Secure Boot may be re-enabled);
write down anything you changed.

## See also

- [Firi0n/loq-15ahp9-linux](https://github.com/Firi0n/loq-15ahp9-linux):
  Linux notes for the LOQ 15AHP9, including NVIDIA dGPU D3cold and a
  speaker EQ for EasyEffects.

## Install

Requires fwupd 1.9.1 or newer, UEFI boot and the charger connected during
updates.

```sh
git clone https://github.com/c8dhjp4tyv-bit/loq-fwupd-remote
cd loq-fwupd-remote
sudo ./install.sh
fwupdmgr get-updates
fwupdmgr update
```

`install.sh` checks the root CA fingerprint, installs it as a trust anchor
for fwupd, adds the remote and refreshes. Before running it, compare the
fingerprint below with the one pinned in the Discord, so a tampered copy of
this repository cannot slip in a different CA:

```
10:C7:CF:91:34:03:F6:95:2D:B6:E0:5F:AB:37:8A:3C:CC:3F:AE:4A:5F:B5:FD:98:BA:A6:33:FB:3D:C0:BC:44
```

The remote does not change fwupd's `OnlyTrusted` setting. Anything not
signed by this CA (or LVFS) is still rejected.

## Uninstall

```sh
sudo ./uninstall.sh
```

## Reporting results

Please report every update, successful or not, with the model, machine
type, old and new BIOS version and `fwupdmgr get-history` (remove serial
numbers and UUIDs first). Reports are how the status column moves forward.

Discord: https://discord.gg/UCWS3Drfv

## Takedown

If Lenovo asks for the firmware to be removed, the release assets will be
taken down. The scripts and metadata tooling remain.

## License

Scripts and documentation: MIT ([LICENSE](LICENSE)). The firmware images
are Lenovo's and are not covered by this license.

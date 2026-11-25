# Crisis recovery (Fn+R) for Lenovo LOQ

Keep a recovery USB ready **before** any firmware test. Crisis recovery
reflashes the BIOS from USB through the embedded controller, so it works
even when the BIOS no longer boots.

**Unofficial, use at your own risk.** Only the models marked *confirmed*
below have actually been recovered this way.

## Recovery file per model

The file is the `.ROM` extracted unchanged from Lenovo's BIOS `.exe`,
renamed to `<machine type>.bin`. Do **not** use a raw SPI dump or a file
from another model.

| Model | Machine type | File on USB | ROM in Lenovo exe | Status |
|---|---|---|---|---|
| LOQ 15AHP10 | 83JG | `83JG.bin` | `KLG2xxxx.ROM` (e.g. `r8cn26ww.exe` → `KLG20026.ROM`) | confirmed (one unit) |
| LOQ 15AHP9 | 83DX | `83DX.bin` | `JLG5xxxx.ROM` (e.g. `nzcn42ww.exe` → `JLG50042.ROM`) | **not tested** |

The ROM is the signed PE image, about 34 MB (starts with `MZ`), not a raw
32 MB dump. Check its SHA-256 before copying it:

| ROM | SHA-256 |
|---|---|
| `KLG20026.ROM` (R8CN26WW) | `5eafb981b6ea5802717f4c7bf0e4c858a4d0effeaff39fa1a3dc3c758b4aed5e` |
| `JLG50042.ROM` (NZCN42WW) | `57bb5042c6f083f64b4b57a4aa91e097e86011a1d0231b15eb7254581c0d7e40` |

Your machine type is the `ProductName` field:

```sh
cat /sys/class/dmi/id/product_name
```

## 1. Extract the ROM (Linux)

```sh
mkdir rom && 7z x -orom r8cn26ww.exe
ls -l rom/*.ROM
sha256sum rom/*.ROM
```

## 2. Prepare the USB drive

This erases the USB drive. Identify it carefully first: `lsblk` before
and after plugging it in, and check the size and model.

```sh
lsblk -o NAME,SIZE,MODEL,TRAN
# replace sdX with the USB drive, NOT your system disk
sudo wipefs -a /dev/sdX
sudo parted -s /dev/sdX mklabel gpt mkpart primary fat32 1MiB 100%
sudo mkfs.vfat -F 32 /dev/sdX1
sudo mount /dev/sdX1 /mnt
sudo cp rom/KLG20026.ROM /mnt/83JG.bin
sync && sudo umount /mnt
```

Only the `.bin` file needs to be in the root directory.

## 3. Recover the laptop

1. Turn the laptop completely off and **unplug the charger**.
2. Hold the power button for 30 seconds, then release it.
3. Plug in the recovery USB.
4. Hold **Fn + R** for about 5 seconds.
5. While still holding Fn + R, press the power button.
6. Keep holding Fn + R for about 30 seconds, then release.
7. There is no prompt or confirmation: the laptop just beeps
   continuously, then restarts to the Lenovo logo showing that it is
   flashing. **Do not interrupt it or remove the USB**; this can take
   several minutes.
8. When it finishes, the laptop should boot. BIOS settings are back to
   defaults (Secure Boot may be re-enabled).

## Reporting

If you try this on a model not marked confirmed, report the model,
machine type, BIOS version of the file and the result, so the table can
be updated.

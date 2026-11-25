#!/bin/sh
set -eu

EXPECTED_FP="10:C7:CF:91:34:03:F6:95:2D:B6:E0:5F:AB:37:8A:3C:CC:3F:AE:4A:5F:B5:FD:98:BA:A6:33:FB:3D:C0:BC:44"

if [ "$(id -u)" -ne 0 ]; then
    echo "run as root: sudo ./install.sh" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CA="$SCRIPT_DIR/loq-community-root-ca.pem"
CONF="$SCRIPT_DIR/loq-community.conf"

for cmd in fwupdmgr openssl; do
    command -v "$cmd" >/dev/null || { echo "missing: $cmd" >&2; exit 1; }
done

fp=$(openssl x509 -in "$CA" -noout -fingerprint -sha256 | sed 's/^.*=//')
if [ "$fp" != "$EXPECTED_FP" ]; then
    echo "root CA fingerprint mismatch: $fp" >&2
    exit 1
fi

product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo unknown)
case "$product" in
    83JG|83DX) ;;
    *)
        echo "warning: machine type $product is not a supported model;" >&2
        echo "the remote will install but offer nothing for this machine." >&2
        ;;
esac

install -d -o root -g root -m 0755 /etc/pki/fwupd /etc/pki/fwupd-metadata /etc/fwupd/remotes.d
install -o root -g root -m 0644 "$CA" /etc/pki/fwupd/loq-community-root-ca.pem
install -o root -g root -m 0644 "$CA" /etc/pki/fwupd-metadata/loq-community-root-ca.pem
install -o root -g root -m 0644 "$CONF" /etc/fwupd/remotes.d/loq-community.conf

# fwupd reads trust anchors and remotes at startup.
if command -v systemctl >/dev/null && systemctl is-active --quiet fwupd; then
    systemctl restart fwupd
fi

fwupdmgr refresh --force
fwupdmgr get-remotes | grep -A3 -i 'LOQ Community' || true
echo "installed; run: fwupdmgr get-updates"

#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "run as root: sudo ./uninstall.sh" >&2
    exit 1
fi

rm -f /etc/fwupd/remotes.d/loq-community.conf
rm -f /etc/pki/fwupd/loq-community-root-ca.pem
rm -f /etc/pki/fwupd-metadata/loq-community-root-ca.pem

if command -v systemctl >/dev/null && systemctl is-active --quiet fwupd; then
    systemctl restart fwupd
fi
fwupdmgr refresh --force >/dev/null 2>&1 || true
echo "loq-community remote removed"

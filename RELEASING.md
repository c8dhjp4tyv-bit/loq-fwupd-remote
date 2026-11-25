# Releasing

The remote always points at `releases/latest/download/`, so **every release
must contain all CABs**, not only the new one. CABs never go into Git.

Build and sign in the private workspace (signing key stays there):

```sh
TAG=2026.11.25
cd "<workspace>/fwupd/community-remote"
# build CABs from model profiles, then sign all of them together with
#   --base-uri https://github.com/c8dhjp4tyv-bit/loq-fwupd-remote/releases/download/$TAG/
# (fwupd needs absolute CAB URLs; pin them to the release tag)
./verify_local_remote.sh
```

Publish the signed output as a new release (same TAG as above):

```sh
cd "<workspace>/fwupd/community-remote"
gh release create "$TAG" --repo c8dhjp4tyv-bit/loq-fwupd-remote \
  --title "$TAG" --notes "Models and BIOS versions in this release: ..." \
  firmware.xml.gz firmware.xml.gz.jcat SHA256SUMS *.cab
```

Then on a supported machine with the remote installed:

```sh
fwupdmgr refresh --force
fwupdmgr get-updates
```

When adding a model, update the table in README.md and the machine-type
check in install.sh.

## Takedown

Delete the affected release assets (or the release). The remote then fails
to refresh instead of offering anything.

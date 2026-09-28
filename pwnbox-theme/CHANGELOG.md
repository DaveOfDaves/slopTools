# Changelog

All notable changes to `pwnbox-theme` are listed here, newest first.

## 2026-09-28

### Changed
- The prompt now shows the primary network adapter's IP when the VPN is not connected.
  The primary adapter is the one that carries the default route (for example `ens33` or `eth0`).
  When `tun0` is up, the VPN IP is still shown instead. If there is no network, the IP is left out.

### Added
- First release of `pwnbox-theme.sh`, which makes a Parrot OS (MATE) install look like the HackTheBox Pwnbox:
  - HackTheBox GTK theme, icons, window borders, Breeze cursor and wallpaper.
    Installs `parrot-core-htb` and `hackthebox-icon-theme` if they are missing.
  - A `Pwnbox` mate-terminal profile using the HTB colour palette, set as the default.
  - The Pwnbox two-line bash prompt, showing the `tun0` VPN IP.
  - A backup of current settings on every run, and `--restore` to undo.

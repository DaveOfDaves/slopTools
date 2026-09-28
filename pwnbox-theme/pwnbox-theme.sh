#!/usr/bin/env bash
# pwnbox-theme.sh - make a Parrot OS (MATE) install look like the HackTheBox Pwnbox.
#
# Usage:
#   ./pwnbox-theme.sh            apply the theme (backs up current settings first)
#   ./pwnbox-theme.sh --restore  restore the most recent backup
#
# Safe to re-run: the prompt block in ~/.bashrc is replaced, not duplicated.

set -euo pipefail

BACKUP_ROOT="$HOME/.pwnbox-backup"
MARK_START="# --- Pwnbox-style prompt (pwnbox-theme.sh) ---"
MARK_END="# --- end Pwnbox prompt ---"

info() { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[-]\033[0m %s\n' "$*" >&2; exit 1; }

restore() {
    local latest
    latest=$(ls -1d "$BACKUP_ROOT"/*/ 2>/dev/null | sort | tail -n1) || true
    [ -n "$latest" ] || die "No backups found in $BACKUP_ROOT"
    info "Restoring from $latest"
    dconf load /org/mate/ < "$latest/mate-dconf.ini"
    cp "$latest/bashrc" "$HOME/.bashrc"
    info "Done. Open a new terminal (or log out/in) to see the change."
    exit 0
}

[ "${1:-}" = "--restore" ] && restore
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { sed -n '2,8p' "$0"; exit 0; }

# --- Pre-flight -----------------------------------------------------------
command -v gsettings >/dev/null || die "gsettings not found"
command -v dconf >/dev/null     || die "dconf not found"
[ "${XDG_CURRENT_DESKTOP:-}" = "MATE" ] || warn "Desktop is '${XDG_CURRENT_DESKTOP:-unknown}', not MATE - settings may not apply"

# Parrot's HTB edition packages provide the GTK theme, icons and wallpaper.
if [ ! -d /usr/share/themes/htb-gtk-theme ] || [ ! -d /usr/share/icons/hackthebox ]; then
    warn "HTB themes not installed."
    if command -v apt-get >/dev/null; then
        info "Installing parrot-core-htb and hackthebox-icon-theme (needs sudo)"
        sudo apt-get update && sudo apt-get install -y parrot-core-htb hackthebox-icon-theme \
            || warn "Install failed - continuing with what's available"
    fi
fi

# --- Backup ---------------------------------------------------------------
BACKUP="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
dconf dump /org/mate/ > "$BACKUP/mate-dconf.ini"
cp "$HOME/.bashrc" "$BACKUP/bashrc" 2>/dev/null || touch "$BACKUP/bashrc"
info "Backed up current settings to $BACKUP"

# --- Desktop --------------------------------------------------------------
set_if() {  # set_if <schema> <key> <value> [path that must exist]
    if [ -n "${4:-}" ] && [ ! -e "$4" ]; then
        warn "Skipping $1 $2 ($4 missing)"; return
    fi
    gsettings set "$1" "$2" "$3"
}

info "Applying desktop theme"
set_if org.mate.interface gtk-theme 'HackTheBox' /usr/share/themes/HackTheBox
set_if org.mate.interface icon-theme 'hackthebox' /usr/share/icons/hackthebox
set_if org.mate.Marco.general theme 'htb-gtk-theme' /usr/share/themes/htb-gtk-theme/metacity-1
set_if org.mate.peripherals-mouse cursor-theme 'breeze_cursors' /usr/share/icons/breeze_cursors
set_if org.mate.background picture-filename '/usr/share/backgrounds/hackthebox.jpg' /usr/share/backgrounds/hackthebox.jpg
gsettings set org.mate.background picture-options 'zoom'

# --- Terminal profile -----------------------------------------------------
info "Creating 'Pwnbox' mate-terminal profile"
dconf load /org/mate/terminal/ <<'EOF'
[profiles/pwnbox]
visible-name='Pwnbox'
title='Pwnbox'
use-theme-colors=false
use-system-font=false
font='Monospace 12'
background-type='solid'
background-color='#1A2332'
foreground-color='#A4B1CD'
bold-color='#FFFFFF'
bold-color-same-as-fg=false
allow-bold=true
cursor-shape='block'
palette='#000000:#FF3E3E:#9FEF00:#FFAF00:#004CFF:#9F00FF:#2EE7B6:#FFFFFF:#666666:#FF8484:#C5F467:#FFCC5C:#5CB2FF:#C16CFA:#5CECC6:#FFFFFF'
scrollback-unlimited=true
scrollbar-position='hidden'
EOF

profiles=$(gsettings get org.mate.terminal.global profile-list)
if ! grep -q "'pwnbox'" <<<"$profiles"; then
    profiles=$(sed "s/]$/, 'pwnbox']/; s/\[, /[/" <<<"$profiles")
    gsettings set org.mate.terminal.global profile-list "$profiles"
fi
gsettings set org.mate.terminal.global default-profile 'pwnbox'

# --- Bash prompt ----------------------------------------------------------
info "Installing Pwnbox prompt in ~/.bashrc"
touch "$HOME/.bashrc"
sed -i "/^$MARK_START\$/,/^$MARK_END\$/d" "$HOME/.bashrc"
cat >> "$HOME/.bashrc" <<EOF
$MARK_START
__pwnbox_vpn() {
    local ip
    ip=\$(ip -4 -o addr show tun0 2>/dev/null | awk '{print \$4}' | cut -d/ -f1)
    [ -n "\$ip" ] && printf '[\001\033[1;34m\002%s\001\033[1;32m\002]─' "\$ip"
}
PS1='\[\033[1;32m\]┌─\$(__pwnbox_vpn)[\[\033[1;37m\]\u\[\033[1;32m\]@\[\033[1;34m\]\h\[\033[1;32m\]]─[\[\033[1;37m\]\w\[\033[1;32m\]]\n\[\033[1;32m\]└──╼ [\[\033[1;33m\]★\[\033[1;32m\]]\\\$ \[\033[0m\]'
$MARK_END
EOF

info "Done. Open a new terminal; log out/in for cursor and window borders."
info "Undo with: $0 --restore"

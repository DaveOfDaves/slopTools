# pwnbox-theme

Makes a Parrot OS (MATE) install look like the HackTheBox Pwnbox.

```bash
./pwnbox-theme.sh            # apply
./pwnbox-theme.sh --restore  # undo (restores the latest backup)
```

What it does:

- **Desktop:** HackTheBox GTK theme, `hackthebox` icons, HTB window borders, Breeze cursor, HTB wallpaper.
  If the themes are missing it installs `parrot-core-htb` and `hackthebox-icon-theme` using apt.
- **Terminal:** adds a `Pwnbox` mate-terminal profile (navy `#1A2332` background, `#A4B1CD` text, HTB colour palette) and makes it the default.
- **Prompt:** adds the Pwnbox two-line prompt to `~/.bashrc`, showing your `tun0` VPN IP when connected, or your primary adapter's IP otherwise:
  ```
  ┌─[10.10.14.2]─[user@host]─[~]
  └──╼ [★]$
  ```

Each run backs up `/org/mate/` dconf settings and `~/.bashrc` to `~/.pwnbox-backup/<timestamp>/`.
You can run it more than once: the prompt block is replaced, not duplicated.
Open a new terminal to see the change; log out and back in for the cursor and window borders.

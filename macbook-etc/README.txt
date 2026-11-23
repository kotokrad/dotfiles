Standalone home-manager for the macbook (Fedora Asahi Remix):
  nix run home-manager -- switch --flake ~/nixos-config#macbook

Fedora setup, outside home-manager

Packages (dnf install)
  nix nix-daemon                    # nix package manager
  gcc make                          # treesitter parsers, blink.cmp, rust/cgo linking
  android-tools                     # adb's udev rules
  gnome-disk-utility                # needs Fedora's udisks + polkit
  brightnessctl pipewire-utils      # quickshell brightness OSD, audio profiles
  bluez tuned-ppd                   # quickshell Bluetooth and Power tiles
  blueman                           # pairing agent, Bluetooth list's More…
  avd-fw                            # video decoder firmware
  thunar gvfs tumbler               # a Nix Thunar can't load Fedora's gvfs (trash, MTP)
  thunar-archive-plugin file-roller # Thunar's Extract here / Create archive
  gnome-keyring gnome-keyring-pam   # login.keyring unlocked at login through PAM
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk fish

Packages from their own repos
  mullvad-vpn tailscale

Built from source
  keyd (fn+hjkl arrows): not in Fedora, and SELinux won't let systemd run it from /nix/store
    git clone -b v2.6.0 https://github.com/rvaiya/keyd && cd keyd
    make && sudo make install       # /usr/local
    sudo systemctl enable --now keyd

Commands
  sudo systemctl enable --now nix-daemon
  sudo systemctl enable --now bluetooth
  gsettings set org.blueman.general plugin-list "['!ConnectionNotifier']" # disable bluetooth notifications
  sudo systemctl enable --now polkit-agent-helper.socket  # quickshell's Nix polkit can't find the setuid helper
  chsh -s /usr/bin/fish
  sudo usermod -aG dialout $USER    # serial ports: tio, arduino-cli
  sudo grubby --update-kernel=ALL --args=appledrm.show_notch=1  # screen around the notch
  xdg-mime default librewolf-private.desktop x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml
  sudo tailscale set --netfilter-mode=off  # Mullvad + Tailscale, as in vpn.nix
  sudo systemctl enable --now mullvad-tailscale

Files:
  sudo cp -r ~/nixos-config/macbook-etc/. /
  sudo chmod 0440 /etc/sudoers.d/nix-profile # sudo also finds ~/.nix-profile binaries (last in secure_path),
                                             # and sudo'd GUI apps keep WAYLAND_DISPLAY
  sudo dracut -f                             # hid_apple.conf: swap ctrl/fn, proper F-keys
  sudo systemctl kill -s HUP systemd-logind  # power-key.conf
  sudo keyd reload                           # keyd/default.conf
  sudo systemctl daemon-reload               # mullvad-tailscale.service: vpn.nix's nft table and
                                             # tailscale-direct rules (nftables.service conflicts with firewalld)

Edits to Fedora's own files
  /etc/tuned/ppd.conf, [profiles]   # then sudo systemctl restart tuned tuned-ppd
    power-saver=battery-saver
  /etc/firewalld/firewalld.conf     # then sudo systemctl restart firewalld
    IPv6_rpfilter=loose

After the first switch
  run the sudo GPU setup command it prints
  copy ~/.config/gammastep/config.ini and the wallpaper (~/pictures/wallpapers)

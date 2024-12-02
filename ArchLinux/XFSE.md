```bash
sudo pacman -S xfce4 xfce4-goodies
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
# sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol --noconfirm
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack --noconfirm
systemctl --user enable --now pipewire pipewire-pulse
sudo pacman -S ntfs-3g exfat-utils --noconfirm
sudo pacman -S gparted gvfs --noconfirm
sudo pacman -S xfce4-mount-plugin
sudo pacman -S gvfs-smb
sudo pacman -S gvfs-mtp





# Лишнее(ставиться автоматом)
sudo pacman -S xfce4-appfinder --noconfirm
sudo pacman -S xfce4-pulseaudio-plugin --noconfirm
sudo pacman -S xfce4-battery-plugin --noconfirm
sudo pacman -S xfce4-screenshooter --noconfirm
sudo pacman -S xfce4-notifyd --noconfirm
sudo pacman -S orage --noconfirm
```
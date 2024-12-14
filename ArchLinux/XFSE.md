```bash
sudo pacman -S xfce4 xfce4-goodies --noconfirm
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
sudo pacman -S lightdm-gtk-greeter-settings --noconfirm
sudo pacman -S lightdm-webkit2-greeter --noconfirm
sudo yaourt -S mugshot --noconfirm
sudo pacman -S ark --noconfirm
sudo pacman -S networkmanager --noconfirm
sudo pacman -S networkmanager-openvpn --noconfirm
sudo pacman -S openvpn --noconfirm
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
#cisco-secure-client
sudo systemctl enable lightdm



# sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol --noconfirm
sudo pacman -S ntfs-3g exfat-utils --noconfirm
sudo pacman -S gparted gvfs --noconfirm
sudo pacman -S xfce4-mount-plugin --noconfirm
sudo pacman -S gvfs-smb --noconfirm
sudo pacman -S gvfs-mtp --noconfirm
sudo pacman -S tilix --noconfirm




# Лишнее(входи в xfce4-goodies)
sudo pacman -S xfce4-appfinder --noconfirm
sudo pacman -S xfce4-pulseaudio-plugin --noconfirm
sudo pacman -S xfce4-battery-plugin --noconfirm
sudo pacman -S xfce4-screenshooter --noconfirm
sudo pacman -S xfce4-notifyd --noconfirm
sudo pacman -S orage --noconfirm
```
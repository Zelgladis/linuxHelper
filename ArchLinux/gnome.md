### GNOME
### Установка Графической оболчки(Gnome) и менеджера(gdm)
```bash
sudo pacman -S gnome gnome-extra --noconfirm
sudo pacman -S gdm --noconfirm
sudo pacman -S networkmanager --noconfirm
yaourt -S extension-manager --noconfirm
yaourt -S gnome-extensions-cli --noconfirm
systemctl enable gdm.service
systemctl enable NetworkManager.service


```

###### wayland
```bash
sudo pacman -Qi wayland --noconfirm
sudo pacman -S --needed wayland --noconfirm
sudo pacman -S --needed xorg-xwayland xorg-xlsclients glfw-wayland --noconfirm
sudo pacman -S --needed gnome gnome-tweaks nautilus-sendto gnome-nettool gnome-usage gnome-multi-writer adwaita-icon-theme xdg-user-dirs-gtk fwupd arc-gtk-theme --noconfirm
```

### Gnome ПО
```bash
# Вернём привычные -▢X
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
```


### Gnome visual
###### Шрифты
Установить в терминале шрифт Dejavu-sans-mono 14
###### Расширения Gnome
- Dash to Panel
- ArchMenu
- Tray icons: Reloaded
- AppIndicator and KStatusNotifierItem Support
- Gtk4 Desktop Icons NG (DING)
- Add to desktop

### Удаляем игры
```bash
yaourt -R gnome-sudoku --noconfirm
yaourt -R gnome-mines --noconfirm
yaourt -R five-or-more --noconfirm
yaourt -R gnome-robots --noconfirm
yaourt -R gnome-mahjongg --noconfirm
yaourt -R gnome-2048 --noconfirm
yaourt -R gnome-tetravex --noconfirm
yaourt -R hitori --noconfirm
yaourt -R gnome-nibbles --noconfirm
yaourt -R gnome-taquin --noconfirm
yaourt -R gnome-klotski --noconfirm
yaourt -R gnome-chess --noconfirm
yaourt -R four-in-a-row --noconfirm
yaourt -R iagno --noconfirm
yaourt -R swell-foop --noconfirm
yaourt -R tali --noconfirm
yaourt -R quadrapassel --noconfirm
```

```bash

sudo pacman -S cinnamon
sudo pacman -S lightdm lightdm-gtk-greeter
sudo pacman -S tilix --noconfirm
sudo pacman -S ark --noconfirm
sudo pacman -S eog --noconfirm
sudo pacman -S networkmanager --noconfirm
sudo pacman -S networkmanager-openvpn --noconfirm
sudo pacman -S openvpn --noconfirm
sudo pacman -S gtk-engine-murrine --noconfirm
sudo pacman -S materia-gtk-theme

sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl enable lightdm

sudo pacman -S font-manager --noconfirm
sudo pacman -S conky --noconfirm
sudo pacman -S playerctl --noconfirm
sudo pacman -S strawberry --noconfirm
sudo pacman -S gnome-terminal --noconfirm
```

##### Cursor
Sturn

##### icons
relax-icons-dark
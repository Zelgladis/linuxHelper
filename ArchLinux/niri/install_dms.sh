sudo pacman -Syu
sudo pacman -S niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk alacritty dms-shell-niri matugen cava qt6-multimedia-ffmpeg dms mako waybar swaybg swayidle fuzzel
systemctl --user add-wants niri.service
systemctl --user add-wants niri.service mako.service
systemctl --user add-wants niri.service waybar.service

# Графическое окружение и Wayland
sudo pacman -S --needed hyprland wayland wayland-protocols xdg-desktop-portal-hyprland \
    waybar polkit-gnome hyprpaper hyprlock hypridle hyprpolkitagent \
    mesa vulkan-icd-loader

# Приложения
sudo pacman -S --needed alacritty nautilus rofi-wayland firefox swaync

# Дисплейный менеджер
sudo pacman -S --needed sddm sddm-kcm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
sudo systemctl enable sddm

# Шрифты
sudo pacman -S --needed ttf-firacode-nerd noto-fonts noto-fonts-emoji ttf-dejavu \
    ttf-nerd-fonts-symbols-mono ttf-ibm-plex

# Утилиты
sudo pacman -S --needed grim slurp wl-clipboard cliphist brightnessctl playerctl \
    udiskie udisks2 file-roller git curl wget dbus

# Темы и оформление
sudo pacman -S --needed papirus-icon-theme lxappearance kvantum nwg-look

# ⚠️ Звук: выберите ОДИН вариант!
## Вариант А: PipeWire (рекомендуется для современных систем)
sudo pacman -S --needed pipewire pipewire-pulse pipewire-alsa wireplumber gst-plugin-pipewire
systemctl --user enable --now pipewire pipewire-pulse wireplumber
## Вариант Б: PulseAudio (если PipeWire вызывает проблемы)
# sudo pacman -S --needed pulseaudio pulseaudio-alsa pavucontrol



# 1. Клонируем репозиторий во временную директорию
cd ~
git clone https://github.com/knMaqHe/Dots-Arch-Linux-Hyprland.git temp-dots

# 2. Копируем конфиги приложений в ~/.config/
#    (используем cp -r с явными путями, а не "скопируйте папки")
cp -r temp-dots/hypr/* ~/.config/hypr/
cp -r temp-dots/waybar/* ~/.config/waybar/
cp -r temp-dots/rofi/* ~/.config/rofi/
cp -r temp-dots/alacritty/* ~/.config/alacritty/
cp -r temp-dots/swaync/* ~/.config/swaync/

# 3. Копируем обои и изображения
mkdir -p ~/Images/Wallpaper
cp -r temp-dots/Images/* ~/Images/

# 4. Устанавливаем тему SDDM
sudo mkdir -p /usr/share/sddm/themes/
sudo cp -r temp-dots/sddm-astronaut-theme /usr/share/sddm/themes/

# 5. Настраиваем SDDM
sudo mkdir -p /etc/sddm.conf.d/
echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
echo -e "[General]\nInputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf

# 6. Удаляем временную папку
rm -rf ~/temp-dots


# Устанавливаем базовые инструменты для сборки
sudo pacman -S --needed git base-devel

# Клонируем Paru из AUR
cd ~
git clone https://aur.archlinux.org/paru.git
cd paru

# Собираем и устанавливаем (зависимости подтянутся автоматически)
makepkg -si

# Возвращаемся в домашнюю директорию и удаляем исходники
cd ~ && rm -rf paru


# Устанавливаем курсор из AUR
paru -S bibata-cursor-theme

# Добавляем настройки в конфиги Hyprland
mkdir -p ~/.config/hypr/source/
echo "exec-once = hyprctl setcursor Bibata-Modern-Ice 24" >> ~/.config/hypr/source/autostart.conf
echo -e "env = XCURSOR_THEME,Bibata-Modern-Ice\nenv = XCURSOR_SIZE,24" >> ~/.config/hypr/source/environment.conf


### Финальный проверека

# ✓ PipeWire активен?
pactl info | grep -q "PulseAudio (on PipeWire)" && echo "✅ PipeWire OK" || echo "❌ PipeWire error"

# ✓ Paru работает?
paru --version && echo "✅ Paru OK"

# ✓ Конфиги на месте?
[[ -f ~/.config/hypr/hyprland.conf ]] && echo "✅ Hyprland config OK" || echo "❌ Config missing"

# ✓ Шрифты загружены?
fc-list | grep -qi "fira code" && echo "✅ Fonts OK" || echo "❌ Fonts missing"

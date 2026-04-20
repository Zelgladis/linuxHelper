# install dash-to-dock
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>Alt_L']"
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
# gsettings list-recursively org.gnome.shell | grep favorite
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Nautilus.desktop', 'org.manjaro.pamac.manager.desktop', 'org.gnome.Console.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Calculator.desktop']"
gnome-extensions enable system-monitor@gnome-shell-extensions.gcampax.github.com
#gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
#gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.9
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable status-icons@gnome-shell-extensions.gcampax.github.com


# Включение официального репозитория Starship
sudo dnf copr enable atim/starship
# Установка Starship
sudo dnf install starship
# 1. Скачиваем шрифт
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
# 2. Создаем папку для шрифтов (если её нет)
mkdir -p ~/.local/share/fonts
# 3. Распаковываем архивы
unzip JetBrainsMono.zip -d ~/.local/share/fonts/
# 4. Обновляем кэш шрифтов
fc-cache -fv
# 5. Чистим за собой (удаляем zip-архив)
rm JetBrainsMono.zip
# 6. Устанавливаем шрифт
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 12'


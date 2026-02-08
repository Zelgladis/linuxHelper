#!/bin/bash
# Красота в консоле
# echo 'PS1="\[\e[91m\]\$(if [[ \$? -eq 0 ]]; then echo '✔️'; else echo '❌'; fi) \[\e[92m\]\u@\h\[\e[0m\] \[\e[94m\]🌸 \[\e[33m\]\w\[\e[0m\]\[\e[95m\]\$(git branch 2>/dev/null | grep '^*' | colrm 1 2 | awk '{printf \" (%s)\", \$1}') \[\e[0m\]💫 $ "' >> ~/.bashrc

set -e

visual_list=(
    "Cinnamon"
    "KDE"
    "XFCE"
    "GNOME"
    "Выход"
)
po_list=(
   "flatpak|Менедже sпакетов флатпак|OFF|base_po"
   "keepassxc|NOT|OFF|base_po"
   "dbeaver|NOT|OFF|prog_po"
   "docker|NOT|OFF|prog_po"
   "docker-compose|NOT|OFF|prog_po"
   "intellij-idea-community-edition|NOT|OFF|prog_po"
   "telegram-desktop|NOT|OFF|base_po"
   "kate|NOT|OFF|base_po"
   "cmake|NOT|OFF|system_po"
   "corectrl|NOT|OFF|system_po"
   "pavucontrol|NOT|OFF|system_po"
   "meld|NOT|OFF|base_po"
   "kdf|NOT|OFF|base_po"
   "htop|NOT|OFF|system_po"
   "psensor|NOT|OFF|system_po"
   "lm_sensors|NOT|OFF|system_po"
   "xsensors|NOT|OFF|system_po"
   "yakuake|NOT|OFF|base_po"
   "blueman|NOT|OFF|system_po"
   "partitionmanager|NOT|OFF|system_po"
   "flatseal|NOT|OFF|base_po"
   "filelight|NOT|OFF|base_po"
   "kcalc|NOT|OFF|base_po"
   "openrgb|NOT|OFF|system_po"
   "dolphin|NOT|OFF|base_po"
   "koko|NOT|OFF|base_po"
   "lutris|NOT|OFF|gamig_po"
   "inkscape|NOT|OFF|visual_po"
   "blender|NOT|OFF|visual_po"
   "firefox|NOT|OFF|base_po"
   "elisa|NOT|OFF|base_po"
   "obs-studio|NOT|OFF|gamig_po"
   "rhythmbox|NOT|OFF|base_po"
   "krecorder|NOT|OFF|base_po"
   "vlc|NOT|OFFbase_po"
   "virtualbox|NOT|OFF|prog_po"
   "ark|NOT|OFF|base_po"
   "kleopatra|NOT|OFF|system_po"
   "protontricks|NOT|OFF|gamig_po"
   "wine|NOT|OFF|gamig_po"
   "krita|NOT|OFF|visual_po"
)

yesno=('Yes' 'No')

po_main_list=(
    "all"
    "nothing"
    "choice"
    "choice_min"
)
po_min_list=(
    "base_po|Базовое по текстовый редактор и тд.|OFF"
    "system_po|Установка не которых системных по htop и тд.|OFF"
    "gamig_po|Игровое по lutris и тд.|OFF"
    "visual_po|Визуальные редакторы blender kirita|OFF"
    "prog_po|Всякие докеры и тд.|OFF"
)

po_install_final=()

win_size=(20 90 10)

visual_opt=()
for((i=0; i<${#visual_list[@]}; i++)); do
    visual_opt+=("$((i+1))" "${visual_list[$i]}")
done

po_opt=()
for((i=0; i<${#po_list[@]}; i++)); do
    IFS="|" read -r a b c <<< "${po_list[$i]}"
    po_opt+=("$a" "$b" "$c")
done

po_main_opt=()
for((i=0; i<${#po_main_list[@]}; i++)); do
    po_main_opt+=("$((i+1))" "${po_main_list[$i]}")
done
po_min_opt=()
for((i=0;i<${#po_min_list[@]}; i++)); do
    IFS="|" read -r a b c <<< "${po_min_list[$i]}"
    po_min_opt+=("$a" "$b" "$c")
done

visual=$(whiptail --title "Выбор опции" \
    --menu "Интерфейс системы - GNOME XFCE KDE CIN(cinnamon)" \
    "${win_size[@]}" \
    "${visual_opt[@]}" \
    3>&1 1>&2 2>&3)
exit_status=$?

vb=$(whiptail --title "Установить VBox" --menu "VirtualBoxGuestAdditions" "${win_size[@]}" \
    1 "Yes" \
    2 "No" 3>&1 1>&2 2>&3)
exit_status=$?

po_main=$(whiptail --title "Доплнительное по" --menu "Выбор дополнительного по" "${win_size[@]}" \
    "${po_main_opt[@]}" 3>&1 1>&2 2>&3)
exit_status=$?

if [[ "${po_main_list[$po_main-1]}" == "choice_min" ]]; then
    po_install_str=$(whiptail --title "Настройки" \
        --checklist "Выберите параметры:" "${win_size[@]}" \
        --separate-output \
        "${po_min_opt[@]}" 3>&1 1>&2 2>&3)
    exit_status=$?
elif [[ ${po_main_list[$po_main-1]} == "choice" ]]; then
    po_install_str=$(whiptail --title "Настройки" \
        --checklist "Выберите параметры:" "${win_size[@]}" \
        --separate-output \
        "${po_opt[@]}" \
        3>&1 1>&2 2>&3)
    exit_status=$?
fi

if [[ "${po_main_list[$po_main-1]}" == "choice" ]]; then
    IFS=$'\n' read -r -d '' -a po_install <<< "$po_install_str"
elif [[ "${po_main_list[$po_main-1]}" == "all" ]]; then
    po_install=""
    for ((i=0; i<${#po_list[@]};i++)); do
        IFS="|" read -r a b c <<< "${po_list[$i]}"
        po_install+="$a "
    done
    po_install="${po_install% }"
elif [[ "${po_main_list[$po_main-1]}" == "choice_min" ]]; then
    po_install=""
    po_min_tmp=()
    IFS=$'\n' read -r -d '' -a po_min_check <<< "${po_install_str}"
    for ((i=0; i<${#po_list[@]};i++)); do
        IFS="|" read -r a b c d <<< "${po_list[$i]}"
        if [[ " ${po_min_check[@]} " =~ " $d " ]]; then
            po_install+="$a "
        fi
    done
    po_install="${po_install% }"
fi

echo "
System Interface: ${visual_list[$visual-1]}
VirtualBoxGuest: ${yesno[$vb-1]}
Utils ${po_main_list[$po_main-1]}:
${po_install[@]}


Продолжаем?(y/n): "
read conte


if [[ "$conte" != 'y' ]];then
    exit 0
fi

# Ещё доп по
sudo pacman -S wget \
    yajl \
    git \
    base-devel \
    linux-headers \
    dkms \
    go \
    ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family noto-fonts-emoji --noconfirm
git clone https://github.com/scopatz/nanorc.git ~/.nano
echo 'include "~/.nano/*.nanorc"' >> ~/.nanorc


# YAY aur
mkdir ~/OTB
mkdir ~/OTB/gits
cd ~/OTB/gits
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si && cd ~

if [[ "${visual_list[$visual-1]}" == 'XFCE' ]];then
    echo "XFCE"
    sudo pacman -S xfce4 xfce4-goodies --noconfirm
    sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
    sudo pacman -S lightdm-gtk-greeter-settings --noconfirm
    sudo pacman -S lightdm-webkit2-greeter --noconfirm
    sudo pacman -S ark --noconfirm
    sudo pacman -S networkmanager network-manager-applet --noconfirm

    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
    #cisco-secure-client
    sudo systemctl enable lightdm
    yay -S mugshot --noconfirm
    # sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol --noconfirm
    sudo pacman -S ntfs-3g exfat-utils --noconfirm
    sudo pacman -S gparted gvfs --noconfirm
    sudo pacman -S xfce4-mount-plugin --noconfirm
    sudo pacman -S gvfs-smb --noconfirm
    sudo pacman -S gvfs-mtp --noconfirm
elif [[ "${visual_list[$visual-1]}" == 'KDE' ]]; then
    echo "KDE"
    sudo pacman -S --needed sddm --noconfirm
    sudo pacman -S --needed plasma plasma-workspace plasma-x11-session --noconfirm
    sudo pacman -S --needed qt6 --noconfirm
    sudo pacman -S --needed networkmanager-openvpn --noconfirm
    sudo pacman -S networkmanager-openconnect --noconfirm

    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
elif [[ "${visual_list[$visual-1]}" == 'Cinnamon' ]];then
    echo "Cinnammon"
    sudo pacman -S cinnamon --noconfirm
    #sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
    sudo pacman -S sddm --noconfirm
    sudo pacman -S tilix --noconfirm
    sudo pacman -S ark --noconfirm
    sudo pacman -S eog --noconfirm
    sudo pacman -S networkmanager --noconfirm
    sudo pacman -S networkmanager-openvpn --noconfirm
    sudo pacman -S openvpn --noconfirm
    sudo pacman -S gtk-engine-murrine --noconfirm
    sudo pacman -S materia-gtk-theme --noconfirm
    sudo pacman -S xed --noconfirm
    sudo pacman -S krita --noconfirm
    sudo pacman -S gnome-terminal --noconfirm
    sudo pacman -S file-roller --noconfirm
    sudo pacman -S meld --noconfirm
    sudo pacman -S mpv --noconfirm
    sudo pacman -S cmus --noconfirm
    sudo pacman -S rhythmbox --noconfirm
    yay sddm-sugar-candy-git --noconfirm

    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
    sudo systemctl enable sddm
    sudo systemctl start sddm

    sudo pacman -S font-manager --noconfirm
    sudo pacman -S conky --noconfirm
    sudo pacman -S playerctl --noconfirm
    sudo pacman -S Rhythmbox --noconfirm
    sudo pacman -S gnome-terminal --noconfirm
    yay -S beautyline --noconfirm
    mkdir -p ~/.themes
    cd /tmp
    wget -c https://github.com/EliverLara/Sweet/releases/download/v6.0/Sweet-Dark-v40.tar.xz
    tar -xf Sweet-Dark-v40.tar.xz -C ~/.themes/
    cd ~/
    sudo echo "[Theme]" > /etc/sddm.conf
    sudo echo "Current=sugar-candy" >> /etc/sddm.conf
elif [[ "${visual_list[$visual-1]}" == 'GNOME' ]];then
    sudo pacman -S gnome-shell \
        gnome-terminal \
        gnome-tweaks \
        gnome-control-center \
        xdg-user-dirs \
        gdm \
        gnome-keyring \
        nautilus \
        eog \
        file-roller \
        gnome \
        gnome-extra \
        gnome-shell-extensions \
        packagekit \
        network-manager-applet \
        gnome-shell-extensions \
        gnome-shell-extension-desktop-icons-ng \
        firefox --noconfirm

    yay -S gnome-shell-extension-dash-to-dock pamac-aur --noconfirm
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
    gnome-extensions enable pamac-updates@manjaro.org
    gnome-extensions enable status-icons@gnome-shell-extensions.gcampax.github.com


sudo systemctl enable --now NetworkManager
sudo systemctl enable gdm
elif [[ "${visual_list[$visual-1]}" == 'MangoWC' ]]; then
    echo 'TODO make it'
elif [[ "${visual_list[$visual-1]}" == 'Hyprland' ]]; then
    # Установка (официальные репозитории!)
    sudo pacman -S hyprland

    # Дополнительные полезные компоненты
    sudo pacman -S waybar rofi wofi grim slurp mako
fi

if [[ " choice choice_min all " =~ " ${po_main_list[$po_main-1]} " ]];then
    echo "Add PO"
    sudo pacman -S ${po_install[@]} --noconfirm
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    sudo usermod -aG docker $USER || true
fi

if [[ "${yesno[$vb-1]}" == 'Yes' ]];then
    echo "VirtualBox"
    sudo pacman -S linux-headers virtualbox-guest-utils --noconfirm
    sudo systemctl enable --now vboxservice.service
    sudo modprobe -a vboxguest vboxsf vboxvideo
    echo -e "vboxguest\nvboxsf\nvboxvideo" | sudo tee /etc/modules-load.d/virtualbox.conf
fi

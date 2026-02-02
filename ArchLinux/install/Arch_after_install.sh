#!/bin/bash
# Красота в консоле
# echo 'PS1="\[\e[91m\]\$(if [[ \$? -eq 0 ]]; then echo '✔️'; else echo '❌'; fi) \[\e[92m\]\u@\h\[\e[0m\] \[\e[94m\]🌸 \[\e[33m\]\w\[\e[0m\]\[\e[95m\]\$(git branch 2>/dev/null | grep '^*' | colrm 1 2 | awk '{printf \" (%s)\", \$1}') \[\e[0m\]💫 $ "' >> ~/.bashrc

echo "Интерфейс системы - GNOME XFCE KDE CIN(cinnamon)"
read visual

echo "VirtualBoxGuest 1, No 0"
read vb

echo "Add Utils 1, No 0"
read dop
echo "
System Interface: $visual
Utils: $dop
VirtualBoxGuest: $vb

Continue?(y/n) default n"
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

if [[ "$visual" == 'XFCE' ]];then
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
    sudo pacman -S tilix --noconfirm
elif [[ "$visual" == 'KDE' ]]; then
    echo "KDE"
    sudo pacman -S --needed sddm --noconfirm
    sudo pacman -S --needed plasma plasma-workspace plasma-x11-session --noconfirm
    sudo pacman -S --needed qt6 --noconfirm
    sudo pacman -S --needed networkmanager-openvpn --noconfirm
    sudo pacman -S networkmanager-openconnect --noconfirm

    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
elif [[ "$visual" == 'CIN' ]];then
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
elif [[ "$visual" == 'GNOME' ]];then
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
        dash-to-dock \
        network-manager-applet

sudo systemctl enable --now NetworkManager
sudo systemctl enable gdm
fi





if [[ "$dop" == '1' ]];then
    echo "Add PO"
    sudo pacman -S firefox \
        flatpak \
        keepassxc \
        dbeaver \
        docker \
        docker-compose \
        intellij-idea-community-edition \
        telegram-desktop \
        kate \
        cmake \
        corectrl \
        pavucontrol \
        meld \
        kdf \
        htop \
        psensor \
        lm_sensors \
        xsensors \
        yakuake \
        blueman \
        partitionmanager \
        flatseal \
        filelight \
        kcalc \
        openrgb \
        dolphin \
        koko \
        lutris \
        telegram-desktop \
        inkscape \
        kate \
        blender \
        firefox \
        elisa \
        obs-studio \
        rhythmbox \
        krecorder \
        vlc \
        virtualbox \
        ark \
        kleopatra \
        protontricks \
        wine wine-mono vkd3d winetricks \
        krita --noconfirm
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo usermod -aG docker $USER
fi

if [[ "$vb" == '1' ]];then
    echo "VirtualBox"
    pacman -S linux-headers virtualbox-guest-utils --noconfirm
    systemctl enable --now vboxservice.service
    modprobe -a vboxguest vboxsf vboxvideo
    echo -e "vboxguest\nvboxsf\nvboxvideo" | tee /etc/modules-load.d/virtualbox.conf
fi

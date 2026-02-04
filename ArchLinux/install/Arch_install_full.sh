#!/bin/bash
set -e

if [[ "$1" == '1' ]]; then
echo "Имя пользователя"
read usern

echo "EFI 1, LEGACY 0:"
read efi

echo "auto grub 1, manual 0"
read auto_grub

echo "hostname"
read myhostname

echo "nvidia 1 radeo 2 other *"
read graph

echo "Интерфейс системы - GNOME XFCE KDE CIN(cinnamon) Hyprland MangoWC"
read visual

echo "VirtualBoxGuest 1, No 0"
read vb

echo "Add Utils 1, No 0"
read dop
fi

function echoVars(){
echo "
Username: $usern
Password: 123 смени его после установки
UEFI: $efi
Auto GRUB: $auto_grub
Hostname: $myhostname
System Interface: $visual
Utils: $dop
VirtualBoxGuest: $vb

Continue?(y/n) default n"
read conte

if [[ "$conte" != 'y' ]]; then
    exit 0
fi
}

function saveVars(){
cat << EOF > "/home/$usern/myvars.sh"
usern="$usern"
efi="$efi"
auto_grub="$auto_grub"
myhostname="$myhostname"
graph="$visual"
dop="$dop"
vb="$vb"
EOF
}
function readVars(){
source "home/$USER/myvars.sh"
}

function part1(){
echoVars
# Europe/Saratov ваш регион/город Синхронизация часов
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime 
hwclock --systohc

# Локализация
sed -i 's/#en_US.UTF\-8 UTF\-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#ru_RU.UTF\-8 UTF\-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
# Генерация локали в систему
locale-gen
echo 'LANG=ru_RU.UTF-8' >  /etc/locale.conf
echo 'KEYMAP=ru
FONT=cyr-sun16' > /etc/vconsole.conf

# Настройка сети
echo "$myhostname" > /etc/hostname
echo "127.0.0.1 localhost
::1 localhost
127.0.1.1 $myhostname.localdomain $myhostname" >> /etc/hosts

#Доп по(необходимое):
pacman -Syu --noconfirm
pacman -S vi nano reflector gcc perl make dhcpcd openssh \
    btrfs-progs e2fsprogs grub efibootmgr os-prober hwinfo --noconfirm
systemctl enable sshd
systemctl enable dhcpcd

# EFI
if [[ "$efi" == '1' ]];then
    echo "----------- EFI CHOSEN -----------"
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=ArchLinux --recheck
    mkinitcpio -p linux
# LEGACY
else
    echo "----------- LEGACY -----------"
    grub-install /dev/sda
    # Перегенерируйте initramfs
    mkinitcpio -p linux
fi

if [[ "$auto_grub" == '1' ]];then
    echo "AUTOGRUB"
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo 'source $prefix/menu.cfg' > /boot/grub/grub.cfg
    cat << EOF > /boot/grub/menu.cfg
set timeout=5
set default=0

menuentry "Arch Linux" {
    search --no-floppy --fs-uuid --set=root --label ROOT
    linux /boot/vmlinuz-linux root=LABEL=ROOT rw quiet
    initrd /boot/initramfs-linux.img
}

menuentry "Arch Linux (Fallback)" {
    search --no-floppy --fs-uuid --set=root --label ROOT
    linux /boot/vmlinuz-linux root=LABEL=ROOT rw
    initrd /boot/initramfs-linux-fallback.img
}
menuentry "Windows 11 (EFI)" {
    search --no-floppy --fs-uuid --set=root e66ce8ef-66cf-4b2a-a36c-7bd61b9c4c51
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
# Для Windows legacy
menuentry "Windows 7 (Legacy)" {
    set root='hd0,msdos2'
    chainloader +1
}
EOF
    chattr +i /boot/grub/grub.cfg
    sed -i '/#NoExtract   =/a NoUpgrade = boot/grub/grub.cfg' /etc/pacman.conf
fi

useradd -m -g users -G wheel -s /bin/bash $usern

# Предоставить членам группы wheel доступ к sudo: 
# в файле /etc/sudoers разкоментить %wheel      ALL=(ALL:ALL) ALL
pacman -S sudo --noconfirm
echo "gentoo:123" | sudo chpasswd
echo "root:123" | sudo chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# drivers
pacman -S xf86-video-vesa mesa \
    alsa-utils alsa-plugins \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack --noconfirm
systemctl --user enable --now pipewire pipewire-pulse

# radeon
if [[ "${graph}" == '1' ]]; then
    pacman -S mesa xf86-video-amdgpu --noconfirm
else
    pacman -S mesa --noconfirm
fi
# xorg dop
pacman -S xorg xorg-server xorg-drivers noto-fonts-cjk otf-ipafont --noconfirm

sed -i '/^#\[\s*multilib\s*\]/, /^#\[/ {
  s/^#\(\[multilib\]\)/\1/
  s/^#\(Include\s*=\s*\/etc\/pacman.d\/mirrorlist\)/\1/
}' /etc/pacman.conf

pacman -Syu --noconfirm

pacman -S wget \
    yajl \
    git \
    base-devel \
    linux-headers \
    dkms \
    go \
    ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family noto-fonts-emoji --noconfirm

saveVars
}

function part2(){
if [[ "$(whoami)" == 'root' ]]; then
    echo "Не под рутом"
    exit 0
fi
readVars
echoVars
git clone https://github.com/scopatz/nanorc.git ~/.nano
echo 'include "~/.nano/*.nanorc"' >> ~/.nanorc

# xorg-drivers # Ниже есть драйвера но это вроде тоже
# Xorg :0 -configure # После драверов
# cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов

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
elif [[ "$visual" == 'MangoWC' ]]; then
    echo 'TODO make it'
elif [[ "$visual" == 'Hyprland' ]]; then
    # Установка (официальные репозитории!)
    sudo pacman -S hyprland

    # Дополнительные полезные компоненты
    sudo pacman -S waybar rofi wofi grim slurp mako

    sudo pacman -S greetd \
        hyprpaper \
        hyprlock \
        hypridle \
        tlp powertop \
        power-profiles-daemon \
        hyprpicker \
        xdg-desktop-portal-hyprland \
        swaylock \
        grim \
        slurp \
        waybar \
        man-db \
        kitty \
        noto-fonts \
        ttf-jetbrains-mono \
        ttf-font-awesome \
        sddm \
        ntfs-3g \
        bluez \
        bluez-utils \
        firefox --noconfirm
        yay -S hyprpanel --noconfirm

        # Install libvirt and qemu things.
sudo pacman -S libvirt virt-viewer qemu-common
# Add yourself to the libvirt group.
sudo usermod -a -G libvirt mio # Replace 'USER' with your username.
# Enable and start libvirtd.
systemctl enable --now libvirtd

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
    sudo pacman -S linux-headers virtualbox-guest-utils --noconfirm
    sudo systemctl enable --now vboxservice.service
    sudo modprobe -a vboxguest vboxsf vboxvideo
    echo -e "vboxguest\nvboxsf\nvboxvideo" | sudo tee /etc/modules-load.d/virtualbox.conf
fi

}

set -e

if [[ "$1" == '1' ]]; then
    part1
elif [[ "$1" == '2' ]]; then
    part2
fi


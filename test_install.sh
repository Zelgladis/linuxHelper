#!/bin/bash
echo "username"
read usern
echo "EFI 1 LEGACY 0:"
read efi
echo "auto grub 1 manual 0"
read auto_grub
echo "VI- XFCE KDE CIN(cinnamon)"
read visual
echo "VirtualBox 1 No 0"
read vb
echo "Add Utils 1 No 0"
read dop

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
echo 'ariko' > /etc/hostname
echo '127.0.0.1 localhost
::1 localhost
127.0.1.1 ariko.localdomain ariko' >> /etc/hosts

#Доп по(необходимое):
pacman -Suy
pacman -S gvim vi nano --noconfirm
# Для автоматического получения сетевых настроек установите dhcpcd и добавить в автозапуск
pacman -S dhcpcd --noconfirm
pacman -S openssh --noconfirm
systemctl enable sshd
systemctl enable dhcpcd
# Установите пакет grub и efibootmgr
pacman -S btrfs-progs --noconfirm
pacman -S e2fsprogs --noconfirm
pacman -S grub efibootmgr os-prober hwinfo --noconfirm

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
fi

useradd -m -g users -G wheel -s /bin/bash $usern
echo "$usern:123" | sudo chpasswd

# Предоставить членам группы wheel доступ к sudo: 
# в файле /etc/sudoers разкоментить %wheel      ALL=(ALL:ALL) ALL
pacman -S sudo --noconfirm
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Красота в консоле
# echo 'PS1="\[\e[91m\]\$(if [[ \$? -eq 0 ]]; then echo '✔️'; else echo '❌'; fi) \[\e[92m\]\u@\h\[\e[0m\] \[\e[94m\]🌸 \[\e[33m\]\w\[\e[0m\]\[\e[95m\]\$(git branch 2>/dev/null | grep '^*' | colrm 1 2 | awk '{printf \" (%s)\", \$1}') \[\e[0m\]💫 $ "' >> ~/.bashrc

# Ещё доп по
sudo pacman -S wget --noconfirm
sudo pacman -S yajl --noconfirm
sudo pacman -S git --noconfirm
sudo pacman -S base-devel --noconfirm
sudo pacman -S linux-headers --noconfirm
sudo pacman -S dkms --noconfirm
sudo pacman -S ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family noto-fonts-emoji --noconfirm

# YAY aur
mkdir ~/OTB
mkdir ~/OTB/gits
cd ~/OTB/gits
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si && cd ~

# drivers
sudo pacman -S xf86-video-vesa --noconfirm
# radeon
sudo pacman -S mesa --noconfirm
sudo pacman -S lib32-mesa --noconfirm
sudo pacman -S xf86-video-amdgpu --noconfirm
sudo pacman -S lib32-amdvlk --noconfirm
sudo pacman -S amdvlk --noconfirm
sudo pacman -S alsa-utils alsa-plugins --noconfirm
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack --noconfirm
systemctl --user enable --now pipewire pipewire-pulse

# xorg
sudo pacman -S xorg-server --noconfirm
sudo pacman -S xorg-drivers --noconfirm
sudo pacman -S xorg --noconfirm
# не обязательно
sudo pacman -S gcc perl make --noconfirm

xorg-drivers # Ниже есть драйвера но это вроде тоже
Xorg :0 -configure # После драверов
cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов

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
    sudo pacman -S --needed xorg sddm --noconfirm
    sudo pacman -S --needed plasma --noconfirm
    sudo pacman -S --needed qt6 --noconfirm
    sudo pacman -S --needed networkmanager-openvpn --noconfirm
    sudo pacman -S networkmanager-openconnect --noconfirm

    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
elif [[ "$visual" == 'CIN' ]];then
    echo "Cinnammon"
    sudo pacman -S cinnamon --noconfirm
    sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
    sudo pacman -S tilix --noconfirm
    sudo pacman -S ark --noconfirm
    sudo pacman -S eog --noconfirm
    sudo pacman -S networkmanager --noconfirm
    sudo pacman -S networkmanager-openvpn --noconfirm
    sudo pacman -S openvpn --noconfirm
    sudo pacman -S gtk-engine-murrine --noconfirm
    sudo pacman -S materia-gtk-theme --noconfirm

    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
    sudo systemctl enable lightdm

    sudo pacman -S font-manager --noconfirm
    sudo pacman -S conky --noconfirm
    sudo pacman -S playerctl --noconfirm
    sudo pacman -S strawberry --noconfirm
fi

if [[ "$vb" == '1' ]];then
    echo "VirtualBox"
    sudo pacman -S linux-headers virtualbox-guest-utils --noconfirm
    sudo systemctl enable --now vboxservice.service
    # (если нужно загрузить прямо сейчас)
    sudo modprobe -a vboxguest vboxsf vboxvideo
    echo -e "vboxguest\nvboxsf\nvboxvideo" | sudo tee /etc/modules-load.d/virtualbox.conf
fi

sudo pacman -S noto-fonts-cjk --noconfirm
sudo pacman -S otf-ipafont --noconfirm


sudo sed -i '/^#\[\s*multilib\s*\]/, /^#\[/ {
  s/^#\(\[multilib\]\)/\1/
  s/^#\(Include\s*=\s*\/etc\/pacman.d\/mirrorlist\)/\1/
}' /etc/pacman.conf


if [[ "$dop" == '1' ]];then
    echo "Add PO"
    sudo pacman -S firefox --noconfirm
    sudo pacman -S flatpak --noconfirm
    yay -S visual-studio-code-bin --noconfirm
    yay -S intellij-idea-community-edition --noconfirm
    yay -S keepassxc --noconfirm
    yay -S dbeaver --noconfirm
    yay -S docker --noconfirm
    yay -S docker-compose --noconfirm
    sudo usermod -aG docker $usern
    yay -S telegram-desktop --noconfirm
    yay -S kate --noconfirm
    flatpak install flathub com.getpostman.Postman --noconfirm
fi

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

if [[ "$conte" != 'y' ]];then
    exit 0
fi
fi
set -e

function saveVars(){
cat << EOF > "home/$usern/myvars.sh"
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
source "home/$usern/myvars.sh"
}

function part1(){
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
echo "$usern:123" | sudo chpasswd
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
}




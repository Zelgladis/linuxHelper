#!/bin/bash
pacman -Syu
pacman -S libnewt --noconfirm
boot_loader_list=("EFI" "LEGACY")
auto_grub_list=("Auto" "Manual")
graph_list=("Nvidia" "Radeon" "Intel" "Other(VM)")
win_size=(20 90 10)
boot_loader_opt=()
for((i=0;i<${#boot_loader_list[@]};i++)); do
    boot_loader_opt+=("$((i+1))" "${boot_loader_list[$i]}")
done
auto_grub_opt=()
for((i=0;i<${#auto_grub_list[@]};i++)); do
    auto_grub_opt+=("$((i+1))" "${auto_grub_list[$i]}")
done
graph_opt=()
for((i=0;i<${#graph_list[@]};i++)); do
    graph_opt+=("$((i+1))" "${graph_list[$i]}")
done

usern=$(whiptail --title "Имя пользователя" --inputbox "Имя" "${win_size[@]:0:2}" 3>&1 1>&2 2>&3)
exit_status=$?
boot_loader=$(whiptail --title "Загрузчик" --menu "Версия Загрузчика" "${win_size[@]}" \
    "${boot_loader_opt[@]}" 3>&1 1>&2 2>&3)
exit_status=$?

auto_grub=$(whiptail --title "Загрузчик" --menu "Вариант Загрузчика" "${win_size[@]}" \
    "${auto_grub_opt[@]}" 3>&1 1>&2 2>&3)
exit_status=$?

myhostname=$(whiptail --title "Имя компьютера" --inputbox "Имя хоста" "${win_size[@]:0:2}" 3>&1 1>&2 2>&3)
exit_status=$?

graph=$(whiptail --title "Видеокарта" --menu "Ваша Видеокарта" "${win_size[@]}" \
    "${graph_opt[@]}" 3>&1 1>&2 2>&3)
exit_status=$?

echo "
Username: $usern
Password: 123 смени его после установки
UEFI: ${boot_loader_list[$boot_loader-1]}
Auto GRUB: ${auto_grub_list[auto_grub-1]}
Hostname: $myhostname
VideoCard: ${graph_list[$graph-1]}

Continue?(y/n) default n"
read conte

if [[ "$conte" != 'y' ]];then
    exit 0
fi
set -e

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
       btrfs-progs e2fsprogs grub efibootmgr os-prober hwinfo bash-completion \
       chafa libsixel imagemagick ntfs-3g --noconfirm
systemctl enable sshd
systemctl enable dhcpcd

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --country Russia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# EFI
if [[ "${boot_loader_list[$boot_loader-1]}" == 'EFI' ]];then
    echo "----------- EFI CHOSEN -----------"
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux --recheck
    mkinitcpio -p linux
# LEGACY
else
    echo "----------- LEGACY -----------"
    grub-install /dev/sda
    # Перегенерируйте initramfs
    mkinitcpio -p linux
fi

if [[ "${auto_grub_list[auto_grub-1]}" == 'Auto' ]];then
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

# Предоставить членам группы wheel доступ к sudo: 
# в файле /etc/sudoers разкоментить %wheel      ALL=(ALL:ALL) ALL
pacman -S sudo --noconfirm
useradd -m -g users -G wheel -s /bin/bash $usern
echo "$usern:123" | sudo chpasswd
echo "root:123" | sudo chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# drivers
pacman -S xf86-video-vesa mesa \
    alsa-utils alsa-plugins \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack easyeffects --noconfirm
systemctl --user enable pipewire pipewire-pulse

# radeon
if [[ "${graph_list[$graph-1]}" == 'Radeon' ]]; then
    pacman -S xf86-video-amdgpu amdsmi --noconfirm
elif [[ "${graph_list[$graph-1]}" == 'Nvidia' ]]; then
    pacman -S nvidia-utils nvidia-open nvidia-prime --noconfirm
elif [[ "${graph_list[$graph-1]}" == 'Intel' ]]; then
    pacman -S intel-gpu-tools --noconfirm
fi
# xorg dop and fonts
pacman -S xorg xorg-server xorg-drivers noto-fonts-cjk otf-ipafont --noconfirm

sudo sed -i '/^#\[\s*multilib\s*\]/, /^#\[/ {
  s/^#\(\[multilib\]\)/\1/
  s/^#\(Include\s*=\s*\/etc\/pacman.d\/mirrorlist\)/\1/
}' /etc/pacman.conf

pacman -S networkmanager
systemctl enable NetworkManager

sudo pacman -Syu --noconfirm


# xorg-drivers # Ниже есть драйвера но это вроде тоже
# Xorg :0 -configure # После драверов
# cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов


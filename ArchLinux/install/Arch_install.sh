#!/bin/bash
echo "Имя пользователя"
read usern

echo "EFI 1, LEGACY 0:"
read efi

echo "auto grub 1, manual 0"
read auto_grub

echo "hostname"
read myhostname

echo "
Username: $usern
Password: 123 смени его после установки
UEFI: $efi
Auto GRUB: $auto_grub
Hostname: $myhostname

Continue?(y/n) default n"
read conte

if [[ "$conte" != 'y' ]];then
    exit 0
fi

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
pacman -Suy --noconfirm
pacman -S vi nano reflector --noconfirm
# Для автоматического получения сетевых настроек установите dhcpcd и добавить в автозапуск
pacman -S dhcpcd openssh --noconfirm
systemctl enable sshd
systemctl enable dhcpcd
# Установите пакет grub и efibootmgr
pacman -S btrfs-progs e2fsprogs grub efibootmgr os-prober hwinfo --noconfirm

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
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# drivers
pacman -S xf86-video-vesa --noconfirm
# radeon
pacman -S mesa \
    xf86-video-amdgpu \
    alsa-utils alsa-plugins \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack --noconfirm
systemctl --user enable --now pipewire pipewire-pulse

# xorg
pacman -S xorg xorg-server xorg-drivers xorg-init --noconfirm
# не обязательно
pacman -S gcc perl make --noconfirm

# xorg-drivers # Ниже есть драйвера но это вроде тоже
# Xorg :0 -configure # После драверов
# cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов


#!/bin/bash
# https://wiki.gentoo.org/wiki/Handbook:AMD64/ru
# https://www.gentoo.org/downloads/signatures/

# Сетка если не работает
modprobe 8139too

echo "123" | chpasswd

# Создание разделов номера для правильных типов дисков
fdisk /dev/sda
/dev/sda1 EFI t 1
/dev/sda2 SWAP t 19
/dev/sda3 ROOT t 23

# Форматируем диски в нужные fs
mkfs.vfat -F 32 -n EFI /dev/sda1
mkswap -L SWAP /dev/sda2
mkfs.btrfs -L ROOT /dev/sda3

# Создаём директории и подключаем созданные диски
mkdir --parents /mnt/gentoo
swapon /dev/sda2
mount /dev/sda3 /mnt/gentoo
mkdir --parents /mnt/gentoo/efi

cd /mnt/gentoo
date
chronyd -q

links https://www.gentoo.org/downloads/mirrors/ # Качаем downloads/stage3-desktop-systemd ~700mb
gpg --import /usr/share/openpgp-keys/gentoo-release.asc # скачивание gpg ключей
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo # установка stage3
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# Первоначальная Настройка системы установки
# Настройка менеджера пакетов portage
cat > /mnt/gentoo/etc/portage/make.conf << 'EOF'
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

USE="systemd grub alsa dbus networkmanager pipewire pulseaudio dracut"
USE="${USE} video_cards_vmware"
# USE="${USE} X wayland plasma qt5 qt6 kde firewall kwallet crypt discover flatpak rdp thunderbolt"
# USE="${USE}  bluetooth -efistub -grub -refind -systemd-boot -ugrd -uki -ukify wacom"

#VIDEO_CARDS="VMSVGA"


RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"

MAKEOPTS="-j4 -l5"
EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=5"

FEATURES="${FEATURES} getbinpkg"
# Require signatures
FEATURES="${FEATURES} binpkg-request-signature"

# NOTE: This stage was built with the bindist USE flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.UTF-8
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

GENTOO_MIRRORS="https://mirror.yandex.ru/gentoo-distfiles/ \
    http://mirror.yandex.ru/gentoo-distfiles/ \
    ftp://mirror.yandex.ru/gentoo-distfiles/"

GRUB_PLATFORMS="efi-64"
EOF

# Монтирование и привязка необходимых ФС
# Каталог /proc/ монтируется в /mnt/gentoo/proc/, остальные — через перепривязку точки монтирования. 
# Это означает, что, например, /mnt/gentoo/sys/ на самом деле будет /sys/ (это просто вторая точка входа в ту же файловую систему), 
# тогда как /mnt/gentoo/proc/ является новой точкой монтирования (так сказать, экземпляром) файловой системы. 
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run 

# Вход в устанавливаемую систему
chroot /mnt/gentoo /bin/bash 
source /etc/profile && export PS1="(chroot) ${PS1}"
mount /dev/sda1 /efi

emerge-webrsync
emerge --ask --verbose --oneshot app-portage/mirrorselect
emerge --ask --oneshot app-portage/cpuid2cpuflags
# mirrorselect -i -o >> /etc/portage/make.conf
emerge --sync

cat > /etc/portage/binrepos.conf/gentoobinhost.conf << 'EOF'
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consider using a local mirror.

[gentoo]
priority = 1
# sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64
sync-uri = https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/binpackages/23.0/x86-64/
location = /var/cache/binhost/gentoo
verify-signature = true

[binhost]
priority = 9999
#sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64/
sync-uri = https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/binpackages/23.0/x86-64/
EOF

# Поддержка процессора и видеокарты
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
# echo '*/* VIDEO_CARDS: amdgpu radeonsi' >  /etc/portage/package.use/00video_cards
echo '*/* VIDEO_CARDS: VMSVGA' >  /etc/portage/package.use/00video_cards


# Настройка локали
ls -l /usr/share/zoneinfo/Europe/Saratov
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

eselect locale list
eselect locale set 5

# Перезагрузка окружения
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"


# Установка ЯДРА
# Большая часть драйверов
emerge --ask sys-kernel/linux-firmware
# OpenSource драйвера
emerge --ask sys-firmware/sof-firmware
# Загрузчик
emerge --ask sys-kernel/installkernel
mkdir -p /efi/EFI/Gentoo
echo 'sys-kernel/installkernel dracut' > /etc/portage/package.use/installkernel
mkdir /etc/dracut.conf.d

blkid # ROOT UUID осюда взять
echo "kernel_cmdline=\" root=UUID=$(blkid | grep 'ROOT' | cut -d'"' -f4) \"" > /etc/dracut.conf.d/00-installkernel.conf
# echo 'sys-apps/systemd boot' > /etc/portage/package.use/uki
emerge --ask sys-kernel/installkernel
emerge --ask sys-kernel/gentoo-kernel-bin
emerge --ask sys-kernel/gentoo-sources

eselect kernel list
eselect kernel set 2
ls -l /usr/src/linux

# TODO генерация fstab и hosts
nano /etc/fstab
echo ariko > /etc/hostname
nano /etc/hosts

systemd-machine-id-setup
systemctl preset-all --preset-mode=enable-only

# Установка системных приложений
# emerge --ask app-admin/sysklogd
# rc-update add sysklogd default
emerge --ask net-misc/dhcpcd
emerge --ask net-misc/openssh
emerge --ask net-misc/networkmanager
emerge --ask app-misc/ca-certificates

# emerge --ask net-misc/openssh
# systemctl enable sshd
update-ca-certificates
emerge --ask app-shells/bash-completion
emerge --ask sys-apps/mlocate
emerge --ask net-misc/chrony

systemctl enable chronyd.service
systemctl enable getty@tty1.service
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable dhcpcd

# Утилиты для работы с файловыми системами и НВМЕ
emerge --ask sys-fs/btrfs-progs sys-fs/e2fsprogs sys-block/io-scheduler-udev-rules

# WIFI PPPp
emerge --ask net-dialup/ppp
emerge --ask net-wireless/iw net-wireless/wpa_supplicant

emerge --ask --verbose sys-boot/grub
grub-install --efi-directory=/efi
mkdir /efi/grub
grub-mkconfig -o /efi/grub/grub.cfg
cp /efi/EFI/gentoo/grubx64.efi /efi/grub/

passwd
emerge --ask app-admin/sudo
useradd -m -G users,wheel,audio -s /bin/bash mio 
passwd mio
passwd -l root
EDITOR=nano visudo
# %wheel ALL=(ALL) ALL

# Finnale По идеи после этой команды можно загружаться в систему и всё должно работать
emerge --ask --update --deep --newuse @world
# Починить конфы(точнее обновить)
dispatch-conf
locale-gen
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
eselect locale list



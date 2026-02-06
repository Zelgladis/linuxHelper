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
#mount /dev/sd1 /mnt/gentoo/

# Установка основы системы stage3 desktop systemd(современная)
cd /mnt/gentoo
date
chronyd -q

links https://www.gentoo.org/downloads/mirrors/ # Качаем downloads/stage3-desktop-systemd ~700mb
gpg --import /usr/share/openpgp-keys/gentoo-release.asc # скачивание gpg ключей
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo # установка stage3

# Первоначальная Настройка системы установки
# Настройка менеджера пакетов portage
nano /mnt/gentoo/etc/portage/make.conf # confs/make.conf

# Для Rust и настройки проца
# RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"
# MAKEOPTS="-j4 -l5"
# EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=5"

# Копируем настройки DNS из мастер системы
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

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

# mount /dev/sda1 /efi 
emerge-webrsync

# установка и настройка зеркал
emerge --ask --verbose --oneshot app-portage/mirrorselect
mirrorselect -i -o >> /etc/portage/make.conf
emerge --sync

# Выбираем для KDE plasma
eselect profile set 8
eselect profile list

# Поддержка bin пакетов
nano /etc/portage/binrepos.conf/gentoobinhost.conf # confs/gentoobinhost.conf

# Поддержка процессора и видеокарты
emerge --ask --oneshot app-portage/cpuid2cpuflags
cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
# vmware
# echo '*/* VIDEO_CARDS: amdgpu radeonsi' >  /etc/portage/package.use/00video_cards
# echo '*/* VIDEO_CARDS: VMSVGA' >  /etc/portage/package.use/00video_cards
# emerge --ask sys-fs/btrfs-progs

# Настройка локали
ls -l /usr/share/zoneinfo/Europe/Saratov
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime

nano /etc/locale.gen # confs/locale.gen
locale-gen

eselect locale list
eselect locale set 5
# /etc/env.d/02locale
### LANG="ru_RU.UTF-8"
### LC_COLLATE="C.UTF-8"

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
nano /etc/portage/package.use/installkernel
# sys-kernel/installkernel dracut
mkdir /etc/dracut.conf.d
blkid # ROOT UUID осюда взять
nano /etc/dracut.conf.d/00-installkernel.conf
# kernel_cmdline=" root=UUID=611e1df1-f128-4957-b3c7-d336df9a82ec "
# echo 'sys-apps/systemd boot' > /etc/portage/package.use/uki
emerge --ask sys-kernel/installkernel
emerge --ask sys-kernel/gentoo-kernel-bin
emerge --ask sys-kernel/gentoo-sources

eselect kernel list
eselect kernel set 2
ls -l /usr/src/linux

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
emerge --ask app-shells/bash-completion
emerge --ask sys-apps/mlocate
emerge --ask net-misc/chrony

update-ca-certificates
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
# emerge --ask --update --newuse --verbose sys-boot/grub
### Если какая-то шляпа
umount /dev/sda1
mount /dev/sda1 /efi
###

# grub-install --efi-directory=/efi --target=x86_64-efi
grub-install --efi-directory=/efi
grub-mkconfig -o /boot/grub/grub.cfg

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


# Но нам нужно KDE так-что продолжаем
emerge --ask kde-plasma/plasma-meta
emerge --ask x11-misc/sddm \
            x11-base/xorg-server \
            media-video/wireplumber \
            media-video/pipewire \
            kde-plasma/plasma-systemmonitor \
            sys-apps/xdg-desktop-portal kde-plasma/xdg-desktop-portal-kde \
            app-portage/gentoolkit \
            media-libs/mesa x11-apps/mesa-progs \
            kde-apps/dolphin \

systemctl enable sddm
systemctl enable NetworkManager
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl enable bluetooth

# dop po KDE
emerge --ask kde-apps/konsole \
            app-misc/fastfetch \
            kde-plasma/discover \
            app-eselect/eselect-repository \
            sys-apps/flatpak \
            kde-misc/kdeconnect \
            kde-apps/ark \
            kde-apps/okular \
            kde-apps/gwenview \
            kde-apps/ksystemlog \
            kde-apps/yakuake


emerge --ask app-portage/gentoolkit \    # equery, revdep-rebuild
            app-portage/eix \            # быстрый поиск пакетов
            app-portage/ufed \           # TUI-менеджер USE-флагов
            app-portage/elogv            # удобный просмотр elog

# MY LOVED PO
sudo emerge --ask --verbose app-containers/docker \
            app-containers/docker-cli \
            app-containers/docker-compose
sudo usermod -aG docker $USER

sudo emerge --ask media-sound/rhythmbox \
            app-admin/keepassxc \
            dev-build/cmake \
            sys-process/htop \
            media-gfx/inkscape \
            media-sound/elisa \
            media-gfx/krita
sudo emerge --ask media-gfx/blender




protontricks
lutris
obs-studio


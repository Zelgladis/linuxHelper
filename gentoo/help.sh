mkfs.fat -F32 /dev/sda1 -n EFI
mkfs.btrfs /dev/sda2 -L ROOT
mkswap /dev/sda3 -L SWAP

swapon /dev/sda3
mount /dev/sda2 /mnt/gentoo
mkdir -p /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot

cd /mnt/gentoo
# Качаем stage3 systemd
links https://www.gentoo.org/downloads/

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

cp -L /etc/resolv.conf /mnt/gentoo/etc/

# mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
cat > /mnt/gentoo/etc/portage/make.conf << 'EOF'
# USE-флаги для KDE Plasma и VirtualBox
USE="X wayland plasma kde qt5 qt6 dbus networkmanager wifi 
     alsa pulseaudio bluetooth systemd elogind 
     virtualbox-guest-additions dri xvmc 
     network-manager sdl v4l vulkan"

# Оптимизация для процессора (VirtualBox обычно x86-64)
# Для виртуальной машины лучше использовать generic, а не native
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"

# Параллельная сборка (ядра + 1, для VM можно меньше)
MAKEOPTS="-j5"
EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=5"

# Для VirtualBox (гостевая система)
VIDEO_CARDS="virtualbox"
INPUT_DEVICES="libinput vmmouse"

# Для systemd
GRUB_PLATFORMS="efi-64"

# Особенности Portage
FEATURES="buildpkg candy parallel-fetch parallel-install"
EMERGE_DEFAULT_OPTS="--with-bdeps=y --binpkg-respect-use=y"

# Для ускорения сборки в VM (бинарные пакеты)
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --getbinpkg --binpkg-changed-deps=y"

GENTOO_MIRRORS="https://mirror.yandex.ru/gentoo-distfiles/ \
    http://mirror.yandex.ru/gentoo-distfiles/ \
    ftp://mirror.yandex.ru/gentoo-distfiles/ \
    https://ru.mirrors.cicku.me/gentoo/"

EOF


chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

mkdir /etc/portage/repos.conf
portageq repos_config / > /etc/portage/repos.conf/gentoo.conf
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime
nano /etc/locale.gen
locale-gen



##
# nano /etc/portage/make.conf
## 

# Установка ядра
# emerge-webrsync

# Установите ядро с поддержкой VirtualBox
# Вариант A: Дистрибутивное ядро (проще, но может не иметь всех нужных модулей)
emerge --ask sys-kernel/gentoo-kernel-bin

# Вариант B: Собрать ядро с нужными опциями
emerge --ask sys-kernel/gentoo-sources
cd /usr/src/linux

# Минимальные настройки для VirtualBox:
make menuconfig

emerge --sync

eselect profile set 8
eselect profile list
# default/linux/amd64/23.0/desktop/plasma/systemd

emerge --ask app-eselect/eselect-python
emerge --ask dev-lang/python:3.12
emerge --ask dev-python/pillow
emerge --ask app-admin/sudo

eselect python list
eselect python set python3.12

useradd -m -G users,wheel -s /bin/bash mio
passwd mio

EDITOR=nano visudo
# %wheel ALL=(ALL) ALL
##
nano /etc/portage/package.use/zz-autounmask
##
systemd-machine-id-setup
eselect repository enable flathub
eselect repository enable kde
emaint sync -r kde

emerge --ask --update --deep --newuse @world
emerge --ask kde-plasma/plasma-meta

emerge --ask sys-kernel/gentoo-kernel
emerge --ask sys-kernel/gentoo-sources
emerge --ask sys-kernel/genkernel
emerge --ask sys-boot/grub
emerge --ask x11-misc/sddm
emerge --ask net-misc/networkmanager
emerge --ask net-misc/openssh
emerge --ask kde-apps/konsole
emerge --ask app-misc/fastfetch
emerge --ask kde-plasma/discover
emerge --ask app-eselect/eselect-repository
emerge --ask sys-apps/flatpak
emerge --ask media-video/wireplumber
emerge --ask media-video/pipewire
emerge --ask kde-plasma/plasma-systemmonitor
emerge --ask sys-apps/xdg-desktop-portal
emerge --ask kde-plasma/xdg-desktop-portal-kde
emerge --ask app-portage/gentoolkit
# Добавляем конфигурацию USE-флагов для Firefox
echo "www-client/firefox X dbus pulseaudio system-icu system-jpeg system-libevent system-libvpx system-webp system-harfbuzz wayland media-libs/libvpx postproc" >> /etc/portage/package.use/firefox
emerge --ask www-client/firefox



flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# video
# VM
emerge --ask x11-drivers/xf86-video-vmware x11-libs/libdrm media-libs/mesa 
emerge --ask media-libs/mesa
emerge --ask x11-apps/mesa-progs
echo "x11-libs/libdrm ~amd64" >> /etc/portage/package.accept_keywords/99-libdrm
echo "x11-libs/libdrm ~amd64" >> /etc/portage/package.accept_keywords/99-vmware
echo "media-libs/mesa ~amd64" >> /etc/portage/package.accept_keywords/99-vmware
echo "x11-drivers/xf86-video-vmware ~amd64" >> /etc/portage/package.accept_keywords/99-vmware
echo 'x11-libs/libdrm video_cards_vmware' >> /etc/portage/package.accept_keywords/99-vmware
echo 'media-libs/mesa xa video_cards_vmware' >> /etc/portage/package.accept_keywords/99-vmware
emerge --ask --newuse @world


# glxinfo | grep "OpenGL renderer"
# END VM

cd /usr/src
KERNEL_DIR=$(ls -d linux-*-gentoo | head -n1)
[ ! -e linux ] && ln -s "$KERNEL_DIR" linux

genkernel all

blkid

nano /etc/fstab
# /dev/sda1  /boot  vfat  defaults,noatime  0 2

echo "sys-boot/grub efi" >> /etc/portage/package.use/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Gentoo
grub-mkconfig -o /boot/grub/grub.cfg


systemctl enable NetworkManager
systemctl enable sddm
systemctl enable sshd
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl enable bluetooth



#mkdir -p /var/db/repos
#emerge-webrsync


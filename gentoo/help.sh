mkfs.fat -F32 /dev/sda1 -n EFI
mkfs.ext4 /dev/sda2 -L ROOT
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

cp -L /etc/resolv.conf /mnt/gentoo/etc/resolv.conf

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(gentoo) $PS1"

##
nano /etc/portage/make.conf
## 

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

# временно для сборки
echo "media-libs/tiff -webp" >> /etc/portage/package.use/temp
#echo "dev-python/pillow -truetype" >> /etc/portage/package.use/temp
emerge --ask --update --deep --newuse @world
rm /etc/portage/package.use/temp

emerge --ask kde-plasma/plasma-meta


#mkdir -p /var/db/repos
#emerge-webrsync

